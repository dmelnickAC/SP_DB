DECLARE @thecode VARCHAR(100) = 'HUD_HOUSINGMOVEINDATE';

WITH clients AS
	(
	
		SELECT client_id FROM da_answer
		WHERE question_code = @thecode

	)

SELECT

	entry_exit_id
	, (SELECT TOP 1
		answer_id
	FROM da_answer
	WHERE date_effective <= ee.entry_date
	AND question_code = @thecode
	AND client_id = ee.client_id
	ORDER BY date_effective DESC,date_added DESC)

FROM sp_entry_exit ee
INNER JOIN clients c
	ON ee.client_id = c.client_id
WHERE ee.active = 't'

SELECT top 10 * FROM da_answer
WHERE question LIKE '%housing move-in date%'
AND val IS NOT NULL
ORDER BY date_effective DESC