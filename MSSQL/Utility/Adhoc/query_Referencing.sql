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


-- What is the object referencing
SELECT DISTINCT
    ISNULL(RO.type_desc, 'Unavailable') AS ObjectType
,   ISNULL(sed.referenced_server_name, 'DefaultServer') AS ServerName
,   ISNULL(sed.referenced_database_name, 'DefaultDB') AS DatabaseName
,   sed.referenced_schema_name AS SchemaName
,   sed.referenced_entity_name AS ObjectName

--,   C.[RowCount] AS RowCountToday
--,   C1.[RowCount] AS RowCountYesterday

--,   OBJECT_NAME(sed.referencing_id) AS referencing_entity_name
--,   O.type_desc AS referencing_desciption
--,   COALESCE(COL_NAME(sed.referencing_id, sed.referencing_minor_id), '(n/a)') AS referencing_minor_id
--,   COALESCE(COL_NAME(sed.referenced_id, sed.referenced_minor_id), '(n/a)') AS referenced_column_name
--,   sed.is_caller_dependent
--,   sed.is_ambiguous

FROM 
            sys.sql_expression_dependencies SED
LEFT JOIN   sys.objects                     O   ON  SED.referencing_id = O.[object_id]
LEFT JOIN   sys.objects                     RO  ON  SED.referenced_id = RO.[object_id]
WHERE
    SED.referencing_id = OBJECT_ID(@objectnamequalified)