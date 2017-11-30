use chicago_export;

with level2 AS
	(
		select
			provider_id
		from sp_provider p
		WHERE p.parent_provider_id = 1
	)
, level3 AS
	(
	
		select
			p.provider_id
		from sp_provider p
		INNER JOIN level2 l2
			ON l2.provider_id = p.parent_provider_id
	
	)
, provider AS
	(
	
		select
			p.provider_id
		from sp_provider p
		INNER JOIN level3 l3
			ON l3.provider_id = p.parent_provider_id
		UNION
		SELECT * FROM level3
	
	)

SELECT

	p.provider_id as ProviderID
	, pd.name as Provider
	, ns.client_id as ClientID
	, ns.ssvf_fin_assist_amount AS Amount
	, cast(ns.provide_start_date AS DATE) AS ServiceDate

FROM provider p

INNER JOIN sp_provider pd
	ON pd.provider_id = p.provider_id
INNER JOIN sp_need_service ns
	ON ns.provide_provider_id = p.provider_id

WHERE

	pd.name = 'Heartland Human Care Services - SSVF - Rapid Re-housing (RRH)'
	AND program_type_code = 'PH - Rapid Re-Housing (HUD)'
	AND ns.active = 't'
	AND ns.code = 'BT'
	and ns.provide_start_date >= '2017-01-01'