IF OBJECT_ID(N'dbo.BOMONTH') IS NOT NULL
  DROP FUNCTION dbo.BOMONTH
GO


CREATE FUNCTION dbo.BOMONTH(@Date DATETIME)
RETURNS DATETIME
AS
BEGIN
	RETURN DATEFROMPARTS(YEAR(@Date), MONTH(@Date), 1)
END
GO

