/****************************************************************************************
Object      : dbo.Cube_CustomerRoute
Layer       : Fact
Grain       : 1 row per CustomersRouteID + VisitDate  (planned PJP visit)
Purpose     : Planned Journey Plan (PJP) — which outlet an Order Booker is scheduled
              to visit, on which day of the week, on which route. isRoute flags
              whether the route assignment is currently active.
              Feeds the "Planned" side of route-execution KPIs and is Source #1
              (src = 'PJP') in the AssignedShops SSAS view.
Source      : ZIL_SND.dbo.SA_CustomerRoute (OLTP, cross-database)
****************************************************************************************/
USE [SalesAssistDWH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Cube_CustomerRoute](
	[ID]                [bigint]        IDENTITY(1,1) NOT NULL,
	[DistributionID]    [int]           NULL,
	[OrderBookerID]     [int]           NULL,
	[Weeks]             [nvarchar](50)  NULL,
	[Day]               [nvarchar](10)  NULL,
	[CustomerID]        [int]           NULL,
	[isRoute]           [bit]           NULL,
	[VisitDate]         [date]          NULL,
	[CustomersRouteID]  [int]           NULL,
	[RouteName]         [nvarchar](max) NULL,
	[OrderBookerKey]    [int]           NULL,
	[DistributionKey]   [int]           NULL,
	[CustomerKey]       [int]           NULL,
	[CustomersRouteKey] [int]           NULL,
	[DateKey]           [nvarchar](50)  NULL,
	[RouteCreatedOn]    [datetime]      NULL,
	[AddOn]             [datetime]      NULL,
 CONSTRAINT [PK_Cube_CustomerRoute] PRIMARY KEY CLUSTERED
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Cube_CustomerRoute] ADD DEFAULT (getdate()) FOR [AddOn]
GO

/****************************************************************************************
Object      : dbo.NonProductiveCustomers
Layer       : Fact
Grain       : 1 row per visit attempt that did NOT result in a sale
Purpose     : Captures Order Booker visits where the outlet was reached but no order
              was booked, with a reason code + GPS coordinates. Rows where
              CustomersRouteID IS NULL represent unplanned non-productive visits and
              are Source #3 (src = 'Unplanned_NonProductiveShops') in AssignedShops.
Source      : ZIL_SND.dbo.NonProductiveCustomers (OLTP, cross-database)
****************************************************************************************/
CREATE TABLE [dbo].[NonProductiveCustomers](
	[ID]                [int]           IDENTITY(1,1) NOT NULL,
	[DistributionID]    [int]           NULL,
	[OrderBookerID]     [int]           NULL,
	[CustomerID]        [int]           NULL,
	[CustomersRouteID]  [int]           NULL,
	[ReasonCodeID]      [int]           NULL,
	[Reason]            [nvarchar](max) NULL,
	[Lattitude]         [nvarchar](128) NULL,
	[Longitude]         [nvarchar](128) NULL,
	[Synchronized]      [bit]           NULL,
	[CreatedOn]         [datetime]      NULL,
	[DistributionKey]   [int]           NULL,
	[OrderBookerKey]    [int]           NULL,
	[CustomerKey]       [int]           NULL,
	[CustomersRouteKey] [int]           NULL,
	[DateKey]           [nvarchar](8)   NULL,
 CONSTRAINT [PK_NonProductiveCustomers] PRIMARY KEY CLUSTERED
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
