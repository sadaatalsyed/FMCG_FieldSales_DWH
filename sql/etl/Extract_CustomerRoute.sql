/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : [ZIL_SND].dbo.SA_CustomerRoute
Target            : dbo.Cube_CustomerRoute
Load type         : Incremental — CreatedOn BETWEEN @DateFrom AND @DateTo (SSIS params)
********************************************************************/
SELECT
    DistributionID,
    OrderBookerID,
    Weeks,
    Day,
    CustomerID,
    isRoute,
    VisitDate,
    CustomersRouteID,
    RouteName,
    Concat(100, OrderBookerID) OrderBookerKey,
    Concat(100, DistributionID) DistributionKey,
    Concat(100, CustomerID) CustomerKey,
    Concat(100, CustomersRouteID) CustomersRouteKey,
    FORMAT(VisitDate,'ddMMyyyy') AS 'DateKey',
    CreatedOn RouteCreatedon
FROM [ZIL_SND].dbo.SA_CustomerRoute
WHERE Cast(CreatedOn as Date) >= @DateFrom AND Cast(CreatedOn as Date) <= @DateTo;
