/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : OrderBookerTargets
Joined Tables     : Product, ProductDetail
Target            : dbo.New_Targets
Load type         : Monthly — current month (Month = MONTH(GETDATE()-1), Year likewise)
********************************************************************/
SELECT obt.DistributionID, obt.ProductID, obt.OrderBookerID, MONTH, YEAR,
    SUM(cast(isnull(obt.TargetPieces,0) AS FLOAT)) AS 'TargetPieces',
    SUM(cast(isnull(obt.TargetPieces,0) AS FLOAT) / cast(p.UnitPerCarton AS FLOAT)) AS 'TargetCases',
    SUM(isnull(obt.TargetPieces,0) * p.UnitWeight / 1000) AS 'TargetKg',
    SUM(isnull(obt.TargetTonage,0)) AS 'TargetTon',
    SUM((pd.DistributionCasePrice / p.UnitPerCarton) * obt.TargetPieces) as TargetInvoice,
    SUM(isnull(obt.TargeValue,0)) as 'TargetValue',
    CONCAT(100, obt.DistributionID) AS 'DistributionKey',
    CONCAT(100, obt.OrderBookerID) AS 'OrderBookerKey',
    CONCAT(100, obt.ProductID) AS 'ProductKey',
    CONCAT(format(DATEFROMPARTS(obt.[Year], obt.[Month], 1),'MM'), obt.Year) AS 'DateTargetKey'
FROM OrderBookerTargets AS obt
INNER JOIN Product AS p ON p.ProductID = obt.ProductID
INNER JOIN ProductDetail as pd ON pd.ProductID = p.ProductID AND pd.Active = 1
WHERE 1 = 1
  AND obt.[Month] = month(GETDATE() - 1) AND obt.[Year] = YEAR(GETDATE() - 1)
GROUP BY obt.DistributionID, obt.ProductID, obt.OrderBookerID, [MONTH], [YEAR];
