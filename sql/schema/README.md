# Schema — CREATE TABLE scripts

Physical DDL for `SalesAssistDWH`, split by warehouse layer:

- **`dimensions/`** — 9 dimension tables (`Date`, `DateTarget`, `New_Product`,
  `New_Batch`, `New_Customers`, `New_Distribution`, `New_OrderBooker`,
  `New_Salesman`, `New_Vans`)
- **`facts/`** — 9 fact tables (`SalesDataDump`, `New_PrimaryOrders`, `PrimaryTargets`,
  `Cube_CustomerRoute`, `NonProductiveCustomers`, `New_Targets`, `New_SalesTargets`,
  `New_Productivity`, `New_Stock`)

Run order for a fresh environment: dimensions first, then facts (some facts don't
have enforced FK constraints in the source system, but loading dims first keeps
the ETL's `CONCAT(100, ID)` surrogate-key joins meaningful from the first load).

After tables exist, run `/sql/indexes/Recommended_Indexes.sql`, then
`/sql/views/AssignedShops.sql`.

See `docs/architecture-diagram.svg` for how these tables relate to each other, and
`docs/data-dictionary.md` for key/column conventions.
