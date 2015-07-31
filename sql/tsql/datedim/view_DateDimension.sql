IF OBJECT_ID(N'dbo.DateDimension', N'V') IS NOT NULL
  DROP VIEW dbo.DateDimension
GO


CREATE VIEW dbo.DateDimension
AS

-- Rankings for Relative Calculations
WITH RelativeRankings AS (
SELECT
	ThisDate

,	DENSE_RANK() OVER(ORDER BY GregorianYear, GregorianQuarterOfYear) AS GregorianQuarterNumRank
,	DENSE_RANK() OVER(ORDER BY GregorianYear, GregorianMonthOfYear) AS GregorianMonthNumRank
,	DENSE_RANK() OVER(ORDER BY GregorianYear, GregorianWeekOfYear) AS GregorianWeekNumRank

--,	DENSE_RANK() OVER(ORDER BY Calendar1Year, Calendar1QuarterOfYear) AS Calendar1QuarterNumRank
--,	DENSE_RANK() OVER(ORDER BY Calendar1Year, Calendar1MonthOfYear) AS Calendar1MonthNumRank
--,	DENSE_RANK() OVER(ORDER BY Calendar1Year, Calendar1WeekOfYear) AS Calendar1WeekNumRank
FROM dbo.DimDate
)

-- Data for Today
, Today AS
(SELECT
	T.GregorianYear AS CurrentGregorianYear
,	T.GregorianQuarterOfYear AS CurrentGregorianQuarterOfYear
,	T.GregorianMonthOfYear AS CurrentGregorianMonthOfYear
,	T.GregorianWeekOfYear AS CurrentGregorianWeekOfYear
,	T.GregorianDayOfYear AS CurrentGregorianDayOfYear
,	T.GregorianDayOfQuarter AS CurrentGregorianDayOfQuarter
,	T.GregorianDayOfMonth AS CurrentGregorianDayOfMonth
,	T.GregorianDayOfWeek AS CurrentGregorianDayOfWeek

,	R.GregorianQuarterNumRank AS CurrentGregorianQuarterNumRank
,	R.GregorianMonthNumRank AS CurrentGregorianMonthNumRank
,	R.GregorianWeekNumRank AS CurrentGregorianWeekNumRank

--,	T.Calendar1Year AS CurrentCalendar1Year
--,	T.Calendar1QuarterOfYear AS CurrentCalendar1QuarterOfYear
--,	T.Calendar1MonthOfYear AS CurrentCalendar1MonthOfYear
--,	T.Calendar1WeekOfYear AS CurrentCalendar1WeekOfYear
--,	T.Calendar1DayOfYear AS CurrentCalendar1DayOfYear
--,	T.Calendar1DayOfQuarter AS CurrentCalendar1DayOfQuarter
--,	T.Calendar1DayOfMonth AS CurrentCalendar1DayOfMonth
--,	T.Calendar1DayOfWeek AS CurrentCalendar1DayOfWeek

--,	R.Calendar1QuarterNumRank AS CurrentCalendar1QuarterNumRank
--,	R.Calendar1MonthNumRank AS CurrentCalendar1MonthNumRank
--,	R.Calendar1WeekNumRank AS CurrentCalendar1WeekNumRank
FROM
			dbo.DimDate		T
INNER JOIN RelativeRankings	R	ON T.ThisDate = R.ThisDate
WHERE
	T.ThisDate = CAST(GETDATE() AS DATE)
)

SELECT
	D.ThisDate
,	IsHoliday
,	IsWeekend

-- This is here for cube Time Dimension
,	N'Current Period' AS PeriodID


-- ***********************************************************************
-- GREGORIAN YEAR CALCULATIONS
,	D.GregorianYear

-- Gregorian Calendar Years always begin and end on the same days no matter what year it is,
--	this code is here for non-Gregorian calendars
-- Last Day of the Year this date is in
--,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.GregorianYear ORDER BY D.ThisDate DESC) AS GregorianYearEndDate
-- First Day of the Year this date is in
--,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.GregorianYear ORDER BY D.ThisDate ASC) AS GregorianYearBeginDate

-- How many years ago was this date
,	D.GregorianYear - T.CurrentGregorianYear AS GregorianRelativeToTodayYear
-- Label
,	CASE
		WHEN (D.GregorianYear - T.CurrentGregorianYear) = 0 THEN 'Current Year'
		WHEN (D.GregorianYear - T.CurrentGregorianYear) > 0 THEN CAST((D.GregorianYear - T.CurrentGregorianYear) AS VARCHAR) + ' Years From Now'
		ELSE CAST(ABS(D.GregorianYear - T.CurrentGregorianYear) AS VARCHAR) + ' Years Ago'
	END AS GregorianRelativeToTodayYearLabel

-- Is this date in the YTD range
,	CASE WHEN D.GregorianDayOfYear <= T.CurrentGregorianDayOfYear THEN 'Yes' ELSE 'No' END AS GregorianIsParallelSalesYTDByDay
-- ***********************************************************************


-- ***********************************************************************
-- GREGORIAN QUARTER CALCULATIONS
,	D.GregorianQuarterOfYear

-- Gregorian Calendar Quarters always begin and end on the same days no matter what year it is,
--	this code is here for non-Gregorian calendars
-- Last Day of the Quarter this date is in
--,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.GregorianYear, D.GregorianQuarterOfYear ORDER BY D.ThisDate DESC) AS GregorianQuarterEndDate
-- First Day of the Quarter this date is in
--,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.GregorianYear, D.GregorianQuarterOfYear ORDER BY D.ThisDate ASC) AS GregorianQuarterBeginDate

-- Unique Quarter Label for hierarchies
,	CAST(D.GregorianYear AS VARCHAR) + ' Q' + CAST(D.GregorianQuarterOfYear AS VARCHAR) AS GregorianQuarterOfYearUniqueLabel
-- Standard Quarter Label
,	'Q' + CAST(D.GregorianQuarterOfYear AS VARCHAR) AS GregorianQuarterOfYearLabel

-- How many quarters ago was this date
,	R.GregorianQuarterNumRank - T.CurrentGregorianQuarterNumRank AS GregorianRelativeToTodayQuarter
-- Label
,	CASE
		WHEN R.GregorianQuarterNumRank - T.CurrentGregorianQuarterNumRank = 0 THEN 'Current Quarter '
		WHEN R.GregorianQuarterNumRank - T.CurrentGregorianQuarterNumRank > 0
			THEN CAST((R.GregorianQuarterNumRank - T.CurrentGregorianQuarterNumRank) AS VARCHAR) + ' Quarters From Now'
		ELSE CAST(ABS(R.GregorianQuarterNumRank - T.CurrentGregorianQuarterNumRank) AS VARCHAR) + ' Quarters Ago'
	END AS GregorianRelativeToTodayQuarterLabel

-- Is this date in the QTD range for the same quarter as the current date is in
,	CASE WHEN D.GregorianDayOfQuarter <= T.CurrentGregorianDayOfQuarter AND D.GregorianQuarterOfYear = T.CurrentGregorianQuarterOfYear THEN 'Yes' ELSE 'No' END AS GregorianIsParallelSalesQTDSameQuarterByDay
-- Is this date in the QTD range for any quarter
,	CASE WHEN D.GregorianDayOfQuarter <= T.CurrentGregorianDayOfQuarter THEN 'Yes' ELSE 'No' END AS GregorianIsParallelSalesQTDAnyQuarterByDay
-- ***********************************************************************


-- ***********************************************************************
-- GREGORIAN MONTH CALCULATIONS
,	D.GregorianMonthOfYear

-- Because of Leap years February may end on a different day depending on year
-- Last Day of the Month this date is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.GregorianYear, D.GregorianMonthOfYear ORDER BY D.ThisDate DESC) AS GregorianMonthEndDate
-- First Day of the Month this date is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.GregorianYear, D.GregorianMonthOfYear ORDER BY D.ThisDate ASC) AS GregorianMonthBeginDate

-- Unique Month Label for hierarchies
,	CAST(D.GregorianYear AS VARCHAR) + ' P' + CASE WHEN D.GregorianMonthOfYear < 10 THEN '0' ELSE '' END + CAST(D.GregorianMonthOfYear AS VARCHAR) AS GregorianMonthOfYearUniqueLabel

-- Standard Quarter Label
,	SUBSTRING(DATENAME(mm, D.ThisDate), 1, 3) AS GregorianMonthOfYearLabel
--	The next line is here for new non-gregorian calendars
--,	'P' + CASE WHEN D.GregorianMonthOfYear < 10 THEN '0' ELSE '' END + CAST(D.GregorianMonthOfYear AS VARCHAR) AS GregorianMonthOfYearLabel

-- How many months ago was this date
,	R.GregorianMonthNumRank - T.CurrentGregorianMonthNumRank AS GregorianRelativeToTodayMonth
-- Label
,	CASE
		WHEN R.GregorianMonthNumRank - T.CurrentGregorianMonthNumRank = 0	THEN 'Current Month'
		WHEN R.GregorianMonthNumRank - T.CurrentGregorianMonthNumRank > 0
			THEN CAST((R.GregorianMonthNumRank - T.CurrentGregorianMonthNumRank) AS VARCHAR) + ' Months From Now'
		ELSE CAST(ABS(R.GregorianMonthNumRank - T.CurrentGregorianMonthNumRank) AS VARCHAR) + ' Months Ago'
	END AS GregorianRelativeToTodayMonthLabel

-- Is this date in the MTD range for the same month as the current date is in
,	CASE WHEN D.GregorianDayOfMonth <= T.CurrentGregorianDayOfMonth AND D.GregorianMonthOfYear = T.CurrentGregorianMonthOfYear THEN 'Yes' ELSE 'No' END AS GregorianIsParallelSalesMTDSameMonthByDay
-- Is this date in the MTD range for any month
,	CASE WHEN D.GregorianDayOfMonth <= T.CurrentGregorianDayOfMonth THEN 'Yes' ELSE 'No' END AS GregorianIsParallelSalesMTDAnyMonthByDay
-- ***********************************************************************


-- ***********************************************************************
-- GREGORIAN WEEK CALCULATIONS
,	D.GregorianWeekOfYear

-- Last Day of the Week this date is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.GregorianYear, D.GregorianWeekOfYear ORDER BY D.ThisDate DESC) AS GregorianWeekEndDate
-- First Day of the Week this date is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.GregorianYear, D.GregorianWeekOfYear ORDER BY D.ThisDate ASC) AS GregorianWeekBeginDate

-- Unique Week Label for hierarchies
,	CAST(D.GregorianYear AS VARCHAR) + ' W' + CASE WHEN D.GregorianWeekOfYear < 10 THEN '0' ELSE '' END + CAST(D.GregorianWeekOfYear AS VARCHAR) AS GregorianWeekOfYearUniqueLabel

-- Standard Quarter Label
,	'W' + CASE WHEN D.GregorianWeekOfYear < 10 THEN '0' ELSE '' END + CAST(D.GregorianWeekOfYear AS VARCHAR) AS GregorianWeekOfYearLabel

-- How many weeks ago was this date
,	R.GregorianWeekNumRank - T.CurrentGregorianWeekNumRank AS GregorianRelativeToTodayWeek
-- Label
,	CASE
		WHEN R.GregorianWeekNumRank - T.CurrentGregorianWeekNumRank = 0 THEN 'Current Week'
		WHEN R.GregorianWeekNumRank - T.CurrentGregorianWeekNumRank > 0
			THEN CAST((R.GregorianWeekNumRank - T.CurrentGregorianWeekNumRank) AS VARCHAR) + ' Weeks From Now'
		ELSE CAST(ABS(R.GregorianWeekNumRank - T.CurrentGregorianWeekNumRank) AS VARCHAR) + ' Weeks Ago'
	END AS GregorianRelativeToTodayWeekLabel

-- Is this date in the WTD range for the same week as the current date is in
,	CASE WHEN D.GregorianDayOfWeek <= T.CurrentGregorianDayOfWeek AND D.GregorianWeekOfYear = T.CurrentGregorianWeekOfYear THEN 'Yes' ELSE 'No' END AS GregorianIsParallelSalesWTDSameWeekByDay
-- Is this date in the WTD range for any month
,	CASE WHEN D.GregorianDayOfWeek <= T.CurrentGregorianDayOfWeek THEN 'Yes' ELSE 'No' END AS GregorianIsParallelSalesWTDAnyWeekByDay
-- ***********************************************************************


-- ***********************************************************************
-- TODAY GREGORIAN DATA
,	T.CurrentGregorianYear
,	T.CurrentGregorianQuarterOfYear
,	T.CurrentGregorianMonthOfYear
,	T.CurrentGregorianWeekOfYear
,	T.CurrentGregorianDayOfYear
,	T.CurrentGregorianDayOfQuarter
,	T.CurrentGregorianDayOfMonth
,	T.CurrentGregorianDayOfWeek
-- ***********************************************************************




---- ***********************************************************************
---- CALENDAR1 YEAR CALCULATIONS
--,	D.Calendar1Year

---- Calendar1 Calendar Years always begin and end on the same days no matter what year it is,
----	this code is here for non-Calendar1 calendars
---- Last Day of the Year this date is in
--,	CASE
--		WHEN D.Calendar1Year IS NULL THEN NULL
--		ELSE FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.Calendar1Year ORDER BY D.ThisDate DESC)
--	END AS Calendar1YearEndDate
---- First Day of the Year this date is in
--,	CASE
--		WHEN D.Calendar1Year IS NULL THEN NULL
--		ELSE FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.Calendar1Year ORDER BY D.ThisDate ASC)
--	END AS Calendar1YearBeginDate

---- How many years ago was this date
--,	CASE
--		WHEN D.Calendar1Year IS NULL THEN NULL
--		ELSE D.Calendar1Year - T.CurrentCalendar1Year
--	END AS Calendar1RelativeToTodayYear
---- Label
--,	CASE
--		WHEN D.Calendar1Year IS NULL THEN NULL
--		WHEN (D.Calendar1Year - T.CurrentCalendar1Year) = 0 THEN 'Current Year'
--		WHEN (D.Calendar1Year - T.CurrentCalendar1Year) > 0 THEN CAST((D.Calendar1Year - T.CurrentCalendar1Year) AS VARCHAR) + ' Years From Now'
--		ELSE CAST(ABS(D.Calendar1Year - T.CurrentCalendar1Year) AS VARCHAR) + ' Years Ago'
--	END AS Calendar1RelativeToTodayYearLabel

---- Is this date in the YTD range
--,	CASE
--		WHEN D.Calendar1Year IS NULL THEN NULL
--		WHEN D.Calendar1DayOfYear <= T.CurrentCalendar1DayOfYear THEN 'Yes'
--		ELSE 'No'
--	END AS Calendar1IsParallelSalesYTDByDay
---- ***********************************************************************


---- ***********************************************************************
---- CALENDAR1 QUARTER CALCULATIONS
--,	D.Calendar1QuarterOfYear

---- Calendar1 Calendar Quarters always begin and end on the same days no matter what year it is,
----	this code is here for non-Calendar1 calendars
---- Last Day of the Quarter this date is in
--,	CASE
--		WHEN D.Calendar1QuarterOfYear IS NULL THEN NULL
--		ELSE FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.Calendar1Year, D.Calendar1QuarterOfYear ORDER BY D.ThisDate DESC)
--	END AS Calendar1QuarterEndDate
---- First Day of the Quarter this date is in
--,	CASE
--		WHEN D.Calendar1QuarterOfYear IS NULL THEN NULL
--		ELSE FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.Calendar1Year, D.Calendar1QuarterOfYear ORDER BY D.ThisDate ASC)
--	END AS Calendar1QuarterBeginDate

---- Unique Quarter Label for hierarchies
--,	CASE
--		WHEN D.Calendar1QuarterOfYear IS NULL THEN NULL
--		ELSE CAST(D.Calendar1Year AS VARCHAR) + ' Q' + CAST(D.Calendar1QuarterOfYear AS VARCHAR)
--	END AS Calendar1QuarterOfYearUniqueLabel
---- Standard Quarter Label
--,	'Q' + CAST(D.Calendar1QuarterOfYear AS VARCHAR) AS Calendar1QuarterOfYearLabel

---- How many quarters ago was this date
--,	CASE
--		WHEN D.Calendar1QuarterOfYear IS NULL THEN NULL
--		ELSE R.Calendar1QuarterNumRank - T.CurrentCalendar1QuarterNumRank
--	END AS Calendar1RelativeToTodayQuarter
---- Label
--,	CASE
--		WHEN D.Calendar1QuarterOfYear IS NULL THEN NULL
--		WHEN R.Calendar1QuarterNumRank - T.CurrentCalendar1QuarterNumRank = 0 THEN 'Current Quarter '
--		WHEN R.Calendar1QuarterNumRank - T.CurrentCalendar1QuarterNumRank > 0
--			THEN CAST((R.Calendar1QuarterNumRank - T.CurrentCalendar1QuarterNumRank) AS VARCHAR) + ' Quarters From Now'
--		ELSE CAST(ABS(R.Calendar1QuarterNumRank - T.CurrentCalendar1QuarterNumRank) AS VARCHAR) + ' Quarters Ago'
--	END AS Calendar1RelativeToTodayQuarterLabel

---- Is this date in the QTD range for the same quarter as the current date is in
--,	CASE
--		WHEN D.Calendar1QuarterOfYear IS NULL THEN NULL
--		WHEN D.Calendar1DayOfQuarter <= T.CurrentCalendar1DayOfQuarter AND D.Calendar1QuarterOfYear = T.CurrentCalendar1QuarterOfYear THEN 'Yes'
--		ELSE 'No'
--	END AS Calendar1IsParallelSalesQTDSameQuarterByDay
---- Is this date in the QTD range for any quarter
--,	CASE
--		WHEN D.Calendar1QuarterOfYear IS NULL THEN NULL
--		WHEN D.Calendar1DayOfQuarter <= T.CurrentCalendar1DayOfQuarter THEN 'Yes'
--		ELSE 'No'
--	END AS Calendar1IsParallelSalesQTDAnyQuarterByDay
---- ***********************************************************************


---- ***********************************************************************
---- CALENDAR1 MONTH CALCULATIONS
--,	D.Calendar1MonthOfYear

---- Because of Leap years February may end on a different day depending on year
---- Last Day of the Month this date is in
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		ELSE FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.Calendar1Year, D.Calendar1MonthOfYear ORDER BY D.ThisDate DESC)
--	END AS Calendar1MonthEndDate
---- First Day of the Month this date is in
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		ELSE FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.Calendar1Year, D.Calendar1MonthOfYear ORDER BY D.ThisDate ASC)
--	END AS Calendar1MonthBeginDate

---- Unique Month Label for hierarchies
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		ELSE CAST(D.Calendar1Year AS VARCHAR) + ' P' + CASE WHEN D.Calendar1MonthOfYear < 10 THEN '0' ELSE '' END + CAST(D.Calendar1MonthOfYear AS VARCHAR)
--	END AS Calendar1MonthOfYearUniqueLabel

---- Standard Quarter Label
----,	SUBSTRING(DATENAME(mm, D.ThisDate), 1, 3) AS Calendar1MonthOfYearLabel
----	The next line is here for new non-Calendar1 calendars
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		ELSE 'P' + CASE WHEN D.Calendar1MonthOfYear < 10 THEN '0' ELSE '' END + CAST(D.Calendar1MonthOfYear AS VARCHAR)
--	END AS Calendar1MonthOfYearLabel

---- How many months ago was this date
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		ELSE R.Calendar1MonthNumRank - T.CurrentCalendar1MonthNumRank
--	END AS Calendar1RelativeToTodayMonth
---- Label
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		WHEN R.Calendar1MonthNumRank - T.CurrentCalendar1MonthNumRank = 0	THEN 'Current Month'
--		WHEN R.Calendar1MonthNumRank - T.CurrentCalendar1MonthNumRank > 0
--			THEN CAST((R.Calendar1MonthNumRank - T.CurrentCalendar1MonthNumRank) AS VARCHAR) + ' Months From Now'
--		ELSE CAST(ABS(R.Calendar1MonthNumRank - T.CurrentCalendar1MonthNumRank) AS VARCHAR) + ' Months Ago'
--	END AS Calendar1RelativeToTodayMonthLabel

---- Is this date in the MTD range for the same month as the current date is in
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		WHEN D.Calendar1DayOfMonth <= T.CurrentCalendar1DayOfMonth AND D.Calendar1MonthOfYear = T.CurrentCalendar1MonthOfYear THEN 'Yes'
--		ELSE 'No'
--	END AS Calendar1IsParallelSalesMTDSameMonthByDay
---- Is this date in the MTD range for any month
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		WHEN D.Calendar1DayOfMonth <= T.CurrentCalendar1DayOfMonth THEN 'Yes'
--		ELSE 'No'
--	END AS Calendar1IsParallelSalesMTDAnyMonthByDay
---- ***********************************************************************


---- ***********************************************************************
---- CALENDAR1 WEEK CALCULATIONS
--,	D.Calendar1WeekOfYear

---- Last Day of the Week this date is in
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		ELSE FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.Calendar1Year, D.Calendar1WeekOfYear ORDER BY D.ThisDate DESC)
--	END AS Calendar1WeekEndDate
---- First Day of the Week this date is in
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		ELSE FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.Calendar1Year, D.Calendar1WeekOfYear ORDER BY D.ThisDate ASC)
--	END AS Calendar1WeekBeginDate

---- Unique Week Label for hierarchies
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		ELSE CAST(D.Calendar1Year AS VARCHAR) + ' W' + CASE WHEN D.Calendar1WeekOfYear < 10 THEN '0' ELSE '' END + CAST(D.Calendar1WeekOfYear AS VARCHAR)
--	END AS Calendar1WeekOfYearUniqueLabel

---- Standard Quarter Label
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		ELSE 'W' + CASE WHEN D.Calendar1WeekOfYear < 10 THEN '0' ELSE '' END + CAST(D.Calendar1WeekOfYear AS VARCHAR)
--	END AS Calendar1WeekOfYearLabel

---- How many weeks ago was this date
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		ELSE R.Calendar1WeekNumRank - T.CurrentCalendar1WeekNumRank
--	END AS Calendar1RelativeToTodayWeek
---- Label
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		WHEN R.Calendar1WeekNumRank - T.CurrentCalendar1WeekNumRank = 0 THEN 'Current Week'
--		WHEN R.Calendar1WeekNumRank - T.CurrentCalendar1WeekNumRank > 0
--			THEN CAST((R.Calendar1WeekNumRank - T.CurrentCalendar1WeekNumRank) AS VARCHAR) + ' Weeks From Now'
--		ELSE CAST(ABS(R.Calendar1WeekNumRank - T.CurrentCalendar1WeekNumRank) AS VARCHAR) + ' Weeks Ago'
--	END AS Calendar1RelativeToTodayWeekLabel

---- Is this date in the WTD range for the same week as the current date is in
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		WHEN D.Calendar1DayOfWeek <= T.CurrentCalendar1DayOfWeek AND D.Calendar1WeekOfYear = T.CurrentCalendar1WeekOfYear THEN 'Yes'
--		ELSE 'No'
--	END AS Calendar1IsParallelSalesWTDSameWeekByDay
---- Is this date in the WTD range for any month
--,	CASE
--		WHEN D.Calendar1MonthOfYear IS NULL THEN NULL
--		WHEN D.Calendar1DayOfWeek <= T.CurrentCalendar1DayOfWeek THEN 'Yes'
--		ELSE 'No'
--	END AS Calendar1IsParallelSalesWTDAnyWeekByDay
---- ***********************************************************************


---- ***********************************************************************
---- TODAY CALENDAR1 DATA
--,	T.CurrentCalendar1Year
--,	T.CurrentCalendar1QuarterOfYear
--,	T.CurrentCalendar1MonthOfYear
--,	T.CurrentCalendar1WeekOfYear
--,	T.CurrentCalendar1DayOfYear
--,	T.CurrentCalendar1DayOfQuarter
--,	T.CurrentCalendar1DayOfMonth
--,	T.CurrentCalendar1DayOfWeek
---- ***********************************************************************

FROM
			dbo.DimDate		D
INNER JOIN	RelativeRankings	R	ON	D.ThisDate = R.ThisDate
CROSS JOIN	Today			T
GO