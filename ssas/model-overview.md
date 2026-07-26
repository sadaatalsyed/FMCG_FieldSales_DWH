# SSAS Tabular Model — Overview

**18 tables · 37 relationships · ~120 DAX measures** (counts confirmed from the
exported SSAS model documentation). See `er-diagram.svg` in this folder for the
full relationship diagram, and `docs/architecture-diagram.svg` for the same
structure using physical DWH table names.

## SSAS logical name → physical DWH table

The Tabular model renames every table to a shorter, report-friendly alias. This
mapping matters when moving between DAX/SSAS docs and the SQL schema in `/sql`:

| SSAS table (logical) | Physical table (`SalesAssistDWH`) |
|---|---|
| `Dim_Date` | `Date` |
| `DateTarget` | `DateTarget` |
| `Dim_Product` | `New_Product` |
| `Dim_Batch` | `New_Batch` |
| `Dim_Distributors` | `New_Distribution` |
| `Dim_OrderBooker` | `New_OrderBooker` |
| `Dim_Salesman` | `New_Salesman` |
| `Dim_Vans` | `New_Vans` |
| `Dim_Outlets` | `New_Customers` |
| `SecondrySales` | `SalesDataDump` |
| `PrimaryOrders` | `New_PrimaryOrders` |
| `Distributor Stock` | `New_Stock` |
| `Targets` | `New_Targets` |
| `PrimaryTargets` | `PrimaryTargets` |
| `Productivity` | `New_Productivity` |
| `CustomerRoute` | `Cube_CustomerRoute` |
| `NonProductiveCustomers` | `NonProductiveCustomers` |
| `AssignedShops` | `AssignedShops` (view) |

## Table sizes (columns / measures, from the exported model)

| Table | Columns | Measures |
|---|---|---|
| `SecondrySales` | 66 | 61 |
| `PrimaryOrders` | 39 | 25 |
| `Distributor Stock` | 18 | 20 |
| `PrimaryTargets` | 18 | 5 |
| `Targets` | 15 | 9 |
| `Dim_Outlets` | 29 | 1 |
| `AssignedShops` | 9 | 4 |
| `Dim_Product` | 19 | 0 |
| `Dim_Distributors` | 31 | 0 |
| `Dim_OrderBooker` | 15 | 0 |
| `Dim_Date` | 15 | 0 (1 hierarchy: `Calendar` = Year > MonthName > QuarterName > Date > WeekName) |
| `Dim_Batch` | 14 | 0 |
| `CustomerRoute` | 17 | 0 |
| `NonProductiveCustomers` | 16 | 0 |
| `Productivity` | 9 | 0 |
| `Dim_Vans` | 7 | 0 |
| `DateTarget` | 4 | 0 |

## Relationships (all 37, as exported from the model)

```
Targets[DateTargetKey]                 -> DateTarget[DateTargetKey]
Targets[DistributionKey]               -> Dim_Distributors[DistributionKey]
Targets[OrderBookerKey]                -> Dim_OrderBooker[OrderBookerKey]
Targets[ProductKey]                    -> Dim_Product[ProductKey]

PrimaryOrders[BatchKey]                -> Dim_Batch[BatchKey]
PrimaryOrders[DistributionKey]         -> Dim_Distributors[DistributionKey]
PrimaryOrders[DateKey]                 -> Dim_Date[DateKey]
PrimaryOrders[ProductKey]              -> Dim_Product[ProductKey]

Dim_Batch[ProductKey]                  -> Dim_Product[ProductKey]

Distributor Stock[DistributionKey]     -> Dim_Distributors[DistributionKey]
Distributor Stock[DateKey]             -> Dim_Date[DateKey]
Distributor Stock[ProductKey]          -> Dim_Product[ProductKey]
Distributor Stock[BatchCode]           -> Dim_Batch[BatchCodeName]

Productivity[DateTargetKey]            -> DateTarget[DateTargetKey]
Productivity[DistributionKey]          -> Dim_Distributors[DistributionKey]
Productivity[OrderBookerKey]           -> Dim_OrderBooker[OrderBookerKey]

Dim_Date[DateTargetKey]                -> DateTarget[DateTargetKey]

SecondrySales[CustomerKey]             -> Dim_Outlets[CustomerKey]
SecondrySales[DistributionKey]         -> Dim_Distributors[DistributionKey]
SecondrySales[VanKey]                  -> Dim_Vans[VanKey]
SecondrySales[OrderBookerKey]          -> Dim_OrderBooker[OrderBookerKey]
SecondrySales[SalesmanKey]             -> Dim_Salesman[SalesmanKey]
SecondrySales[ProductKey]              -> Dim_Product[ProductKey]
SecondrySales[BatchKey]                -> Dim_Batch[BatchKey]
SecondrySales[DateKey]                 -> Dim_Date[DateKey]

PrimaryTargets[MonthYearKey]           -> DateTarget[DateTargetKey]
PrimaryTargets[DistributionKey]        -> Dim_Distributors[DistributionKey]
PrimaryTargets[ProductKey]             -> Dim_Product[ProductKey]

CustomerRoute[DateKey]                 -> Dim_Date[DateKey]
CustomerRoute[DistributionKey]         -> Dim_Distributors[DistributionKey]
CustomerRoute[OrderBookerKey]          -> Dim_OrderBooker[OrderBookerKey]

NonProductiveCustomers[DateKey]        -> Dim_Date[DateKey]
NonProductiveCustomers[DistributionKey]-> Dim_Distributors[DistributionKey]
NonProductiveCustomers[OrderBookerKey] -> Dim_OrderBooker[OrderBookerKey]

AssignedShops[DateKey]                 -> Dim_Date[DateKey]
AssignedShops[OrderBookerKey]          -> Dim_OrderBooker[OrderBookerKey]
AssignedShops[DistributionKey]         -> Dim_Distributors[DistributionKey]
```

> **Note on `SecondrySales[BatchKey]` / `PrimaryOrders[BatchKey]`:** the physical
> `SalesDataDump` and `New_PrimaryOrders` tables (see `/sql/schema/facts`) only
> carry `BatchCode` (string), not a `BatchKey` column. The Tabular model likely
> derives `BatchKey` as a calculated column from `BatchCode` joined through
> `Dim_Batch[BatchCodeName]` — worth double-checking against the live model if
> extending this relationship, since it's the one relationship that doesn't map
> 1:1 onto a physical foreign key the way the other 36 do.

## Star/Galaxy schema

This is a **galaxy schema** (multiple fact tables sharing a common set of dimensions),
built as an SSAS Tabular model over `SalesAssistDWH`. See **`er-diagram.svg`** in
this folder for the full 18-table / 37-relationship diagram (logical SSAS names),
or **`docs/architecture-diagram.svg`** for the same structure in physical DWH
table names.

`Dim_Date` is the busiest hub, related to all 9 fact tables plus `DateTarget`.
`Dim_Product` and `Dim_Distributors` are the next busiest (6 and 8 fact
relationships respectively). `Dim_Product` is deliberately **not** related to
`AssignedShops`/`Productivity` — see the design-decision note below.

## Key design decisions

- **Surrogate key convention**: every dimension key is `CONCAT(100, <SourceID>)` —
  a simple, consistent pattern that avoids collisions across source systems without
  needing an identity/sequence table.
- **Two grains of target**: OB-level monthly targets (`New_Targets`) prorate to a
  daily rate *in DAX* at query time (see `Target Tons` family of measures), while
  Distribution-level primary targets (`PrimaryTargets`) store the per-day rate
  *pre-computed* in the ETL. Both approaches coexist deliberately — the OB-level
  target needs to react to arbitrary date-range selections in Power BI, while the
  primary target's day-count is fixed to the source month, so pre-computing it is safe.
- **Status/Type as the universal filter contract**: almost every additive measure on
  `SalesDataDump` wraps `SUM(...)` in `CALCULATE(..., Status="Settled", Type="Sales")`
  — this is the single most repeated pattern across the whole model. Any new measure
  on this table should follow it unless there's a specific reason not to (e.g. gross
  "booked" measures that intentionally include Open/Pending).
- **`Dim_Product` isolation from Assignment/Productivity facts**: Product is not
  related to `AssignedShops`/`New_Productivity` — this is intentional, to prevent a
  Brand/Category slicer from silently filtering out productivity counts that have
  nothing to do with which products were sold.
- **`REMOVEFILTERS` in Assigned Shops measures**: `Assigned Shops Unique` /
  `Assigned Shops Scheduled` explicitly strip Product and Outlet filters so that a
  Brand-level slicer doesn't shrink the assigned-shop denominator used in
  productivity % — only Distribution/OrderBooker/Date filters should affect it.

## Fact grains (by SSAS logical name)

| Table | Grain |
|---|---|
| `SecondrySales` | InvoiceCode + ProductID |
| `PrimaryOrders` | Distribution + InvoiceDate + Product + BatchCode |
| `CustomerRoute` | CustomersRouteID + VisitDate |
| `NonProductiveCustomers` | 1 row per non-productive visit |
| `Distributor Stock` | Distribution + Product + BatchCode + snapshot Date |
| `Targets` | Distribution + OrderBooker + Product + Month |
| `PrimaryTargets` | Distribution + Product + Month |
| `Productivity` | Distribution + OrderBooker + Month (pre-aggregated) |
| `AssignedShops` | Distribution + OrderBooker + Customer + Date (SSAS calculated table, sourced from a view) |

See `dax-measures.md` for the full measure catalogue, grouped by table.
