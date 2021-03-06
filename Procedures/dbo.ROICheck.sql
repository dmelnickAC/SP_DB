USE [SPReports]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE dbo.ROICheck (@provider INT = NULL)
AS
BEGIN

WITH from_roi AS
	(
		select
			client_id
			, (
				select top 1 documentation
				from chicago_export.dbo.sp_release_of_info
			where
				(
					documentation like 'A - %'
					OR documentation like 'B - %'
					OR documentation like 'C - %'
					OR documentation like 'D - %'
				)
				AND client_id = c.client_id
				AND active = 't'
		ORDER BY date_started DESC) AS MostRecentROIDocumentation
			, (
				select top 1 provider_creating_id
				from chicago_export.dbo.sp_release_of_info
			where
				(
					documentation like 'A - %'
					OR documentation like 'B - %'
					OR documentation like 'C - %'
					OR documentation like 'D - %'
				)
				AND client_id = c.client_id
				AND active = 't'
		ORDER BY date_started DESC) AS MostRecentROIProvider
			, (
				select MAX(date_started)
				from chicago_export.dbo.sp_release_of_info
			where
				(
					documentation like 'A - %'
					OR documentation like 'B - %'
					OR documentation like 'C - %'
					OR documentation like 'D - %'
				)
				AND client_id = c.client_id
				AND active = 't'
			) AS MostRecentROIDATE
		from chicago_export.dbo.sp_client c
	)
, clients_ces_ass AS
	(

			SELECT client_id
			FROM chicago_export.dbo.da_answer
			WHERE question_code = 'PLEASEINDICATETHEOPTI'

	)
, roi_ces_ass AS
	(
		select
			client_id
			, (
				select top 1 val
				from chicago_export.dbo.da_answer
			where question_code = 'PLEASEINDICATETHEOPTI'
				AND client_id = c.client_id
				AND active = 't'
		ORDER BY date_effective DESC) AS MostRecentCESROI
			, (
				select top 1 provider_id
				from chicago_export.dbo.da_answer
			where question_code = 'PLEASEINDICATETHEOPTI'
				AND client_id = c.client_id
				AND active = 't'
		ORDER BY date_effective DESC) AS MostRecentCESROIProvider
			, (
				select MAX(date_effective)
				from chicago_export.dbo.da_answer
			where question_code = 'PLEASEINDICATETHEOPTI'
				AND client_id = c.client_id
				AND active = 't'
			) AS MostRecentCESROIDATE
		from clients_ces_ass c

	)

, combined_ROI AS
	(
		SELECT

			client_id
			, MostRecentROIDocumentation AS Documentation
			, MostRecentROIProvider AS Provider
			, MostRecentROIDATE AS SharingDate

		FROM from_roi
		WHERE (MostRecentROIDocumentation IS NOT NULL)

		UNION

		SELECT

			client_id
			, MostRecentCESROI AS Documentation
			, MostRecentCESROIProvider AS Provider
			, MostRecentCESROIDATE AS SharingDate

		FROM roi_ces_ass
		WHERE (MostRecentCESROIDATE IS NOT NULL)
)

, for_finding_recent AS
	(

	SELECT client_id, MAX(SharingDate) AS MostRecentROI
	FROM combined_ROI
	GROUP BY client_id

	)
, need_locked AS
	(
		SELECT cr.* FROM for_finding_recent ffr
		INNER JOIN combined_ROI cr
			ON cr.client_id = ffr.client_id
			AND cr.SharingDate >= MostRecentROI
		INNER JOIN VisibleClient vc
			ON vc.ClientID = cr.client_id
		WHERE (Documentation LIKE 'B - %'
		OR Documentation LIKE 'D - %')
	)
SELECT
	ee.client_id
	, nl.Documentation
	, o.name AS Agency
	, nl.SharingDate
	, CASE WHEN COUNT(DISTINCT p.organization_id) = 1 AND rp.organization_id = MAX(p.organization_id)
	THEN 1 ELSE 0 END AS OrganizationCanFix
INTO #t
FROM chicago_export.dbo.sp_entry_exit ee
INNER JOIN need_locked nl
	ON nl.client_id = ee.client_id
INNER JOIN chicago_export.dbo.sp_provider p
	ON p.provider_id = ee.provider_id
INNER JOIN chicago_export.dbo.sp_provider rp
	ON rp.provider_id = nl.Provider
INNER JOIN chicago_export.dbo.sp_provider o
	ON o.provider_id = rp.organization_id
WHERE ee.active = 't'
AND (rp.organization_id = @provider OR @provider IS NULL OR @provider = 0)
GROUP BY
	ee.client_id
	, nl.Documentation
	, nl.Provider
	, nl.SharingDate
	, rp.organization_id
	, o.name
IF EXISTS(SELECT * FROM #t)
SELECT * FROM #t;
ELSE RETURN(0)
END
