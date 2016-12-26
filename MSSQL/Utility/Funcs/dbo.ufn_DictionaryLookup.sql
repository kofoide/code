-- USAGE
--	SELECT dbo.ufn_DictionaryLookup('All', 'SMDBUserId')


IF EXISTS (SELECT * FROM sys.objects JOIN sys.schemas ON sys.objects.schema_id = sys.schemas.schema_id
			WHERE sys.schemas.name = N'dbo'
			AND	sys.objects.name = N'ufn_DictionaryLookup'
			AND sys.objects.type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.ufn_DictionaryLookup
GO


CREATE FUNCTION dbo.ufn_DictionaryLookup(
	@ProcessName VARCHAR(50)
,	@Key VARCHAR(50)
)
RETURNS VARCHAR(255)
AS
BEGIN
	DECLARE @ReturnVal VARCHAR(255)
	SELECT @ReturnVal = Value FROM Utility.dbo.Dictionary WHERE ProcessName = @ProcessName AND [Key] = @Key

	RETURN @ReturnVal
END
GO