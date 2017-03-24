-- This uses GROUP_CONCAT aggregate function
--	and can be found here http://groupconcat.codeplex.com/
--	if you cannot install this function, then you nee to figure out how
--	to get the distinct values into a comma separated list

-- The example code uses AdventureWorksDW2014

-- Step 1, get the distinct list of values that will become the columns
DECLARE @columns NVARCHAR(1000)
SELECT @columns = dbo.GROUP_CONCAT(DISTINCT QUOTENAME(ISNULL(ProductLine, 'Unknown')))
FROM dbo.DimProduct


-- Step 2, build the base table that is to be pivoted
IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp

SELECT S.ExtendedAmount, D.CalendarYear, P.ProductLine
INTO #temp
FROM
			dbo.FactInternetSales	S
INNER JOIN	dbo.DimDate				D	ON	S.OrderDateKey = D.DateKey
INNER JOIN	dbo.DimProduct			P	ON	S.ProductKey = P.ProductKey


-- Step 3, create the dynamic sql of the pivot
DECLARE @sql NVARCHAR(4000) = 
N'SELECT CalendarYear, ' + @columns + '
FROM #temp
PIVOT (SUM(ExtendedAmount) FOR ProductLine IN (' + @columns + ')) AS Pvt'


-- Step 4, run
EXEC(@sql)