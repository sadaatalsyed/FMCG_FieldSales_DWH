# Views

## `AssignedShops`

Consumed by the SSAS Tabular model only (not exposed to Power BI directly) — it
backs `Assigned Shops Unique`, `Assigned Shops Scheduled`, and the
`Unique/Scheduled Producitivy %` measures. Unions three sources of "an outlet
was assigned or attempted on a given day": planned route visits, unplanned
sales, and unplanned non-productive visits. Full logic and rationale documented
inline in `AssignedShops.sql` and in `ssas/dax-measures.md`.
