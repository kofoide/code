CREATE PROC SF_CombineColumnSubsetTable
	@Table1 NVARCHAR(128)
,	@Table2 NVARCHAR(128)
,	@ResultTable NVARCHAR(128)
AS

IF EXISTS (SELECT * FROM sys.tables JOIN sys.schemas ON sys.tables.schema_id = sys.schemas.schema_id
			WHERE sys.schemas.name = N'dbo'
			AND sys.tables.name = @ResultTable)
	EXEC ('DROP TABLE ' + @ResultTable)


DECLARE @collist NVARCHAR(MAX) = ''

DECLARE @name NVARCHAR(128)
DECLARE cols CURSOR FOR
SELECT CASE WHEN OBJECT_ID(@Table1) = [object_id] THEN 'T1.' ELSE 'T2.' END + [name] AS [name]
FROM sys.columns
WHERE
	OBJECT_ID(@Table1) = [object_id]
OR	(OBJECT_ID(@Table2) = [object_id] AND [name] NOT IN ('Id', 'SystemModstamp', 'LastModifiedDate', 'CreatedDate'))
ORDER BY
	[name]


OPEN cols

FETCH NEXT FROM cols
INTO @name

SET @collist = @name

FETCH NEXT FROM cols
INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @collist = @collist + ',' + @name

	FETCH NEXT FROM cols
	INTO @name
END

CLOSE cols
DEALLOCATE cols

DECLARE @SQL NVARCHAR(MAX)
SET @SQL = 'SELECT ' + @collist + ' INTO ' + @ResultTable + ' FROM ' + @Table1 + ' T1 INNER JOIN ' + @Table2 + ' T2 ON T1.Id = T2.Id'

EXEC (@SQL)
GO