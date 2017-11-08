USE [SPReports]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE dbo.TransferOldTables
AS
BEGIN

TRUNCATE TABLE SPReports.dbo.sp_client
INSERT SPReports.dbo.sp_client
SELECT * FROM chicago_export.dbo.sp_client

TRUNCATE TABLE SPReports.dbo.sp_entry_exit
INSERT SPReports.dbo.sp_entry_exit
SELECT * FROM chicago_export.dbo.sp_entry_exit

TRUNCATE TABLE SPReports.dbo.sp_provider
INSERT SPReports.dbo.sp_provider
SELECT * FROM chicago_export.dbo.sp_provider

END
