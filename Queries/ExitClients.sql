USE SPReports

WITH locationdates AS
	(
		SELECT
		
			c.unique_id
			, CASE WHEN ((ptc.HousingTypeCategory = 'TH_ES_SH')
				OR (ptc.HousingTypeCategory = 'PSH' AND CAST(ee.entry_date AS DATE) < '2017-10-01')) THEN ee.entry_date
				WHEN SPReports.dbo.VarcharToDate(hmid.val) >= CAST(ee.entry_date AS DATE) THEN SPReports.dbo.VarcharToDate(hmid.val)
				END AS LocationDate
			, p.name AS Provider
		
		FROM chicago_export.dbo.sp_entry_exit ee
		INNER JOIN chicago_export.dbo.sp_provider p
			ON p.provider_id = ee.provider_id
		LEFT OUTER JOIN chicago_export.dbo.da_answer hmid
			ON hmid.client_id = ee.client_id
			AND hmid.question_code = 'HUD_HOUSINGMOVEINDATE'
			AND hmid.active = 't'
		INNER JOIN chicago_export.dbo.sp_client c
			ON c.client_id = ee.client_id
		INNER JOIN SPReports.dbo.ProgramTypeCategory ptc
			ON ptc.ProgramTypeCode = p.program_type_code

		WHERE
			ee.active = 't'
	)
, onlocation AS
	(
	
		SELECT * FROM locationdates
		WHERE LocationDate >= '2017-01-01'
	
	)
SELECT

	ee.entry_exit_id
	, ee.client_id
	, c.unique_id
	, ee.entry_date
	, ol.LocationDate
	, p.name AS StillEnteredProvider
	, ol.Provider AS NewLocationProvider

FROM chicago_export.dbo.sp_entry_exit ee
INNER JOIN chicago_export.dbo.sp_provider p
	ON p.provider_id = ee.provider_id
	AND p.program_type_code IN ('Transitional housing (HUD)','Emergency Shelter (HUD)')
INNER JOIN chicago_export.dbo.sp_client c
	ON c.client_id = ee.client_id
INNER JOIN onlocation ol
	ON ol.unique_id = c.unique_id
WHERE 
	ol.LocationDate > ee.entry_date
	AND ee.exit_date IS NULL
	AND ee.active = 't'