USE Utility;

IF EXISTS (SELECT * FROM sys.objects JOIN sys.schemas ON sys.objects.schema_id = sys.schemas.schema_id
			WHERE sys.schemas.name = N'dbo'
			AND	sys.objects.name = N'CompareTables'
			AND sys.objects.type in (N'P'))
	DROP PROCEDURE dbo.CompareTables
GO

CREATE PROC dbo.CompareTables
	@Table1Schema NVARCHAR(128)
,	@Table1Name NVARCHAR(128)
,	@Table2Schema NVARCHAR(128)
,	@Table2Name NVARCHAR(128)
,	@CompareType VARCHAR(50) = 'All'
AS

IF OBJECT_ID('tempdb..#table1') IS NOT NULL DROP TABLE #table1
SELECT C.name AS Table1Column
INTO #table1
FROM
			sys.columns	C
INNER JOIN	sys.tables	T	ON	C.object_id = t.object_id
INNER JOIN	sys.schemas	S	ON	T.schema_id = S.schema_id
WHERE
	T.name = @Table1Name
AND	S.name = @Table1Schema

IF OBJECT_ID('tempdb..#table2') IS NOT NULL DROP TABLE #table2
SELECT C.name AS Table2Column
INTO #table2
FROM
			sys.columns	C
INNER JOIN	sys.tables	T	ON	C.object_id = t.object_id
INNER JOIN	sys.schemas	S	ON	T.schema_id = S.schema_id
WHERE
	T.name = @Table2Name
AND	S.name = @Table2Schema


IF (@CompareType = 'All')
	SELECT *
	FROM
				#table1	T1
	FULL JOIN	#table2	T2	ON	T1.Table1Column = T2.Table2Column
	ORDER BY ISNULL(T1.Table1Column, T2.Table2Column)
ELSE IF (@CompareType = 'Left')
	SELECT *
	FROM
				#table1	T1
	LEFT JOIN	#table2	T2	ON	T1.Table1Column = T2.Table2Column
	ORDER BY ISNULL(T1.Table1Column, T2.Table2Column)
ELSE IF (@CompareType = 'Right')
	SELECT *
	FROM
				#table1	T1
	RIGHT JOIN	#table2	T2	ON	T1.Table1Column = T2.Table2Column
	ORDER BY ISNULL(T1.Table1Column, T2.Table2Column)
ELSE IF (@CompareType = 'Both')
	SELECT *
	FROM
				#table1	T1
	INNER JOIN	#table2	T2	ON	T1.Table1Column = T2.Table2Column
	ORDER BY ISNULL(T1.Table1Column, T2.Table2Column)
GO