USE [SPReports]
GO
/****** Object:  StoredProcedure [dbo].[loop_through]    Script Date: 12/13/2017 10:36:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[loop_through]
AS
BEGIN
DECLARE @currentval INT = 1;
DECLARE @finalval INT = (select count(*) from SPReports.dbo.dummyemails)
while @currentval <= @finalval
BEGIN
UPDATE  ReportServer.dbo.Subscriptions
  SET     ExtensionSettings = '<ParameterValues>
  <ParameterValue>
  <Name>TO</Name>
  <Value>'
  + CAST(SPReports.dbo.getdummyemail(@currentval) COLLATE Latin1_General_CI_AS_KS_WS AS VARCHAR(max))
  + '</Value>
  </ParameterValue>
  <ParameterValue>
  <Name>IncludeReport</Name>
  <Value>True</Value>
  </ParameterValue>
  <ParameterValue>
  <Name>RenderFormat</Name>
  <Value>MHTML</Value>
  </ParameterValue>
  <ParameterValue>
  <Name>Subject</Name>
  <Value>@ReportName executed at @ExecutionTime</Value>
  </ParameterValue>
  <ParameterValue>
  <Name>IncludeLink</Name>
  <Value>True</Value>
  </ParameterValue>
  <ParameterValue>
  <Name>Priority</Name>
  <Value>NORMAL</Value>
  </ParameterValue>
  </ParameterValues>'
  WHERE   SubscriptionID = 'C9ACD04C-14CE-4DDC-A2BC-5F5F4A4C4DEA'
  
EXEC msdb.dbo.sp_start_job '3574A85C-CE8F-4876-9E46-E76B9835103F'
SET @currentval = @currentval + 1;
BEGIN
WAITFOR DELAY '00:00:05';
END
END
END
