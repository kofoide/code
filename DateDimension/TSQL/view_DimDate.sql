IF OBJECT_ID(N'dim.Date', N'V') IS NOT NULL
  DROP VIEW dim.[Date]
GO


CREATE VIEW [dim].[Date]
AS

-- *******************************************************************
-- PERIOD RANKINGS CTE
-- ************************************
--#region Relative Rankings
WITH RelativePeriods AS (
SELECT
	ID
,	DENSE_RANK() OVER(ORDER BY CalendarYearNumber, CalendarQuarterOfYearNumber) AS CalendarQuarterNumRank
,	DENSE_RANK() OVER(ORDER BY CalendarYearNumber, CalendarMonthOfYearNumber) AS CalendarMonthNumRank
,	DENSE_RANK() OVER(ORDER BY CalendarYearNumber, CalendarWeekOfYearNumber) AS CalendarWeekNumRank
FROM dbo.[Date]
)
--#endregion

-- *******************************************************************
-- TODAY CTE
-- ************************************
--#region Today
, Today AS
(SELECT
	T.CalendarYearNumber			AS CurrentCalendarYearNumber
,	T.CalendarQuarterOfYearNumber	AS CurrentCalendarQuarterOfYearNumber
,	T.CalendarMonthOfYearNumber		AS CurrentCalendarMonthOfYearNumber
,	T.CalendarWeekOfYearNumber		AS CurrentCalendarWeekOfYearNumber
,	T.CalendarDayOfYearNumber		AS CurrentCalendarDayOfYearNumber
,	T.CalendarDayOfQuarterNumber	AS CurrentCalendarDayOfQuarterNumber
,	T.CalendarDayOfMonthNumber		AS CurrentCalendarDayOfMonthNumber
,	T.CalendarDayOfWeekNumber		AS CurrentCalendarDayOfWeekNumber
,	W.CalendarQuarterNumRank		AS CurrentCalendarQuarterNumRank
,	W.CalendarMonthNumRank			AS CurrentCalendarMonthNumRank
,	W.CalendarWeekNumRank			AS CurrentCalendarWeekNumRank
FROM dbo.[Date]     		T
INNER JOIN RelativePeriods	W	ON T.ID = W.ID
WHERE ThisDate = CAST(GETDATE() AS DATE)
)
-- *******************************************************************
--#endregion


SELECT
	D.ID
--#region Individual Columns
,	D.ThisDate
,	D.IsWeekend
,	D.IsOfficeWorkday
,	D.IsCompanyHoliday
,	D.JulianDate
--#endregion

-- *******************************************************************
-- CALENDAR YEAR CALCULATIONS
-- ************************************
--#region Year
,	D.CalendarYearNumber

,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber ORDER BY D.ThisDate ASC) AS CalendarYearBeginDate
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber ORDER BY D.ThisDate DESC) AS CalendarYearEndDate


-- Number of years relative to the current year
,	D.CalendarYearNumber - T.CurrentCalendarYearNumber AS CalendarRelativeYearNumber
,	CASE
		WHEN (D.CalendarYearNumber - T.CurrentCalendarYearNumber) = 0 THEN 'Current Year'
		WHEN (D.CalendarYearNumber - T.CurrentCalendarYearNumber) > 0 THEN CAST((D.CalendarYearNumber - T.CurrentCalendarYearNumber) AS VARCHAR) + ' Years From Now'
		ELSE CAST(ABS(D.CalendarYearNumber - T.CurrentCalendarYearNumber) AS VARCHAR) + ' Years Ago'
	END AS CalendarRelativeYearLabel

-- Is the DayOfYear for This date in the YTD zone
,	CASE WHEN D.CalendarDayOfYearNumber <= T.CurrentCalendarDayOfYearNumber THEN 'TRUE' ELSE 'FALSE' END AS IsParallelCalendarYTDByDay
-- Is the Thisdate in the YTD zone for Closed Months
,	CASE WHEN D.CalendarMonthOfYearNumber < T.CurrentCalendarMonthOfYearNumber THEN 'TRUE' ELSE 'FALSE' END AS IsParallelCalendarYTDByClosedMonth
-- *******************************************************************
--#endregion

-- *******************************************************************
-- CALENDAR QUARTER CALCULATIONS
-- ************************************
--#region Quarter
,	D.CalendarQuarterOfYearNumber

,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarQuarterOfYearNumber ORDER BY D.ThisDate ASC) AS CalendarQuarterBeginDate
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarQuarterOfYearNumber ORDER BY D.ThisDate DESC) AS CalendarQuarterEndDate

,	CAST(D.CalendarYearNumber AS VARCHAR) + ' Q' + CAST(D.CalendarQuarterOfYearNumber AS VARCHAR) AS CalendarQuarterOfYearUniqueLabel
,	'Q' + CAST(D.CalendarQuarterOfYearNumber AS VARCHAR) AS CalendarQuarterOfYearLabel

-- Number of quarters relative to current quarter
,	W.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank AS CalendarRelativeQuarterNumber
,	CASE
		WHEN W.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank = 0 THEN 'Current Quarter '
		WHEN W.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank > 0
			THEN CAST((W.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank) AS VARCHAR) + ' Quarters From Now'
		ELSE CAST(ABS(W.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank) AS VARCHAR) + ' Quarters Ago'
	END AS CalendarRelativeQuarterLabel

-- Ignoring year, what Quarter is this Date's Quarter compared to the Current Day's Quarter
,	(W.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank) % 4 AS CalendarRelativeQuarterByYearToCurrentQuarter

-- Is the DayOfQuarter for This Date in the same QTD zone & in the SAME QuarterOfYear
,	CASE
		WHEN D.CalendarDayOfQuarterNumber <= T.CurrentCalendarDayOfQuarterNumber
		AND D.CalendarQuarterOfYearNumber = T.CurrentCalendarQuarterOfYearNumber
			THEN 'TRUE' ELSE 'FALSE'
	END AS IsParallelCalendarQTDSameQuarterByDay
-- Is the DayOfQuarter for This Date in the same QTD zone for ANY QuarterOfYear
,	CASE WHEN D.CalendarDayOfQuarterNumber <= T.CurrentCalendarDayOfQuarterNumber THEN 'TRUE' ELSE 'FALSE' END AS IsParallelCalendarQTDAnyQuarterByDay
-- *******************************************************************
--#endregion

-- *******************************************************************
-- CALENDAR MONTH CALCULATIONS
-- ************************************
--#region Month
,	D.CalendarMonthOfYearNumber

,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarMonthOfYearNumber ORDER BY D.ThisDate ASC) AS CalendarMonthBeginDate
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarMonthOfYearNumber ORDER BY D.ThisDate DESC) AS CalendarMonthEndDate

,	CAST(D.CalendarYearNumber AS VARCHAR) + ' ' + D.CalendarMonthLabel AS CalendarMonthOfYearUniqueLabel
,	D.CalendarMonthLabel AS CalendarMonthOfYearLabel

-- Number of periods relative to current month
,	W.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank AS CalendarRelativeMonthNumber
,	CASE
		WHEN W.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank = 0	THEN 'Current Period'
		WHEN W.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank > 0
			THEN CAST((W.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank) AS VARCHAR) + ' Months From Now'
		ELSE CAST(ABS(W.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank) AS VARCHAR) + ' Months Ago'
	END AS CalendarRelativeMonthLabel
,	(W.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank) % 12 CalendarRelativeMonthByYearToCurrentMonth

-- Is the DayOfMonth for ThisDate in the same MTD zone & in the SAME MonthOfYear
,	CASE
		WHEN D.CalendarDayOfMonthNumber <= T.CurrentCalendarDayOfMonthNumber
		AND D.CalendarMonthOfYearNumber = T.CurrentCalendarMonthOfYearNumber
			THEN 'TRUE' ELSE 'FALSE'
		END AS IsParallelCalendarMTDSameMonthByDay
-- Is the DayOfMonth for ThisDate in the same MTD zone for ANY MonthOfYear
,	CASE WHEN D.CalendarDayOfMonthNumber <= T.CurrentCalendarDayOfMonthNumber THEN 'TRUE' ELSE 'FALSE' END AS IsParallelCalendarMTDAnyMonthByDay
-- *******************************************************************
--#endregion

-- *******************************************************************
-- CALENDAR WEEK CALCULATIONS
-- ************************************
--#region Week
,	D.CalendarWeekOfYearNumber

,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarWeekOfYearNumber ORDER BY D.ThisDate ASC) AS CalendarWeekBeginDate
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarWeekOfYearNumber ORDER BY D.ThisDate DESC) AS CalendarWeekEndDate

,	CAST(D.CalendarYearNumber AS VARCHAR) + ' W'
		+ CASE WHEN D.CalendarWeekOfYearNumber < 10 THEN '0' ELSE '' END
		+ CAST(D.CalendarWeekOfYearNumber AS VARCHAR) AS CalendarWeekOfYearUniqueLabel
,	'W' + CASE WHEN D.CalendarWeekOfYearNumber < 10 THEN '0' ELSE '' END + CAST(D.CalendarWeekOfYearNumber AS VARCHAR) AS CalendarWeekOfYearLabel

-- Number of weeks relative to the current week
,	W.CalendarWeekNumRank - T.CurrentCalendarWeekNumRank AS CalendarRelativeWeekNumber
,	CASE
		WHEN W.CalendarWeekNumRank - T.CurrentCalendarWeekNumRank = 0 THEN 'Current Week'
		WHEN W.CalendarWeekNumRank - T.CurrentCalendarWeekNumRank > 0
			THEN CAST((W.CalendarWeekNumRank - T.CurrentCalendarWeekNumRank) AS VARCHAR) + ' Weeks From Now'
		ELSE CAST(ABS(W.CalendarWeekNumRank - T.CurrentCalendarWeekNumRank) AS VARCHAR) + ' Weeks Ago'
	END AS CalendarRelativeWeekLabel

-- Is the DayOfPeriod for ThisDate in the same WTD zone & in the SAME WeekOfYear
,	CASE
		WHEN D.CalendarDayOfWeekNumber <= T.CurrentCalendarDayOfWeekNumber
		AND D.CalendarWeekOfYearNumber = T.CurrentCalendarWeekOfYearNumber
			THEN 'TRUE' ELSE 'FALSE'
	END AS IsParallelCalendarWTDSameWeekByDay
-- Is the DayOfPeriod for ThisDate in the same WTD zone for ANY WeekOfYear
,	CASE
		WHEN D.CalendarDayOfWeekNumber <= T.CurrentCalendarDayOfWeekNumber THEN 'TRUE'
		ELSE 'FALSE'
	END AS IsParallelCalendarWTDAnyWeekByDay
-- *******************************************************************
--#endregion

-- *******************************************************************
-- CALENDAR DAY
-- ************************************
--#region Day
-- Number of days into the year ThisDate is in
,	D.CalendarDayOfYearNumber
-- Number of days remining in the year ThisDate is in
,	FIRST_VALUE(D.CalendarDayOfYearNumber) OVER(PARTITION BY D.CalendarYearNumber
													ORDER BY D.ThisDate DESC) - D.CalendarDayOfYearNumber AS CalendarDaysRemainingInYearNumber

-- Number of days into the quarter ThisDate is in
,	D.CalendarDayOfQuarterNumber
-- Number of days remining in the quarter ThisDate is in
,	FIRST_VALUE(D.CalendarDayOfQuarterNumber) OVER(PARTITION BY D.CalendarYearNumber, D.CalendarQuarterOfYearNumber 
													ORDER BY D.ThisDate DESC) - D.CalendarDayOfQuarterNumber AS CalendarDaysRemainingInQuarterNumber

-- Number of days into the period ThisDate is in
,	D.CalendarDayOfMonthNumber
-- Number of days remining in the month ThisDate is in
,	FIRST_VALUE(D.CalendarDayOfMonthNumber) OVER(PARTITION BY D.CalendarYearNumber, D.CalendarMonthOfYearNumber
													ORDER BY D.ThisDate DESC) - D.CalendarDayOfMonthNumber AS CalendarDaysRemainingInMonthNumber

-- Number of days into the week ThisDate is in
,	D.CalendarDayOfWeekNumber
-- Number of days remining in the week ThisDate is in
,	7 - D.CalendarDayOfWeekNumber AS CalendarDaysRemainingInWeekNumber
-- *******************************************************************
--#endregion


FROM
			dbo.[Date]	    D
INNER JOIN	RelativePeriods	W	ON	D.ID = W.ID
CROSS JOIN	Today			T
GO