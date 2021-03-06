USE [SPReports]
GO
/****** Object:  UserDefinedFunction [dbo].[GetEmail]    Script Date: 12/11/2017 1:26:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].VarcharToDate(@string VARCHAR(100))
RETURNS DATE
AS
BEGIN
DECLARE @out DATE

SET @out = CASE WHEN @string IS NOT NULL
			THEN DATEFROMPARTS(left(@string,4),SUBSTRING(@string,6,2),SUBSTRING(@string,9,2))
			END
RETURN @out

END