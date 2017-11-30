WITH clients AS
	(
		SELECT
			client_id
		FROM da_answer
		WHERE CAST(question_code AS VARCHAR(100)) = 'TYPEOFLIVINGSITUATION'
		AND CAST(val AS VARCHAR(100)) = 'Jail, prison or juvenile detention facility (HUD)'
		AND active = 't'
	)

		SELECT

			COUNT(DISTINCT ee.client_id) AS TotalClients
			, COUNT(DISTINCT c.client_id) AS FormerlyIncarcerated
			, CAST(COUNT(DISTINCT c.client_id) AS DECIMAL)/CAST(COUNT(DISTINCT ee.client_id) AS DECIMAL) AS PercentFI
			, p.name AS ProviderName

		FROM sp_entry_exit ee
		INNER JOIN sp_provider p
			ON p.provider_id = ee.provider_id
			AND p.operational = 't'
			AND p.active = 't'
			AND p.program_type_code IN (
										'Emergency Shelter (HUD)'
										, 'Transitional housing (HUD)'
										, 'PH - Rapid Re-Housing (HUD)'
										, 'PH - Permanent Supportive Housing (disability required for entry) (HUD)'
										, 'Safe Haven (HUD)')

		LEFT OUTER JOIN clients c
			ON c.client_id = ee.client_id
		INNER JOIN da_answer HoH
			ON HoH.client_id = ee.client_id
			AND CAST(HoH.question_code AS VARCHAR(100)) = 'HUD_RELATIONTOHOH'
			AND CAST(HoH.val AS VARCHAR(100)) = 'Self (head of household)'

		WHERE
			entry_date < '2018-01-01'
			AND (exit_date >= '2017-01-01' OR exit_date IS NULL)
			AND ee.active = 't'

		GROUP BY
			p.name