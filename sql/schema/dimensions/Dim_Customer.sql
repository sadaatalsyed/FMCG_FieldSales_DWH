/****************************************************************************************
Object      : dbo.New_Customers
Layer       : Dimension
Purpose     : Outlet/customer master — Channel > SubChannel > Element > SubElement
              hierarchy + geo (Locality/SubLocality) + tax registration status.
              ActiveStatus drives the "Show items with no data" pattern in Power BI
              and the active-outlet filter used in the AssignedShops view.
Source      : Customer + Channel + SubChannel + Element + SubElement + Locality +
              SubLocality + CustomerAddress (OLTP)
****************************************************************************************/
USE [SalesAssistDWH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[New_Customers](
	[CompanyName]         [varchar](3)     NULL,
	[CustomerID]          [int]            NULL,
	[CustomerCode]        [nvarchar](max)  NULL,
	[CompanyCustomerCode] [nvarchar](max)  NULL,
	[NTN]                 [nvarchar](32)   NULL,
	[STN]                 [nvarchar](32)   NULL,
	[CNIC]                [nvarchar](20)   NULL,
	[SalesTaxStatus]      [nvarchar](20)   NULL,
	[IncomeTaxStatus]     [nvarchar](10)   NULL,
	[ShopProgram]         [nvarchar](100)  NULL,
	[CustomerName]        [nvarchar](200)  NULL,
	[ChannelName]         [nvarchar](200)  NULL,
	[SubChannel]          [nvarchar](200)  NULL,
	[Element]             [nvarchar](200)  NULL,
	[SubElement]          [nvarchar](200)  NULL,
	[LocalityName]        [nvarchar](max)  NULL,
	[SubLocalityName]     [nvarchar](max)  NULL,
	[Status]              [nvarchar](max)  NULL,
	[CustomerKey]         [int]            NULL,
	[Address]             [nvarchar](max)  NULL,
	[Landmark]            [nvarchar](max)  NULL,
	[Lattitude]           [nvarchar](128)  NULL,
	[Longitude]           [nvarchar](128)  NULL,
	[Mobile]              [nvarchar](250)  NULL,
	[OwnerName]           [nvarchar](200)  NULL,
	[DistributionKey]     [int]            NULL,
	[Outlet(Town)]        [nvarchar](max)  NULL,
	[Outlet(Address)]     [nvarchar](max)  NULL,
	[ActiveStatus]        [bit]            NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
