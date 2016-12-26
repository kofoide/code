IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS
			WHERE TABLE_SCHEMA = N'dbo'
			AND TABLE_NAME = N'TableMetaData')
  DROP VIEW dbo.TableMetaData
GO


CREATE VIEW dbo.TableMetaData
AS

SELECT
	S.name + '.' + T.name AS CommonName
,	S.name AS SchemaName
,	T.name AS TableName
,	C.name AS ColumnName
,	TY.name AS ColumnType
,	CASE
		WHEN TY.name IN ('nvarchar', 'nchar') THEN C.max_length/2
		ELSE C.max_length
	END AS ColumnTypeLength
,	C.[precision] AS ColumnTypePrecision
,	C.scale AS ColumnTypeScale
,	C.is_nullable AS ColumnTypeNillable
,	C.column_id AS ColumnVisibleOrder
FROM
			[sys].[schemas]	S
INNER JOIN	[sys].[tables]	T	ON	S.[schema_id] = T.[schema_id]
INNER JOIN	[sys].[columns]	C	ON	T.[object_id] = C.[object_id]
INNER JOIN	[sys].[types]	TY	ON	C.user_type_id = TY.user_type_id
GO