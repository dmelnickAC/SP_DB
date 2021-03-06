USE [SPReports]
GO
/****** Object:  UserDefinedFunction [dbo].[GetEmail]    Script Date: 1/29/2018 2:53:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].[GetATAEmail](@prov int)
RETURNS VARCHAR(max)
AS
BEGIN
DECLARE @out VARCHAR(max)

SET @out = 
(select
replace(replace(replace(stuff(
(select
	u.email
from chicago_export.dbo.ws_answer a
INNER JOIN chicago_export.dbo.sp_user u
	ON u.user_id = a.entity_id
INNER JOIN chicago_export.dbo.sp_provider p
	ON p.provider_id = u.provider_id
INNER JOIN chicago_export.dbo.sp_provider child
	ON child.organization_id = p.organization_id
where question_code like 'ISUSERANAGENCYTECHNIC'
AND val = 'Y'
AND (p.organization_id = @prov OR child.provider_id = @prov)
FOR XML PATH('')) ,1,0,''),'</email><email>',';'),'<email>',''),'</email>',''))

RETURN @out
END
