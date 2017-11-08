USE [AllChicagoReporting]
GO
/****** Object:  StoredProcedure [dbo].[sp_update_audit_table]    Script Date: 11/1/2017 11:05:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_update_audit_table]
AS
BEGIN
DECLARE @currval INT = 0;
DECLARE @finval INT = (select count(*) from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'sp_client_new' and TABLE_CATALOG = 'AllChicagoReporting');

WHILE @currval <= @finval
BEGIN
exec sp_checkcolumn @currval
SET @currval = @currval + 1;
END;
END;