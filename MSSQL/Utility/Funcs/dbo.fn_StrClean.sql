IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_StrClean]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_StrClean]
GO


CREATE Function [dbo].[fn_StrClean](@p_str1 VARCHAR(MAX)) 
RETURNS VARCHAR(MAX) as 
BEGIN 
 DECLARE @ret_value VARCHAR(MAX)
 SET @ret_value = @p_str1
 SET @ret_value = REPLACE(@ret_value, '.', '')
 SET @ret_value = REPLACE(@ret_value, ',', '') 
 SET @ret_value = REPLACE(@ret_value, '-', '') 
 SET @ret_value = REPLACE(@ret_value, ';', '') 
 SET @ret_value = REPLACE(@ret_value, ':', '') 
 
 RETURN @ret_value
END
GO

