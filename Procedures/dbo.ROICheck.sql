USE [SPReports]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE dbo.ROICheck (@provider INT)
AS
BEGIN

SELECT DISTINCT
	roi.client_id
	, roi.provider_creating_id
	, roi.provider_id
	, MAX(u.email) AS Email
FROM chicago_export.dbo.sp_release_of_info roi
INNER JOIN chicago_export.dbo.sp_user u
	ON u.provider_creating_id = roi.provider_creating_id
WHERE
	(documentation like 'B - %'
	or documentation like 'D - %')
	AND @provider = roi.provider_creating_id
GROUP BY
		roi.client_id
	, roi.provider_creating_id
	, roi.provider_id

END
