-- What is the object referencing

IF OBJECT_ID(N'dbo.Referencing', N'P') IS NOT NULL
  DROP PROCEDURE dbo.Referencing
GO

CREATE PROC dbo.Referencing
     @objectnamequalified NVARCHAR(128)
AS

SELECT DISTINCT
-- Odds are if this object is not in the current db
--  then it is a table from another db
    ISNULL(RO.type_desc, 'USER_TABLE') AS ObjectType 
,   UPPER(ISNULL(sed.referenced_server_name, @@SERVERNAME)) AS ServerName
,   UPPER(ISNULL(sed.referenced_database_name, DB_NAME())) AS DatabaseName
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

ORDER BY
    ObjectType
,   ServerName
,   DatabaseName
,   SchemaName
,   ObjectName