-- Split a string of tokens into individual tokens
--  If the first character is the split character
--  assume the first token is NULL

IF OBJECT_ID(N'dbo.StringSplit', N'TF') IS NOT NULL
  DROP FUNCTION dbo.StringSplit
GO

CREATE FUNCTION dbo.StringSplit(
	@key UNIQUEIDENTIFIER
,	@sInputList VARCHAR(8000) -- List of delimited items
,	@sDelimiter VARCHAR(8000) = ',' -- delimiter that separates items
)
RETURNS
    @List TABLE
    (
        [key] UNIQUEIDENTIFIER
    ,   item VARCHAR(8000)
    ,   CardinalOrder INT
    )

BEGIN
	DECLARE @sItem VARCHAR(8000)
	DECLARE @CardinalOrder INT
	SET @CardinalOrder = 1

    -- Check if the first value is NULL
    IF LEFT(@sInputList, 1) = @sDelimiter
    BEGIN
        INSERT INTO @List SELECT @key, NULL, @CardinalOrder
        SET @CardinalOrder = @CardinalOrder + 1
    END

	WHILE CHARINDEX(@sDelimiter, @sInputList, 0) <> 0
	BEGIN
		SELECT
			@sItem = RTRIM(LTRIM(SUBSTRING(@sInputList, 1, CHARINDEX(@sDelimiter, @sInputList, 0) - 1)))
		,	@sInputList = RTRIM(LTRIM(SUBSTRING(@sInputList, CHARINDEX(@sDelimiter, @sInputList, 0) + LEN(@sDelimiter), LEN(@sInputList))))
 
		IF LEN(@sItem) > 0
		BEGIN
			INSERT INTO @List SELECT @key, @sItem, @CardinalOrder
			SET @CardinalOrder = @CardinalOrder + 1
		END
	END

	IF LEN(@sInputList) > 0
		INSERT INTO @List SELECT @key, @sInputList, @CardinalOrder -- Put the last item in

	RETURN
END
GO