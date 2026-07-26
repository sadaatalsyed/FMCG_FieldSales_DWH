/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : OrderBooker
Joined Tables     : AspNetUsers, Designation, AspNetUserLocality, Locality,
                     AspNetUserSubLocality, SubLocality
Target            : dbo.New_OrderBooker
Load type         : Full refresh
Note              : LocalityName/SubLocalityName use correlated subqueries +
                     STUFF/FOR XML PATH to comma-concatenate multiple locality
                     assignments per Order Booker into a single string column
                     (an Order Booker can be assigned to more than one locality).
********************************************************************/
SELECT
    'Zil' AS Company,
    d.Title AS Designation,
    ob.DistributionID,
    ob.Code AS OrderBookerCode,
    ob.Name AS OrderBookerName,
    ob.CNIC,
    anu.Email,
    anu.PhoneNumber,
    CASE WHEN ob.[Status] = 1 THEN 'Active' ELSE 'InActive' END AS Status,
    ob.UserID,

    LocalityName =
        STUFF((
            SELECT DISTINCT ', ' + l.LocalityName
            FROM AspNetUserLocality aul
            INNER JOIN Locality l ON l.LocalityID = aul.LocalityID
            WHERE aul.UserID = ob.UserID
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)'), 1, 2, ''),

    SubLocalityName =
        STUFF((
            SELECT DISTINCT ', ' + sl.SubLocalityName
            FROM AspNetUserSubLocality ausl
            INNER JOIN SubLocality sl ON sl.SubLocalityID = ausl.SubLocalityID
            WHERE ausl.UserID = ob.UserID
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)'), 1, 2, ''),

    CONCAT(100, ob.OrderBookerID) AS OrderBookerKey

FROM OrderBooker ob
INNER JOIN AspNetUsers anu ON anu.Id = ob.UserID
INNER JOIN Designation d   ON d.DesignationID = anu.DesignationID AND anu.DesignationID = 1;
