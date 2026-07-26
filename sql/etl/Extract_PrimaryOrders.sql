/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT (Sales UNION ALL Return, values pre-negated on Return)
Main Source Table : PrimaryOrder / PrimaryOrderReturn
Joined Tables     : PrimaryOrderDetails / PrimaryOrderReturnDetails, Product
Target            : dbo.New_PrimaryOrders
Load type         : Incremental — CreatedOn range
Note              : Cases/TotalKg/TotalTons are derived from Cartons + Pieces at
                     extraction time using Product.UnitPerCarton/UnitWeight/
                     TonnageFactor, mirroring the same derivation pattern used in
                     Extract_SecondarySales.sql.
********************************************************************/

-- ===== Sales (stock IN) =====
SELECT si.DistributionID, si.ManufacturerInvoiceDate, si.StockType, si.StockStatus,
    si.ManufacturerInvoiceNumber, si.InvoiceNumber,
    sid1.ProductID, sid1.BatchCode, sid1.ExpiryDate, Cast(si.CreatedOn as Date) CreatedOn,
    cast(Sum(((isnull(sid1.Cartons,0) * p.UnitPerCarton) + isnull(sid1.pieces,0)) / p.UnitPerCarton) AS INT) AS 'Cases',
    Sum((ISNULL(sid1.Cartons,0) * ISNULL(p.UnitPerCarton,0)) + ISNULL(sid1.Pieces,0)) as 'TotalPieces',
    Sum((((ISNULL(sid1.Cartons,0) * ISNULL(p.UnitPerCarton,0)) + ISNULL(sid1.Pieces,0)) * ISNULL(p.unitWeight,0)) / 1000) AS 'TotalKg',
    Sum((((ISNULL(sid1.Cartons,0) * ISNULL(p.UnitPerCarton,0)) + ISNULL(sid1.Pieces,0)) * ISNULL(p.unitWeight,0)) / 1000 /
        CASE WHEN ISNULL(p.TonnageFactor,0) = 0 THEN 1000 ELSE p.TonnageFactor END) AS 'TotalTons',
    sid1.FMRRate, Sum(sid1.FMRAmount) AS 'FMRAmount',
    sid1.GSTRate, Sum(sid1.GSTValue) AS 'GSTValue', sid1.AdvanceTaxRate, Sum(sid1.AdvanceTaxValue) AS 'AdvanceTaxValue',
    sid1.FurtherTaxRate, Sum(sid1.FurtherTaxValue) AS 'FurtherTaxValue',
    sid1.MRPRate, Sum(sid1.MRPValue) AS 'MRPValue', sid1.ConfectionaryTaxRate, Sum(sid1.ConfectionaryTaxValue) AS 'ConfectionaryTaxValue',
    sid1.InvoicePriceCase, sid1.RetailPriceCase, sid1.ConsumerPriceCase,
    Sum(sid1.ValueWithoutTax) AS 'ValueWithoutTax', Sum(sid1.TotalTax) AS 'TotalTax',
    Sum(sid1.TotalValueWithTax) AS 'TotalValueWithTax', Sum(sid1.NetAmount) AS 'NetAmount',
    Sum(isnull(sid1.TOAmount,0)) AS 'TOAmount', Sum(isnull(sid1.TOPercentageValue,0)) AS 'TOPercentageValue',
    'Sales' AS 'Type',
    CONCAT(100, si.DistributionID) AS 'DistributionKey',
    CONCAT(100, sid1.ProductID) AS 'ProductKey',
    FORMAT(si.ManufacturerInvoiceDate,'ddMMyyyy') AS 'DateKey'
FROM PrimaryOrder AS si
INNER JOIN PrimaryOrderDetails AS sid1 ON sid1.PrimaryOrderID = si.PrimaryOrderID
INNER JOIN Product AS p ON p.ProductID = sid1.ProductID
WHERE Cast(si.CreatedOn as Date) >= @DeliveryDateFrom AND Cast(si.CreatedOn as Date) <= @DeliveryDateTo
  AND (
        (si.IsAutoDA = 1 AND si.StockStatus NOT IN ('Rejected', 'InTransit'))
        OR (si.IsAutoDA = 0 AND si.StockStatus = 'PO')
      )
GROUP BY si.DistributionID, si.ManufacturerInvoiceDate, si.StockType, si.StockStatus,
    si.ManufacturerInvoiceNumber, si.InvoiceNumber, sid1.ProductID, sid1.BatchCode,
    sid1.ExpiryDate, Cast(si.CreatedOn as Date), sid1.FMRRate, sid1.GSTRate,
    sid1.AdvanceTaxRate, sid1.FurtherTaxRate, sid1.MRPRate, sid1.ConfectionaryTaxRate,
    sid1.InvoicePriceCase, sid1.RetailPriceCase, sid1.ConsumerPriceCase, sid1.BatchCode

UNION ALL

-- ===== Return (stock OUT, values pre-negated) =====
SELECT si.DistributionID,
    COALESCE(si.ManufacturerInvoiceDate, si.ReturnDate) as ManufacturerInvoiceDate,
    si.StockType, si.StockStatus,
    si.ManufacturerInvoiceNumber, si.InvoiceNumber,
    sid1.ProductID, sid1.BatchCode, sid1.ExpiryDate, Cast(si.CreatedOn as Date) CreatedOn,
    -1 * cast(Sum(((isnull(sid1.Cartons,0) * p.UnitPerCarton) + isnull(sid1.pieces,0)) / p.UnitPerCarton) AS INT) AS 'Cases',
    -1 * Sum((ISNULL(sid1.Cartons,0) * ISNULL(p.UnitPerCarton,0)) + ISNULL(sid1.Pieces,0)) as 'TotalPieces',
    -1 * Sum((((ISNULL(sid1.Cartons,0) * ISNULL(p.UnitPerCarton,0)) + ISNULL(sid1.Pieces,0)) * ISNULL(p.unitWeight,0)) / 1000) AS 'TotalKg',
    -1 * Sum((((ISNULL(sid1.Cartons,0) * ISNULL(p.UnitPerCarton,0)) + ISNULL(sid1.Pieces,0)) * ISNULL(p.unitWeight,0)) / 1000 /
        CASE WHEN ISNULL(p.TonnageFactor,0) = 0 THEN 1000 ELSE p.TonnageFactor END) AS 'TotalTons',
    sid1.FMRRate, -1 * Sum(sid1.FMRAmount) AS 'FMRAmount',
    sid1.GSTRate, -1 * Sum(sid1.GSTValue) AS 'GSTValue', sid1.AdvanceTaxRate, Sum(sid1.AdvanceTaxValue * -1) AS 'AdvanceTaxValue',
    sid1.FurtherTaxRate, Sum(sid1.FurtherTaxValue * -1) AS 'FurtherTaxValue',
    sid1.MRPRate, Sum(sid1.MRPValue * -1) AS 'MRPValue', sid1.ConfectionaryTaxRate, Sum(sid1.ConfectionaryTaxValue * -1) AS 'ConfectionaryTaxValue',
    sid1.InvoicePriceCase, sid1.RetailPriceCase, sid1.ConsumerPriceCase,
    Sum(sid1.ValueWithoutTax * -1) AS 'ValueWithoutTax', Sum(sid1.TotalTax * -1) AS 'TotalTax',
    Sum(sid1.TotalValueWithTax * -1) AS 'TotalValueWithTax', Sum(sid1.NetAmount * -1) AS 'NetAmount',
    Sum(isnull(sid1.TOAmount,0) * -1) AS 'TOAmount', Sum(isnull(sid1.TOPercentageValue,0) * -1) AS 'TOPercentageValue',
    'Return' AS 'Type',
    CONCAT(100, si.DistributionID) AS 'DistributionKey',
    CONCAT(100, sid1.ProductID) AS 'ProductKey',
    FORMAT(COALESCE(si.ManufacturerInvoiceDate, si.ReturnDate),'ddMMyyyy') AS 'DateKey'
FROM PrimaryOrderReturn AS si
INNER JOIN PrimaryOrderReturnDetails AS sid1 ON sid1.PrimaryOrderReturnID = si.PrimaryOrderReturnID
INNER JOIN Product AS p ON p.ProductID = sid1.ProductID
WHERE Cast(si.CreatedOn as Date) >= @DeliveryDateFrom AND Cast(si.CreatedOn as Date) <= @DeliveryDateTo
GROUP BY si.DistributionID, si.ReturnDate, si.ManufacturerInvoiceDate, si.StockType, si.StockStatus,
    si.ManufacturerInvoiceNumber, si.InvoiceNumber, sid1.ProductID, sid1.BatchCode,
    sid1.ExpiryDate, Cast(si.CreatedOn as Date), sid1.FMRRate, sid1.GSTRate,
    sid1.AdvanceTaxRate, sid1.FurtherTaxRate, sid1.MRPRate, sid1.ConfectionaryTaxRate,
    sid1.InvoicePriceCase, sid1.RetailPriceCase, sid1.ConsumerPriceCase, sid1.BatchCode;
