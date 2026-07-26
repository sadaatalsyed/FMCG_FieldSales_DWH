/****************************************************************************************
Object      : dbo.New_Targets
Layer       : Fact (target/plan fact — month grain)
Grain       : 1 row per Distribution + OrderBooker + Product + Month + Year
Purpose     : Monthly secondary-sales target per Order Booker/Product. Day-level
              proration (e.g. "how much target for the days selected in the current
              filter") is handled in DAX at query time (see Target Tons / TargetTonsK
              / Target TonsL measures in ssas/dax-measures.md) rather than pre-computed
              here, unlike PrimaryTargets which stores PerDayTarget columns directly.
Source      : OrderBookerTargets + Product + ProductDetail (OLTP)
****************************************************************************************/
USE [SalesAssistDWH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[New_Targets](
	[DistributionID] [int]         NULL,
	[ProductID]      [int]         NULL,
	[OrderBookerID]  [int]         NULL,
	[MONTH]          [int]         NULL,
	[YEAR]           [int]         NULL,
	[TargetPieces]   [float]       NULL,
	[TargetCases]    [float]       NULL,
	[TargetKg]       [float]       NULL,
	[DistributionKey][varchar](24) NULL,
	[OrderBookerKey] [varchar](24) NULL,
	[ProductKey]     [varchar](24) NULL,
	[DateTargetKey]  [nvarchar](8) NULL,
	[TargetValue]    [float]       NULL,
	[TargetTons]     [float]       NULL,
	[TargetInvoice]  [float]       NULL
) ON [PRIMARY]
GO

/****************************************************************************************
Object      : dbo.New_SalesTargets
Layer       : Fact (month-grain target/plan — Distribution level, product-agnostic
              variant used for distribution-wide targets rather than OB-wide targets)
Purpose     : Distribution-level monthly target, structurally mirrors the
              SalesDataDump column set (FMR/GST/AdvanceTax/etc. target components)
              so target-vs-actual comparisons at the same tax/discount granularity
              are possible without extra mapping in DAX.
Source      : DistributionTargets + Product (OLTP)
****************************************************************************************/
CREATE TABLE [dbo].[New_SalesTargets](
	[Company]              [varchar](3)     NULL,
	[DistributionID]       [int]            NULL,
	[Status]               [nvarchar](10)   NULL,
	[OrderBookerID]        [int]            NULL,
	[ProductID]            [int]            NULL,
	[TotalPiecesOrdered]   [int]            NULL,
	[TotalPiecesDelivered] [int]            NULL,
	[FMRRate]              [numeric](18,4)  NULL,
	[FMRAmount]            [numeric](18,4)  NULL,
	[GSTRate]              [numeric](18,4)  NULL,
	[GSTValue]             [numeric](18,4)  NULL,
	[AdvanceTaxRate]       [numeric](18,4)  NULL,
	[AdvanceTaxValue]      [numeric](18,4)  NULL,
	[FurtherTaxRate]       [numeric](18,4)  NULL,
	[FurtherTaxValue]      [numeric](18,4)  NULL,
	[MRPRate]              [numeric](18,4)  NULL,
	[MRPValue]             [numeric](18,4)  NULL,
	[ConfectionaryTaxRate] [numeric](18,4)  NULL,
	[ConfectionaryTaxValue][numeric](18,4)  NULL,
	[InvoicePriceCase]     [numeric](18,4)  NULL,
	[RetailPriceCase]      [numeric](18,4)  NULL,
	[ConsumerPriceCase]    [numeric](18,4)  NULL,
	[ValueWithoutTax]      [numeric](18,4)  NULL,
	[TotalTax]             [numeric](18,4)  NULL,
	[TotalValueWithTax]    [numeric](18,4)  NULL,
	[NetAmount]            [numeric](18,4)  NULL,
	[ToAmount]             [numeric](18,4)  NULL,
	[TOPercentageValue]    [numeric](18,4)  NULL,
	[TotalBillDiscount]    [numeric](18,4)  NULL,
	[OtherDiscount]        [numeric](18,4)  NULL,
	[FreeSKUQuantity]      [int]            NULL,
	[LMTRentals]           [numeric](18,4)  NULL,
	[WholesaleDiscounts]   [numeric](18,4)  NULL,
	[ZChampion]            [numeric](18,4)  NULL,
	[LMTOffInvoice]        [numeric](18,4)  NULL,
	[TO]                   [numeric](18,4)  NULL,
	[OCD]                  [numeric](18,4)  NULL,
	[TYPE]                 [varchar](10)    NULL,
	[DistributionKey]      [varchar](24)    NULL,
	[OrderBookerKey]       [varchar](24)    NULL,
	[ProductKey]           [varchar](24)    NULL,
	[DateTargetKey]        [nvarchar](8)    NULL,
	[LMT Off Invoice 2026] [numeric](18,4)  NULL,
	[Visibility Discount]  [numeric](18,4)  NULL,
	[Z-Cham Off-Invoice]   [numeric](18,4)  NULL,
	[Cases]                [int]            NULL,
	[TotalKg]              [numeric](18,10) NULL,
	[TotalTons]            [float]          NULL
) ON [PRIMARY]
GO

/****************************************************************************************
Object      : dbo.New_Productivity
Layer       : Fact (pre-aggregated daily rollup — month/day-target grain)
Purpose     : Pre-computed Scheduled vs Unique Planned/Visited/Productive counters
              per Distribution + Order Booker + DateTargetKey. Built to avoid
              re-running expensive DISTINCTCOUNT/REMOVEFILTERS logic (see
              AssignedShops + Unique/Scheduled Producitivy % measures) for every
              Power BI refresh — this table is the cached snapshot.
Source      : Derived — aggregated from AssignedShops (SSAS) + SalesDataDump
****************************************************************************************/
CREATE TABLE [dbo].[New_Productivity](
	[DateTargetKey]     [nvarchar](50) NULL,
	[DistributionKey]   [varchar](24)  NULL,
	[OrderBookerKey]    [varchar](24)  NULL,
	[ScheduledPlanned]  [int]          NULL,
	[UniquePlanned]     [int]          NULL,
	[ScheduledVisits]   [int]          NULL,
	[UniqueVisits]      [int]          NULL,
	[ScheduledProductive][int]         NULL,
	[UniqueProductive]  [int]          NULL
) ON [PRIMARY]
GO
