/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : SA_SalesDataDump
Joined Tables     : Product
Target            : dbo.SalesDataDump  (central fact table)
Load type         : Incremental — DeliveryDate range
Note              : Cases/Pieces/TotalKg/TotalTons are derived at extraction time
                     from TotalPiecesDelivered + Product.UnitPerCarton/UnitWeight/
                     TonnageFactor — the fact table stores these pre-computed,
                     it does not recompute them in DAX.
********************************************************************/
SELECT 'Zil' AS 'Company', DistributionID, CustomerID, InvoiceDate, DeliveryDate, [Status],
    OrderBookerID, SalemanID, VanID, RouteName, InvoiceCode, ssdd.ProductID,
    TotalPiecesOrdered, TotalPiecesDelivered, FMRRate, FMRAmount, GSTRate, GSTValue,
    AdvanceTaxRate, AdvanceTaxValue, FurtherTaxRate, FurtherTaxValue,
    MRPRate, MRPValue, ConfectionaryTaxRate, ConfectionaryTaxValue,
    InvoicePriceCase, RetailPriceCase, ConsumerPriceCase, ValueWithoutTax, TotalTax,
    TotalValueWithTax, NetAmount, ToAmount, TOPercentageValue, TotalBillDiscount,
    OtherDiscount, FreeSKUQuantity,
    LMTRentals, WholesaleDiscounts, ZChampion, LMTOffInvoice, [TO], OCD,
    ssdd.[LMT Off Invoice 2026], ssdd.[Visibility Discount], ssdd.[Z-Cham Off-Invoice],
    BatchCode, TYPE,
    isnull(DiscountValue,0) DiscountValue, isnull(DiscountReversal,0) AS DiscountReversal,
    (cast(ssdd.TotalPiecesDelivered AS DECIMAL(18,2)) / p.UnitPerCarton) AS 'Cases',
    (cast(ssdd.TotalPiecesDelivered AS DECIMAL(18,2)) % p.UnitPerCarton) AS 'Pieces',
    (ssdd.TotalPiecesDelivered * p.UnitWeight / 1000) AS 'TotalKg',
    ((ssdd.TotalPiecesDelivered * p.UnitWeight / 1000) /
        CASE WHEN p.TonnageFactor IS NULL OR p.TonnageFactor = 0 THEN 1000 ELSE p.TonnageFactor END
    ) AS 'TotalTons',

    CONCAT(100, ssdd.DistributionID) AS 'DistributionKey',
    CONCAT(100, ssdd.OrderBookerID)  AS 'OrderBookerKey',
    CONCAT(100, ssdd.SalemanID)      AS 'SalesmanKey',
    CONCAT(100, ssdd.VanID)          AS 'VanKey',
    CONCAT(100, ssdd.ProductID)      AS 'ProductKey',
    CONCAT(100, ssdd.CustomerID)     AS 'CustomerKey',
    FORMAT(ssdd.DeliveryDate,'ddMMyyyy') AS 'DateKey'

FROM SA_SalesDataDump AS ssdd
INNER JOIN Product AS p ON p.ProductID = ssdd.ProductID
WHERE 1 = 1
  AND ssdd.DeliveryDate BETWEEN @DeliveryDateFrom AND @DeliveryDateTo;
  -- e.g. AND ssdd.DeliveryDate BETWEEN '2025-10-01' AND '2026-02-28'
