# Docs

| File | Contents |
|---|---|
| `architecture-diagram.svg` | Galaxy schema diagram — physical DWH table names |
| `etl-flow-diagram.svg` | SSIS pipeline: OLTP → SSIS → SalesAssistDWH → SSAS → Power BI/Excel |
| `data-dictionary.md` | Surrogate key convention, DateKey formats, Status/Type business rules, fact grains, known data-quality notes |
| `etl-workflow.md` | Load-pattern breakdown per table, historical-reload caveats, derivation notes for anyone extending the ETL |

For the SSAS-side ER diagram and DAX measure catalogue, see `/ssas` instead —
kept separate because that layer uses its own logical table names (see the
name-mapping table in `ssas/model-overview.md`).
