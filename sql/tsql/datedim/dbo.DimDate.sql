IF OBJECT_ID(N'dbo.DimDate', N'U') IS NOT NULL
  DROP TABLE dbo.DimDate
GO


CREATE TABLE [dbo].[DimDate](
	[DateID] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[AccountingYearNumber] [int] NOT NULL,
	[AccountingQuarterOfYearNumber] [int] NOT NULL,
	[AccountingMonthOfYearNumber] [int] NOT NULL,
	[AccountingMonthOfQuarterNumber] [int] NOT NULL,
	[AccountingWeekOfYearNumber] [int] NOT NULL,
	[AccountingWeekOfMonthNumber] [int] NOT NULL,
	[AccountingDayOfYearNumber] [int] NOT NULL,
	[AccountingDayOfQuarterNumber] [int] NOT NULL,
	[AccountingDayOfMonthNumber] [int] NOT NULL,
	[AccountingDayOfWeekNumber] [int] NOT NULL,

 CONSTRAINT [PK_DimDate_Orig] PRIMARY KEY CLUSTERED 
(
	[DateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO



