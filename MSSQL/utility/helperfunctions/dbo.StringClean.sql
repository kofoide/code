IF OBJECT_ID(N'dbo.StringClean', N'FN') IS NOT NULL
  DROP FUNCTION dbo.StringClean
GO


CREATE FUNCTION dbo.StringClean(
	@MyString as varchar(Max)
)
RETURNS VARCHAR(MAX)
AS

BEGIN
    --NULL
    SET @MyString = REPLACE(@MyString,CHAR(0),'');
    --Horizontal Tab
    SET @MyString = REPLACE(@MyString,CHAR(9),'');
    --Line Feed
    SET @MyString = REPLACE(@MyString,CHAR(10),'');
    --Vertical Tab
    SET @MyString = REPLACE(@MyString,CHAR(11),'');
    --Form Feed
    SET @MyString = REPLACE(@MyString,CHAR(12),'');
    --Carriage Return
    SET @MyString = REPLACE(@MyString,CHAR(13),'');
    --Column Break
    SET @MyString = REPLACE(@MyString,CHAR(14),'');
    --Non-breaking space
    SET @MyString = REPLACE(@MyString,CHAR(160),'');
    --space
    SET @MyString = REPLACE(@MyString,' ','');

	SET @MyString = LTRIM(RTRIM(@MyString));

	--@#$%^&()\|/?<>~'"
	SET @MyString = REPLACE(@MyString, '@', '')
	SET @MyString = REPLACE(@MyString, '#', '')
	SET @MyString = REPLACE(@MyString, '$', '')
	SET @MyString = REPLACE(@MyString, '%', '')
	SET @MyString = REPLACE(@MyString, '&', '')
	SET @MyString = REPLACE(@MyString, '^', '')
	SET @MyString = REPLACE(@MyString, '(', '')
	SET @MyString = REPLACE(@MyString, ')', '')
	SET @MyString = REPLACE(@MyString, '[', '')
	SET @MyString = REPLACE(@MyString, ']', '')
	SET @MyString = REPLACE(@MyString, '{', '')
	SET @MyString = REPLACE(@MyString, '}', '')
	SET @MyString = REPLACE(@MyString, '\', '')
	SET @MyString = REPLACE(@MyString, '|', '')
	SET @MyString = REPLACE(@MyString, ':', '')
	SET @MyString = REPLACE(@MyString, ';', '')
	SET @MyString = REPLACE(@MyString, ',', '')
	SET @MyString = REPLACE(@MyString, '.', '')
	SET @MyString = REPLACE(@MyString, '<', '')
	SET @MyString = REPLACE(@MyString, '>', '')
	SET @MyString = REPLACE(@MyString, '?', '')
	SET @MyString = REPLACE(@MyString, '/', '')
	SET @MyString = REPLACE(@MyString, '"', '')
	SET @MyString = REPLACE(@MyString, '''', '')
	SET @MyString = REPLACE(@MyString, '-', '')

    
    RETURN @MyString
END
GO