IF OBJECT_ID(N'dbo.StringClean', N'FN') IS NOT NULL
  DROP FUNCTION dbo.StringClean
GO


CREATE FUNCTION dbo.StringClean(
	@MyString as varchar(Max)
)
RETURNS VARCHAR(MAX)
AS

BEGIN
    -- Change all funky characters to a space
    --NULL
    SET @MyString = REPLACE(@MyString,CHAR(0),'');
    --Horizontal Tab
    SET @MyString = REPLACE(@MyString,CHAR(9),' ');
    --Line Feed
    SET @MyString = REPLACE(@MyString,CHAR(10),' ');
    --Vertical Tab
    SET @MyString = REPLACE(@MyString,CHAR(11),' ');
    --Form Feed
    SET @MyString = REPLACE(@MyString,CHAR(12),' ');
    --Carriage Return
    SET @MyString = REPLACE(@MyString,CHAR(13),' ');
    --Column Break
    SET @MyString = REPLACE(@MyString,CHAR(14),' ');
    --Non-breaking space
    SET @MyString = REPLACE(@MyString,CHAR(160),'');

	SET @MyString = REPLACE(@MyString, '~', ' ')
   	SET @MyString = REPLACE(@MyString, '`', ' ')
	SET @MyString = REPLACE(@MyString, '!', ' ')
	SET @MyString = REPLACE(@MyString, '@', ' ')
	SET @MyString = REPLACE(@MyString, '#', ' ')
	SET @MyString = REPLACE(@MyString, '$', ' ')
	SET @MyString = REPLACE(@MyString, '%', ' ')
	SET @MyString = REPLACE(@MyString, '^', ' ')
	SET @MyString = REPLACE(@MyString, '&', ' ')
	SET @MyString = REPLACE(@MyString, '(', ' ')
	SET @MyString = REPLACE(@MyString, ')', ' ')
    SET @MyString = REPLACE(@MyString, '_', ' ')
	SET @MyString = REPLACE(@MyString, '-', ' ')
	SET @MyString = REPLACE(@MyString, '+', ' ')
	SET @MyString = REPLACE(@MyString, '=', ' ')
	SET @MyString = REPLACE(@MyString, '[', ' ')
	SET @MyString = REPLACE(@MyString, ']', ' ')
	SET @MyString = REPLACE(@MyString, '{', ' ')
	SET @MyString = REPLACE(@MyString, '}', ' ')
	SET @MyString = REPLACE(@MyString, '|', ' ')
	SET @MyString = REPLACE(@MyString, '\', ' ')
	SET @MyString = REPLACE(@MyString, ':', ' ')
	SET @MyString = REPLACE(@MyString, ';', ' ')
	SET @MyString = REPLACE(@MyString, '"', ' ')
	SET @MyString = REPLACE(@MyString, '''', ' ')
	SET @MyString = REPLACE(@MyString, '<', ' ')
	SET @MyString = REPLACE(@MyString, '>', ' ')
	SET @MyString = REPLACE(@MyString, ',', ' ')
	SET @MyString = REPLACE(@MyString, '.', ' ')
	SET @MyString = REPLACE(@MyString, '?', ' ')
	SET @MyString = REPLACE(@MyString, '/', ' ')

    -- Reduce multiple spaces to a single space
    IF CHARINDEX('  ', @MyString) > 0
    BEGIN
        SET @MyString = REPLACE(LTRIM(RTRIM(@MyString)), '  ', ' ' + CHAR(7))   --Changes 2 spaces to the OX model
        SET @MyString = REPLACE(@MyString, CHAR(7) + ' ', '')                   --Changes the XO model to nothing
        SET @MyString = REPLACE(@MyString, CHAR(7), '')                         --Changes the remaining X's to nothing
    END

    RETURN @MyString
END
GO
