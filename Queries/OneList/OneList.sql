USE SPReports;

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


		--excluding old entries from project types that sometimes dont exit clients. near bottom of mainquery
, yearoldsso AS
	(

		SELECT entry_exit_id FROM chicago_export.dbo.sp_entry_exit ee
		INNER JOIN chicago_export.dbo.sp_provider p
			ON p.provider_id = ee.provider_id
		WHERE DATEDIFF(y,ee.entry_date,GETDATE())>365
		AND (p.program_type_code IN ('Day Shelter (HUD)','Other (HUD)','Services Only (HUD)') OR p.provider_id = 1178)

	)
	
--1340 enrollments entered by CSH staff OR 1340 enrollments that aren't veteran
, cshexclude AS
	(
		SELECT ee.entry_exit_id FROM chicago_export.dbo.sp_entry_exit ee
		INNER JOIN chicago_export.dbo.sp_user u
			ON u.user_id = ee.user_creating_id
		INNER JOIN chicago_export.dbo.sp_client c
			ON c.client_id = ee.client_id
		WHERE ee.provider_id = 1340
		AND (u.provider_id = 1339 --CSH
		OR ISNULL(c.veteran_status,'') <> 'Yes (HUD)')
	)
, bigboy AS
	(
		SELECT
			ee.entry_exit_id
			, ee.provider_id
			, ISNULL(ee.group_id,ee.entry_exit_id) AS GroupUID
			, ee.client_id
			, ee.exit_date
		FROM chicago_export.dbo.sp_entry_exit ee
		INNER JOIN chicago_export.dbo.sp_client c
			ON c.client_id = ee.client_id
		LEFT OUTER JOIN fakeclients fc
			ON fc.client_id = ee.client_id
		INNER JOIN goodproviders gp
			ON gp.provider_id = ee.provider_id
		LEFT OUTER JOIN SO_SSVFnot510 ssnf
			ON ssnf.entry_exit_id = ee.entry_exit_id
		LEFT OUTER JOIN yearoldsso yosso
			ON yosso.entry_exit_id = ee.entry_exit_id
		LEFT OUTER JOIN cshexclude cshe
			ON cshe.entry_exit_id = ee.entry_exit_id
		WHERE
			ee.active = 't'
			AND c.active = 't'
			AND fc.client_id IS NULL
			AND ssnf.entry_exit_id IS NULL
			AND yosso.entry_exit_id IS NULL
			AND cshe.entry_exit_id IS NULL
	)

	
--PHwSS providers this query goes with the purple section
, PHwSS AS
	(

		SELECT entity_id AS provider_id FROM chicago_export.dbo.ws_answer
		WHERE question_code = 'CHICAGOPROGRAMMODEL'
		AND val IN ('Permanent Housing with Short Term Support','Youth Project Based Transitional Housing','Youth Scattered Site Transitional Housing')
	

	)


, alreadyrrhhoused AS--this section is the bottom two queries in the purple section of the mainquery
	(
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
	)



, definitelyhomeless AS
	(
		--green section inside red section
		SELECT ee.entry_exit_id FROM chicago_export.dbo.sp_entry_exit ee
		--if provider is 1340, housing status needs to be 1/4
		INNER JOIN chicago_export.dbo.sp_provider p
			ON p.provider_id = ee.provider_id
		LEFT OUTER JOIN EEAnswerLink eeal_hs
			ON eeal_hs.entry_exit_id = ee.entry_exit_id
			AND eeal_hs.question_code = 'SVP_HUD_HOUSINGSTATUS'
			AND eeal_hs.active = 1
		LEFT OUTER JOIN chicago_export.dbo.da_answer hs
			ON hs.answer_id = eeal_hs.entry_answer_id
		LEFT OUTER JOIN PHwSS --this is the table that got defined earlier in the query in the purple section
			ON PHwSS.provider_id = p.provider_id
		WHERE p.program_type_code IN (
							'Coordinated Assessment (HUD)'
							,'Emergency Shelter (HUD)'
							,'Transitional housing (HUD)'
							,'Safe Haven (HUD)'
							,'Street Outreach (HUD)')
		AND (p.provider_id <> 1340 OR hs.val IN ('Category 1 - Homeless (HUD)','Category 4 - Fleeing domestic violence (HUD)'))
		AND PHwSS.provider_id IS NULL
	)


, serviceshomeless AS
	(

		SELECT ee.entry_exit_id FROM chicago_export.dbo.sp_entry_exit ee
		INNER JOIN chicago_export.dbo.sp_provider p
			ON  p.provider_id = ee.provider_id
		LEFT OUTER JOIN EEAnswerLink eeal_hs
			ON eeal_hs.entry_exit_id = ee.entry_exit_id
			AND eeal_hs.question_code = 'SVP_HUD_HOUSINGSTATUS'
			AND eeal_hs.active = 1
		LEFT OUTER JOIN chicago_export.dbo.da_answer hs
			ON hs.answer_id = eeal_hs.entry_answer_id
		LEFT OUTER JOIN EEAnswerLink eeal_youthhs
			ON eeal_youthhs.entry_exit_id = ee.entry_exit_id
			AND eeal_youthhs.question_code = 'ONLYANSWERIFAGE24ORUN_1'
			AND eeal_youthhs.active = 1
		LEFT OUTER JOIN chicago_export.dbo.da_answer youthhs
			ON youthhs.answer_id = eeal_youthhs.entry_answer_id
		LEFT OUTER JOIN EEAnswerLink eeal_dob
			ON eeal_dob.entry_exit_id = ee.entry_exit_id
			AND eeal_dob.question_code = 'SVPPROFDOB'
			AND eeal_youthhs.active = 1
		LEFT OUTER JOIN chicago_export.dbo.da_answer dob
			ON dob.answer_id = eeal_dob.entry_answer_id
		WHERE (p.program_type_code IN ('Day Shelter (HUD)','Other (HUD)','Services Only (HUD)') OR p.provider_id = 1178)
		AND (
				hs.val LIKE 'Category 1 %'
				OR hs.val LIKE 'Category 2 %'
				OR hs.val LIKE 'Category 4 %'
				OR youthhs.val IN ('Homeless','At imminent risk of losing housing','Fleeing domestic violence','At-risk of homelessness','Age 24 or under and unstably housed'))
		AND SPReports.dbo.AgeAtTime(SPReports.dbo.VarcharToDate(dob.val),ee.entry_date) < 25 --once QA is over, change ee.entry_date to getdate()


	)

, recentexits_inner AS
	(

		SELECT ee.entry_exit_id FROM chicago_export.dbo.sp_entry_exit ee
		INNER JOIN chicago_export.dbo.sp_provider p
			ON p.provider_id = ee.provider_id
		LEFT OUTER JOIN EEAnswerLink eeal_hs
			ON eeal_hs.entry_exit_id = ee.entry_exit_id
			AND eeal_hs.question_code = 'SVP_HUD_HOUSINGSTATUS'
			AND eeal_hs.active = 1
		LEFT OUTER JOIN chicago_export.dbo.da_answer hs
			ON hs.answer_id = eeal_hs.entry_answer_id
		WHERE
			DATEDIFF(y,ee.exit_date,getdate()) < 90
			AND (
					ee.reason_leaving NOT IN
						(
							'CES: Client not living in Chicago (Not eligible for CES)'
							,'CES: Client participated in day project only'
							,'CES: Client is not homeless (should not appear on One List)')
							OR ee.reason_leaving IS NULL
						)
			AND (
					ee.destination IN
						(
							'Emergency shelter, including hotel or motel paid for with emergency shelter voucher (HUD)'
							,'Place not meant for habitation (HUD)'
							,'Safe Haven (HUD)'
							,'Transitional housing for homeless persons (including homeless youth) (HUD)'
						)
					OR
						(
							(
								p.program_type_code IN ('Emergency Shelter (HUD)','Safe Haven (HUD)','Transitional housing (HUD)','Street Outreach (HUD)') OR 
									((hs.val LIKE 'Category 1 %' OR hs.val LIKE 'Category 2 %' OR hs.val LIKE 'Category 4 %') AND
									p.program_type_code NOT IN
										(
											'Homelessness Prevention (HUD)'
											,'PH - Housing only (HUD)'
											,'PH - Housing with services (no disability required for entry) (HUD)'
											,'PH - Permanent Supportive Housing (disability required for entry) (HUD)'
											,'RETIRED (HUD)'
										)
									)
							) AND ee.destination IN
								('Client doesn''t know (HUD)'
								,'Client refused (HUD)'
								,'Data not collected (HUD)'
								,'Emergency shelter, including hotel or motel paid for with emergency shelter voucher (HUD)'
								,'Foster care home or foster care group home (HUD)'
								,'Hospital or other residential non-psychiatric medical facility (HUD)'
								,'Hotel or motel paid for without emergency shelter voucher (HUD)'
								,'Jail, prison or juvenile detention facility (HUD)'
								,'No exit interview completed (HUD)'
								,'Place not meant for habitation (HUD)'
								,'Psychiatric hospital or other psychiatric facility (HUD)'
								,'Residential project or halfway house with no homeless criteria (HUD)'
								,'Safe Haven (HUD)'
								,'Staying or living with family, temporary tenure (e.g., room, apartment or house)(HUD)'
								,'Staying or living with friends, temporary tenure (e.g., room apartment or house)(HUD)'
								,'Substance abuse treatment facility or detox center (HUD)'
								,'Transitional housing for homeless persons (including homeless youth) (HUD)'
								,'Other (HUD)') --we are going to create a table so we dont have to do this big ole list
						)
				)

	)

, stillenrolled AS
	(
		SELECT * FROM bigboy bb
		LEFT OUTER JOIN PHwSS
			ON PHwSS.provider_id = bb.provider_id
		LEFT OUTER JOIN alreadyrrhhoused arrhh_c
			ON arrhh_c.client_id = bb.client_id
		LEFT OUTER JOIN alreadyrrhhoused arrhh_g
			ON arrhh_g.GroupUID = bb.GroupUID
		INNER JOIN chicago_export.dbo.sp_provider p
			ON p.provider_id = bb.provider_id
		LEFT OUTER JOIN definitelyhomeless dh
			ON dh.entry_exit_id = bb.entry_exit_id
		LEFT OUTER JOIN serviceshomeless sh
			ON sh.entry_exit_id = bb.entry_exit_id
		WHERE bb.exit_date IS NULL
		AND ((
				p.program_type_code = 'PH - Rapid Re-Housing (HUD)'
				AND PHwSS.provider_id IS NULL
				AND arrhh_c.client_id IS NULL
				AND arrhh_g.GroupUID IS NULL
			) --purple section
		OR dh.entry_exit_id IS NOT NULL
		OR sh.entry_exit_id IS NOT NULL
		)
	)


, recentexits AS
	(
		SELECT bb.entry_exit_id FROM bigboy bb
		INNER JOIN recentexits_inner rei
			ON re.entry_exit_id = bb.entry_exit_id
		WHERE CAST(bb.exit_date AS DATE) >= CAST(DATEADD(MONTH,-3,GETDATE()) AS DATE)
	)
, reportside AS
	(
		SELECT * FROM recentexits
		UNION
		SELECT * FROM stillenrolled
	)

SELECT * FROM reportside 