IF OBJECT_ID(N'dbo.vw_dim_date2', N'V') IS NOT NULL
  DROP VIEW dbo.vw_dim_date2
GO


CREATE VIEW dbo.vw_dim_date2
AS

-- Rankings for Relative Calculations
WITH RelativePeriods AS (
SELECT
	date_id
,	DENSE_RANK() OVER(ORDER BY SalesYear, SalesWeek) AS SalesWeekNumRank
,	DENSE_RANK() OVER(ORDER BY SalesYear, SalesPeriod) AS SalesPeriodNumRank
,	DENSE_RANK() OVER(ORDER BY SalesYear, SalesQuarter) AS SalesQuarterNumRank
,	ROW_NUMBER() OVER(PARTITION BY SalesYear, SalesQuarter ORDER BY SalesDayInYear) SalesDayInQuarter
,	ROW_NUMBER() OVER(PARTITION BY SalesYear, SalesQuarter, SalesPeriod ORDER BY SalesDayInYear) SalesDayInPeriod
FROM dbo.vw_dim_date
)

-- Data for Today
, Today AS
(SELECT
	T.SalesYear AS CurrentSalesYear
,	T.SalesQuarter AS CurrentSalesQuarter
,	T.SalesPeriod AS CurrentSalesPeriod
,	T.SalesWeek AS CurrentSalesWeek
,	T.SalesDayInYear AS CurrentSalesDayInYear
,	W.SalesWeekNumRank AS CurrentSalesWeekNumRank
,	W.SalesQuarterNumRank AS CurrentSalesQuarterNumRank
,	W.SalesPeriodNumRank AS CurrentSalesPeriodNumRank
,	W.SalesDayInQuarter AS CurrentSalesDayInQuarter
,	W.SalesDayInPeriod AS CurrentSalesDayInPeriod
FROM dbo.vw_dim_date		T
INNER JOIN RelativePeriods	W	ON T.date_id = W.date_id
WHERE DateTimeFormat = CAST(GETDATE() AS DATE)
)

SELECT D.*
, N'Current Period' AS PeriodID

-- SALES YEAR CALCULATIONS
, D.SalesYear - T.CurrentSalesYear AS SalesRelativeYearNumber
, CASE
		WHEN (D.SalesYear - T.CurrentSalesYear) = 0 THEN 'Current Year'
		WHEN (D.SalesYear - T.CurrentSalesYear) > 0 THEN CAST((D.SalesYear - T.CurrentSalesYear) AS VARCHAR) + ' Years From Now'
		ELSE CAST(ABS(D.SalesYear - T.CurrentSalesYear) AS VARCHAR) + ' Years Ago'
	END AS SalesRelativeYearLabel
, CASE WHEN D.SalesDayInYear <= T.CurrentSalesDayInYear THEN 'Yes' ELSE 'No' END AS IsParallelSalesYTDByDay

-- SALES QUARTER CALCULATIONS
, CAST(D.SalesYear AS VARCHAR) + ' Q' + CAST(D.SalesQuarter AS VARCHAR) AS SalesQuarterOfYearLabel
, 'Q' + CAST(D.SalesQuarter AS VARCHAR) AS SalesQuarterLabel
, W.SalesQuarterNumRank - T.CurrentSalesQuarterNumRank AS SalesRelativeQuarterNumber
,	CASE
		WHEN W.SalesQuarterNumRank - T.CurrentSalesQuarterNumRank = 0 THEN 'Current Quarter '
		WHEN W.SalesQuarterNumRank - T.CurrentSalesQuarterNumRank > 0
			THEN CAST((W.SalesQuarterNumRank - T.CurrentSalesQuarterNumRank) AS VARCHAR) + ' Quarters From Now'
		ELSE CAST(ABS(W.SalesQuarterNumRank - T.CurrentSalesQuarterNumRank) AS VARCHAR) + ' Quarters Ago'
	END AS SalesRelativeQuarterLabel
, CASE WHEN W.SalesDayInQuarter <= T.CurrentSalesDayInQuarter AND D.SalesQuarter = T.CurrentSalesQuarter THEN 'Yes' ELSE 'No' END AS IsParallelSalesQTDSameQuarterByDay
, CASE WHEN W.SalesDayInQuarter <= T.CurrentSalesDayInQuarter THEN 'Yes' ELSE 'No' END AS IsParallelSalesQTDAnyQuarterByDay

-- SALES PERIOD CALCULATIONS
, CAST(D.SalesYear AS VARCHAR) + ' P' + CASE WHEN D.SalesPeriod < 10 THEN '0' ELSE '' END + CAST(D.SalesPeriod AS VARCHAR) AS SalesPeriodOfYearLabel
, 'P' + CASE WHEN D.SalesPeriod < 10 THEN '0' ELSE '' END + CAST(D.SalesPeriod AS VARCHAR) AS SalesPeriodLabel
, W.SalesPeriodNumRank - T.CurrentSalesPeriodNumRank AS SalesRelativePeriodNumber
,	CASE
		WHEN W.SalesPeriodNumRank - T.CurrentSalesPeriodNumRank = 0	THEN 'Current Period'
		WHEN W.SalesPeriodNumRank - T.CurrentSalesPeriodNumRank > 0
			THEN CAST((W.SalesPeriodNumRank - T.CurrentSalesPeriodNumRank) AS VARCHAR) + ' Months From Now'
		ELSE CAST(ABS(W.SalesPeriodNumRank - T.CurrentSalesPeriodNumRank) AS VARCHAR) + ' Months Ago'
	END AS SalesRelativePeriodLabel
, CASE WHEN W.SalesDayInPeriod <= T.CurrentSalesDayInPeriod AND D.SalesPeriod = T.CurrentSalesPeriod THEN 'Yes' ELSE 'No' END AS IsParallelSalesPTDSamePeriodByDay
, CASE WHEN W.SalesDayInPeriod <= T.CurrentSalesDayInPeriod THEN 'Yes' ELSE 'No' END AS IsParallelSalesPTDAnyPeriodByDay

-- SALES WEEK CALCULATIONS
, FIRST_VALUE(D.DateTimeFormat) OVER (PARTITION BY D.SalesYear, D.SalesWeek ORDER BY D.DateTimeFormat DESC) AS SalesWeekEndDate
, CAST(D.SalesYear AS VARCHAR) + ' W' + CASE WHEN D.SalesWeek < 10 THEN '0' ELSE '' END + CAST(D.SalesWeek AS VARCHAR) AS SalesWeekOfYearLabel
, 'W' + CASE WHEN D.SalesWeek < 10 THEN '0' ELSE '' END + CAST(D.SalesWeek AS VARCHAR) AS SalesWeekLabel
, W.SalesWeekNumRank - T.CurrentSalesWeekNumRank AS SalesRelativeWeekNumber
,	CASE
		WHEN W.SalesWeekNumRank - T.CurrentSalesWeekNumRank = 0 THEN 'Current Week'
		WHEN W.SalesWeekNumRank - T.CurrentSalesWeekNumRank > 0
			THEN CAST((W.SalesWeekNumRank - T.CurrentSalesWeekNumRank) AS VARCHAR) + ' Weeks From Now'
		ELSE CAST(ABS(W.SalesWeekNumRank - T.CurrentSalesWeekNumRank) AS VARCHAR) + ' Weeks Ago'
	END AS SalesRelativeWeekLabel

-- CURRENT SALES WEEK DATA
,	T.CurrentSalesYear
,	T.CurrentSalesQuarter
,	T.CurrentSalesPeriod
,	T.CurrentSalesWeek
,	T.CurrentSalesDayInYear
,	T.CurrentSalesDayInQuarter
,	T.CurrentSalesDayInPeriod

FROM
			dbo.vw_dim_date	D
INNER JOIN	RelativePeriods	W	ON	D.date_id = W.date_id
CROSS JOIN	Today			T
GO