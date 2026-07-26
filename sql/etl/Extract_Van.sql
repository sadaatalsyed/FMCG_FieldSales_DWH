/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : Van
Joined Tables     : VehicleType
Target            : dbo.New_Vans
Load type         : Full refresh
********************************************************************/
SELECT 'Zil' AS 'CompanyName', v.VanID, v.Code AS 'VanCode', v.Name AS 'VanName',
    v.RegistrationNumber, vt.Name AS 'VehicalType',
    CASE WHEN v.[Status] = 1 THEN 'Active' ELSE 'InActive' END AS 'Status',
    CONCAT(100, v.VanID) AS 'VanKey'
FROM Van AS v
LEFT JOIN VehicleType AS vt ON v.VehicleTypeID = vt.VehicleTypeID;
