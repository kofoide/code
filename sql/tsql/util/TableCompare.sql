DECLARE @table1 VARCHAR(128), @table2 VARCHAR(128)
SELECT @table1 = 'SHL203C', @table2 = 'SHL203C_Test'

SELECT T1.ColumnName, T2.ColumnName
FROM
(
	SELECT
		S.name AS SchemaName
	,	T.name AS TableName
	,	C.name AS ColumnName
	,	TP.name AS TypeName
	,	C.max_length AS TypeLength
	,	C.[precision] AS TypePrecision
	,	C.scale AS TypeScale
	,	C.is_nullable AS ColumnIsNullable
	,	C.column_id AS ColumnCardinalLocation
	,	C.is_identity AS ColumnIsIdentity
	FROM
				sys.tables	T
	INNER JOIN	sys.columns	C	ON	T.object_id = C.object_id
	INNER JOIN	sys.types	TP	ON	C.user_type_id = TP.user_type_id
	INNER JOIN	sys.schemas	S	ON	T.schema_id = S.schema_id
	WHERE
		T.name = @table1
)	T1
FULL JOIN
(
	SELECT
		S.name AS SchemaName
	,	T.name AS TableName
	,	C.name AS ColumnName
	,	TP.name AS TypeName
	,	C.max_length AS TypeLength
	,	C.[precision] AS TypePrecision
	,	C.scale AS TypeScale
	,	C.is_nullable AS ColumnIsNullable
	,	C.column_id AS ColumnCardinalLocation
	,	C.is_identity AS ColumnIsIdentity
	FROM
				sys.tables	T
	INNER JOIN	sys.columns	C	ON	T.object_id = C.object_id
	INNER JOIN	sys.types	TP	ON	C.user_type_id = TP.user_type_id
	INNER JOIN	sys.schemas	S	ON	T.schema_id = S.schema_id
	WHERE
		T.name = @table2
)	T2	ON	T1.ColumnName = T2.ColumnName
;

DECLARE @colnames VARCHAR(4000)
SELECT @colnames = dbo.GROUP_CONCAT(C.name)
FROM
			sys.tables	T
INNER JOIN	sys.columns	C	ON	T.object_id = C.object_id
WHERE T.name = @table2

DECLARE @SQL_Base VARCHAR(MAX)
SELECT @SQL_Base =
'SELECT XXCOLSXX
FROM XXTABLE1XX

EXCEPT

SELECT XXCOLSXX
FROM XXTABLE2XX


SELECT XXCOLSXX
FROM XXTABLE2XX

EXCEPT

SELECT XXCOLSXX
FROM XXTABLE1XX'

DECLARE @SQL_cols VARCHAR(MAX)
SELECT @SQL_cols = REPLACE(@SQL_Base, 'XXCOLSXX', @colnames)

DECLARE @SQL_1 VARCHAR(MAX)
SELECT @SQL_1 = REPLACE(@SQL_cols, 'XXTABLE1XX', @table1)

DECLARE @SQL_2 VARCHAR(MAX)
SELECT @SQL_2 = REPLACE(@SQL_1, 'XXTABLE2XX', @table2)


EXEC (@SQL_2)