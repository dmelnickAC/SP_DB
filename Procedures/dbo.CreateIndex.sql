USE [SPReports]
GO
/****** Object:  StoredProcedure [dbo].[CreateIndex]    Script Date: 1/4/2018 10:40:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[CreateIndex] @tablename varchar(max) = 0, @columnname varchar(max)=0
AS
BEGIN

BEGIN
declare @sql as varchar(max)
set @sql = 'USE chicago_export; CREATE INDEX idx_'+@tablename+'_'+@columnname+' ON '+@tablename+' ('+@columnname+')'
print @sql
EXEC (@sql)
END

END