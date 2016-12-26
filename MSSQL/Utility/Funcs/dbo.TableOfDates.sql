IF OBJECT_ID (N'dbo.TableOfDates') IS NOT NULL
   DROP FUNCTION dbo.TableOfDates
GO


CREATE FUNCTION dbo.TableOfDates(
	@StartDate DATETIME
,	@EndDate DATETIME
)
RETURNS @DateTable TABLE(
	[Date] DATETIME NOT NULL)
BEGIN

	INSERT INTO @DateTable([Date])
	SELECT [Date]
	FROM dw.DimensionDate
	WHERE [Date] BETWEEN @StartDate AND @EndDate

	RETURN;
END
GO