# DAX Measure Catalogue

Organized by home table, matching the SSAS Tabular model's measure grouping.
~100+ measures total. This file documents the ones with non-trivial logic;
simple `SUM(...)`/`DISTINCTCOUNT(...)` passthrough measures are listed in the
summary tables without repeating boilerplate DAX.

---

## Dim_Outlets

| Measure | Expression |
|---|---|
| `Total Outlets` | `DISTINCTCOUNT(Dim_Outlets[Outlet SA Code])` |

---

## Targets (OB-level monthly target — day-proration done live in DAX)

Three variants of the same "prorate monthly target to the current date filter"
problem exist (`Target TonsI`, `TargetTonsK`, `Target TonsL`) — kept side by side
because they were built iteratively while refining the day-count edge cases
(week selections, DayName selections, partial month selections). `Target Tons`
is the production version currently wired to visuals.

```dax
Target Tons =
VAR MonthlyTarget = SUM(Targets[TargetTons])
VAR CurrentMonth = MAX('Dim_Date'[Month])
VAR CurrentYear = MAX('Dim_Date'[Year])
VAR TotalDaysInMonth = DAY(EOMONTH(MAX('Dim_Date'[Date]), 0))
RETURN
    IF(
        ISINSCOPE('Dim_Date'[Date]) || ISINSCOPE('Dim_Date'[Day]),
        DIVIDE(MonthlyTarget, TotalDaysInMonth),
        MonthlyTarget
    )
```

The same pattern (swap `TargetTons` for the relevant column) drives:
`Target KGs`, `Target Pieces`, `Target Cases`, `Target Value`, `Target Invoice`.

**`Target TonsL`** is the most robust variant — instead of assuming the filter
context is always Month/Day, it counts actual selected rows against actual
days-in-month via `ALLEXCEPT`, so it degrades correctly for Week/DayName
selections too:

```dax
Target TonsL =
VAR MonthlyTarget = SUM(Targets[TargetTons])
VAR TotalDaysInMonth =
    CALCULATE(COUNTROWS('Dim_Date'), ALLEXCEPT('Dim_Date', 'Dim_Date'[Year], 'Dim_Date'[Month]))
VAR SelectedDays = COUNTROWS('Dim_Date')
RETURN
    IF(
        ISINSCOPE('Dim_Date'[Year]) && ISINSCOPE('Dim_Date'[Month]) && SelectedDays < TotalDaysInMonth,
        DIVIDE(MonthlyTarget, TotalDaysInMonth) * SelectedDays,
        MonthlyTarget
    )
```

> **Recommendation:** standardize on `Target TonsL`'s pattern going forward and
> retire `TonsI`/`TonsK` once visuals are re-pointed — keeping three versions of
> the same logic is a maintenance risk if the business rule changes.

---

## PrimaryOrders

Mostly direct `SUM()` passthroughs of source columns (pricing, tax, and volume
components at invoice-line grain):

| Measure | Column |
|---|---|
| `PrimaryKGs` | `TotalKg` |
| `PrimaryCases` | `Cases` |
| `Primary Tons` | `TotalTons` |
| `PrimaryFMR%` / `PrimaryFMR` | `FMRRate` / `FMRAmount` |
| `PrimaryGST%` / `Primary GST` | `GSTRate` / `GSTValue` |
| `Primary AdvanceTax%` / `Primary AdvanceTax` | `AdvanceTaxRate` / `AdvanceTaxValue` |
| `PrimaryFurtherTax%` / `Primary FurtherTax` | `FurtherTaxRate` / `FurtherTaxValue` |
| `PrimaryMRP%` / `PrimaryMRP` | `MRPRate` / `MRPValue` |
| `PrimaryConfectionary%` / `PrimaryConfectionary` | `ConfectionaryTaxRate` / `ConfectionaryTaxValue` |
| `PrimaryInvoicePriceCS` / `PrimaryRetailPriceCS` / `PrimaryConsumerPriceCS` | Case-level price columns |
| `PrimaryNetSalesAmount` | `NetAmount` |
| `PrimarySalesAmountWithTax` | `TotalValueWithTax` |
| `PrimaryTotalTaxAmount` | `TotalTax` |
| `PrimaryTOAmount` / `PrimaryToPercentageValue` | `TOAmount` / `TOPercentageValue` |
| `Primary TotalPieces` | `TotalPieces` |

Derived:
```dax
Target vs Primary Achievement% = DIVIDE([Primary Tons], [PrimaryTarget(Tons)], 0)
```

---

## Distributor Stock (Opening/Closing balance pattern)

Every Opening/Closing measure follows the same two shapes. **Closing** = snapshot
at `MAX(Date)` with all date filters removed except that one date. **Opening** =
snapshot at the most recent date *before* `MIN(Date)` — i.e. the previous
available closing balance, so "opening stock for the period" always equals
"closing stock of the day before the period started."

```dax
Closing Stock (Tons) =
VAR _CurrentMaxDate = MAX('Dim_Date'[Date])
VAR _ClosingStock =
    CALCULATE(SUM('Distributor Stock'[TotalTons]), ALL('Dim_Date'), 'Dim_Date'[Date] = _CurrentMaxDate)
RETURN _ClosingStock

Opening Stock (Tons) =
VAR _CurrentMinDate = MIN('Dim_Date'[Date])
VAR _PreviousDate =
    CALCULATE(MAX('Dim_Date'[Date]), ALL('Dim_Date'), 'Dim_Date'[Date] < _CurrentMinDate)
VAR _OpeningStock =
    CALCULATE(SUM('Distributor Stock'[TotalTons]), ALL('Dim_Date'), 'Dim_Date'[Date] = _PreviousDate)
RETURN _OpeningStock
```

Same Opening/Closing pair repeated for: `KGs`, `Cases`, `Pieces`, `TotalPieces`,
`InvoicePrice`, `InvoicePriceWithOutTax`, `TradePrice`, `RetailPrice`, `Tax`.

---

## SecondrySales (main fact — Status/Type filter contract)

**Core rule used everywhere below:** `Status = "Settled"` = Delivered,
`Status IN ("Open","Pending","Settled")` = Booked (Booked has no explicit
measure filter since it's typically the unfiltered/base state); `Type = "Sales"`
excludes returns from productivity/volume counts.

### Volume & value (Settled-filtered)
```dax
Net Sales Amount = CALCULATE(Sum(SecondrySales[NetAmount]), SecondrySales[Status]="Settled")
Secondary Sales Pieces = Calculate(SUM(SecondrySales[TotalPiecesDelivered]), SecondrySales[Status]="Settled")
Secondary Sales KGs = CALCULATE(SUM(SecondrySales[TotalKg]), SecondrySales[Status]="Settled")
Secondary Sales Tons = CALCULATE(SUM(SecondrySales[TotalTons]), SecondrySales[Status]="Settled")
Secondary Sales Cartons = CALCULATE(SUM(SecondrySales[Cartons]), SecondrySales[Status]="Settled")
Gross Amount WithOut Tax = CALCULATE([SalesAmountWithTax]-[TotalTaxAmount], SecondrySales[Status]="Settled")
Gross Amount With Tax = CALCULATE([SalesAmountWithTax]-[AdvanceTax]-[FurtherTax], SecondrySales[Status]="Settled")
Total Net Amount = CALCULATE([Net Sales Amount]-[Total Bill Discount Value], SecondrySales[Status]="Settled")
```

### Unfiltered passthrough sums (tax, pricing, discount components)
`GST`/`GST%`, `AdvanceTax`/`AdvanceTax%`, `FurtherTax`/`FurtherTax%`,
`TotalTaxAmount`, `SalesAmountWithTax`, `FMR`/`FMR%`, `MRP`/`MRP%`,
`Confecitionary%`/`ConfectionaryTax`, `InvoicePriceCS`/`RetailPriceCS`/`ConsumerPriceCS`,
`ToValue`, `ToPercentageAmount`, `Total Bill Discount Value`, `Other Bill Discount Value`,
`FreePieces`, `LMT Rental Value`, `WholeSale Discount Value`, `Z Champion Value`,
`LMT OffInvoice Value`, `TO Discount`, `OCD Value`, `Sales_Cases`, `Sales_Pieces`,
`DeliveredPieces`, `LMT Off Invoice 2026 Value`, `Visibility Discount Value`,
`Z-Cham Off Invoice Value`.

### Derived
```dax
Tax Amount = [TotalTaxAmount]-[AdvanceTax]-[FurtherTax]
Discount Amount = SUM(SecondrySales[OtherDiscount])+SUM(SecondrySales[ToAmount])
Total Discount Amount = SUM(SecondrySales[OtherDiscount])+SUM(SecondrySales[TotalBillDiscount])+SUM(SecondrySales[ToAmount])
Net Discount Amount = [Total Discount Amount]-[Discount  Reversal]
Discount  Reversal = SUM(SecondrySales[DiscountReversal])
Target vs  Secondary Achievement% = DIVIDE([Secondary Sales Tons],[Target Tons],0)
```

### Outlet / call productivity (Settled + Sales filter)
```dax
Productive Calls =
CALCULATE(DISTINCTCOUNT(SecondrySales[InvoiceCode]), SecondrySales[Status]="Settled", SecondrySales[Type]="Sales")

Unique Productive Outlets =
CALCULATE(DISTINCTCOUNT(SecondrySales[CustomerID]), SecondrySales[Status]="Settled", SecondrySales[Type]="Sales")

Unique SKU Sold =
CALCULATE(DISTINCTCOUNT(SecondrySales[ProductID]), SecondrySales[Status]="Settled", SecondrySales[Type]="Sales")

Total SKU Sold =
CALCULATE(DISTINCTCOUNT(SecondrySales[Inv_Prod_Key]), SecondrySales[Status]="Settled", SecondrySales[Type]="Sales")

SKU per Outlet = DIVIDE([Total SKU Sold], [Unique Productive Outlets], 0)
SKU per Bill   = DIVIDE([Total SKU Sold], [Productive Calls], 0)

Unplanned Productive Outlets =
CALCULATE(DISTINCTCOUNT(SecondrySales[CustomerID]), SecondrySales[Status]="Settled", SecondrySales[Type]="Sales",
    SecondrySales[RouteName]="Unplaned Route" || SecondrySales[RouteName]="")

Planned Productive Outlets =
CALCULATE(DISTINCTCOUNT(SecondrySales[CustomerID]), SecondrySales[Status]="Settled", SecondrySales[Type]="Sales",
    SecondrySales[RouteName]<>"Unplaned Route" && SecondrySales[RouteName]<>"")
```

### Drop size
```dax
DropSize(KGs)   = DIVIDE([Secondary Sales KGs], [Unique Productive Outlets], 0)
DropSize(Tons)  = DIVIDE([Secondary Sales Tons], [Unique Productive Outlets], 0)
DropSize(Value) = DIVIDE([Gross Amount With Tax], [Unique Productive Outlets], 0)
```

---

## PrimaryTargets

Same day-proration pattern as the `Targets` table (`ISINSCOPE('Dim_Date'[Date])
|| ISINSCOPE('Dim_Date'[Day])` → divide by days-in-month), applied to:
`PrimaryTarget(Tons)`, `PrimaryTarget(Pieces)`, `PrimaryTarget(Cases)`,
`PrimaryTarget(KGs)`, `PrimaryTarget(Value)`.

---

## AssignedShops

```dax
Assigned Shops Unique =
CALCULATE(DISTINCTCOUNT(AssignedShops[CustomerID]), REMOVEFILTERS(Dim_Product), REMOVEFILTERS(Dim_Outlets))

Assigned Shops Scheduled =
CALCULATE(COUNT(AssignedShops[CustomerID]), REMOVEFILTERS(Dim_Product), REMOVEFILTERS(Dim_Outlets))

Unique Producitivy %   = DIVIDE([Unique Productive Outlets], [Assigned Shops Unique], 0)
Scheduled  Producitivy % = DIVIDE([Productive Calls], [Assigned Shops Scheduled], 0)
```

`REMOVEFILTERS(Dim_Product)` / `REMOVEFILTERS(Dim_Outlets)` is deliberate — see
"Dim_Product isolation" note in `model-overview.md`. Without it, filtering to a
single Brand would shrink the assigned-shop denominator to only shops that sell
that brand, which would inflate productivity % incorrectly.

---

## Naming inconsistencies to clean up before portfolio publish

A few measures carry typos/casing inherited from iterative dev work — worth a
pass before showing this to recruiters, since consistent naming signals
attention to detail:

- `Producitivy` → `Productivity` (`Unique Producitivy %`, `Scheduled Producitivy %`)
- `Discount  Reversal` (double space) → `Discount Reversal`
- `Confecitionary%` → `Confectionary%`
- `Copy of Total SKU Sold` — looks like a leftover duplicate measure
  (`COUNTROWS` instead of `DISTINCTCOUNT`); confirm it's still needed or remove.
