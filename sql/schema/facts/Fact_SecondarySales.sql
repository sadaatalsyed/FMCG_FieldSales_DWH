/****************************************************************************************
Object      : dbo.SalesDataDump
Layer       : Fact  (this is the central fact table of the warehouse)
Grain       : 1 row per InvoiceCode + ProductID  (invoice line)
Purpose     : Secondary sales — every order/delivery transaction between a distributor's
              Order Booker/Van and an outlet. Status and Type together define the
              "Booked vs Delivered" business rule used across every measure:
                Booked    -> Status IN ('Open','Pending','Settled')
                Delivered -> Status = 'Settled'
              Type distinguishes 'Sales' rows from 'Return' rows (see New_PrimaryOrders
              for the equivalent pattern on the primary side).
Grows by    : ~daily incremental load from OLTP SA_SalesDataDump via SSIS
              (see /sql/etl/Extract_SecondarySales.sql for the source query and the
              known snapshot-drift caveat for historical months).
****************************************************************************************/
USE [SalesAssistDWH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SalesDataDump](
	[ID]                    [bigint]        IDENTITY(1,1) NOT NULL,
	[Company]               [varchar](50)   NULL,
	[DistributionID]        [int]           NULL,
	[CustomerID]            [int]           NULL,
	[InvoiceDate]           [date]          NULL,
	[DeliveryDate]          [date]          NULL,
	[Status]                [nvarchar](10)  NULL,
	[OrderBookerID]         [int]           NULL,
	[SalemanID]             [int]           NULL,
	[VanID]                 [int]           NULL,
	[RouteName]             [nvarchar](200) NULL,
	[InvoiceCode]           [nvarchar](100) NULL,
	[ProductID]             [int]           NULL,
	[TotalPiecesOrdered]    [int]           NULL,
	[TotalPiecesDelivered]  [int]           NULL,
	[FMRRate]               [numeric](18,4) NULL,
	[FMRAmount]             [numeric](18,4) NULL,
	[GSTRate]               [numeric](18,4) NULL,
	[GSTValue]              [numeric](18,4) NULL,
	[AdvanceTaxRate]        [numeric](18,4) NULL,
	[AdvanceTaxValue]       [numeric](18,4) NULL,
	[FurtherTaxRate]        [numeric](18,4) NULL,
	[FurtherTaxValue]       [numeric](18,4) NULL,
	[MRPRate]               [numeric](18,4) NULL,
	[MRPValue]              [numeric](18,4) NULL,
	[ConfectionaryTaxRate]  [numeric](18,4) NULL,
	[ConfectionaryTaxValue] [numeric](18,4) NULL,
	[InvoicePriceCase]      [numeric](18,4) NULL,
	[RetailPriceCase]       [numeric](18,4) NULL,
	[ConsumerPriceCase]     [numeric](18,4) NULL,
	[ValueWithoutTax]       [numeric](18,4) NULL,
	[TotalTax]              [numeric](18,4) NULL,
	[TotalValueWithTax]     [numeric](18,4) NULL,
	[NetAmount]             [numeric](18,4) NULL,
	[ToAmount]              [numeric](18,4) NULL,
	[TOPercentageValue]     [numeric](18,4) NULL,
	[TotalBillDiscount]     [numeric](18,4) NULL,
	[OtherDiscount]         [numeric](18,4) NULL,
	[FreeSKUQuantity]       [int]           NULL,
	[LMTRentals]            [numeric](18,4) NULL,
	[WholesaleDiscounts]    [numeric](18,4) NULL,
	[ZChampion]             [numeric](18,4) NULL,
	[LMTOffInvoice]         [numeric](18,4) NULL,
	[TO]                    [numeric](18,4) NULL,
	[OCD]                   [numeric](18,4) NULL,
	[BatchCode]             [nvarchar](50)  NULL,
	[Type]                  [varchar](10)   NULL,
	[Cases]                 [int]           NULL,
	[TotalKg]               [numeric](18,8) NULL,
	[TotalTons]             [float]         NULL,
	[DistributionKey]       [int]           NULL,
	[OrderBookerKey]        [int]           NULL,
	[SalesmanKey]           [int]           NULL,
	[VanKey]                [int]           NULL,
	[ProductKey]            [int]           NULL,
	[CustomerKey]           [bigint]        NULL,
	[DateKey]               [nvarchar](50)  NULL,
	[LMT Off Invoice 2026]  [numeric](18,4) NULL,
	[Visibility Discount]   [numeric](18,4) NULL,
	[Z-Cham Off-Invoice]    [numeric](18,4) NULL,
	[DiscountValue]         [numeric](18,4) NULL,
	[DiscountReversal]      [numeric](18,4) NULL,
	[Pieces]                [int]           NULL,
 CONSTRAINT [PK_SalesDataDump] PRIMARY KEY CLUSTERED
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
