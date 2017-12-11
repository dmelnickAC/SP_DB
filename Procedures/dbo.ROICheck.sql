USE [SPReports]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE dbo.ROICheck (@provider INT)
AS
BEGIN

SELECT DISTINCT
	roi.client_id AS ClientID
	, roi.provider_creating_id AS ProviderCreatingID
	, roiprov.name AS ProviderCreating
	, roi.user_creating_id AS UserCreatingROIID
	, usercreatingroi.name AS UserCreatingROIName
	, CAST(roi.date_added AS DATE) AS DateROIAdded
FROM chicago_export.dbo.sp_release_of_info roi
INNER JOIN chicago_export.dbo.sp_user usercreatingroi
	ON usercreatingroi.user_id = roi.user_creating_id
INNER JOIN dbo.VisibleClient v
	ON roi.client_id = v.ClientID
INNER JOIN dbo.sp_provider roiprov
	ON roi.provider_creating_id = roiprov.provider_id
INNER JOIN chicago_export.dbo.sp_client c
	ON c.client_id = roi.client_id

WHERE
	(documentation like 'B - %'
	or documentation like 'D - %')
	AND @provider = roi.provider_creating_id
	AND @provider = c.provider_creating_id

END
