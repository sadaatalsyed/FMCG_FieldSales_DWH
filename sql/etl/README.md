# ETL Extraction Queries

These are the source-side (OLTP) extraction queries used inside SSIS Data Flow Tasks
to pull data into `SalesAssistDWH`. Each query maps 1:1 to an SSIS package / Data Flow
Task, and each generates the surrogate keys (`CONCAT(100, <ID>)` pattern) and `DateKey`
(`FORMAT(<date>, 'ddMMyyyy')`) that the warehouse tables expect.

| File | Target table | Load type |
|---|---|---|
| `Extract_CustomerRoute.sql` | `Cube_CustomerRoute` | Incremental (CreatedOn between params) |
| `Extract_Batch.sql` | `New_Batch` | Full refresh |
| `Extract_Product.sql` | `New_Product` | Full refresh |
| `Extract_SecondarySales.sql` | `SalesDataDump` | Incremental (date range) |
| `Extract_Customer.sql` | `New_Customers` | Full refresh |
| `Extract_Distribution.sql` | `New_Distribution` | Full refresh |
| `Extract_OrderBooker.sql` | `New_OrderBooker` | Full refresh |
| `Extract_PrimaryOrders.sql` | `New_PrimaryOrders` | Incremental (Sales UNION ALL Return) |
| `Extract_Salesman.sql` | `New_Salesman` | Full refresh |
| `Extract_Stock.sql` | `New_Stock` | Incremental (SnapShotDate >= today-1) |
| `Extract_Targets.sql` | `New_Targets` | Monthly (current month) |
| `Extract_Van.sql` | `New_Vans` | Full refresh |
| `Extract_NonProductiveCustomers.sql` | `NonProductiveCustomers` | Incremental (CreatedOn between params) |
| `Extract_DistributionTargets.sql` | `New_SalesTargets` | Monthly (current month) |

**Known caveat:** `Extract_SecondarySales.sql` reads from `SA_SalesDataDump`, which can
have snapshot drift for historical months (rows amended in OLTP after the original ETL
run). Full historical reloads are handled outside this script — see `docs/etl-workflow.md`.
