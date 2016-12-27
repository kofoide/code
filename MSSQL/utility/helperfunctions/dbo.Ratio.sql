IF OBJECT_ID(N'dbo.Ratio') IS NOT NULL
  DROP FUNCTION dbo.Ratio
GO


CREATE FUNCTION dbo.Ratio(
	@Numerator DECIMAL(18, 5)
,	@Denominator DECIMAL(18, 5)
)
RETURNS DECIMAL(18, 5)
AS
BEGIN
	DECLARE @Retval DECIMAL(18, 5)

	IF ISNULL(@Denominator, 0) = 0
		SET @Retval = NULL
	ELSE
		SET @Retval = @Numerator / @Denominator

	RETURN @Retval
END