
--fake clients
SELECT client_id FROM chicago_export.dbo.da_answer fake
WHERE fake.question_code = 'ISTHISATESTCLIENT'
AND fake.val = 'Y'

--operational providers with other jazz
--in order to be able to see the onelist as of a previous date (with the information we know now) this table join will have to reference the provideraudit table
SELECT provider_id FROM chicago_export.dbo.sp_provider p
WHERE p.active = 't'
AND p.operational = 't'
AND p.spuser = 't'
--AND providerlevel >= 3
AND p.provider_id NOT IN (1280,1281,1341,1391,1303,1315,1314,1416,1408,1420,1421,1422,1423)
AND p.program_type_code IS NOT NULL
AND p.name NOT LIKE 'All Chicago%'


--PHwSS providers this query goes with the purple section
SELECT entity_id FROM chicago_export.dbo.ws_answer
WHERE question_code = 'CHICAGOPROGRAMMODEL'
AND val IN ('Permanent Housing with Short Term Support','Youth Project Based Transitional Housing','Youth Scattered Site Transitional Housing')

--this section is the bottom two queries in the purple section of the mainquery
SELECT DISTINCT
	ee.client_id
	, ISNULL(ee.group_id,ee.entry_exit_id) AS GroupUID
FROM chicago_export.dbo.sp_entry_exit_review eer
INNER JOIN chicago_export.dbo.sp_entry_exit ee
	ON ee.entry_exit_id = eer.entry_exit_id
INNER JOIN chicago_export.dbo.sp_provider p
	ON p.provider_id = ee.provider_id
	AND program_type_code = 'PH - Rapid Re-Housing (HUD)'
INNER JOIN SPReports.dbo.EERAnswerLink eeral
	ON eeral.entry_exit_review_id = eer.entry_exit_review_id
	AND question_code = 'HUD_HOUSINGMOVEINDATE'
INNER JOIN chicago_export.dbo.da_answer a
	ON a.answer_id = eeral.answer_id
	--AND a.val IS NOT NULL
WHERE SPReports.dbo.VarcharToDate(a.val) >= ee.entry_date --for VOA the move in date could be before entry date

--1340 enrollments entered by CSH staff OR 1340 enrollments that aren't veteran
SELECT ee.entry_exit_id FROM chicago_export.dbo.sp_entry_exit ee
INNER JOIN chicago_export.dbo.sp_user u
	ON u.user_id = ee.user_creating_id
INNER JOIN chicago_export.dbo.sp_client c
	ON c.client_id = ee.client_id
WHERE ee.provider_id = 1340
AND (u.provider_id = 1339 --CSH
OR ISNULL(c.veteran_status,'') <> 'Yes (HUD)')
ORDER BY veteran_status


--excluding old entries from project types that sometimes dont exit clients. near bottom of mainquery
SELECT entry_exit_id FROM chicago_export.dbo.sp_entry_exit ee
INNER JOIN chicago_export.dbo.sp_provider p
	ON p.provider_id = ee.provider_id
WHERE DATEDIFF(y,ee.entry_date,GETDATE())>365
AND (p.program_type_code IN ('Day Shelter (HUD)','Other (HUD)','Services Only (HUD)') OR p.provider_id = 1178)
ORDER BY entry_date DESC