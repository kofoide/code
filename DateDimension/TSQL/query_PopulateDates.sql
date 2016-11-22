DECLARE @TheYear INT = 1990
DECLARE @StopYear INT = 2030

WHILE @TheYear <= @StopYear
BEGIN

	-- tmp table will hold 1 years' worth of dates
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


	INSERT INTO dbo.[Date](
		ThisDate
	,	JulianDate
	,	CalendarYearNumber
	,	CalendarQuarterOfYearNumber
	,	CalendarMonthOfYearNumber
	,	CalendarMonthOfQuarterNumber
	,	CalendarWeekOfYearNumber
	,	CalendarWeekOfQuarterNumber
	,	CalendarWeekOfMonthNumber
	,	CalendarDayOfYearNumber
	,	CalendarDayOfQuarterNumber
	,	CalendarDayOfMonthNumber
	,	CalendarDayOfWeekNumber
	,	CalendarMonthLabel
	,	CommonDayOfWeekLabel
	,	IsWeekend
	,	IsCompanyHoliday
	,	IsOfficeWorkday)
	SELECT
		ThisDate
	,	DATEPART(yy, ThisDate) * 1000 + DATEPART(dy, ThisDate)
	,	DATEPART(yy, ThisDate) AS CalendarYearNumber
	,	DATEPART(q, ThisDate) AS CalendarQuarterOfYearNumber
	,	DATEPART(m, ThisDate) AS CalendarMonthOfYearNumber
	,	DENSE_RANK() OVER(PARTITION BY DATEPART(q, ThisDate) ORDER BY DATEPART(m, ThisDate)) AS CalendarMonthOfQuarterNumber
	,	DATEPART(wk, ThisDate) AS CalendarWeekOfYearNumber
	,	DENSE_RANK() OVER(PARTITION BY DATEPART(q, ThisDate) ORDER BY DATEPART(wk, ThisDate)) AS CalendarWeekOfQuarterNumber
	,	DENSE_RANK() OVER(PARTITION BY DATEPART(m, ThisDate) ORDER BY DATEPART(wk, ThisDate)) AS CalendarWeekOfMonthNumber
	,	DATEPART(dy, ThisDate) AS CalendarDayOfYearNumber
	,	DENSE_RANK() OVER(PARTITION BY DATEPART(q, ThisDate) ORDER BY DATEPART(dy, ThisDate)) AS CalendarDayOfQuarterNumber
	,	DENSE_RANK() OVER(PARTITION BY DATEPART(m, ThisDate) ORDER BY DATEPART(dy, ThisDate)) AS CalendarDayOfMonthNumber
	,	DATEPART(dw, ThisDate) AS CalendarDayOfWeekNumber
	,	DATENAME(mm, ThisDate) AS CalendarMonthLabel
	,	DATENAME(dw, ThisDate) AS CommonDayOfWeekLabel
	,	CASE WHEN DATEPART(dw, ThisDate) IN (1, 7) THEN 'TRUE' ELSE 'FALSE' END AS IsWeekend
	,	'FALSE' AS IsCompanyHoliday
	,	CASE WHEN DATEPART(dw, ThisDate) NOT IN (1, 7) THEN 'TRUE' ELSE 'FALSE' END AS IsWeekend
	FROM #tmp

	SET @TheYear = @TheYear + 1
END