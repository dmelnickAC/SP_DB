USE [SPReports]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[ProviderChangedToDiffAgency] (@CES INT)
AS
BEGIN

select 
ee.client_id, ee.entry_date,
p.name as OldProject, 
pr.name as NewProject, 
eeaudit.*, 
userz.name, userz.email,
p.organization_id as OldAgency, 
pr.organization_id as NewAgency 

INTO #CoolTempTable

from EntryExitAudit as eeaudit
INNER JOIN chicago_export.dbo.sp_user as userz
	ON userupdatingID = userz.user_id
INNER JOIN chicago_export.dbo.sp_provider as p
	ON oldvalue = p.provider_id
INNER JOIN chicago_export.dbo.sp_provider as pr
	ON newvalue = pr.provider_id
INNER JOIN chicago_export.dbo.sp_entry_exit as ee
	ON EntryExitID = entry_exit_id

where fieldname ='provider_id'
and  p.organization_id<> pr.organization_id
--and newvalue<>1474
--and oldvalue <>1474


	if @CES = 0 
	BEGIN
		SELECT * from #CoolTempTable
		where newvalue <>1474 
		and oldvalue <>1474
	END;

	if @CES = 1
	BEGIN
		SELECT * from #CoolTempTable
		where newvalue = 1474 
		OR oldvalue = 1474
	END;

END
GO


