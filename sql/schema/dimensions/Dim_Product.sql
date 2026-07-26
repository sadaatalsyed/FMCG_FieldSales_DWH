/****************************************************************************************
Object      : dbo.New_Product
Layer       : Dimension
Purpose     : Product master — Type > Category > Brand > Segment > Variant hierarchy.
              ProductKey = CONCAT(100, ProductID) — surrogate key pattern used across
              this warehouse (see docs/data-dictionary.md for the full key convention).
Source      : Product + Type + Category + Brand + Segment + Variant + Principle (OLTP)
****************************************************************************************/
USE [SalesAssistDWH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[New_Product](
	[CompanyName]        [varchar](3)    NULL,
	[ProductID]          [int]           NULL,
	[Type]               [nvarchar](50)  NULL,
	[Category]           [nvarchar](50)  NULL,
	[Brand]              [nvarchar](50)  NULL,
	[Segment]            [nvarchar](50)  NULL,
	[Variant]            [nvarchar](max) NULL,
	[ProductCode]        [nvarchar](max) NULL,
	[ProductCompanyCode] [nvarchar](max) NULL,
	[ProductName]        [nvarchar](max) NULL,
	[ProductDisplayName] [nvarchar](max) NULL,
	[UnitPerCarton]      [smallint]      NULL,
	[UnitWeight]         [numeric](18,4) NULL,
	[UOM]                [nvarchar](200) NULL,
	[ProductKey]         [int]           NULL,
	[TonnageFactor]      [int]           NULL,
	[PackagingType]      [nvarchar](200) NULL,
	[Active]             [bit]           NULL,
	[MainCode]           [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****************************************************************************************
Object      : dbo.New_Batch
Layer       : Dimension (product/pricing sub-dimension)
Purpose     : Batch-level pricing snapshot (Invoice/Trade/Retail price + tax split)
              per product batch code. Feeds pricing measures in SSAS.
              InvoicePriceWithoutTax = InvoicePrice - extracted tax component
              (tax derived from MRP%/GST% depending on TaxDescription — see ETL script).
Source      : BatchCode + Product + ProductDetail + ProductTax + Tax (OLTP)
****************************************************************************************/
CREATE TABLE [dbo].[New_Batch](
	[BatchKey]              [bigint]        NOT NULL,
	[ProductID]             [int]           NULL,
	[ProductKey]            [int]           NULL,
	[BatchCodeName]         [nvarchar](50)  NULL,
	[ExpiryDate]            [date]          NULL,
	[ProductDetailID]       [int]           NULL,
	[TaxID]                 [int]           NULL,
	[TaxDescription]        [nvarchar](20)  NULL,
	[TaxPercentage]         [decimal](18,8) NULL,
	[InvoicePrice]          [decimal](18,8) NULL,
	[TradePrice]            [decimal](18,8) NULL,
	[RetailPrice]           [decimal](18,8) NULL,
	[Tax]                   [decimal](18,8) NULL,
	[InvoicePriceWithoutTax][decimal](18,8) NULL,
 CONSTRAINT [PK_New_Batch] PRIMARY KEY CLUSTERED
(
	[BatchKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
