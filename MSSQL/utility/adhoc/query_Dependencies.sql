DECLARE @objectname1 VARCHAR(128) = 'dbo.usp_DimAccount'
DECLARE @objectname2 VARCHAR(128) = 'usp_DimAccount'

-- What is referencing the object
SELECT
    referencing_schema_name
,   referencing_entity_name
,   referencing_id
,   referencing_class_desc
,   is_caller_dependent  
FROM sys.dm_sql_referencing_entities (@objectname1, 'OBJECT')


-- What is the object referencing
SELECT DISTINCT
    o.type_desc
,   ISNULL(referenced_database_name, 'NHAAnalytics') referenced_database_name
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


-- What is the object referencing and subreferences
SELECT  space(iteration * 4) + TheFullEntityName + ' (' + rtrim(TheType) + ')' AS ThePath
FROM    dbo.It_Depends(@objectname2, 1)
ORDER BY ThePath DESC


-- What is the object referencing
SELECT DISTINCT
    ISNULL(RO.type_desc, 'Unavailable') AS ObjectType
,   ISNULL(sed.referenced_server_name, 'ASC-PRD-SQL07') AS ServerName
,   ISNULL(sed.referenced_database_name, 'NHAAnalytics') AS DatabaseName
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
LEFT JOIN   sys.objects                     O   ON  SED.referencing_id = O.object_id
LEFT JOIN   sys.objects                     RO  ON  SED.referenced_id = RO.object_id
--LEFT JOIN   eric.TableRowCountTrack         C   ON  ISNULL(SED.referenced_database_name, 'NHAAnalytics') = C.DatabaseName
--                                                AND SED.referenced_schema_name = C.SchemaName
--                                                AND SED.referenced_entity_name = C.TableName
--                                                AND C.RunDate = dbo.CastDate(GETDATE())
--LEFT JOIN   eric.TableRowCountTrack         C1  ON  ISNULL(SED.referenced_database_name, 'NHAAnalytics') = C1.DatabaseName
--                                                AND SED.referenced_schema_name = C1.SchemaName
--                                                AND SED.referenced_entity_name = C1.TableName
--                                                AND C1.RunDate = dbo.CastDate(GETDATE()-1)
WHERE
    SED.referencing_id = OBJECT_ID(@objectname1)