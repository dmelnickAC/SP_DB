
--PHwSS providers
SELECT entity_id FROM ws_answer
WHERE question_code = 'CHICAGOPROGRAMMODEL'
AND val = 'Permanent Housing with Short Term Support'

--fake clients
SELECT client_id FROM da_answer fake
WHERE fake.question_code = 'ISTHISATESTCLIENT'
AND fake.val = 'Y'

--operational providers with other jazz
SELECT * FROM sp_provider p
WHERE p.active = 't'
AND p.operational = 't'
AND p.spuser = 't'
--AND providerlevel >= 3
AND p.provider_id NOT IN (1280,1281,1341,1391,1303,1315,1314,1416,1408,1420,1421,1422,1423)
AND p.program_type_code IS NOT NULL
AND p.name NOT LIKE 'All Chicago%'