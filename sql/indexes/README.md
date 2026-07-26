# Indexes

The original CREATE TABLE scripts ship with a clustered PK (or heap) only —
no supporting non-clustered indexes. `Recommended_Indexes.sql` adds indexes
chosen from the **actual** join and filter columns observed across:

- the SSIS extraction queries (`/sql/etl`)
- the `AssignedShops` view (`/sql/views`)
- the DAX measure filter patterns (`/ssas/dax-measures.md`)

Priority order if applying to a live/production-sized table: start with
`IX_SalesDataDump_Status_Type` — it backs the single most repeated filter
pattern in the entire model (`Status = 'Settled', Type = 'Sales'`) on the
largest and most frequently queried table in the warehouse.
