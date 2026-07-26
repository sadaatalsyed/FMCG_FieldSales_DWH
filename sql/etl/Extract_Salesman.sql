/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : Salesmen
Joined Tables     : AspNetUsers, Designation
Target            : dbo.New_Salesman
Load type         : Full refresh
********************************************************************/
SELECT 'Zil' AS 'Company', d.Title AS 'Designation',
    ob.DistributionID, ob.Code as SaleManCode, ob.Name as SaleManName, ob.CNIC,
    anu.Email, anu.PhoneNumber,
    CASE WHEN ob.[Status] = 1 THEN 'Active' ELSE 'InActive' END AS 'Status',
    ob.UserID,
    CONCAT(100, ob.SalesmenID) AS 'SalesmanKey'
FROM Salesmen AS ob
INNER JOIN AspNetUsers AS anu ON anu.Id = ob.UserID
INNER JOIN Designation AS d   ON d.DesignationID = anu.DesignationID;
