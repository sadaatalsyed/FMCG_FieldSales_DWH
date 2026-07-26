/********************************************************************
Purpose           : Extract data (SSIS Data Flow Source)
Operation         : SELECT
Main Source Table : Customer
Joined Tables     : Channel, SubChannel, Element, SubElement, Locality, SubLocality,
                     CustomerAddress
Target            : dbo.New_Customers
Load type         : Full refresh
********************************************************************/
SELECT 'Zil' as 'CompanyName', c2.CustomerID, c2.Code AS 'CustomerCode', c2.MainCode AS 'CompanyCustomerCode',
    c2.NTN, c2.STN, c2.CNIC, c2.SalesTaxStatus, c2.IncomeTaxStatus, c2.ShopProgram,
    c2.Name AS 'CustomerName',
    c.Title AS 'ChannelName', sc.Title AS 'SubChannel', e.Title AS 'Element',
    se.Title AS 'SubElement', l.LocalityName, sl.SubLocalityName, c2.[Status] as 'Status',
    c2.Active,
    c2.OwnerName, c2.Mobile, c2.Lattitude, c2.Longitude, c2.Address, c2.Landmark,
    ca.Town as 'Oulet(Town)', ca.AddressLine1 as 'Outlet(Address)',
    CONCAT(100, c2.CustomerID) AS 'CustomerKey',
    CONCAT(100, C2.DistributionID) AS 'DistributionKey'
FROM Customer AS c2
LEFT JOIN Channel AS c        ON c.ChannelID = c2.ChannelID
LEFT JOIN SubChannel AS sc    ON sc.SubChannelID = c2.SubChannelID
LEFT JOIN Element AS e        ON e.ElementID = c2.ElementID
LEFT JOIN SubElement AS se    ON se.SubElementID = c2.SubElementID
LEFT JOIN Locality AS l       ON l.LocalityID = c2.LocalityID
LEFT JOIN SubLocality AS sl   ON sl.SubLocalityID = c2.SubLocalityID
LEFT JOIN CustomerAddress ca  ON ca.CustomerID = c2.CustomerID;
