/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : BatchCode
Joined Tables     : Product, ProductDetail, ProductTax, Tax
Target            : dbo.New_Batch
Load type         : Full refresh
Note              : Tax is derived from RetailPrice/ConsumerPrice depending on
                     whether TaxDescription is 'MRP%' or 'GST%' — this is a
                     price-decomposition calc, not a stored tax value in OLTP.
********************************************************************/
SELECT
    p.ProductID,
    bc.BatchCodeName,
    pd.ProductDetailID,
    t.TaxID,
    t.TaxDescription,
    t.TaxPercentage,
    BatchCodeID as BatchKey,
    ExpiryDate,
    CONCAT(100, p.ProductID) AS 'ProductKey',
    pd.DistributionCasePrice / p.UnitPerCarton AS InvoicePrice,
    pd.RetailCasePrice / p.UnitPerCarton       AS TradePrice,
    CASE
        WHEN t.TaxDescription LIKE 'MRP%' THEN pd.ConsumerCasePrice / p.UnitPerCarton
        WHEN t.TaxDescription LIKE 'GST%' THEN pd.RetailCasePrice / p.UnitPerCarton
    END AS RetailPrice,

    -- Tax per unit (extracted from RetailPrice)
    ROUND(
        CASE
            WHEN t.TaxDescription LIKE 'MRP%' THEN pd.ConsumerCasePrice / p.UnitPerCarton
            WHEN t.TaxDescription LIKE 'GST%' THEN pd.RetailCasePrice / p.UnitPerCarton
        END
        / (1 + t.TaxPercentage / 100.0) * (t.TaxPercentage / 100.0)
    , 2) AS Tax,

    -- InvoicePrice minus the tax portion
    (pd.DistributionCasePrice / p.UnitPerCarton) -
    ROUND(
        CASE
            WHEN t.TaxDescription LIKE 'MRP%' THEN pd.ConsumerCasePrice / p.UnitPerCarton
            WHEN t.TaxDescription LIKE 'GST%' THEN pd.RetailCasePrice / p.UnitPerCarton
        END
        / (1 + t.TaxPercentage / 100.0) * (t.TaxPercentage / 100.0)
    , 2) AS InvoicePriceWithoutTax

FROM BatchCode bc
JOIN Product p           ON bc.ProductID = p.ProductID
JOIN ProductDetail pd     ON bc.ProductDetailID = pd.ProductDetailID
INNER JOIN ProductTax pt  ON pt.ProductID = p.ProductID
INNER JOIN Tax t          ON t.TaxID = pt.TaxID
WHERE 1 = 1
  AND (t.TaxDescription LIKE 'MRP%' OR t.TaxDescription LIKE 'GST%');
