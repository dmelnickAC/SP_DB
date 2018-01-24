WITH fakeclients AS
	(

		SELECT client_id FROM chicago_export.dbo.da_answer fake
		WHERE fake.question_code = 'ISTHISATESTCLIENT'
		AND fake.val = 'Y'

	)


--operational providers with other jazz
--in order to be able to see the onelist as of a previous date (with the information we know now) this table join will have to reference the provideraudit table
, goodproviders AS
	(
		SELECT provider_id FROM chicago_export.dbo.sp_provider p
		WHERE p.active = 't'
		AND p.operational = 't'
		AND p.spuser = 't'
		--AND providerlevel >= 3
		AND p.provider_id NOT IN (1280,1281,1341,1391,1303,1315,1314,1416,1408,1420,1421,1422,1423,1480,1507)
		AND p.program_type_code IS NOT NULL
		AND p.name NOT LIKE 'All Chicago%'
	)

--top red section eliminating street outreach and ssvf if they're not in il-510
, SO_SSVFnot510 AS
	(
		SELECT ee.entry_exit_id FROM chicago_export.dbo.sp_entry_exit ee
		INNER JOIN EEAnswerLink eeal_loc
			ON eeal_loc.entry_exit_id = ee.entry_exit_id
			AND eeal_loc.question_code = 'HUD_COCCLIENTLOCATION'
			AND eeal_loc.active = 1
		INNER JOIN chicago_export.dbo.da_answer loc
			ON loc.answer_id = eeal_loc.entry_answer_id
		INNER JOIN chicago_export.dbo.sp_provider p
			ON p.provider_id = ee.provider_id
		WHERE (p.name LIKE '%SSVF%' OR p.program_type_code = 'Street Outreach (HUD)')
		AND ISNULL(loc.val,'IL-510') <> 'IL-510'
	)

SELECT TOP 10
	*
FROM chicago_export.dbo.sp_entry_exit ee
INNER JOIN chicago_export.dbo.sp_client c
	ON c.client_id = ee.client_id
LEFT OUTER JOIN fakeclients fc
	ON fc.client_id = ee.client_id
INNER JOIN goodproviders gp
	ON gp.provider_id = ee.provider_id
LEFT OUTER JOIN SO_SSVFnot510 ssnf
	ON ssnf.entry_exit_id = ee.entry_exit_id
WHERE
	ee.active = 't'
	AND c.active = 't'
	AND fc.client_id IS NULL
	AND ssnf.entry_exit_id IS NULL