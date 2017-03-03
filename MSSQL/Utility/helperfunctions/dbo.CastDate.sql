IF OBJECT_ID(N'dbo.CastDate', N'FN') IS NOT NULL
  DROP FUNCTION dbo.CastDate
GO


CREATE FUNCTION [dbo].[CastDate](
	@ThisDate DATETIME
)
RETURNS DATE
AS
BEGIN
	RETURN CAST(@ThisDate AS DATE)
END
GO


