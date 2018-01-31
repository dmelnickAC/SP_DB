select

	ee.client_id
	, entry_date
	, exit_date
	, destination
	, dbo.VarcharToDate(mid.val) as hmid

from chicago_export.dbo.sp_entry_exit ee
INNER JOIN chicago_export.dbo.sp_provider p
	ON p.provider_id = ee.provider_id
LEFT OUTER JOIN chicago_export.dbo.sp_entry_exit_review eer
	ON eer.entry_exit_id = ee.entry_exit_id
LEFT OUTER JOIN EERAnswerLink eeral_mid
	ON eeral_mid.entry_exit_review_id = eer.entry_exit_review_id
	AND eeral_mid.active = 1
	AND eeral_mid.question_code = 'HUD_HOUSINGMOVEINDATE'
LEFT OUTER JOIN chicago_export.dbo.da_answer mid
	ON mid.answer_id = eeral_mid.answer_id
where p.name like '%rrh%'
AND ee.active = 't'
AND (p.name LIKE '%renaissance%' OR p.name LIKE '%primo%')