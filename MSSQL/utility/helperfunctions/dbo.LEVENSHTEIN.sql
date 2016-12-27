IF OBJECT_ID(N'dbo.LEVENSHTEIN') IS NOT NULL
  DROP FUNCTION dbo.LEVENSHTEIN
GO


CREATE FUNCTION [dbo].[LEVENSHTEIN]( @left varchar(100), @right varchar(100) ) 
   RETURNS INT
AS
BEGIN
   DECLARE @difference int, @lenRight int, @lenLeft int, @leftIndex int, @rightIndex int,   @left_char char(1), @right_char char(1), @compareLength int 
   SET @lenLeft = LEN(@left) 
   SET @lenRight = LEN(@right) 
   SET @difference = 0  
   If @lenLeft = 0 
   BEGIN
      SET @difference = @lenRight GOTO done 
   END
   IF @lenRight = 0 
   BEGIN
      SET @difference = @lenLeft 
      GOTO done 
   END 
   GOTO comparison  
 
   comparison: 
   IF (@lenLeft >= @lenRight) 
      SET @compareLength = @lenLeft 
   ELSE
      SET @compareLength = @lenRight  
   SET @rightIndex = 1 
   SET @leftIndex = 1 
   WHILE @leftIndex <= @compareLength 
   BEGIN
      SET @left_char = substring(@left, @leftIndex, 1)
      SET @right_char = substring(@right, @rightIndex, 1)
      IF @left_char <> @right_char 
      BEGIN -- Would an insertion make them re-align? 
         IF(@left_char = substring(@right, @rightIndex+1, 1))    
            SET @rightIndex = @rightIndex + 1 
         -- Would an deletion make them re-align? 
         ELSE
            IF(substring(@left, @leftIndex+1, 1) = @right_char)
               SET @leftIndex = @leftIndex + 1
               SET @difference = @difference + 1 
      END
      SET @leftIndex = @leftIndex + 1 
      SET @rightIndex = @rightIndex + 1 
   END 
   GOTO done  
 
   DONE: 
      RETURN @difference 
END
GO