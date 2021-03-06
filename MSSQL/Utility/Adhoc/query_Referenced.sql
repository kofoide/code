DECLARE @objectnamequalified VARCHAR(128) = 'dbo.statesdb'

-- What is referencing the object
SELECT
    RE.referencing_schema_name AS ReferencingSchema
,   RE.referencing_entity_name AS ReferencingEntity
,   O.type_desc AS ReferencingType
,   RE.referencing_id  AS ReferencingObjectId
,   RE.is_caller_dependent  
FROM
            sys.dm_sql_referencing_entities (@objectnamequalified, 'OBJECT')    RE
LEFT JOIN   sys.objects                                                 O   ON  RE.referencing_id = O.[object_id]