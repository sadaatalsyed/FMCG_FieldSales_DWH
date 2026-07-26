/****************************************************************************************
Object      : dbo.AssignedShops
Layer       : View (consumed by SSAS Tabular model only — not exposed in Power BI
              directly; backs the Assigned Shops Unique / Scheduled measures and
              the Unique/Scheduled Producitivy % measures — see ssas/dax-measures.md)
Purpose     : Unions three sources of "an outlet was assigned/attempted on a given
              day" into one row set, tagging provenance via `src`:

                1. 'PJP'                          -> planned route visit (Cube_CustomerRoute,
                                                      isRoute = 1, outlet Active = 1)
                2. 'UnplannedProductiveShops'      -> a sale happened (SalesDataDump,
                                                      Status='Settled', Type='Sales')
                                                      outside a planned route
                                                      (RouteName = 'Unplaned Route' or blank)
                3. 'Unplanned_NonProductiveShops'  -> a visit attempt with no sale and
                                                      no route assignment
                                                      (NonProductiveCustomers,
                                                      CustomersRouteID IS NULL)

              This is what lets Scheduled vs Unique productivity measures count both
              planned AND ad-hoc (unplanned) shop coverage without double-defining
              the logic in three separate DAX measures.
****************************************************************************************/
USE [SalesAssistDWH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AssignedShops] AS (
SELECT
    DistributionID, a.DistributionKey, a.OrderBookerKey, a.DateKey, OrderBookerID,
    VisitDate, a.CustomerID, Concat(a.CustomerID, a.DateKey) CutomerDateKey, src

FROM (
    -- Source 1: Planned Journey Plan (PJP) — route assigned, outlet currently active
    SELECT
        cr.DistributionID, cr.DistributionKey, cr.OrderBookerID, cr.OrderBookerKey,
        cr.CustomerID, VisitDate, cr.DateKey, 'PJP' as src
    FROM Cube_CustomerRoute cr
    LEFT JOIN New_Customers as c ON c.CustomerKey = cr.CustomerKey
    JOIN New_OrderBooker as ob   ON ob.OrderBookerKey = cr.OrderBookerKey
    WHERE cr.isRoute = 1 AND c.ActiveStatus = 1

    UNION ALL

    -- Source 2: A sale was made outside any planned route (unplanned but productive)
    SELECT
        si.DistributionID, si.DistributionKey, si.OrderBookerID, si.OrderBookerKey,
        si.CustomerID, DeliveryDate as VisitDate, si.DateKey, 'UnplannedProductiveShops' as src
    FROM SalesDataDump si
    WHERE si.Status = 'Settled' AND si.Type = 'Sales'
      AND (si.RouteName = 'Unplaned Route' OR RouteName = '')
    GROUP BY si.DistributionID, si.OrderBookerID, si.CustomerID, DeliveryDate,
             si.InvoiceCode, si.DistributionKey, si.OrderBookerKey, si.DateKey

    UNION ALL

    -- Source 3: A visit was attempted (no sale) with no route assignment at all
    SELECT DISTINCT
        npc.DistributionID, npc.DistributionKey, npc.OrderBookerID, npc.OrderBookerKey,
        npc.CustomerID, Cast(npc.CreatedOn as Date) as VisitDate, npc.DateKey,
        'Unplanned_NonProductiveShops' as src
    FROM NonProductiveCustomers npc
    WHERE npc.CustomersRouteID IS NULL
    GROUP BY npc.DistributionID, OrderBookerID, CustomerID, Cast(npc.CreatedOn as Date),
             npc.DistributionKey, npc.OrderBookerKey, npc.DateKey

) AS a
)
GO
