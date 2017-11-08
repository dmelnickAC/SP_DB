USE [AllChicagoReporting]
GO
/****** Object:  StoredProcedure [dbo].[sp_checkcolumn]    Script Date: 11/1/2017 11:04:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_checkcolumn] (@column int)
AS
BEGIN
DECLARE @var_FieldName varchar(max)
SET @var_FieldName = (select Field_Name from client_field_table where Field_ID = @column);

DECLARE @sql nvarchar(max) = 'INSERT INTO audit_table(client_id, FieldID, NewValue, OldValue, user_creating_id, date_updated, PROC_DATE)

select
	cn.client_id,
	'+cast(@column as varchar(2))+' as FieldID,
	cn.' + @var_FieldName + ' as NewValue,
	co.' + @var_FieldName + ' as OldValue,
	cn.[user_creating_id],
	cn.[date_updated],
	GETDATE()
from [dbo].[sp_client_new] cn
left join [dbo].[sp_client_old] co
on cn.client_id = co.client_id

where (cn.' + @var_FieldName + '<> co.' + @var_FieldName + '
or co.client_id is null)

AND
NOT EXISTS
(SELECT * from audit_table at where
cn.client_id = at.client_id
AND
 '+cast(@column as varchar(2))+' = at.FieldID
AND CONVERT(DATE, at.PROC_DATE) = CONVERT(DATE, cn.date_updated))
';
--
--select @sql into audit_table(client_id)
--print @sql
exec sp_executesql @sql
--insert into audit_table
--select * from ##temptable
END;
