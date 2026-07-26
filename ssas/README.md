# SSAS Tabular Model

| File | Contents |
|---|---|
| `model-overview.md` | Table/relationship/measure counts, SSAS-name → physical-table mapping, all 37 relationships, key design decisions |
| `er-diagram.svg` | Visual ER diagram of the 18-table model (logical SSAS names) |
| `dax-measures.md` | Full DAX measure catalogue, grouped by table, with the reusable patterns (Status/Type filter, Opening/Closing stock, day-prorated targets, AssignedShops productivity) called out |

Start with `model-overview.md` if you're new to this model — it explains *why*
the relationships are shaped the way they are (e.g. why `Dim_Product` is
deliberately not related to `AssignedShops`), not just what they are.
