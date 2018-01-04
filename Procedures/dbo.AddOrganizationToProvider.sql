USE SPReports
GO
/****** Object:  StoredProcedure [dbo].[sp_update_audit_table]    Script Date: 11/1/2017 11:05:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE dbo.AddOrganizationToProvider
AS
BEGIN

IF (select object_id From chicago_export.sys.all_columns
where name = 'organization_id') IS NULL
BEGIN
ALTER TABLE chicago_export.dbo.sp_provider
ADD organization_id INT;
END
END;