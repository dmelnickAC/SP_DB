USE [SPReports]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'UpdateQuestions'))
BEGIN
    DROP TABLE UpdateQuestions
END


CREATE TABLE dbo.UpdateQuestions(
	question_code VARCHAR(100) PRIMARY KEY
) ON [PRIMARY]
GO

INSERT UpdateQuestions
SELECT TOP 24 question_code
FROM chicago_export.dbo.da_answer
WHERE date_added >= DATEADD(year,-1,getdate())
GROUP BY question_code
ORDER BY COUNT(answer_id) DESC
