USE SPReports
GO
/****** Object:  StoredProcedure [dbo].[sp_update_audit_table]    Script Date: 11/1/2017 11:05:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE dbo.Load_Organization
AS
BEGIN

UPDATE p
SET p.organization_id =
	CASE WHEN pp.parent_provider_id = 1 THEN pp.provider_id
	WHEN p.parent_provider_id = 1 THEN p.provider_id
	ELSE pp.parent_provider_id END
FROM chicago_export.dbo.sp_provider p
INNER JOIN chicago_export.dbo.sp_provider pp
	ON pp.provider_id = p.parent_provider_id;

END;