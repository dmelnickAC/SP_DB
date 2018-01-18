USE [SPReports]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'EEAnswerLink'))
BEGIN
    DROP TABLE EEAnswerLink
END


CREATE TABLE dbo.EEAnswerLink(
	EEAnswerLinkID INT IDENTITY(1,1) PRIMARY KEY,
	entry_exit_id INT NOT NULL,
	question_code VARCHAR(100) NOT NULL,
	entry_answer_id INT NULL,
	exit_answer_id INT NULL
) ON [PRIMARY]
GO