USE [SPReports]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'ProgramTypeCategory'))
BEGIN
    DROP TABLE ProgramTypeCategory
END


CREATE TABLE dbo.ProgramTypeCategory(
	ProgramTypeCode VARCHAR(300) NOT NULL
	, HousingTypeCategory VARCHAR(50) NOT NULL
) ON [PRIMARY]
GO