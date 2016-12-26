SELECT *
FROM
(
SELECT *
FROM SalesForceArchive.dbo.TableMetaData
WHERE
	TableName = 'Company_Revenue__c'
AND	SchemaName = 'dbo'
)	A
FULL JOIN

(
SELECT *
FROM SalesForce.dbo.TableMetaData
WHERE
	TableName = 'Company_Revenue__c'
AND	SchemaName = 'dbo'
)	L	ON	A.ColumnName = L.ColumnName