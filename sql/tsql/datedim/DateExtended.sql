IF OBJECT_ID(N'dbo.DateExtended', N'V') IS NOT NULL
  DROP VIEW dbo.DateExtended
GO


CREATE VIEW [dbo].[DateExtended]
AS

SELECT
	D.[Date]

-- PRODUCTION CALENDAR
,	D.ProductionYearNumber
,	'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) AS ProductionYearUniqueName

-- D.Production Quarter
,	D.ProductionQuarterOfYearNumber
,	ProductionQuarterOfYearName =
	CASE
		WHEN D.ProductionQuarterOfYearNumber = 1 THEN 'First Quarter'
		WHEN D.ProductionQuarterOfYearNumber = 2 THEN 'Second Quarter'
		WHEN D.ProductionQuarterOfYearNumber = 3 THEN 'Third Quarter'
		WHEN D.ProductionQuarterOfYearNumber = 4 THEN 'Fourth Quarter'
	END
,	ProductionQuarterOfYearUniqueName = 
	CASE
		WHEN D.ProductionQuarterOfYearNumber = 1 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Q 1'
		WHEN D.ProductionQuarterOfYearNumber = 2 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Q 2'
		WHEN D.ProductionQuarterOfYearNumber = 3 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Q 3'
		WHEN D.ProductionQuarterOfYearNumber = 4 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Q 4'
	END

-- D.Production Month
,	D.ProductionMonthOfYearNumber
,	ProductionMonthOfYearName =
	CASE
		WHEN D.ProductionMonthOfYearNumber = 1 THEN 'January'
		WHEN D.ProductionMonthOfYearNumber = 2 THEN 'February'
		WHEN D.ProductionMonthOfYearNumber = 3 THEN 'March'
		WHEN D.ProductionMonthOfYearNumber = 4 THEN 'April'
		WHEN D.ProductionMonthOfYearNumber = 5 THEN 'May'
		WHEN D.ProductionMonthOfYearNumber = 6 THEN 'June'
		WHEN D.ProductionMonthOfYearNumber = 7 THEN 'July'
		WHEN D.ProductionMonthOfYearNumber = 8 THEN 'August'
		WHEN D.ProductionMonthOfYearNumber = 9 THEN 'September'
		WHEN D.ProductionMonthOfYearNumber = 10 THEN 'October'
		WHEN D.ProductionMonthOfYearNumber = 11 THEN 'November'
		WHEN D.ProductionMonthOfYearNumber = 12 THEN 'December'
	END
,	ProductionMonthOfYearUniqueName = 
	CASE
		WHEN D.ProductionMonthOfYearNumber = 1 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Jan'
		WHEN D.ProductionMonthOfYearNumber = 2 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Feb'
		WHEN D.ProductionMonthOfYearNumber = 3 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Mar'
		WHEN D.ProductionMonthOfYearNumber = 4 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Apr'
		WHEN D.ProductionMonthOfYearNumber = 5 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' May'
		WHEN D.ProductionMonthOfYearNumber = 6 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Jun'
		WHEN D.ProductionMonthOfYearNumber = 7 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Jul'
		WHEN D.ProductionMonthOfYearNumber = 8 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Aug'
		WHEN D.ProductionMonthOfYearNumber = 9 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Sep'
		WHEN D.ProductionMonthOfYearNumber = 10 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Oct'
		WHEN D.ProductionMonthOfYearNumber = 11 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Nov'
		WHEN D.ProductionMonthOfYearNumber = 12 THEN 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Dec'
	END
		
,	D.ProductionWeekOfYearNumber
,	ProductionWeekOfYearName = 'Week ' + CASE WHEN LEN(CAST(D.ProductionWeekOfYearNumber AS VARCHAR)) = 1 THEN '0' ELSE '' END + CAST(D.ProductionWeekOfYearNumber AS VARCHAR)
,	ProductionWeekOfYearUniqueName = 'FY ' + CAST(D.ProductionYearNumber AS VARCHAR) + ' Week ' + CASE WHEN LEN(CAST(D.ProductionWeekOfYearNumber AS VARCHAR)) = 1 THEN '0' ELSE '' END + CAST(D.ProductionWeekOfYearNumber AS VARCHAR)

,	D.ProductionWeekOfMonthNumber
,	D.ProductionDayOfYearNumber
,	D.ProductionDayOfQuarterNumber
,	D.ProductionDayOfMonthNumber
,	D.ProductionDayOfWeekNumber

,	ProductionYearBeginDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber ORDER BY D.[Date] ASC)
,	ProductionYearEndDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber ORDER BY D.[Date] DESC)
,	ProductionQuarterBeginDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber ORDER BY D.[Date] ASC)
,	ProductionQuarterEndDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber ORDER BY D.[Date] DESC)
,	ProductionMonthBeginDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber, D.ProductionMonthOfYearNumber ORDER BY D.[Date] ASC)
,	ProductionMonthEndDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber, D.ProductionMonthOfYearNumber ORDER BY D.[Date] DESC)
,	ProductionWeekBeginDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber, D.ProductionMonthOfYearNumber, D.ProductionWeekOfYearNumber ORDER BY D.[Date] ASC)
,	ProductionWeekEndDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber, D.ProductionMonthOfYearNumber, D.ProductionWeekOfYearNumber ORDER BY D.[Date] DESC)
,	ProductionWeekBeginDateAsNumber = YEAR(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber, D.ProductionMonthOfYearNumber, D.ProductionWeekOfYearNumber ORDER BY D.[Date] ASC)) * 10000 + MONTH(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber, D.ProductionMonthOfYearNumber, D.ProductionWeekOfYearNumber ORDER BY D.[Date] ASC)) * 100 + DAY(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber, D.ProductionMonthOfYearNumber, D.ProductionWeekOfYearNumber ORDER BY D.[Date] ASC))
,	ProductionWeekEndDateAsNumber = YEAR(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber, D.ProductionMonthOfYearNumber, D.ProductionWeekOfYearNumber ORDER BY D.[Date] DESC)) * 10000 + MONTH(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber, D.ProductionMonthOfYearNumber, D.ProductionWeekOfYearNumber ORDER BY D.[Date] DESC)) * 100 + DAY(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.ProductionYearNumber, D.ProductionQuarterOfYearNumber, D.ProductionMonthOfYearNumber, D.ProductionWeekOfYearNumber ORDER BY D.[Date] DESC))

-- PRODUCTION CALENDAR CALCULATIONS
-- Production Relative Years
,	D.ProductionYearNumber - T.ProductionYearNumber AS ProductionRelativeYearNumber
,	CASE
		WHEN (D.ProductionYearNumber - T.ProductionYearNumber) = 0 THEN 'Now'
		WHEN (D.ProductionYearNumber - T.ProductionYearNumber) > 0 THEN CAST((D.ProductionYearNumber - T.ProductionYearNumber) AS VARCHAR) + ' Years From Now'
		ELSE CAST(ABS(D.ProductionYearNumber - T.ProductionYearNumber) AS VARCHAR) + ' Years Ago'
	END AS ProductionRelativeYearName
,	CAST('1/1/' + CAST(D.ProductionYearNumber AS VARCHAR) AS DATE) AS ProductionYearBeginDateAsCalendarDate

-- Production Relative Quarters
,	D.ProductionQuarterOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 4) - T.ProductionQuarterOfYearNumber AS ProductionRelativeQuarterNumber
,	CASE
		WHEN D.ProductionQuarterOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 4) - T.ProductionQuarterOfYearNumber = 0
			THEN 'Now'
		WHEN D.ProductionQuarterOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 4) - T.ProductionQuarterOfYearNumber > 0
			THEN CAST((D.ProductionQuarterOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 4) - T.ProductionQuarterOfYearNumber) AS VARCHAR) + ' Quarters From Now'
		ELSE CAST(ABS(D.ProductionQuarterOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 4) - T.ProductionQuarterOfYearNumber) AS VARCHAR) + ' Quarters Ago'
	END AS ProductionRelativeQuarterName
,	CASE
		WHEN D.ProductionQuarterOfYearNumber = 1 THEN CAST('1/1/' + CAST(D.ProductionYearNumber AS VARCHAR) AS DATE)
		WHEN D.ProductionQuarterOfYearNumber = 2 THEN CAST('4/1/' + CAST(D.ProductionYearNumber AS VARCHAR) AS DATE)
		WHEN D.ProductionQuarterOfYearNumber = 3 THEN CAST('7/1/' + CAST(D.ProductionYearNumber AS VARCHAR) AS DATE)
		WHEN D.ProductionQuarterOfYearNumber = 4 THEN CAST('10/1/' + CAST(D.ProductionYearNumber AS VARCHAR) AS DATE)
	END AS ProductionQuarterBeginDateAsCalendarDate

-- Production Relative Months
,	D.ProductionMonthOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 12) - T.ProductionMonthOfYearNumber AS ProductionRelativeMonthNumber
,	CASE
		WHEN D.ProductionMonthOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 12) - T.ProductionMonthOfYearNumber = 0
			THEN 'Now'
		WHEN D.ProductionMonthOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 12) - T.ProductionMonthOfYearNumber > 0
			THEN CAST((D.ProductionMonthOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 12) - T.ProductionMonthOfYearNumber) AS VARCHAR) + ' Months From Now'
		ELSE CAST(ABS(D.ProductionMonthOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 12) - T.ProductionMonthOfYearNumber) AS VARCHAR) + ' Months Ago'
	END AS ProductionRelativeMonthName
,	CAST(CAST(D.ProductionMonthOfYearNumber AS VARCHAR) + '/1/' + CAST(D.ProductionYearNumber AS VARCHAR) AS DATE) AS ProductionMonthBeginDateAsCalendarDate

-- Production Relative Weeks
,	D.ProductionWeekOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 52) - T.ProductionWeekOfYearNumber AS ProductionRelativeWeekNumber
,	CASE
		WHEN D.ProductionWeekOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 52) - T.ProductionWeekOfYearNumber = 0
			THEN 'Now'
		WHEN D.ProductionWeekOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 52) - T.ProductionWeekOfYearNumber > 0
			THEN CAST((D.ProductionWeekOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 52) - T.ProductionWeekOfYearNumber) AS VARCHAR) + ' Weeks From Now'
		ELSE CAST(ABS(D.ProductionWeekOfYearNumber + ((D.ProductionYearNumber - T.ProductionYearNumber) * 52) - T.ProductionWeekOfYearNumber) AS VARCHAR) + ' Weeks Ago'
	END AS ProductionRelativeWeekName

-- Production Relative Helpers
,	CASE WHEN D.ProductionWeekOfYearNumber <= T.ProductionWeekOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelProductionYTD
,	CASE WHEN D.ProductionWeekOfYearNumber <= T.ProductionWeekOfYearNumber AND D.ProductionQuarterOfYearNumber = T.ProductionQuarterOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelProductionQTD
,	CASE WHEN D.ProductionWeekOfYearNumber <= T.ProductionWeekOfYearNumber AND D.ProductionMonthOfYearNumber = T.ProductionMonthOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelProductionMTD
,	CASE WHEN D.ProductionWeekOfYearNumber = T.ProductionWeekOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelProductionWTD

,	CASE WHEN D.ProductionQuarterOfYearNumber = T.ProductionQuarterOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelProductionQuarterOfYear
,	CASE WHEN D.ProductionMonthOfYearNumber = T.ProductionMonthOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelProductionMonthOfYear
,	CASE WHEN D.ProductionWeekOfYearNumber = T.ProductionWeekOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelProductionWeekOfYear

-- Today's Production Numbers (Used to help in date math for front end tools)
,	T.ProductionYearNumber AS TodayProductionYearNumber
,	T.ProductionQuarterOfYearNumber AS TodayProductionQuarterOfYearNumber
,	T.ProductionMonthOfYearNumber AS TodayProductionMonthOfYearNumber
,	T.ProductionWeekOfYearNumber AS TodayProductionWeekOfYearNumber
,	T.ProductionDayOfYearNumber AS TodayProductionDayOfYearNumber



-- ACCOUNTING CALENDAR
,	D.AccountingYearNumber
,	'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) AS AccountingYearUniqueName

-- D.Accounting Quarter
,	D.AccountingQuarterOfYearNumber
,	AccountingQuarterOfYearName =
	CASE
		WHEN D.AccountingQuarterOfYearNumber = 1 THEN 'First Quarter'
		WHEN D.AccountingQuarterOfYearNumber = 2 THEN 'Second Quarter'
		WHEN D.AccountingQuarterOfYearNumber = 3 THEN 'Third Quarter'
		WHEN D.AccountingQuarterOfYearNumber = 4 THEN 'Fourth Quarter'
	END
,	AccountingQuarterOfYearUniqueName = 
	CASE
		WHEN D.AccountingQuarterOfYearNumber = 1 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Q 1'
		WHEN D.AccountingQuarterOfYearNumber = 2 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Q 2'
		WHEN D.AccountingQuarterOfYearNumber = 3 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Q 3'
		WHEN D.AccountingQuarterOfYearNumber = 4 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Q 4'
	END

-- D.Accounting Month
,	D.AccountingMonthOfYearNumber
,	AccountingMonthOfYearName =
	CASE
		WHEN D.AccountingMonthOfYearNumber = 1 THEN 'January'
		WHEN D.AccountingMonthOfYearNumber = 2 THEN 'February'
		WHEN D.AccountingMonthOfYearNumber = 3 THEN 'March'
		WHEN D.AccountingMonthOfYearNumber = 4 THEN 'April'
		WHEN D.AccountingMonthOfYearNumber = 5 THEN 'May'
		WHEN D.AccountingMonthOfYearNumber = 6 THEN 'June'
		WHEN D.AccountingMonthOfYearNumber = 7 THEN 'July'
		WHEN D.AccountingMonthOfYearNumber = 8 THEN 'August'
		WHEN D.AccountingMonthOfYearNumber = 9 THEN 'September'
		WHEN D.AccountingMonthOfYearNumber = 10 THEN 'October'
		WHEN D.AccountingMonthOfYearNumber = 11 THEN 'November'
		WHEN D.AccountingMonthOfYearNumber = 12 THEN 'December'
	END
,	AccountingMonthOfYearUniqueName = 
	CASE
		WHEN D.AccountingMonthOfYearNumber = 1 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Jan'
		WHEN D.AccountingMonthOfYearNumber = 2 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Feb'
		WHEN D.AccountingMonthOfYearNumber = 3 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Mar'
		WHEN D.AccountingMonthOfYearNumber = 4 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Apr'
		WHEN D.AccountingMonthOfYearNumber = 5 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' May'
		WHEN D.AccountingMonthOfYearNumber = 6 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Jun'
		WHEN D.AccountingMonthOfYearNumber = 7 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Jul'
		WHEN D.AccountingMonthOfYearNumber = 8 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Aug'
		WHEN D.AccountingMonthOfYearNumber = 9 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Sep'
		WHEN D.AccountingMonthOfYearNumber = 10 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Oct'
		WHEN D.AccountingMonthOfYearNumber = 11 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Nov'
		WHEN D.AccountingMonthOfYearNumber = 12 THEN 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Dec'
	END
		
,	D.AccountingWeekOfYearNumber
,	AccountingWeekOfYearName = 'Week ' + CASE WHEN LEN(CAST(D.AccountingWeekOfYearNumber AS VARCHAR)) = 1 THEN '0' ELSE '' END + CAST(D.AccountingWeekOfYearNumber AS VARCHAR)
,	AccountingWeekOfYearUniqueName = 'FY ' + CAST(D.AccountingYearNumber AS VARCHAR) + ' Week ' + CASE WHEN LEN(CAST(D.AccountingWeekOfYearNumber AS VARCHAR)) = 1 THEN '0' ELSE '' END + CAST(D.AccountingWeekOfYearNumber AS VARCHAR)

,	D.AccountingWeekOfMonthNumber
,	D.AccountingDayOfYearNumber
,	D.AccountingDayOfQuarterNumber
,	D.AccountingDayOfMonthNumber
,	D.AccountingDayOfWeekNumber

,	AccountingYearBeginDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber ORDER BY D.[Date] ASC)
,	AccountingYearEndDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber ORDER BY D.[Date] DESC)
,	AccountingQuarterBeginDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber ORDER BY D.[Date] ASC)
,	AccountingQuarterEndDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber ORDER BY D.[Date] DESC)
,	AccountingMonthBeginDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber, D.AccountingMonthOfYearNumber ORDER BY D.[Date] ASC)
,	AccountingMonthEndDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber, D.AccountingMonthOfYearNumber ORDER BY D.[Date] DESC)
,	AccountingWeekBeginDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber, D.AccountingMonthOfYearNumber, D.AccountingWeekOfYearNumber ORDER BY D.[Date] ASC)
,	AccountingWeekEndDate = FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber, D.AccountingMonthOfYearNumber, D.AccountingWeekOfYearNumber ORDER BY D.[Date] DESC)
,	AccountingWeekBeginDateAsNumber = YEAR(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber, D.AccountingMonthOfYearNumber, D.AccountingWeekOfYearNumber ORDER BY D.[Date] ASC)) * 10000 + MONTH(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber, D.AccountingMonthOfYearNumber, D.AccountingWeekOfYearNumber ORDER BY D.[Date] ASC)) * 100 + DAY(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber, D.AccountingMonthOfYearNumber, D.AccountingWeekOfYearNumber ORDER BY D.[Date] ASC))
,	AccountingWeekEndDateAsNumber = YEAR(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber, D.AccountingMonthOfYearNumber, D.AccountingWeekOfYearNumber ORDER BY D.[Date] DESC)) * 10000 + MONTH(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber, D.AccountingMonthOfYearNumber, D.AccountingWeekOfYearNumber ORDER BY D.[Date] DESC)) * 100 + DAY(FIRST_VALUE(D.[Date]) OVER(PARTITION BY D.AccountingYearNumber, D.AccountingQuarterOfYearNumber, D.AccountingMonthOfYearNumber, D.AccountingWeekOfYearNumber ORDER BY D.[Date] DESC))

-- ACCOUNTING CALENDAR CALCULATIONS
-- Accounting Relative Years
,	D.AccountingYearNumber - T.AccountingYearNumber AS AccountingRelativeYearNumber
,	CASE
		WHEN (D.AccountingYearNumber - T.AccountingYearNumber) = 0 THEN 'Now'
		WHEN (D.AccountingYearNumber - T.AccountingYearNumber) > 0 THEN CAST((D.AccountingYearNumber - T.AccountingYearNumber) AS VARCHAR) + ' Years From Now'
		ELSE CAST(ABS(D.AccountingYearNumber - T.AccountingYearNumber) AS VARCHAR) + ' Years Ago'
	END AS AccountingRelativeYearName
,	CAST('1/1/' + CAST(D.AccountingYearNumber AS VARCHAR) AS DATE) AS AccountingYearBeginDateAsCalendarDate

-- Accounting Relative Quarters
,	D.AccountingQuarterOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 4) - T.AccountingQuarterOfYearNumber AS AccountingRelativeQuarterNumber
,	CASE
		WHEN D.AccountingQuarterOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 4) - T.AccountingQuarterOfYearNumber = 0
			THEN 'Now'
		WHEN D.AccountingQuarterOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 4) - T.AccountingQuarterOfYearNumber > 0
			THEN CAST((D.AccountingQuarterOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 4) - T.AccountingQuarterOfYearNumber) AS VARCHAR) + ' Quarters From Now'
		ELSE CAST(ABS(D.AccountingQuarterOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 4) - T.AccountingQuarterOfYearNumber) AS VARCHAR) + ' Quarters Ago'
	END AS AccountingRelativeQuarterName
,	CASE
		WHEN D.AccountingQuarterOfYearNumber = 1 THEN CAST('1/1/' + CAST(D.AccountingYearNumber AS VARCHAR) AS DATE)
		WHEN D.AccountingQuarterOfYearNumber = 2 THEN CAST('4/1/' + CAST(D.AccountingYearNumber AS VARCHAR) AS DATE)
		WHEN D.AccountingQuarterOfYearNumber = 3 THEN CAST('7/1/' + CAST(D.AccountingYearNumber AS VARCHAR) AS DATE)
		WHEN D.AccountingQuarterOfYearNumber = 4 THEN CAST('10/1/' + CAST(D.AccountingYearNumber AS VARCHAR) AS DATE)
	END AS AccountingQuarterBeginDateAsCalendarDate

-- Accounting Relative Months
,	D.AccountingMonthOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 12) - T.AccountingMonthOfYearNumber AS AccountingRelativeMonthNumber
,	CASE
		WHEN D.AccountingMonthOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 12) - T.AccountingMonthOfYearNumber = 0
			THEN 'Now'
		WHEN D.AccountingMonthOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 12) - T.AccountingMonthOfYearNumber > 0
			THEN CAST((D.AccountingMonthOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 12) - T.AccountingMonthOfYearNumber) AS VARCHAR) + ' Months From Now'
		ELSE CAST(ABS(D.AccountingMonthOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 12) - T.AccountingMonthOfYearNumber) AS VARCHAR) + ' Months Ago'
	END AS AccountingRelativeMonthName
,	CAST(CAST(D.AccountingMonthOfYearNumber AS VARCHAR) + '/1/' + CAST(D.AccountingYearNumber AS VARCHAR) AS DATE) AS AccountingMonthBeginDateAsCalendarDate

-- Accounting Relative Weeks
,	D.AccountingWeekOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 52) - T.AccountingWeekOfYearNumber AS AccountingRelativeWeekNumber
,	CASE
		WHEN D.AccountingWeekOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 52) - T.AccountingWeekOfYearNumber = 0
			THEN 'Now'
		WHEN D.AccountingWeekOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 52) - T.AccountingWeekOfYearNumber > 0
			THEN CAST((D.AccountingWeekOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 52) - T.AccountingWeekOfYearNumber) AS VARCHAR) + ' Weeks From Now'
		ELSE CAST(ABS(D.AccountingWeekOfYearNumber + ((D.AccountingYearNumber - T.AccountingYearNumber) * 52) - T.AccountingWeekOfYearNumber) AS VARCHAR) + ' Weeks Ago'
	END AS AccountingRelativeWeekName


-- Accounting Relative Helpers
,	CASE WHEN D.AccountingWeekOfYearNumber <= T.AccountingWeekOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelAccountingYTD
,	CASE WHEN D.AccountingWeekOfYearNumber <= T.AccountingWeekOfYearNumber AND D.AccountingQuarterOfYearNumber = T.AccountingQuarterOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelAccountingQTD
,	CASE WHEN D.AccountingWeekOfYearNumber <= T.AccountingWeekOfYearNumber AND D.AccountingMonthOfYearNumber = T.AccountingMonthOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelAccountingMTD
,	CASE WHEN D.AccountingWeekOfYearNumber = T.AccountingWeekOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelAccountingWTD

,	CASE WHEN D.AccountingQuarterOfYearNumber = T.AccountingQuarterOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelAccountingQuarterOfYear
,	CASE WHEN D.AccountingMonthOfYearNumber = T.AccountingMonthOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelAccountingMonthOfYear
,	CASE WHEN D.AccountingWeekOfYearNumber = T.AccountingWeekOfYearNumber THEN 'Y' ELSE 'N' END AS IsParallelAccountingWeekOfYear


-- Today's Accounting Numbers (Used to help in date math for front end tools)
,	T.AccountingYearNumber AS TodayAccountingYearNumber
,	T.AccountingQuarterOfYearNumber AS TodayAccountingQuarterOfYearNumber
,	T.AccountingMonthOfYearNumber AS TodayAccountingMonthOfYearNumber
,	T.AccountingWeekOfYearNumber AS TodayAccountingWeekOfYearNumber
,	T.AccountingDayOfYearNumber AS TodayAccountingDayOfYearNumber


,	D.DateID - 19000000 AS AS400DateNumber

FROM
			dbo.DimDate	D
CROSS JOIN	(SELECT * FROM dbo.DimDate WHERE [Date] = CAST(GETDATE() AS DATE)) T
GO