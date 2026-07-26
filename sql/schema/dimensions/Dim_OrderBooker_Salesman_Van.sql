/****************************************************************************************
Object      : dbo.New_OrderBooker
Layer       : Dimension
Purpose     : Order Booker (field sales rep) master — this is the primary "actor"
              dimension for the ICE Daily Tracker scorecard (Order Booker performance).
              Dim_OrderBooker uses "Show items with no data" in Power BI so OBs with
              zero activity on a given day still appear in the matrix.
Source      : OrderBooker + AspNetUsers + Designation (+ Locality/SubLocality via
              correlated subqueries for multi-locality assignment) (OLTP)
****************************************************************************************/
USE [SalesAssistDWH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[New_OrderBooker](
	[ID]              [int]           IDENTITY(1,1) NOT NULL,
	[Company]         [varchar](50)   NULL,
	[Designation]     [nvarchar](100) NULL,
	[DistributionID]  [int]           NULL,
	[OrderBookerCode] [nvarchar](max) NULL,
	[OrderBookerName] [nvarchar](max) NULL,
	[CNIC]            [nvarchar](20)  NULL,
	[Email]           [nvarchar](256) NULL,
	[PhoneNumber]     [nvarchar](max) NULL,
	[Status]          [varchar](8)    NULL,
	[OrderBookerKey]  [int]           NULL,
	[SalesmanKey]     [int]           NULL,
	[UserID]          [nvarchar](128) NULL,
	[SubLocality]     [nvarchar](max) NULL,
	[Locality]        [nvarchar](max) NULL,
 CONSTRAINT [PK_New_DSF] PRIMARY KEY CLUSTERED
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****************************************************************************************
Object      : dbo.New_Salesman
Layer       : Dimension
Purpose     : Salesman master — distinct from Order Booker in source system
              (different designation/role); linked to OrderBookerKey for reporting
              roll-up where the two roles map 1:1 per distributor.
Source      : Salesmen + AspNetUsers + Designation (OLTP)
****************************************************************************************/
CREATE TABLE [dbo].[New_Salesman](
	[Designation]   [nvarchar](100) NULL,
	[DistributionID][int]           NULL,
	[SaleManCode]   [nvarchar](max) NULL,
	[SaleManName]   [nvarchar](max) NULL,
	[CNIC]          [nvarchar](20)  NULL,
	[Email]         [nvarchar](256) NULL,
	[PhoneNumber]   [nvarchar](max) NULL,
	[Status]        [varchar](8)    NULL,
	[Company]       [varchar](3)    NULL,
	[SalesmanKey]   [varchar](24)   NULL,
	[OrderBookerKey][int]           NULL,
	[UserID]        [nvarchar](128) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****************************************************************************************
Object      : dbo.New_Vans
Layer       : Dimension
Purpose     : Delivery van master — linked to Secondary Sales fact for van-wise
              distribution/delivery analysis.
Source      : Van + VehicleType (OLTP)
****************************************************************************************/
CREATE TABLE [dbo].[New_Vans](
	[Company]           [varchar](50)   NULL,
	[VanID]             [int]           NULL,
	[VanCode]           [nvarchar](max) NULL,
	[VanName]           [nvarchar](max) NULL,
	[RegistrationNumber][nvarchar](max) NULL,
	[VehicalType]       [nvarchar](max) NULL,
	[Status]            [varchar](8)    NULL,
	[VanKey]            [int]           NOT NULL,
 CONSTRAINT [PK_New_Vans] PRIMARY KEY CLUSTERED
(
	[VanKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
