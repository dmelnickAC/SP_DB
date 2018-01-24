USE SPReports

DECLARE @daysback INT = CASE WHEN DATEPART(WEEKDAY,GETDATE()) = 2 THEN 3 ELSE 1 END
DECLARE @qcode VARCHAR(100)
DECLARE @i INT = 0
DECLARE @total INT = (SELECT COUNT(*) FROM UpdateQuestions);

WHILE @i < @total --(@total-20)
	BEGIN
		WITH up AS (SELECT TOP (@total - @i) question_code FROM UpdateQuestions ORDER BY question_code ASC)

		SELECT TOP 1 question_code INTO #down FROM up ORDER BY question_code DESC --this selects 

		SET @qcode = (SELECT question_code FROM #down)

		IF OBJECT_ID('tempdb..#down') IS NOT NULL DROP TABLE #down;
		IF OBJECT_ID('tempdb..#clients') IS NOT NULL DROP TABLE #clients;

			SELECT DISTINCT
				client_id
				, a.question_code
			INTO #clients
			FROM chicago_export.dbo.da_answer a
			WHERE (CAST(date_added AS DATE) >= DATEADD(DAY,-1*@daysback,CAST(GETDATE() AS DATE)) OR CAST(date_inactive AS DATE) >= DATEADD(DAY,-1*@daysback,CAST(GETDATE() AS DATE))) AND
			question_code = @qcode

--	INSERT INTO SPReports.dbo.EEAnswerLink (entry_exit_id, question_code, entry_answer_id,exit_answer_id)
		IF OBJECT_ID('tempdb..#inc_eeal') IS NOT NULL DROP TABLE #inc_eeal;	
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
			AND val IS NOT NULL
			ORDER BY date_effective DESC,date_added DESC) as entry_answer_id
			, (SELECT TOP 1
				answer_id
			FROM chicago_export.dbo.da_answer
			WHERE date_effective <= ee.exit_date
			AND question_code = @qcode
			AND client_id = ee.client_id
			AND active = 't'
			AND val IS NOT NULL
			ORDER BY date_effective DESC,date_added DESC) as exit_answer_id
		
		INTO #inc_eeal
		FROM #clients c
		INNER JOIN chicago_export.dbo.sp_entry_exit ee
			ON ee.client_id = c.client_id
		WHERE ee.active = 't'

--	INSERT INTO SPReports.dbo.EERAnswerLink (entry_exit_review_id, question_code, answer_id)
		IF OBJECT_ID('tempdb..#inc_eeral') IS NOT NULL DROP TABLE #inc_eeral;
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
			AND val IS NOT NULL
			ORDER BY date_effective DESC,date_added DESC) as answer_id

		INTO #inc_eeral
		FROM #clients c
		INNER JOIN chicago_export.dbo.sp_entry_exit ee
			ON ee.client_id = c.client_id
		INNER JOIN chicago_export.dbo.sp_entry_exit_review eer
			ON eer.entry_exit_id = ee.entry_exit_id
		WHERE eer.active = 't'

	SELECT * FROM #inc_eeal

--these rows get inserted
INSERT INTO EEAnswerLink (entry_exit_id, question_code, entry_answer_id,exit_answer_id,active)
	SELECT
		ieeal.entry_exit_id
		, ieeal.question_code
		, ieeal.entry_answer_id
		, ieeal.exit_answer_id
		, 1
	FROM #inc_eeal ieeal
	LEFT OUTER JOIN EEAnswerLink eeal
		ON ieeal.entry_exit_id = eeal.entry_exit_id
		AND ieeal.question_code = eeal.question_code
		AND isnull(ieeal.entry_answer_id,0) = isnull(eeal.entry_answer_id,0)
		AND isnull(ieeal.exit_answer_id,0) = isnull(eeal.exit_answer_id,0)
		AND eeal.active = 1
	WHERE eeal.EEAnswerLinkID IS NULL

--these rows get updated
UPDATE EEAnswerLink
SET active = 0
--	SELECT *
	FROM EEAnswerLink eeal
	INNER JOIN #inc_eeal ieeal
		ON ieeal.entry_exit_id = eeal.entry_exit_id
		AND ieeal.question_code = eeal.question_code
	WHERE (isnull(ieeal.entry_answer_id,0) <> isnull(eeal.entry_answer_id,0) OR isnull(ieeal.exit_answer_id,0) <> isnull(eeal.exit_answer_id,0))
	and eeal.active = 1

--these rows get inserted
INSERT INTO EERAnswerLink (entry_exit_review_id, question_code, answer_id, active)
	SELECT
		ieeral.entry_exit_review_id
		, ieeral.question_code
		, ieeral.answer_id
		, 1
	FROM #inc_eeral ieeral
	LEFT OUTER JOIN EERAnswerLink eeral
		ON ieeral.entry_exit_review_id = eeral.entry_exit_review_id
		AND ieeral.question_code = eeral.question_code
		AND ISNULL(ieeral.answer_id,0) = ISNULL(eeral.answer_id,0)
		AND eeral.active = 1
	WHERE eeral.EERAnswerLinkID IS NULL

--these rows get updated
UPDATE EERAnswerLink
SET active = 0
--	SELECT *
	FROM EERAnswerLink eeral
	INNER JOIN #inc_eeral ieeral
		ON ieeral.entry_exit_review_id = eeral.entry_exit_review_id
		AND ieeral.question_code = eeral.question_code
	WHERE (isnull(ieeral.answer_id,0) <> isnull(eeral.answer_id,0))
	AND eeral.active = 1


	SET @i = @i + 1
END

