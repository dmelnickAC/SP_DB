USE [SPReports]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'EERAnswerLink'))
BEGIN
    DROP TABLE EERAnswerLink
END


CREATE TABLE dbo.EERAnswerLink(
	EERAnswerLinkID INT IDENTITY(1,1) PRIMARY KEY,
	entry_exit_review_id INT NOT NULL,
	question_code VARCHAR(100) NOT NULL,
	answer_id INT NULL,
	active INT NOT NULL
) ON [PRIMARY]
GO