USE [SPReports]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'VisibleClient'))
BEGIN
    DROP TABLE VisibleClient
END


CREATE TABLE dbo.VisibleClient(
	ClientID INT NOT NULL
) ON [PRIMARY]
GO