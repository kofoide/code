DECLARE @objectnamequalified VARCHAR(128) = 'dbo.usp_DimAccount'
DECLARE @objectnameunqualified VARCHAR(128) = 'usp_DimAccount'

-- What is the object referencing
SELECT DISTINCT
    o.type_desc
,   ISNULL(referenced_database_name, 'DefaultDB') referenced_database_name
,   referenced_schema_name
,   referenced_entity_name
,   referenced_minor_name
,   referenced_minor_id
,   referenced_class_desc
,   is_caller_dependent
,   is_ambiguous
,   is_updated
FROM sys.dm_sql_referenced_entities (@objectnamequalified, 'OBJECT') a
INNER JOIN  sys.objects o ON a.referenced_id = o.[object_id]
WHERE referenced_minor_id = 0


-- What is the object referencing and subreferences
SELECT  space(iteration * 4) + TheFullEntityName + ' (' + rtrim(TheType) + ')' AS ThePath
FROM    dbo.It_Depends(@objectnameunqualified, 1)
ORDER BY ThePath DESC