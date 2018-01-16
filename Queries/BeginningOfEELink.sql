USE SPReports

DECLARE @qcode VARCHAR(100)
DECLARE @i INT = 0
DECLARE @total INT = (SELECT COUNT(*) FROM UpdateQuestions);

WHILE @i < @total
BEGIN
	WITH up AS (SELECT TOP (@total - @i) question_code FROM UpdateQuestions ORDER BY question_code ASC)

	SELECT TOP 1 question_code INTO #down FROM up ORDER BY question_code DESC

	SET @qcode = (SELECT question_code FROM #down)
	DROP TABLE #down
DROP TABLE #clients

		SELECT
			client_id
			, a.question_code
		INTO #clients
		FROM chicago_export.dbo.da_answer a
		WHERE (CAST(date_added AS DATE) = DATEADD(DAY,-3,CAST(GETDATE() AS DATE))
		OR CAST(date_inactive AS DATE) = DATEADD(DAY,-3,CAST(GETDATE() AS DATE)))
		AND question_code = @qcode

SELECT

	entry_exit_id
	, ee.client_id
	, @qcode
	, (SELECT TOP 1
		answer_id
	FROM chicago_export.dbo.da_answer
	WHERE date_effective <= ee.entry_date
	AND question_code = @qcode
	AND client_id = ee.client_id
	AND active = 't'
	ORDER BY date_effective DESC,date_added DESC)
	, (SELECT TOP 1
		answer_id
	FROM chicago_export.dbo.da_answer
	WHERE date_effective <= ee.exit_date
	AND question_code = @qcode
	AND client_id = ee.client_id
	AND active = 't'
	ORDER BY date_effective DESC,date_added DESC)

FROM #clients c
INNER JOIN chicago_export.dbo.sp_entry_exit ee
	ON ee.client_id = c.client_id
WHERE ee.active = 't'

SELECT

	eer.entry_exit_review_id
	, @qcode
	, (SELECT TOP 1
		answer_id
	FROM chicago_export.dbo.da_answer
	WHERE date_effective <= eer.review_date
	AND question_code = @qcode
	AND client_id = ee.client_id
	AND active = 't'
	ORDER BY date_effective DESC,date_added DESC)

FROM #clients c
INNER JOIN chicago_export.dbo.sp_entry_exit ee
	ON ee.client_id = c.client_id
INNER JOIN chicago_export.dbo.sp_entry_exit_review eer
	ON eer.entry_exit_id = ee.entry_exit_id
WHERE eer.active = 't'
	SET @i = @i + 1
END

