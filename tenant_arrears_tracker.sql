--  Tenant Lease & Rent Arrears tracker

-- Section 1. Create Tables

CREATE DATABASE property_management;
USE property_management;



-- 1. Create Properties Table

CREATE TABLE Properties
(Property_ID INT PRIMARY KEY,
Property_Name VARCHAR (100) , 
Monthly_Rent DECIMAL(10, 2)
);


-- 2. Create Tenants Table
CREATE TABLE Tenants
(Tenant_ID INT PRIMARY KEY,
Tenant_Name VARCHAR (100),
Property_ID INT,
Lease_Start_Date DATE,
Lease_End_Date DATE,
FOREIGN KEY (Property_ID) REFERENCES Properties (Property_ID)
);

-- 3. Create Payments Table
CREATE TABLE Payments
(Payment_ID INT PRIMARY KEY ,
Tenant_ID INT ,
Payment_Date DATE ,
Amount_Paid DECIMAL (10, 2),
FOREIGN KEY (Tenant_ID) REFERENCES Tenants (Tenant_ID)
);

-- Section 2. Insert data into tables

-- Make sure we're in the correct database
USE property_management;

-- 1. Insert data into properties
INSERT INTO Properties (Property_ID, Property_Name, Monthly_Rent) VALUES
(101, ' Panarama Suite 1A ' , 15000.00) ,
(102, ' World Cup Park 6D ' , 12500.00) ,
(103, ' Violin Strings 2C' , 9500.00) ,
(104, ' MMA Apartments 4A ' , 15000.00) 
;

-- 2. Insert data into tenants
INSERT INTO Tenants (Tenant_ID, Tenant_Name, Property_ID, Lease_Start_Date, Lease_End_Date) VALUES
(1, ' ANTONIO ODENDAAL' , 101, '2026-01-01' , '2026-12-31') ,
(2, ' lionel messi' , 102, '2026-02-15' , '2027-02-14') ,
(3, '   Enrico Sangiuliano  ' , 103, '2026-03-01' , '2026-08-31') ,
(4, ' Conor McGregor' , 104, '2026-05-01' , '2027-04-30') 
;

-- 3. Insert data into payments (including full, partial and missing payments)
INSERT INTO Payments (Payment_ID, Tenant_ID, Payment_Date, Amount_Paid) VALUES
(1001, 1, '2026-07-01' , 15000.00) , -- Fully paid
(1002, 2 , '2026-07-02' , 10000.00) , -- Partially paid
(1003, 3, '2026-07-01' , 9500.00) -- Fully paid, and Conor hasn't paid anything
;

SELECT *
FROM Tenants;


 -- Section 3. Clean Data

-- 1. Turn off safe updates
SET SQL_SAFE_UPDATES = 0;

-- 2. Clean up propererties table
UPDATE Properties
SET Property_Name = TRIM(Property_Name) 
;

-- 3. Clean tenants table = fix spaces & use uppercase
UPDATE Tenants
SET Tenant_Name = UPPER(TRIM(Tenant_Name))
;

-- 4. Turn safe updates back on
SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM Tenants;


-- Section 4. Account status

SELECT
    t.Tenant_ID,
    t.Tenant_Name,
    p.Property_Name,
    p.Monthly_Rent,
    
    -- If nothing was paid, replace NULL with value 0
    COALESCE(SUM(pay.Amount_Paid) , 0) AS Total_Paid,
    -- Calculate remaining balance owed
    p.Monthly_Rent - COALESCE(SUM(pay.Amount_Paid) , 0) AS Balance_Owed,
    -- Flag arrears status
    CASE
              WHEN COALESCE(SUM(pay.Amount_Paid) , 0) = 0 THEN 'No Payment / Severe Arrears'
              WHEN COALESCE(SUM(pay.Amount_Paid) , 0) < p.Monthly_Rent THEN 'Patrial Payment / In Arrears'
              ELSE 'Account Up To Date'
	END AS Arrears_Status
FROM Tenants t
JOIN Properties p ON t.Property_ID = p.Property_Id
LEFT JOIN Payments pay ON t.Tenant_ID = pay.Tenant_ID
GROUP BY t.Tenant_ID, t.Tenant_Name, p.Property_Name, p.Monthly_Rent
;
              








