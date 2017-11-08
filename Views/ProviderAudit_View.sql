USE [AllChicagoReporting]
GO

/****** Object:  View [dbo].[ProviderAudit_View]    Script Date: 11/1/2017 11:07:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[ProviderAudit_View]
AS
select pnt.provider_id, pnt.name, pnt.date_updated, pat.NewValue as UpdatedValue from sp_provider_new pnt
join audit_table_provider pat on pnt.provider_id = pat.Provider_id
join provider_Field_Table pft on pft.Field_ID = pat.FieldID
GO


