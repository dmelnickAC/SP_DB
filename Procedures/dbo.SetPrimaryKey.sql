USE [SPReports]
GO
/****** Object:  StoredProcedure [dbo].[SetPrimaryKey]    Script Date: 1/4/2018 10:43:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SetPrimaryKey] @tablename varchar(max) = 0, @columnname varchar(max)=0
AS
BEGIN
BEGIN
declare @index_name as varchar(max)
declare @sql2 as varchar(max)
set @index_name = (select name from chicago_export.sys.indexes
where object_id = (select object_id from chicago_export.sys.objects where name = @tablename)
AND
name is not null
AND name like '%'+@columnname
)
print @index_name
IF EXISTS (select name from chicago_export.sys.indexes
where object_id = (select object_id from chicago_export.sys.objects where name = @tablename))
BEGIN
set @sql2 = 'USE chicago_export; DROP INDEX '+@tablename+'.'+@index_name
print @sql2
EXEC (@sql2)
END
END

declare @sql as varchar(max)
declare @sql1 as varchar(max)
declare @datatype as varchar(max)
set @datatype = (
SELECT DATA_TYPE 
FROM chicago_export.INFORMATION_SCHEMA.COLUMNS
WHERE 
     TABLE_NAME = @tablename AND 
     COLUMN_NAME = @columnname
	 )
set @sql =
'USE chicago_export; ALTER table chicago_export.dbo.'+@tablename+' ALTER COLUMN '+@columnname+' '+@datatype+' NOT NULL'+'
;'
exec(@sql)
print @sql
set @sql1 = 
'USE chicago_export; ALTER table chicago_export.dbo.' +@tablename+ ' add CONSTRAINT PK_'+@tablename+'_'+@columnname+ ' PRIMARY KEY ('+ @columnname+')'
print @sql1
exec(@sql1)
END