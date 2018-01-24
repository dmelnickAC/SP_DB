USE [SPReports]
GO
/****** Object:  StoredProcedure [dbo].[ToVARCHAR]    Script Date: 1/19/2018 12:55:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ToVARCHAR]
AS
BEGIN
alter table [chicago_export].[dbo].[sp_need_service] alter column [service_note] varchar(max);
alter table [chicago_export].[dbo].[sp_goal_casenote] alter column [note] varchar(max);
END
BEGIN
declare @sql nvarchar(max);
set @sql = stuff((
    select 
      char(10)+'use ' + quotename(c.table_catalog) + '; alter table ' 
      + quotename(c.table_schema) + '.' + quotename(c.table_name) 
      + ' alter column ' + quotename(c.column_name) + ' varchar(8000);'
    from chicago_export.information_schema.columns as c
      inner join chicago_export.information_schema.tables t 
        on c.table_name = t.table_name 
      and c.table_schema = t.table_schema
    where c.data_type = 'text'
      and t.table_type = 'base table'
	  ----
	  --and c.CHARACTER_MAXIMUM_LENGTH = 8000
	  ----
    for xml path (''), type).value('.','nvarchar(max)')
  ,1,1,'')
--select @sql
  --rollback TRAN Transaction1
--select CodeGenerated = @sql;
exec sp_executesql @sql
END