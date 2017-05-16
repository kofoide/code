--Get random rows from a table

--CREATE PROC RandomRows
--	@TableName NVARCHAR(128)
--,	@RowCount Int
--AS

DECLARE @TableName NVARCHAR(128) = 'fact.Invoice'
DECLARE @RowCount INT = 2000

DECLARE @UpperSQL NVARCHAR(4000), @ParmDef NVARCHAR(500)
DECLARE @Random INT
DECLARE @Upper INT
DECLARE @Lower INT


SET @UpperSQL = 'SELECT @maxOUT = MAX(RowNum) FROM ' + @TableName
SET @ParmDef = N'@maxOUT INT OUTPUT'


SET @Lower = 1 ---- The lowest random number
EXEC sp_executeSQL @UpperSQL, @ParmDef, @maxOUT = @Upper OUTPUT;


IF OBJECT_ID('tempdb..#tmp') IS NOT NULL DROP TABLE #tmp
CREATE TABLE #tmp(RowNum INT NOT NULL)

DECLARE @looper INT = 1
WHILE (@looper <= @RowCount)
BEGIN
	--INSERT INTO #tmp(RowNum)
	SELECT ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)

	SET @looper = @looper + 1
END

SELECT * FROM #tmp
