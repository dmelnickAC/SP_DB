USE [AllChicagoReporting]
GO

/****** Object:  View [dbo].[ClientAudit_View]    Script Date: 11/1/2017 11:08:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[ClientAudit_View]
AS
select cnt.client_id, cnt.first_name, cnt.last_name, cnt.middle_name, cnt.date_updated, at.NewValue as UpdatedValue from sp_client_new cnt
join audit_table at on cnt.client_id = at.client_id
join client_Field_Table cft on cft.Field_ID = at.FieldID
GO


