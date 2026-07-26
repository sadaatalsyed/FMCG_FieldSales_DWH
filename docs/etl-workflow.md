# ETL Workflow

## Pipeline shape

```
OLTP source (SQL Server)
   └── SSIS packages, one Data Flow Task per source query in /sql/etl/
         ├── OLE DB Source  → runs the extraction SELECT (with SSIS parameters
         │                    bound to @DateFrom/@DateTo or @DeliveryDateFrom/To)
         └── OLE DB Destination → target table in SalesAssistDWH
   └── SalesAssistDWH (SQL Server) — this repo's schema
         └── SSAS Tabular model (processed on a schedule after SSIS completes)
               └── Power BI Service (scheduled refresh, live connection to SSAS)
               └── Excel (Analyze in Excel / PivotTables against the same Tabular model)
```

## Load types by table

| Load pattern | Tables | Trigger |
|---|---|---|
| **Incremental — date range** | `SalesDataDump`, `New_PrimaryOrders`, `Cube_CustomerRoute`, `NonProductiveCustomers` | SSIS parameters set to a rolling window (e.g. last N days) on each run |
| **Incremental — snapshot** | `New_Stock` | `SnapShotDate >= today - 1`, runs daily |
| **Monthly refresh** | `New_Targets`, `New_SalesTargets` | `Month = MONTH(GETDATE()-1)`, `Year = YEAR(GETDATE()-1)` — always pulls "yesterday's month," which only matters at month boundaries |
| **Full refresh** | `New_Product`, `New_Customers`, `New_Distribution`, `New_OrderBooker`, `New_Salesman`, `New_Vans`, `New_Batch` | Dimensions are small enough to truncate + reload every run |

## Why `SalesDataDump` needs care on historical reloads

Historical rows in the OLTP source (`SA_SalesDataDump`) can be amended after the
original ETL run already captured them — a return processed weeks later, a status
change from Pending to Settled, a manual correction. Because the DWH load is
date-range incremental rather than full-table, a plain re-run of
`Extract_SecondarySales.sql` for a past date range does not automatically pick up
rows that were logically "already there" but changed status. Reloading a historical
month correctly requires either:

1. Deleting the existing rows for that `DeliveryDate` range in `SalesDataDump` before
   re-inserting (safe, but needs a maintenance window), or
2. An `EXCEPT`-based diff query to find only the changed rows and MERGE them in.

This warehouse currently favors option 1 for ad-hoc historical corrections.

## Data type / derivation notes worth knowing before extending this ETL

- **Cases/Pieces/TotalKg/TotalTons are computed at extraction time**, not stored in
  the OLTP source directly — derived from `TotalPiecesDelivered` (or `Cartons +
  Pieces` on the primary side) using `Product.UnitPerCarton`, `UnitWeight`, and
  `TonnageFactor`. Any change to how tonnage factor defaults are handled
  (`TonnageFactor IS NULL OR = 0 → treat as 1000`) needs to be applied consistently
  in both `Extract_SecondarySales.sql` and `Extract_PrimaryOrders.sql`.
- **Batch-level tax decomposition** (`Extract_Batch.sql`) infers whether a tax line
  is MRP-based or GST-based purely from `TaxDescription LIKE 'MRP%'/'GST%'` — if a
  new tax description pattern is introduced upstream, this CASE logic needs updating
  or pricing will silently fall through to `NULL`.
