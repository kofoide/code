CREATE TABLE dbo.[Date] (
	ID INT NOT NULL IDENTITY
,	ThisDate DATE NOT NULL
,	JulianDate INT NOT NULL
,	CalendarYearNumber INT NOT NULL
,	CalendarQuarterOfYearNumber INT NOT NULL
,	CalendarMonthOfYearNumber INT NOT NULL
,	CalendarMonthOfQuarterNumber INT NOT NULL
,	CalendarWeekOfYearNumber INT NOT NULL
,	CalendarWeekOfQuarterNumber INT NOT NULL
,	CalendarWeekOfMonthNumber INT NOT NULL
,	CalendarDayOfYearNumber INT NOT NULL
,	CalendarDayOfQuarterNumber INT NOT NULL
,	CalendarDayOfMonthNumber INT NOT NULL
,	CalendarDayOfWeekNumber INT NOT NULL
,	CalendarMonthLabel VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
,	CommonDayOfWeekLabel VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
,	IsWeekend VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
,	IsCompanyHoliday VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
,	IsOfficeWorkday VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
,	CONSTRAINT PK_eric_DateDim PRIMARY KEY (ID)
)
