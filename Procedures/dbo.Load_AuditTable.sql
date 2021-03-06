USE SPReports
GO
/****** Object:  StoredProcedure [dbo].[sp_update_audit_table]    Script Date: 11/1/2017 11:05:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE dbo.Load_AuditTable (@Table VARCHAR(50))
AS
BEGIN
DECLARE @currval INT = 1;
DECLARE @finval INT =
	(
		SELECT
			count(*)
		FROM sys.all_objects ao
		INNER JOIN sys.all_columns ac
			ON ao.object_id = ac.object_id
		WHERE
			ao.name = @Table);

WHILE @currval <= @finval
BEGIN
EXEC dbo.ColumnChanges @Table, @currval
SET @currval = @currval + 1;
END;
END;