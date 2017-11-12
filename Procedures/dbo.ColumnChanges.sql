USE SPReports
GO
/****** Object:  StoredProcedure [dbo].[sp_update_audit_table]    Script Date: 11/1/2017 11:05:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE dbo.ColumnChanges (@Table VARCHAR(50),@Column INT)
AS
BEGIN

DECLARE @TableStrip varchar(50) = right(@Table,len(@Table)-3)
DECLARE @TableStripForTableName varchar(50) = replace(@TableStrip,'_','')
DECLARE @FieldName varchar(max);
SET @FieldName =
	(
		select
			ac.name
		from sys.all_objects ao
		inner join sys.all_columns ac
			on ao.object_id = ac.object_id
		where
			ao.name = @Table
			and ac.column_id = @Column);

DECLARE @sql nvarchar(max) =
	'INSERT INTO SPReports.dbo.	'+@TableStripForTableName+'Audit
		('+@TableStripForTableName+'ID
		, FieldID
		, FieldName
		, NewValue
		, OldValue
		, UserUpdatingID
		, DateUpdated
		, DateLoaded
		)
	select
		cn.'+@TableStrip+'_id,
		'+cast(@Column as varchar(2))+' as FieldID,
		'''+@FieldName+''' as FieldName,
		cast(cn.' + @FieldName + ' as VARCHAR(100)) as NewValue,
		cast(co.' + @FieldName + ' as VARCHAR(100)) as OldValue,
		cn.user_updating_id,
		cn.date_updated,
		CAST(GETDATE() AS DATE) AS DateLoaded
	from chicago_export.dbo.'+@Table+' cn
	LEFT OUTER JOIN SPReports.dbo.'+@Table+' co
		ON cn.'+@TableStrip+'_id = co.'+@TableStrip+'_id
	LEFT OUTER JOIN SPReports.dbo.'+@TableStripForTableName+'Audit audit
		ON audit.'+@TableStripForTableName+'ID = cn.'+@TableStrip+'_id
		AND audit.FieldID = '+cast(@Column as varchar(2))+'
		AND audit.FieldName = '''+@FieldName+'''
		AND audit.NewValue = cast(cn.' + @FieldName + ' as VARCHAR(100))
		AND audit.OldValue = cast(co.' + @FieldName + ' as VARCHAR(100))
		AND audit.UserUpdatingID = cn.user_updating_id
		AND audit.DateUpdated = cn.date_updated

	where (cast(cn.' + @FieldName + ' as varchar(100))<> cast(co.' + @FieldName + ' as varchar(100)))
	AND audit.'+@TableStripForTableName+'AuditID IS NULL
	';

exec sp_executesql @sql;

END