# Data Dictionary

## Surrogate key convention

Every key ending in `Key` is generated the same way across the whole warehouse:

```sql
CONCAT(100, <SourceSystemID>)
```

e.g. `ProductKey = CONCAT(100, ProductID)`, `OrderBookerKey = CONCAT(100, OrderBookerID)`.
This is a simple prefix-based surrogate key — it avoids needing an identity/sequence
table per dimension, at the cost of being predictable rather than opaque. Fine for a
single-source-system warehouse like this one.

## Date key conventions

| Key | Format | Used for |
|---|---|---|
| `DateKey` | `ddMMyyyy` (e.g. `26072026`) | Day-grain join to `Dim_Date` |
| `DateTargetKey` | `MMyyyy` (e.g. `072026`) | Month-grain join for `New_Targets`/`New_SalesTargets` |
| `MonthYearKey` | `MMyyyy` | Month-grain join for `New_SalesTargets` (distribution-level) |

## Status / Type business rules (SalesDataDump)

| Column | Values | Meaning |
|---|---|---|
| `Status` | `Open`, `Pending`, `Settled` | Order lifecycle. **Booked** = any of these three. **Delivered** = `Settled` only. |
| `Type` | `Sales`, `Return` | Whether the row is a sale or a return against a prior sale. |
| `RouteName` | route name, `'Unplaned Route'`, or blank | Blank/`'Unplaned Route'` = the sale happened outside the Order Booker's planned journey plan (PJP). |

This rule is applied consistently across DAX measures, the ETL extraction query, and
the `AssignedShops` view — see `ssas/dax-measures.md` for the DAX side.

## Fact table grains

| Table | Grain |
|---|---|
| `SalesDataDump` | 1 row per InvoiceCode + ProductID (invoice line) |
| `New_PrimaryOrders` | 1 row per Distribution + InvoiceDate + Product + BatchCode |
| `Cube_CustomerRoute` | 1 row per CustomersRouteID + VisitDate |
| `NonProductiveCustomers` | 1 row per non-productive visit attempt |
| `New_Stock` | 1 row per Distribution + Product + BatchCode + snapshot Date |
| `New_Targets` / `New_SalesTargets` / `PrimaryTargets` | 1 row per Distribution (+OrderBooker) + Product + Month |
| `New_Productivity` | 1 row per Distribution + OrderBooker + Month (pre-aggregated) |

## Known data-quality notes (carried over from source system, not fixed at ETL layer)

- `New_PrimaryOrders`'s extracted DDL was missing 2 trailing columns in the original
  script dump (`DateKey`, `TotalPieces`, `CreatedOn`) — confirmed and added back from
  the full source script; verify against SSMS if regenerating this repo from a newer
  export.
- The original `Extract_PrimaryOrders.sql` source script had a stray `;` after the
  first `UNION ALL`, which would have silently truncated the Sales/Return union into
  two separate statements if run as-is — removed in this repo's copy.
- `Discount  Reversal` (double space) and a few similarly-cased measure names are
  carried over as-is from the SSAS model; see the cleanup note at the end of
  `ssas/dax-measures.md`.
