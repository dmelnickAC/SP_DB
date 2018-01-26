DECLARE @SSO1StartDate DATE = '2017-10-01';

WITH referrals AS
	(
		SELECT
			ns.need_service_id
			, n.need_id
			, ns.client_id
			, ns.refer_date
			, n.status AS need_status
		FROM chicago_export.dbo.sp_need_service ns
		INNER JOIN chicago_export.dbo.sp_need n
			ON n.need_id = ns.need_id
			AND n.active = 't'
		WHERE refer_date IS NOT NULL
		AND ns.provider_creating_id = 1474
		AND ns.active = 't'
	)
, priorentries AS
	(
		SELECT unique_id from chicago_export.dbo.sp_client
		WHERE date_added < @SSO1StartDate
		AND active = 't'
	)
, totalentries AS
	(

		SELECT
		
			c.unique_id
		
		FROM chicago_export.dbo.sp_entry_exit ee
		INNER JOIN chicago_export.dbo.sp_client c
			ON c.client_id = ee.client_id
		LEFT OUTER JOIN priorentries pe
			ON pe.unique_id = c.unique_id
		WHERE entry_date >= @SSO1StartDate
		AND pe.unique_id IS NULL
		AND ee.active = 't'
		AND c.active = 't'

	)
SELECT TOP 10 * FROM totalentries;


WITH enrolledinsoornav AS
	(

		select unique_id from chicago_export.dbo.sp_entry_exit ee
		INNER JOIN chicago_export.dbo.sp_provider p
			ON p.provider_id = ee.provider_id
			AND p.active = 't'
		INNER JOIN EEAnswerLink eeal_hoh
			ON eeal_hoh.entry_exit_id = ee.entry_exit_id
			AND eeal_hoh.question_code = 'HUD_RELATIONTOHOH'
			AND eeal_hoh.active = 1
		INNER JOIN chicago_export.dbo.da_answer hoh
			ON hoh.answer_id = eeal_hoh.entry_answer_id
		INNER JOIN chicago_export.dbo.sp_client c
			ON c.client_id = ee.client_id
		WHERE (p.program_type_code = 'Street Outreach (HUD)'
			OR p.provider_id IN (1421 --featherfist
			, 1422 --franciscan
			, 1507 --ff
			, 1420 --heartland
			, 1423) ) --VOA
		AND ee.active = 't'
		AND entry_date >= @SSO1StartDate

	)
		SELECT DISTINCT
			ee.client_id
			, c.unique_id
			, (SELECT TOP 1 destination
			FROM chicago_export.dbo.sp_entry_exit
			WHERE client_id = ee.client_id AND ee.active = 't' AND exit_date > @SSO1StartDate
			AND ee.type_entry_exit IN ('HUD','RHY','VA') AND p.provider_id <> 644
			ORDER BY exit_date DESC) AS LastDestination
			, (SELECT TOP 1 exit_date
			FROM chicago_export.dbo.sp_entry_exit
			WHERE client_id = ee.client_id AND ee.active = 't' AND exit_date > @SSO1StartDate
			AND ee.type_entry_exit IN ('HUD','RHY','VA') AND p.provider_id <> 644
			ORDER BY exit_date DESC) AS LastExit
		INTO #systemexitcid
		FROM chicago_export.dbo.sp_entry_exit ee
		INNER JOIN chicago_export.dbo.sp_client c
			ON c.client_id = ee.client_id
		INNER JOIN chicago_export.dbo.sp_provider p
			ON p.provider_id = ee.provider_id
			AND p.active = 't'
			AND p.operational = 't'
		WHERE ee.exit_date > @SSO1StartDate
		AND ee.active = 't'
		AND ee.type_entry_exit IN ('HUD','RHY','VA')
		AND p.provider_id <> 644 --hpcc
--	)
--, systemexituid AS
--	(

		SELECT DISTINCT
		
			unique_id
			, (SELECT TOP 1 LastDestination FROM #systemexitcid WHERE unique_id = secid.unique_id ORDER BY LastExit DESC)
		
		FROM #systemexitcid secid

	--)

SELECT

	SUM(Win)*100/COUNT(Win) AS DiversionThenProjEntry

FROM(
SELECT
	c.unique_id
	, MAX(CASE WHEN ee.provider_id = 1396 THEN entry_date END) AS DivEntry
	, MAX(CASE WHEN ee.provider_id <> 1396 THEN entry_date END) AS NonDivEntry
	, CASE WHEN DATEDIFF(y,MAX(CASE WHEN ee.provider_id = 1396 THEN entry_date END),MAX(CASE WHEN ee.provider_id <> 1396 THEN entry_date END)) BETWEEN 0 AND 180 THEN 1 ELSE 0 END AS Win
FROM chicago_export.dbo.sp_entry_exit ee
INNER JOIN chicago_export.dbo.sp_client c
	ON c.client_id = ee.client_id
GROUP BY c.unique_id
HAVING MAX(CASE WHEN ee.provider_id = 1396 THEN entry_date END) IS NOT NULL
) t

--select name,* from chicago_export.dbo.sp_provider
--where name like '%diversion%'

--SELECT * FROM UpdateQuestions

--SELECT DISTINCT status FROM chicago_export.dbo.sp_need WHERE status LIKE 'CES%'

