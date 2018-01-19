USE [SPReports]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE dbo.TransferOldTables
AS
BEGIN

--DROP TABLE SPReports.dbo.sp_client
SELECT * INTO SPReports.dbo.sp_client FROM chicago_export.dbo.sp_client

--DROP TABLE SPReports.dbo.sp_entry_exit
SELECT * INTO SPReports.dbo.sp_entry_exit FROM chicago_export.dbo.sp_entry_exit

--DROP TABLE SPReports.dbo.sp_provider
SELECT * INTO SPReports.dbo.sp_provider FROM chicago_export.dbo.sp_provider

END
