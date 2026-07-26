/****************************************************************************************
Object      : dbo.Date
Layer       : Dimension
Purpose     : Standalone calendar dimension. Grain = 1 row per calendar date.
              DateKey format: ddMMyyyy (nvarchar) — matches DateKey generated in ETL
              extraction queries via FORMAT(<date_col>, 'ddMMyyyy').
Related to  : Every fact table via DateKey (Sales, Primary Orders, Stock, Route, etc.)
****************************************************************************************/
USE [SalesAssistDWH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Date](
	[DateKey]        [nvarchar](50)  NOT NULL,
	[Date]           [date]          NULL,
	[WeekNo]         [int]           NULL,
	[Day]            [int]           NULL,
	[Month]          [int]           NULL,
	[Year]           [int]           NULL,
	[SaleMonth]      [nvarchar](6)   NULL,
	[DateTargetKey]  [nvarchar](50)  NULL,
	[MonthName]      [varchar](20)   NULL,
	[MonthShortName] [varchar](3)    NULL,
	[QuarterName]    [varchar](2)    NULL,
	[DayName]        [varchar](20)   NULL,
	[IsWeekend]      [bit]           NULL,
	[WeekName]       [varchar](20)   NULL,
	[YearWeek]       [varchar](20)   NULL,
 CONSTRAINT [PK_Date] PRIMARY KEY CLUSTERED
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****************************************************************************************
Object      : dbo.DateTarget
Layer       : Dimension (month-grain lookup)
Purpose     : Month/Year grain lookup used to join monthly target facts
              (New_Targets, New_SalesTargets, PrimaryTargets) back to the calendar.
              DateTargetKey format: MMyyyy.
****************************************************************************************/
CREATE TABLE [dbo].[DateTarget](
	[Month]         [int]          NULL,
	[Year]          [int]          NULL,
	[SaleMonth]     [nvarchar](6)  NULL,
	[DateTargetKey] [nvarchar](50) NULL
) ON [PRIMARY]
GO
