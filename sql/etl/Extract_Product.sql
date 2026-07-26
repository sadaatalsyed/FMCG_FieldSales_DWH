/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : Product
Joined Tables     : [Type], Category, Brand, Segment, Variant, Principle
Target            : dbo.New_Product
Load type         : Full refresh
********************************************************************/
SELECT
    'Zil' AS 'CompanyName', p.ProductID, t.Title AS 'Type',
    cat.Title AS 'Category', b.Title AS 'Brand', seg.Title AS 'Segment', vnt.VariantName AS 'Variant',
    p.ProductCode, p.CompanyCode AS 'ProductCompanyCode', p.[Name] AS 'ProductName',
    p.DisplayName AS 'ProductDisplayName', p.UnitPerCarton, p.UnitWeight,
    p.UOM,
    p.Active,
    p.PackagingType,
    p.TonnageFactor,
    p.MainCode,
    CONCAT(100, p.ProductID) AS 'ProductKey'
FROM Product AS p
INNER JOIN [Type] AS t      ON t.TypeID = p.TypeID
INNER JOIN Category AS cat  ON cat.CategoryID = p.CategoryID
INNER JOIN Brand AS b       ON b.BrandID = p.BrandID
INNER JOIN Segment AS seg   ON seg.SegmentID = p.SegmentID
LEFT JOIN Variant AS vnt    ON vnt.VariantID = p.VariantID
INNER JOIN Principle AS p2  ON p2.PrincipleID = p.PrincipleID;
-- WHERE p.[Active] = 1  -- uncomment to load active products only
