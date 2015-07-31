IF OBJECT_ID(N'dbo.DimDate', N'U') IS NOT NULL
  DROP TABLE dbo.DimDate
GO


CREATE TABLE [dbo].[DimDate](
	[ThisDate] [date] NOT NULL,

	[GregorianYear] [int] NOT NULL,
	[GregorianQuarterOfYear] [int] NOT NULL,
	[GregorianMonthOfYear] [int] NOT NULL,
	[GregorianMonthOfQuarter] [int] NOT NULL,
	[GregorianWeekOfYear] [int] NOT NULL,
	[GregorianWeekOfQuarter] [int] NOT NULL,
	[GregorianWeekOfMonth] [int] NOT NULL,
	[GregorianDayOfYear] [int] NOT NULL,
	[GregorianDayOfQuarter] [int] NOT NULL,
	[GregorianDayOfMonth] [int] NOT NULL,
	[GregorianDayOfWeek] [int] NOT NULL,

	[Calendar1Year] [int] NULL,
	[Calendar1QuarterOfYear] [int] NULL,
	[Calendar1MonthOfYear] [int] NULL,
	[Calendar1MonthOfQuarter] [int] NULL,
	[Calendar1WeekOfYear] [int] NULL,
	[Calendar1WeekOfQuarter] [int] NULL,
	[Calendar1WeekOfMonth] [int] NULL,
	[Calendar1DayOfYear] [int] NULL,
	[Calendar1DayOfQuarter] [int] NULL,
	[Calendar1DayOfMonth] [int] NULL,
	[Calendar1DayOfWeek] [int] NULL,

	[IsHoliday] [bit] NULL,
	[IsWeekend] [bit] NOT NULL,
 CONSTRAINT [PK_DimDate_1] PRIMARY KEY CLUSTERED 
(
	[ThisDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO




