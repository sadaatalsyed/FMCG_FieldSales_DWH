/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : [ZIL_SND].dbo.NonProductiveCustomers
Target            : dbo.NonProductiveCustomers
Load type         : Incremental — CreatedOn BETWEEN @DateFrom AND @DateTo
********************************************************************/
SELECT
    DistributionID,
    OrderBookerID,
    CustomerID,
    CustomersRouteID,
    ReasonCodeID,
    Reason,
    Lattitude,
    Longitude,
    Synchronized,
    CreatedOn,
    CONCAT(100, DistributionID) AS DistributionKey,
    CONCAT(100, OrderBookerID) AS OrderBookerKey,
    CONCAT(100, CustomerID) AS CustomerKey,
    CONCAT(100, CustomersRouteID) AS CustomersRouteKey,
    FORMAT(CreatedOn, 'ddMMyyyy') AS DateKey
FROM [ZIL_SND].dbo.NonProductiveCustomers
WHERE CAST(CreatedOn AS DATE) BETWEEN @DateFrom AND @DateTo;
