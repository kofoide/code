DECLARE @TheYear INT = 2010
DECLARE @StopYear INT = 2016

WHILE @TheYear <= @StopYear
BEGIN

	IF OBJECT_ID('tempdb..#tmp') IS NOT NULL DROP TABLE #tmp
	CREATE TABLE #tmp(
		ThisDate date NOT NULL
	)

	DECLARE @CurrentDate DATE = DATEFROMPARTS(@TheYear, 1, 1)
	DECLARE @EndDate DATE = DATEFROMPARTS(@TheYear, 12, 31)

	WHILE @CurrentDate <= @EndDate
	BEGIN
		INSERT INTO #tmp(ThisDate)
		VALUES(@CurrentDate)

		SET @CurrentDate = DATEADD(dd, 1, @CurrentDate)
	END

	INSERT INTO dbo.DimDate(ThisDate, GregorianYear, GregorianQuarterOfYear, GregorianMonthOfYear, GregorianMonthOfQuarter, GregorianWeekOfYear, GregorianWeekOfQuarter, GregorianWeekOfMonth, GregorianDayOfYear, GregorianDayOfQuarter, GregorianDayOfMonth, GregorianDayOfWeek, IsWeekend)
	SELECT
		ThisDate
	,	DATEPART(yy, ThisDate) AS GregorianYear
	,	DATEPART(q, ThisDate) AS GregorianQuarterOfYear
	,	DATEPART(m, ThisDate) AS GregorianMonthOfYear
	,	DENSE_RANK() OVER(PARTITION BY DATEPART(q, ThisDate) ORDER BY DATEPART(m, ThisDate)) AS GregorianMonthOfQuarter
	,	DATEPART(wk, ThisDate) AS GregorianWeekOfYear
	,	DENSE_RANK() OVER(PARTITION BY DATEPART(q, ThisDate) ORDER BY DATEPART(wk, ThisDate)) AS GregorianWeekOfQuarter
	,	DENSE_RANK() OVER(PARTITION BY DATEPART(m, ThisDate) ORDER BY DATEPART(wk, ThisDate)) AS GregorianWeekOfMonth
	,	DATEPART(dy, ThisDate) AS GregorianDayOfYear
	,	DENSE_RANK() OVER(PARTITION BY DATEPART(q, ThisDate) ORDER BY DATEPART(dy, ThisDate)) AS GregorianDayOfQuarter
	,	DENSE_RANK() OVER(PARTITION BY DATEPART(m, ThisDate) ORDER BY DATEPART(dy, ThisDate)) AS GregorianDayOfMonth
	,	DATEPART(dw, ThisDate) AS GregorianDayOfWeek
	,	CASE WHEN DATEPART(dw, ThisDate) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend
	FROM #tmp

	SET @TheYear = @TheYear + 1
END