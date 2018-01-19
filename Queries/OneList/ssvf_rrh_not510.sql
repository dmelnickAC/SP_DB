ssvfrrhnot510


SELECT --* FROM sp_entry_exit ee
ee.entry_exit_id,ee.client_id,count(DISTINCT loc.answer_id) FROM sp_entry_exit ee
INNER JOIN sp_provider p
	ON p.provider_id = ee.provider_id
	AND p.name LIKE '%SSVF%'
	AND p.active = 't'
INNER JOIN entry_exit_answer_link locl
	ON locl.entry_exit_id = ee.entry_exit_id
	AND p.program_type_code = 'PH - Rapid Re-Housing (HUD)'
INNER JOIN da_answer loc
	ON locl.answer_id = loc.answer_id
	--AND loc.date_effective = ee.entry_date
	AND loc.question_code = 'HUD_COCCLIENTLOCATION'
	AND loc.val <> 'IL-510'
	AND loc.active = 't'
--INNER JOIN (SELECT client_id,date_effective,MAX(date_added) AS date_added FROM da_answer
--	WHERE question_code = 'HUD_COCCLIENTLOCATION'
--	--AND val <> 'IL-510'
--	AND active = 't' GROUP BY date_effective,client_id) t
--	ON t.date_added = loc.date_added
--	AND t.date_effective = loc.date_effective
--	AND t.client_id = loc.client_id
WHERE ee.active = 't'
AND ee.exit_date IS NULL
--AND ee.entry_exit_id = 375923
GROUP BY ee.entry_exit_id,ee.client_id
HAVING count(DISTINCT loc.answer_id) > 1




SELECT TOP 10
	*
FROM sp_entry_exit ee
INNER JOIN sp_provider p
	ON p.provider_id = ee.provider_id
	AND p.active = 't'
	AND p.operational = 't'
LEFT OUTER JOIN ws_answer cpt
	ON cpt.entity_id = ee.provider_id
	AND cpt.entity_type = 'sp_provider'
	AND cpt.question_code = 'CHICAGOPROGRAMMODEL'

WHERE p.program_type_code IN
	(
		'Emergency Shelter (HUD)'
		,'Transitional housing (HUD)'
		,'Street Outreach (HUD)'
		,'Safe Haven (HUD)'
		,'PH - Rapid Re-Housing (HUD)'
		,'Coordinated Assessment (HUD)'
	)

SELECT DISTINCT program_type_code FROM sp_provider

SELECT DISTINCT val FROM da_answer
WHERE question_code = 'HUD_COCCLIENTLOCATION'
AND val = 'IL-511'


SELECT top 10 * FROM da_answer
WHERE val like '%il-511%'