SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXAMPLE USE
--SELECT S.*, G.api_id
--FROM
--			dbo.GOOGLE_API	G
--CROSS APPLY	dbo.fnSplit(G.api_id, G.api_dimensions, ',') S
--GROUP BY
--	S.[key]


IF EXISTS (SELECT * FROM sys.objects JOIN sys.schemas ON sys.objects.schema_id = sys.schemas.schema_id
			WHERE sys.schemas.name = N'dbo'
			AND	sys.objects.name = N'tfn_StringSplit'
			AND sys.objects.type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.tfn_StringSplit
GO

CREATE FUNCTION [dbo].[tfn_StringSplit](
	@key INT
,	@sInputList VARCHAR(8000) -- List of delimited items
,	@sDelimiter VARCHAR(8000) = ',' -- delimiter that separates items
) RETURNS @List TABLE ([key] INT, item VARCHAR(8000), CardinalOrder INT)

BEGIN
	DECLARE @sItem VARCHAR(8000)
	DECLARE @CardinalOrder INT
	SET @CardinalOrder = 1

	WHILE CHARINDEX(@sDelimiter,@sInputList,0) <> 0
	BEGIN
		SELECT
			@sItem=RTRIM(LTRIM(SUBSTRING(@sInputList,1,CHARINDEX(@sDelimiter,@sInputList,0)-1)))
		,	@sInputList=RTRIM(LTRIM(SUBSTRING(@sInputList,CHARINDEX(@sDelimiter,@sInputList,0)+LEN(@sDelimiter),LEN(@sInputList))))
 
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


