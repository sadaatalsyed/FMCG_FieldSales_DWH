/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : DistributionTargets
Joined Tables     : Product
Target            : dbo.New_SalesTargets
Load type         : Monthly — current month (Month = MONTH(GETDATE()-1), Year likewise)
********************************************************************/
SELECT
    dt.DistributionID,
    dt.ProductID,
    dt.Month,
    dt.Year,

    -- Total days in the target month
    DAY(EOMONTH(DATEFROMPARTS(dt.Year, dt.Month, 1))) AS DaysInMonth,

    -- Monthly targets
    SUM(ISNULL(dt.TargetTonage,0)) AS TargetTons,
    SUM(ISNULL(dt.TargetPieces,0)) AS TargetPieces,
    SUM(ISNULL(dt.TargeValue,0)) AS TargetValue,
    SUM(ISNULL(dt.TargetPieces,0) * p.UnitWeight / 1000.0) AS TargetKGs,
    SUM(ISNULL(dt.TargetPieces,0) / NULLIF(p.UnitPerCarton,0)) AS TargetCases,

    Concat(100, dt.DistributionID) AS DistributionKey,
    Concat(100, dt.ProductID) AS ProductKey,
    CONCAT(format(DATEFROMPARTS(dt.[Year], dt.[Month], 1),'MM'), dt.Year) AS 'MonthYearKey'
FROM DistributionTargets dt
JOIN Product p ON dt.ProductID = p.ProductID
WHERE dt.[Month] = month(GETDATE() - 1) AND dt.[Year] = YEAR(GETDATE() - 1)
GROUP BY
    dt.DistributionID,
    dt.ProductID,
    dt.Month,
    dt.Year,
    DAY(EOMONTH(DATEFROMPARTS(dt.Year, dt.Month, 1)));
