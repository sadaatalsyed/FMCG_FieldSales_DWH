
# Power BI / Excel — Consumption Layer

The SSAS Tabular model is the single semantic layer behind two front ends:

- **Power BI Service** — scheduled-refresh dashboards built on a Live Connection
  to the Tabular model. The main deliverable on this data is the **ICE Daily
  Tracker**, a 4-sheet weighted Order Booker scorecard (35/30/20/15%):
  1. **Daily Sales Performance** — Booked/Delivered volume & value, Pareto outlet
     analysis, Previous Day comparisons
  2. **Route Execution & Productivity** — Scheduled/Unique productivity %,
     planned vs. unplanned shop coverage (via `AssignedShops`)
  3. **Market Time & GPS** — visit timing, idle time, GPS compliance, Haversine
     distance between planned and actual visit coordinates
  4. **Product Mix & Brand Performance** — Brand/Category pivot of secondary sales

- **Excel** — power users connect via *Analyze in Excel* / PivotTables directly
  against the same Tabular model, so finance/ops teams get the same numbers as
  the Power BI dashboards without needing a Power BI license.

## Report-level patterns worth knowing

- **`Dim_OrderBooker` uses "Show items with no data"** — an Order Booker with
  zero activity on a given day still appears in the matrix, at zero, rather than
  disappearing. Important for the scorecard's fairness — a "0" is a meaningful
  signal (no work done), not the same as "not applicable."
- **A standalone `Dim_Date`** (not auto-generated) drives every visual's date
  slicer, so Previous Day/Month comparisons stay consistent across all 4 sheets
  regardless of which fact table a given visual is querying.
- **Market Time & GPS aggregation strategy** — at OrderBooker-per-date grain,
  clock-time columns use `MEDIANX` (a single very early/late outlier visit
  shouldn't skew the whole day's average), while worst-case compliance flags use
  `MAXX` (if any single visit breached GPS/time compliance, the day is flagged).

> Screenshots of the actual Power BI report pages aren't included in this repo
> (would need to be exported from the live workspace) — add them here as PNGs
> if you want the README to show finished visuals rather than just describe them.
