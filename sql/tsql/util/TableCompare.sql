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
	T.name = 'SHL203A') T1


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
	T.name = 'SHP203') T2	ON	T1.ColumnName = T2.ColumnName
;


SELECT CUCUNO, CUCORG, CUSTATUS, CUCUNM, CUADD1, CUADD2, CUADD3, CUCITY, CUSTATE, CUZIP, CUCNTRY, CUARCUNO, CUPACUNO, CUSHCUFL, CUARCUFL, CUPACUFL, CUCCNM, CUCCTEL, CUCCFAX, CUCUGRCD, CUCUGRDS, CUCUTYCD, CUCUTYDS, CUDISTFL, CUTFEXCD, CUCMMKCD, CUBKFL, CUBKCD, CUBKNM, CUBKGLNO, CUSRCD, CURGCD, CURGDS, CUSTCD, CUSTDS, CUMKCD, CUMKDS, CUMKSPCD, CUMKSPNM, CUMKBKCD, CUMKBKNM, CUBGRGCD, CUBGRGNM, CUPRGCD, CUPRGNM, CUSHZONE, CUSHZONEDS
FROM [PORK\erick].[SHP203]

EXCEPT

SELECT CUCUNO, CUCORG, CUSTATUS, CUCUNM, CUADD1, CUADD2, CUADD3, CUCITY, CUSTATE, CUZIP, CUCNTRY, CUARCUNO, CUPACUNO, CUSHCUFL, CUARCUFL, CUPACUFL, CUCCNM, CUCCTEL, CUCCFAX, CUCUGRCD, CUCUGRDS, CUCUTYCD, CUCUTYDS, CUDISTFL, CUTFEXCD, CUCMMKCD, CUBKFL, CUBKCD, CUBKNM, CUBKGLNO, CUSRCD, CURGCD, CURGDS, CUSTCD, CUSTDS, CUMKCD, CUMKDS, CUMKSPCD, CUMKSPNM, CUMKBKCD, CUMKBKNM, CUBGRGCD, CUBGRGNM, CUPRGCD, CUPRGNM, CUSHZONE, CUSHZONEDS
FROM [PORK\erick].[SHL203A]