SELECT DISTINCT
	client_id
	, provider_creating_id
	, provider_id
FROM chicago_export.dbo.sp_release_of_info
WHERE
	documentation like 'B - %'
	or documentation like 'D - %'