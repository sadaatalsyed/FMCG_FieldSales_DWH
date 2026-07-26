/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : Distribution
Joined Tables     : DistributionClass, Level1, Level2, Level3, Level4
Target            : dbo.New_Distribution
Load type         : Full refresh
********************************************************************/
SELECT 'Zil' AS 'CompanyName', d.DistributionID, d.Code AS 'DistributionCode',
    d.DisplayName AS 'DistributionName', d.LegalName AS 'DistributionLegalName',
    d.NTN, d.STN, d.[Address], d.SoldTo, d.ShipTo, dc.DistributionType, dc.ClassName AS 'DistributionClass',
    CASE WHEN d.[Active] = 1 THEN 'Active' ELSE 'InActive' END AS 'Status',
    d.OwnerContactNo AS 'Cell Number', d.OwnerCNIC AS 'OwnerCNIC', d.Phone AS 'Contact Number',
    d.OwnerEmail, d.OwnerName, d.POCDesignation, d.POCName, d.POCContactNo, d.POCEmail, d.Province, d.IntegratedWith,
    d.FBRIntegration, l1.Attribute1 as Zone,
    l1.Name AS 'Level1', l2.Name AS 'Level2', l3.Name AS 'Level3', l4.Name AS 'Level4',
    CONCAT(100, d.DistributionID) AS 'DistributionKey'
FROM Distribution AS d
LEFT JOIN DistributionClass AS dc ON dc.DistributionClassID = d.DistributionClassID
LEFT JOIN Level1 AS l1            ON l1.Level1ID = d.Level1ID
LEFT JOIN Level2 AS l2            ON l2.Level2ID = d.Level2ID
LEFT JOIN Level3 AS l3            ON l3.Level3ID = d.Level3ID
LEFT JOIN Level4 AS l4            ON l4.Level4ID = d.Level4ID;
