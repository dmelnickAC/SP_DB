USE SPReports;


BEGIN
DECLARE @qcode VARCHAR(100)
DECLARE @i INT = 0
DECLARE @total INT = (SELECT COUNT(*) FROM UpdateQuestions);

WHILE @i < 24 --(@total-20)
	BEGIN
		WITH up AS (SELECT TOP (@total - @i) question_code FROM UpdateQuestions ORDER BY question_code ASC)

		SELECT TOP 1 question_code INTO #down FROM up ORDER BY question_code DESC

		SET @qcode = (SELECT question_code FROM #down)

		IF OBJECT_ID('tempdb..#down') IS NOT NULL DROP TABLE #down;
		IF OBJECT_ID('tempdb..#clients') IS NOT NULL DROP TABLE #clients;

			SELECT DISTINCT
				client_id
				, a.question_code
			INTO #clients
			FROM chicago_export.dbo.da_answer a
			WHERE --(CAST(date_added AS DATE) >= DATEADD(DAY,-15,CAST(GETDATE() AS DATE)) OR CAST(date_inactive AS DATE) >= DATEADD(DAY,-15,CAST(GETDATE() AS DATE))) AND
			question_code = @qcode

--	INSERT INTO SPReports.dbo.EEAnswerLink (entry_exit_id, question_code, entry_answer_id,exit_answer_id)
	
		SELECT

			entry_exit_id
			, @qcode as question_code
			, (SELECT TOP 1
				answer_id
			FROM chicago_export.dbo.da_answer
			WHERE date_effective <= ee.entry_date
			AND question_code = @qcode
			AND client_id = ee.client_id
			AND active = 't'
			ORDER BY date_effective DESC,date_added DESC) as entry_answer_id
			, (SELECT TOP 1
				answer_id
			FROM chicago_export.dbo.da_answer
			WHERE date_effective <= ee.exit_date
			AND question_code = @qcode
			AND client_id = ee.client_id
			AND active = 't'
			ORDER BY date_effective DESC,date_added DESC) as exit_answer_id

		FROM #clients c
		INNER JOIN chicago_export.dbo.sp_entry_exit ee
			ON ee.client_id = c.client_id
		WHERE ee.active = 't'

--	INSERT INTO SPReports.dbo.EERAnswerLink (entry_exit_review_id, question_code, answer_id)

		SELECT

			eer.entry_exit_review_id
			, @qcode as question_code
			, (SELECT TOP 1
				answer_id
			FROM chicago_export.dbo.da_answer
			WHERE date_effective <= eer.review_date
			AND question_code = @qcode
			AND client_id = ee.client_id
			AND active = 't'
			ORDER BY date_effective DESC,date_added DESC) as answer_id

		FROM #clients c
		INNER JOIN chicago_export.dbo.sp_entry_exit ee
			ON ee.client_id = c.client_id
		INNER JOIN chicago_export.dbo.sp_entry_exit_review eer
			ON eer.entry_exit_id = ee.entry_exit_id
		WHERE eer.active = 't'

	SET @i = @i + 1
END

END