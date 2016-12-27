IF OBJECT_ID(N'dbo.GetNakedDomain', N'FN') IS NOT NULL
  DROP FUNCTION dbo.GetNakedDomain
GO

CREATE FUNCTION dbo.GetNakedDomain(
	@Source NVARCHAR(255)
,	@SourceType INT)
RETURNS NVARCHAR(255)
BEGIN
	DECLARE @retval NVARCHAR(255)
	
	-- Email
	IF (@SourceType = 1)
	BEGIN
		DECLARE @atIndex INT
		SET @atIndex = CHARINDEX('@', @Source)
		IF (@atIndex > 1)
			SET @retval = SUBSTRING(@Source, @atIndex + 1, LEN(@Source) - @atIndex)
		ELSE
			SET @retval = NULL
	END
	ELSE
	-- Website URL
	BEGIN
		SET @Source = REPLACE(@Source, 'http://', '')

		DECLARE @reverse NVARCHAR(255)
		SET @reverse = REVERSE(@Source)
		DECLARE @dotIndex INT
		SET @dotIndex = CHARINDEX('.', @reverse)
		IF (@dotIndex > 1)
		BEGIN
			DECLARE @dot2Index INT
			SET @dot2Index = CHARINDEX('.', @reverse, @dotIndex+1)
			IF (@dot2Index > 1)
			BEGIN
				SET @retval = SUBSTRING(@Source, LEN(@Source) - (@dot2Index - 2), LEN(@Source))
			END
			ELSE
				SET @retval = @Source
		END
		ELSE
			SET @retval = NULL

	END

	RETURN @retval
END