/****************************************************************************************
Object      : dbo.New_PrimaryOrders
Layer       : Fact
Grain       : 1 row per Distribution + ManufacturerInvoiceDate + ProductID + BatchCode
Purpose     : Primary sales — stock movement from the principal/manufacturer into the
              distributor's warehouse. Type distinguishes 'Sales' (stock-in) from
              'Return' (stock-out, values stored pre-negated at -1 in the ETL union).
              Business rule for inclusion (see /sql/etl/Extract_PrimaryOrders.sql):
                (IsAutoDA = 1 AND StockStatus NOT IN ('Rejected','InTransit'))
                OR (IsAutoDA = 0 AND StockStatus = 'PO')
****************************************************************************************/
USE [SalesAssistDWH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[New_PrimaryOrders](
	[DistributionID]           [int]            NULL,
	[ManufacturerInvoiceDate]  [date]           NULL,
	[StockType]                [nvarchar](10)   NULL,
	[StockStatus]              [nvarchar](50)   NULL,
	[ManufacturerInvoiceNumber][nvarchar](30)   NULL,
	[InvoiceNumber]            [nvarchar](30)   NULL,
	[ProductID]                [int]            NULL,
	[Cases]                    [int]            NULL,
	[BatchCode]                [nvarchar](100)  NULL,
	[ExpiryDate]               [date]           NULL,
	[TotalKg]                  [numeric](38,7)  NULL,
	[TotalTons]                [numeric](38,11) NULL,
	[FMRRate]                  [numeric](18,4)  NULL,
	[FMRAmount]                [numeric](38,4)  NULL,
	[GSTRate]                  [numeric](18,4)  NULL,
	[GSTValue]                 [numeric](38,4)  NULL,
	[AdvanceTaxRate]           [numeric](18,4)  NULL,
	[AdvanceTaxValue]          [numeric](38,4)  NULL,
	[FurtherTaxRate]           [numeric](18,4)  NULL,
	[FurtherTaxValue]          [numeric](38,4)  NULL,
	[MRPRate]                  [numeric](18,4)  NULL,
	[MRPValue]                 [numeric](38,4)  NULL,
	[ConfectionaryTaxRate]     [numeric](18,4)  NULL,
	[ConfectionaryTaxValue]    [numeric](38,4)  NULL,
	[InvoicePriceCase]         [numeric](18,4)  NULL,
	[RetailPriceCase]          [numeric](18,4)  NULL,
	[ConsumerPriceCase]        [numeric](18,4)  NULL,
	[ValueWithoutTax]          [numeric](38,4)  NULL,
	[TotalTax]                 [numeric](38,4)  NULL,
	[TotalValueWithTax]        [numeric](38,4)  NULL,
	[NetAmount]                [numeric](38,4)  NULL,
	[TOAmount]                 [numeric](38,4)  NULL,
	[TOPercentageValue]        [numeric](38,4)  NULL,
	[Type]                     [varchar](6)     NULL,
	[DistributionKey]          [varchar](24)    NULL,
	[ProductKey]               [varchar](24)    NULL,
	[DateKey]                  [nvarchar](50)   NULL,
	[TotalPieces]              [int]            NULL,
	[CreatedOn]                [date]           NULL
) ON [PRIMARY]
GO

/****************************************************************************************
Object      : dbo.PrimaryTargets
Layer       : Fact (target/plan fact — month grain)
Purpose     : Monthly primary sales targets per Distribution + Product, pre-computed
              with per-day breakdown columns (PerDayTarget...) so Power BI/SSAS do not
              need to re-derive day-count logic for the primary side (contrast with
              the DAX-side day-proration used for New_Targets/Targets on the secondary
              side — see ssas/dax-measures.md).
****************************************************************************************/
CREATE TABLE [dbo].[PrimaryTargets](
	[DistributionID]      [int]         NULL,
	[ProductID]           [int]         NULL,
	[MONTH]               [int]         NULL,
	[YEAR]                [int]         NULL,
	[TargetPieces]        [float]       NULL,
	[TargetCases]         [float]       NULL,
	[TargetKg]            [float]       NULL,
	[TargetValue]         [float]       NULL,
	[TargetTons]          [float]       NULL,
	[PerDayTarget(Tons)]  [float]       NULL,
	[PerDayTarget(KGs)]   [float]       NULL,
	[PerDayTarget(Pieces)][float]       NULL,
	[PerDayTarget(Cases)] [float]       NULL,
	[PerDayTarget(Value)] [float]       NULL,
	[DistributionKey]     [varchar](24) NULL,
	[ProductKey]          [varchar](24) NULL,
	[MonthYearKey]        [nvarchar](24)NULL,
	[DaysInMonth]         [int]         NULL
) ON [PRIMARY]
GO
