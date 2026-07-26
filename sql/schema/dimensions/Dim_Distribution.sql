/****************************************************************************************
Object      : dbo.New_Distribution
Layer       : Dimension
Purpose     : Distributor master — legal/tax identity + geo hierarchy
              (Level1 = Zone, Level2-4 = territory drill-down) + POC contact info.
              DistributionKey is the top-level filter used by nearly every fact table
              and by AssignedShops (REMOVEFILTERS(Dim_Product/Dim_Outlets) pattern in
              SSAS still respects Distribution filters).
Source      : Distribution + DistributionClass + Level1 + Level2 + Level3 + Level4 (OLTP)
****************************************************************************************/
USE [SalesAssistDWH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[New_Distribution](
	[DistributionID]       [int]           NULL,
	[DistributionCode]     [nvarchar](20)  NULL,
	[DistributionName]     [nvarchar](250) NULL,
	[DistributionLegalName][nvarchar](250) NULL,
	[NTN]                  [nvarchar](20)  NULL,
	[STN]                  [nvarchar](20)  NULL,
	[Address]              [nvarchar](max) NULL,
	[SoldTo]               [nvarchar](20)  NULL,
	[ShipTo]               [nvarchar](20)  NULL,
	[OwnerName]            [nvarchar](50)  NULL,
	[DistributionType]     [nvarchar](max) NULL,
	[DistributionClass]    [nvarchar](max) NULL,
	[Status]               [varchar](8)    NULL,
	[CompanyName]          [varchar](3)    NULL,
	[Cell Number]          [nvarchar](50)  NULL,
	[OwnerCNIC]            [nvarchar](50)  NULL,
	[Contact Number]       [nvarchar](20)  NULL,
	[DistributionKey]      [varchar](53)   NULL,
	[Level1]               [nvarchar](max) NULL,
	[Level2]               [nvarchar](max) NULL,
	[Level3]               [nvarchar](max) NULL,
	[Level4]               [nvarchar](max) NULL,
	[OwnerEmail]           [nvarchar](50)  NULL,
	[POCDesignation]       [nvarchar](50)  NULL,
	[POCContactNo]         [nvarchar](50)  NULL,
	[POCEmail]             [nvarchar](50)  NULL,
	[Province]             [nvarchar](256) NULL,
	[IntegratedWith]       [nvarchar](128) NULL,
	[FBRIntegration]       [nvarchar](128) NULL,
	[Zone]                 [nvarchar](max) NULL,
	[POC_Name]             [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
