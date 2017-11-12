USE SPReports
GO
/****** Object:  StoredProcedure [dbo].[sp_update_audit_table]    Script Date: 11/1/2017 11:05:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE dbo.EntryProviderChange
AS
BEGIN

SELECT
	ee.client_id
	, op.name as OldProvider
	, np.name as NewProvider
	, ucr.name as UserCreating
	, ucr.provider_id as UserCreatingProvider
	, uch.name as UserChanging
	, uch.provider_id as UserChangingProvider

FROM EntryExitAudit eea
INNER JOIN chicago_export.dbo.sp_entry_exit ee
	ON ee.entry_exit_id = eea.EntryExitID
INNER JOIN chicago_export.dbo.sp_user uch
	ON uch.user_id = eea.UserUpdatingID
INNER JOIN chicago_export.dbo.sp_user ucr
	ON ucr.user_id = ee.user_creating_id
INNER JOIN chicago_export.dbo.sp_provider op
	ON op.provider_id = eea.OldValue
INNER JOIN chicago_export.dbo.sp_provider np
	ON np.provider_id = eea.NewValue
WHERE fieldname = 'provider_id'

END