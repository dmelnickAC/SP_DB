USE chicago_export

select
	
	p.name
	, i.inventory_start_date
	, i.inventory_end_date
	, i.bed_inventory
	, i.hmis_beds
	, i.date_updated
	, p.provider_id
	, oi.bed_inventory AS OldBeds

from sp_bed_unit_inventory i
INNER JOIN sp_provider p
	ON p.provider_id = i.provider_id
INNER JOIN sp_bed_unit_inventory oi
	on oi.provider_id = i.provider_id
	and DATEADD(d,-1,i.inventory_start_date) = oi.inventory_end_date
where i.inventory_start_date >= '2017-06-01'
and i.active = 't'
and i.user_creating_id = 3722