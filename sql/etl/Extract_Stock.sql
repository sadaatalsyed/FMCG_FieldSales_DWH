/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : InventorySnapshot
Joined Tables     : Product
Target            : dbo.New_Stock
Load type         : Incremental — SnapShotDate >= today-1 (runs daily)
********************************************************************/
SELECT 'Zil' AS 'CompanyName',
    is1.DistributionID, is1.BatchCode, is1.StockType,
    SUM(isnull(is1.TotalPieces,0)) AS TotalPieces,
    SUM(isnull(is1.HoldPieces,0)) AS 'HoldPieces',
    SUM(isnull(is1.TotalPieces,0) * p.UnitWeight / 1000) as TotalKGs,
    SUM((ISNULL(is1.TotalPieces,0) * p.UnitWeight / 1000) /
        CASE WHEN p.TonnageFactor IS NULL OR p.TonnageFactor = 0 THEN 1000 ELSE p.TonnageFactor END) TotalTons,
    SUM(Cast((ISNULL(is1.TotalPieces,0) / p.UnitPerCarton) as int)) as Cases,
    SUM(Cast((ISNULL(is1.TotalPieces,0) % p.UnitPerCarton) as int)) as Pieces,
    FORMAT(is1.SnapShotDate,'ddMMyyyy') AS 'DateKey',
    CONCAT(100, is1.ProductID) AS 'ProductKey',
    CONCAT(100, is1.DistributionID) AS 'DistributionKey'
FROM InventorySnapshot AS is1
JOIN Product p ON p.ProductID = is1.ProductID
WHERE cast(is1.SnapShotDate AS DATE) >= Cast(GETDATE() - 1 as Date)
GROUP BY is1.DistributionID, is1.BatchCode, is1.StockType, FORMAT(is1.SnapShotDate,'ddMMyyyy'),
    CONCAT(100, is1.ProductID), CONCAT(100, is1.DistributionID);
