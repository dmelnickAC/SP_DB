USE [SPReports]
GO
/****** Object:  UserDefinedFunction [dbo].[VarcharToDate]    Script Date: 1/23/2018 14:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].[AgeAtTime](@DOB date, @pointintime date)
RETURNS int
AS
BEGIN
DECLARE @out int

SET @out = CASE WHEN @DOB IS NOT NULL and @pointintime IS NOT NULL
			THEN 
				CASE WHEN month(@DOB)>month(@pointintime) then year(@pointintime) - year(@DOB) - 1
				WHEN month(@DOB) > month(@pointintime) then year(@pointintime) - year(@DOB)
				WHEN month(@DOB) = month(@pointintime) then
					CASE WHEN day(@DOB) > day(@pointintime) then year(@pointintime) - year(@DOB) - 1
					WHEN day(@DOB) <= day(@pointintime) then year(@pointintime) - year(@DOB)
					END
				END
			END
RETURN @out

END