USE [SPReports]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE dbo.DFSSDataDump
AS
BEGIN
IF OBJECT_ID('tempdb..#provider') IS NOT NULL DROP TABLE #provider;

--all we need to do is define the conditions on the providers, then the baby runs!
SELECT
	p.*
	, pp.parent_provider_id AS grand_parent_provider_id
INTO #provider
FROM chicago_export.dbo.sp_provider p
INNER JOIN chicago_export.dbo.sp_provider pp
	ON pp.provider_id = p.parent_provider_id
WHERE p.provider_id = 1305
AND p.active = 't'


IF OBJECT_ID('tempdb..#providersforvisibility') IS NOT NULL DROP TABLE #providersforvisibility;
CREATE TABLE #providersforvisibility (ProviderID INT)

INSERT #providersforvisibility
SELECT provider_id FROM #provider UNION SELECT parent_provider_id FROM #provider UNION SELECT grand_parent_provider_id FROM #provider 

IF OBJECT_ID('tempdb..#ee') IS NOT NULL DROP TABLE #ee;

SELECT ee.* INTO #ee FROM chicago_export.dbo.sp_entry_exit ee
INNER JOIN #provider p
	ON p.provider_id = ee.provider_id
WHERE ee.active = 't'

IF OBJECT_ID('tempdb..#client') IS NOT NULL DROP TABLE #client;

SELECT c.* INTO #client FROM chicago_export.dbo.sp_client c
INNER JOIN #ee ee
	ON ee.client_id = c.client_id

IF OBJECT_ID('tempdb..#answer') IS NOT NULL DROP TABLE #answer;

SELECT a.* INTO #answer FROM chicago_export.dbo.da_answer a
INNER JOIN #client c
	ON c.client_id = a.client_id
INNER JOIN #providersforvisibility pfv
	ON pfv.ProviderID = a.provider_id
	
IF OBJECT_ID('tempdb..#recordset') IS NOT NULL DROP TABLE #recordset;

SELECT rs.* INTO #recordset FROM chicago_export.dbo.da_recordset rs
INNER JOIN #providersforvisibility pfv
	ON pfv.ProviderID = rs.provider_creating_id
	
IF OBJECT_ID('tempdb..#recordsetanswer') IS NOT NULL DROP TABLE #recordsetanswer;

SELECT rsa.* INTO #recordsetanswer FROM chicago_export.dbo.da_recordset_answer rsa
INNER JOIN #providersforvisibility pfv
	ON pfv.ProviderID = rsa.provider_creating_id
INNER JOIN #recordset rs
	ON rs.recordset_id = rsa.recordset_id

END