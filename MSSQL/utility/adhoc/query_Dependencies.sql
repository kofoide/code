DECLARE @objectname1 VARCHAR(128) = 'dbo.usp_DimAccount'
DECLARE @objectname2 VARCHAR(128) = 'usp_DimAccount'

SELECT
    referencing_schema_name
,   referencing_entity_name
,   referencing_id
,   referencing_class_desc
,   is_caller_dependent  
FROM sys.dm_sql_referencing_entities ('crm.FilteredOppProd', 'OBJECT')




SELECT
    o.type_desc
,    referenced_database_name
,   referenced_schema_name
,   referenced_entity_name
,   referenced_minor_name
,   referenced_minor_id
,   referenced_class_desc
,   is_caller_dependent
,   is_ambiguous
,   is_updated
FROM sys.dm_sql_referenced_entities (@objectname1, 'OBJECT') a
INNER JOIN  sys.objects o ON a.referenced_id = o.[object_id]
WHERE referenced_minor_id = 0




SELECT  space(iteration * 4) + TheFullEntityName + ' (' + rtrim(TheType) + ')' AS ThePath
FROM    dbo.It_Depends(@objectname2, 1)
ORDER BY ThePath DESC
