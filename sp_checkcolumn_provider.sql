USE [AllChicagoReporting]
GO
/****** Object:  StoredProcedure [dbo].[sp_checkcolumn_provider]    Script Date: 11/1/2017 11:05:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_checkcolumn_provider] (@column_provider int)
AS
BEGIN
DECLARE @var_FieldName_provider varchar(max)
SET @var_FieldName_provider = (select Field_Name from provider_Field_Table where Field_ID = @column_provider);
	


DECLARE @sql_provider nvarchar(max) = 'INSERT INTO audit_table_provider(provider_id, FieldID, NewValue, OldValue, user_creating_id, date_updated)
select
	pn.provider_id,
	'+cast(@column_provider as varchar(2))+' as FieldID,
	pn.' + @var_FieldName_provider + ' as NewValue,
	po.' + @var_FieldName_provider + ' as OldValue,
	pn.[user_creating_id],
	pn.[date_updated]

from [dbo].[sp_provider_new] pn
left join [dbo].[sp_provider_old] po
on pn.provider_id = po.provider_id

where (pn.' + @var_FieldName_provider + '<> po.' + @var_FieldName_provider + '
or po.provider_id is null)';

--select @sql into audit_table(client_id)
--print @sql
exec sp_executesql @sql_provider
--insert into audit_table
--select * from ##temptable
END