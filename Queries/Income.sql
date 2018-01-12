DROP TABLE #recordset
DROP TABLE #amt
DROP TABLE #sd
DROP TABLE #ed
DROP TABLE #it
DROP TABLE #dob
DROP TABLE #t
DROP TABLE #tt

SELECT
	rs.recordset_id
	, c.unique_id
	, rs.client_id
	, rs.provider_creating_id
	, s.StartDate
	, s.[End Date] AS EndDate
INTO #recordset
FROM sp_client c
INNER JOIN SPReports.dbo.[2018-01-04_StayersStartEndDates] s
--INNER JOIN SPReports.dbo.[2018-01-04_LeaversStartEndDates] s
	ON s.ClientUniqueId = c.unique_id
INNER JOIN da_recordset rs
	ON rs.client_id = c.client_id
	AND rs.active = 't'
INNER JOIN da_recordset_answer nz
	on nz.recordset_id = rs.recordset_id
	AND nz.question = 'Monthly Amount'

SELECT
	amt.recordset_id
	, CAST(val AS MONEY) AS MonthlyIncome
INTO #amt
FROM da_recordset_answer amt
INNER JOIN (SELECT recordset_id,MAX(date_added) AS MostRecent FROM da_recordset_answer WHERE question = 'Monthly Amount' GROUP BY recordset_id) t
	ON t.recordset_id = amt.recordset_id
	AND t.MostRecent = amt.date_added
INNER JOIN #recordset rs
	ON rs.recordset_id = amt.recordset_id
WHERE
	amt.question = 'Monthly Amount'

SELECT
	dob.client_id
	, SPReports.dbo.VarcharToDate(val) AS DOB
INTO #dob
FROM da_answer dob
INNER JOIN (SELECT client_id, MAX(date_added) AS MostRecent FROM da_answer WHERE question_code = 'SVPPROFDOB' GROUP BY client_id) t
	ON t.client_id = dob.client_id
	AND t.MostRecent = dob.date_added
INNER JOIN #recordset rs
	ON rs.client_id = dob.client_id
WHERE
	dob.question_code = 'SVPPROFDOB'

SELECT
	it.recordset_id
	, val AS IncomeType
INTO #it
FROM da_recordset_answer it
INNER JOIN (SELECT recordset_id,MAX(date_added) AS MostRecent FROM da_recordset_answer WHERE question = 'Source of Income' GROUP BY recordset_id) t
	ON t.recordset_id = it.recordset_id
	AND t.MostRecent = it.date_added
INNER JOIN #recordset rs
	ON rs.recordset_id = it.recordset_id
WHERE
	it.question = 'Source of Income'

SELECT
	sd.recordset_id
	, SPReports.dbo.VarcharToDate(val) AS StartDate
INTO #sd
FROM da_recordset_answer sd
INNER JOIN (SELECT recordset_id,MAX(date_added) AS MostRecent FROM da_recordset_answer WHERE question = 'Start Date' GROUP BY recordset_id) t
	ON t.recordset_id = sd.recordset_id
	AND t.MostRecent = sd.date_added
INNER JOIN #recordset rs
	ON rs.recordset_id = sd.recordset_id
WHERE
	sd.question = 'Start Date'

SELECT
	ed.recordset_id
	, SPReports.dbo.VarcharToDate(val) AS EndDate
INTO #ed
FROM da_recordset_answer ed
INNER JOIN (SELECT recordset_id,MAX(date_added) AS MostRecent FROM da_recordset_answer WHERE question = 'End Date' GROUP BY recordset_id) t
	ON t.recordset_id = ed.recordset_id
	AND t.MostRecent = ed.date_added
INNER JOIN #recordset rs
	ON rs.recordset_id = ed.recordset_id
WHERE
	ed.question = 'End Date'

SELECT DISTINCT

	rs.*
	, amt.MonthlyIncome
	, sd.StartDate AS IncomeStartDate
	, ed.EndDate AS IncomeEndDate
	, dob.DOB
	, CASE WHEN it.IncomeType = 'Earned Income (HUD)' THEN 1 ELSE 0 END AS Earned
	, CASE WHEN sd.StartDate <= rs.StartDate AND (ed.EndDate > rs.StartDate OR ed.EndDate IS NULL) THEN MonthlyIncome END AS IAB
	, CASE WHEN sd.StartDate <= rs.EndDate AND (ed.EndDate > rs.EndDate OR ed.EndDate IS NULL) THEN MonthlyIncome END AS IAE

INTO #t
FROM #recordset rs
INNER JOIN #amt amt
	ON amt.recordset_id = rs.recordset_id
INNER JOIN #sd sd
	ON sd.recordset_id = rs.recordset_id
LEFT OUTER JOIN #ed ed
	ON ed.recordset_id = rs.recordset_id
INNER JOIN #it it
	ON it.recordset_id = rs.recordset_id
LEFT OUTER JOIN #dob dob
	ON dob.client_id = rs.client_id

SELECT

	unique_id
	, provider_creating_id
	, client_id
	, StartDate
	, EndDate
	, DOB
	, SUM(IAB) AS IAB
	, SUM(IAE) AS IAE
	, SUM(CASE WHEN Earned = 1 THEN IAB END) AS IAB_Earned
	, SUM(CASE WHEN Earned = 1 THEN IAE END) AS IAE_Earned

into #tt
FROM #t

GROUP BY
	unique_id
	, provider_creating_id
	, client_id
	, DOB
	, StartDate
	, EndDate

SELECT
	unique_id
	, StartDate
	, EndDate
	, DATEDIFF(year,max(DOB),EndDate) AS Age
	, max(client_id) AS ClientID1
	, min(client_id) AS ClientID2
	, MAX(IAB) AS IAB
	, MAX(IAE) AS IAE
	, MAX(IAB_Earned) AS IAB_Earned
	, MAX(IAE_Earned) AS IAE_Earned
FROM #tt
GROUP BY
	unique_id
	, StartDate
	, EndDate