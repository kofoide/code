CREATE PROC dbo.CreateRESTAPIObject
	@TableName VARCHAR(100)
AS

SELECT 
CASE WHEN T.c_type = 'DateTime' THEN '[JsonConverter(typeof(SFDCDateTimeConverter))]' + CHAR(13) + CHAR(10) ELSE '' END + 'public ' + T.c_type + CASE WHEN is_nullable = 1 AND T.c_type <> 'string' THEN '?' ELSE '' END +  ' ' + C.Name + ' { get; set; }'
FROm sys.columns C
INNER JOIN	TypeConversion	T	ON	C.user_type_id = T.user_type_id
WHERE object_id = OBJECT_ID(@TableName)
AND C.Name NOT IN ('Id', 'Name', 'CreatedDate', 'SystemModstamp', 'CreatedById', 'LastActivityDate', 'LastModifiedDate', 'LastModifiedById')
ORDER BY C.Name