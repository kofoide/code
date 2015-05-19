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
ORDER BY
	S.name, T.name, C.column_id