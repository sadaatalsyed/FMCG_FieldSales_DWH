/****************************************************************************************
Object      : dbo.New_Stock
Layer       : Fact (snapshot fact — 1 row per Distribution + Product + BatchCode + Date)
Purpose     : Daily distributor warehouse stock snapshot. Opening/Closing stock DAX
              measures (see ssas/dax-measures.md) derive "opening" as the closing
              balance of the previous available date via ALL('Dim_Date') + MAX/MIN
              date pattern — this table itself only stores the point-in-time snapshot,
              not pre-computed opening/closing values.
Source      : InventorySnapshot + Product (OLTP), loaded daily (SnapShotDate >= today-1)
****************************************************************************************/
USE [SalesAssistDWH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[New_Stock](
	[CompanyName]    [varchar](3)     NULL,
	[DistributionID] [int]            NULL,
	[BatchCode]      [nvarchar](50)   NULL,
	[StockType]      [nvarchar](max)  NULL,
	[TotalPieces]    [int]            NULL,
	[HoldPieces]     [int]            NULL,
	[DateKey]        [nvarchar](4000) NULL,
	[ProductKey]     [int]            NULL,
	[DistributionKey][int]            NULL,
	[Cases]          [int]            NULL,
	[TotalKGs]       [decimal](18,10) NULL,
	[TotalTons]      [decimal](18,10) NULL,
	[Pieces]         [int]            NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
