IF OBJECT_ID(N'dbo.StringToProperCase', N'FN') IS NOT NULL
  DROP FUNCTION dbo.StringToProperCase
GO

CREATE FUNCTION dbo.StringToProperCase(@String VARCHAR(255)) RETURNS VARCHAR(255)
AS
BEGIN
    SET @String = LTRIM(RTRIM(@String))

    DECLARE @Index INT                      -- index
    DECLARE @StringLength INT               -- input length
    DECLARE @CurrentChar NCHAR(1)           -- current char
    DECLARE @FirstLetterFlag INT            -- first letter flag (1/0)
    DECLARE @Output VARCHAR(255) = ''       -- output string, defaulted to an empty string
    DECLARE @WhiteSpaceChars VARCHAR(10)    -- characters considered as white space

    -- CHAR(13) = CR = Carriage Return
    -- CHAR(10) = LF = Line Feed
    -- CHAR(9)  = Tab
    -- CHAR(160) = Non Breaking Space

    SET @WhiteSpaceChars = '[' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(160) + ' ' + ']'
    SET @Index = 1
    SET @StringLength = LEN(@String)
    SET @FirstLetterFlag = 1
    SET @Index = ''

    WHILE @Index <= @StringLength
    BEGIN
        -- Set Current Charcter to the next charater in the input string
        SET @CurrentChar = SUBSTRING(@String, @Index, 1)

        -- If the previous
        IF @FirstLetterFlag = 1 
        BEGIN
            -- Convert this character to UPPER
            SET @Output = @Output + UPPER(@CurrentChar)
            -- Clear first letter flag as we have just handled it
            SET @FirstLetterFlag = 0
        END
        ELSE
            -- Convert this character to LOWER
            SET @Output = @Output + LOWER(@CurrentChar)
    
        -- If this character is whitespace, then next character is beginning of token
        IF @CurrentChar LIKE @WhiteSpaceChars
            SET @FirstLetterFlag = 1

        SET @Index = @Index + 1
    END

    RETURN @Output
END
GO