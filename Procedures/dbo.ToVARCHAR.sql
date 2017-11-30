USE [chicago_export]
GO

/****** Object:  StoredProcedure [dbo].[ToVARCHAR]    Script Date: 11/30/2017 4:00:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='call_answer'

--select * from INFORMATION_SCHEMA.TABLES

--DECLARE @Transace varchar(max) = 'Transaction1';
--BEGIN TRAN Transaction1
ALTER PROCEDURE [dbo].[ToVARCHAR]
AS
BEGIN
declare @sql nvarchar(max);

set @sql = stuff((
    select 
      char(10)+'use ' + quotename(c.table_catalog) + '; alter table ' 
      + quotename(c.table_schema) + '.' + quotename(c.table_name) 
      + ' alter column ' + quotename(c.column_name) + ' varchar(max);'
    from information_schema.columns as c
      inner join information_schema.tables t 
        on c.table_name = t.table_name 
      and c.table_schema = t.table_schema
    where c.data_type = 'text' 
      and t.table_type = 'base table'
    for xml path (''), type).value('.','nvarchar(max)')
  ,1,1,'')
--select @sql
  --rollback TRAN Transaction1
--select CodeGenerated = @sql;
exec sp_executesql @sql
END
GO


