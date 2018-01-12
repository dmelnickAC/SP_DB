SELECT TOP 10
	*
FROM sp_entry_exit ee
INNER JOIN sp_client c
	ON c.client_id = ee.client_id
LEFT OUTER JOIN da_answer fake
	ON fake.client_id = ee.client_id
	AND fake.question_code = 'ISTHISATESTCLIENT'
	AND fake.val = 'Y'
--joins for dealing with il510 need to be entered here
LEFT OUTER JOIN ws_answer cpt
	ON cpt.entity_id = ee.provider_id
	AND cpt.entity_type = 'sp_provider'
	AND cpt.question_code = 'CHICAGOPROGRAMMODEL'
WHERE
	ee.active = 't'
	AND c.active = 't'
	AND fake.answer_id IS NULL




p.program_type_code IN
	(
		'Emergency Shelter (HUD)'
		,'Transitional housing (HUD)'
		,'Street Outreach (HUD)'
		,'Safe Haven (HUD)'
		,'PH - Rapid Re-Housing (HUD)'
		,'Coordinated Assessment (HUD)'
	)


--------------------------------
SELECT top 10 provider_id, name FROM sp_provider
where spuser = 'f'
SELECT * FROM da_answer
WHERE question like '%test client%'