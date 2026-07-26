/****************************************************************************************
Recommended non-clustered indexes for SalesAssistDWH
----------------------------------------------------------------------------------------
These are not part of the original CREATE TABLE scripts (the tables only ship with
clustered PK / heap). Every index below is chosen from actual join/filter columns
observed in:
  - /sql/etl/*.sql              (SSIS extraction queries)
  - /sql/views/AssignedShops.sql (SSAS-consumed view)
  - /ssas/dax-measures.md        (CALCULATE filter columns used repeatedly)

Naming convention: IX_<Table>_<LeadingColumn(s)>
****************************************************************************************/
USE [SalesAssistDWH]
GO

-- ============================================================================
-- dbo.SalesDataDump  (central fact — highest read volume, prioritize this table first)
-- ============================================================================

-- Almost every measure filters on Status + Type (e.g. Status='Settled', Type='Sales')
-- before aggregating — this is the single highest-value index on this table.
CREATE NONCLUSTERED INDEX [IX_SalesDataDump_Status_Type]
ON [dbo].[SalesDataDump] ([Status], [Type])
INCLUDE ([DeliveryDate], [TotalTons], [TotalKg], [NetAmount], [TotalValueWithTax],
         [CustomerID], [InvoiceCode], [ProductID])
GO

-- Star-join columns used to relate the fact to every dimension in Power BI/SSAS
CREATE NONCLUSTERED INDEX [IX_SalesDataDump_Keys]
ON [dbo].[SalesDataDump] ([DateKey], [DistributionKey], [OrderBookerKey], [ProductKey])
GO

-- RouteName drives Planned vs Unplanned productivity split (AssignedShops view,
-- Planned/Unplanned Productive Outlets measures)
CREATE NONCLUSTERED INDEX [IX_SalesDataDump_RouteName]
ON [dbo].[SalesDataDump] ([RouteName])
INCLUDE ([Status], [Type], [CustomerID], [DistributionID], [OrderBookerID])
GO

-- Delivery-date range scans (SSIS incremental extraction, "Previous Day" DAX measures)
CREATE NONCLUSTERED INDEX [IX_SalesDataDump_DeliveryDate]
ON [dbo].[SalesDataDump] ([DeliveryDate])
INCLUDE ([DistributionID], [Status], [Type])
GO

-- ============================================================================
-- dbo.Cube_CustomerRoute (PJP fact)
-- ============================================================================
CREATE NONCLUSTERED INDEX [IX_Cube_CustomerRoute_isRoute_VisitDate]
ON [dbo].[Cube_CustomerRoute] ([isRoute], [VisitDate])
INCLUDE ([DistributionID], [OrderBookerID], [CustomerID], [DistributionKey],
         [OrderBookerKey], [DateKey])
GO

CREATE NONCLUSTERED INDEX [IX_Cube_CustomerRoute_CustomerKey]
ON [dbo].[Cube_CustomerRoute] ([CustomerKey])
GO

-- ============================================================================
-- dbo.NonProductiveCustomers
-- ============================================================================
-- AssignedShops view filters CustomersRouteID IS NULL for the "unplanned" branch
CREATE NONCLUSTERED INDEX [IX_NonProductiveCustomers_RouteID]
ON [dbo].[NonProductiveCustomers] ([CustomersRouteID])
INCLUDE ([DistributionID], [OrderBookerID], [CustomerID], [CreatedOn],
         [DistributionKey], [OrderBookerKey], [DateKey])
GO

CREATE NONCLUSTERED INDEX [IX_NonProductiveCustomers_CreatedOn]
ON [dbo].[NonProductiveCustomers] ([CreatedOn])
GO

-- ============================================================================
-- dbo.New_PrimaryOrders / dbo.PrimaryTargets
-- ============================================================================
CREATE NONCLUSTERED INDEX [IX_New_PrimaryOrders_Keys]
ON [dbo].[New_PrimaryOrders] ([DistributionKey], [ProductKey], [DateKey])
INCLUDE ([Type], [TotalTons], [TotalKg], [Cases])
GO

CREATE NONCLUSTERED INDEX [IX_PrimaryTargets_Keys]
ON [dbo].[PrimaryTargets] ([DistributionKey], [ProductKey], [MonthYearKey])
GO

-- ============================================================================
-- dbo.New_Targets / dbo.New_SalesTargets
-- ============================================================================
CREATE NONCLUSTERED INDEX [IX_New_Targets_Keys]
ON [dbo].[New_Targets] ([DistributionKey], [OrderBookerKey], [ProductKey], [DateTargetKey])
GO

CREATE NONCLUSTERED INDEX [IX_New_SalesTargets_Keys]
ON [dbo].[New_SalesTargets] ([DistributionKey], [OrderBookerKey], [ProductKey], [DateTargetKey])
GO

-- ============================================================================
-- dbo.New_Stock
-- ============================================================================
-- Opening/Closing Stock DAX measures always resolve MIN/MAX date first, then
-- filter the snapshot by DistributionKey + ProductKey — composite index matches
-- that access pattern.
CREATE NONCLUSTERED INDEX [IX_New_Stock_DateKey]
ON [dbo].[New_Stock] ([DateKey], [DistributionKey], [ProductKey])
INCLUDE ([TotalTons], [TotalKGs], [Cases], [Pieces])
GO

-- ============================================================================
-- dbo.New_Productivity
-- ============================================================================
CREATE NONCLUSTERED INDEX [IX_New_Productivity_Keys]
ON [dbo].[New_Productivity] ([DistributionKey], [OrderBookerKey], [DateTargetKey])
GO

-- ============================================================================
-- Dimension lookups (light, but ActiveStatus/Active filters are hit on every query)
-- ============================================================================
CREATE NONCLUSTERED INDEX [IX_New_Customers_CustomerKey]
ON [dbo].[New_Customers] ([CustomerKey])
INCLUDE ([ActiveStatus], [DistributionKey])
GO

CREATE NONCLUSTERED INDEX [IX_New_Product_ProductKey]
ON [dbo].[New_Product] ([ProductKey])
INCLUDE ([Active], [Brand], [Category])
GO

CREATE NONCLUSTERED INDEX [IX_New_OrderBooker_OrderBookerKey]
ON [dbo].[New_OrderBooker] ([OrderBookerKey])
INCLUDE ([DistributionID], [Status])
GO
