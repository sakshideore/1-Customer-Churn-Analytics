---Create your database

CREATE DATABASE Customer_Churn_Analytics;
GO

USE Customer_Churn_Analytics;
GO

---Create a staging table
CREATE TABLE stg_Telco (
    customerID NVARCHAR(50),
    gender NVARCHAR(20),
    SeniorCitizen INT,
    Partner NVARCHAR(10),
    Dependents NVARCHAR(10),
    tenure INT,
    PhoneService NVARCHAR(10),
    MultipleLines NVARCHAR(50),
    InternetService NVARCHAR(50),
    OnlineSecurity NVARCHAR(50),
    OnlineBackup NVARCHAR(50),
    DeviceProtection NVARCHAR(50),
    TechSupport NVARCHAR(50),
    StreamingTV NVARCHAR(50),
    StreamingMovies NVARCHAR(50),
    Contract NVARCHAR(50),
    PaperlessBilling NVARCHAR(10),
    PaymentMethod NVARCHAR(100),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges NVARCHAR(50),
    Churn NVARCHAR(10)
);

---Create cleaned table
SELECT
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents,
    tenure,
    PhoneService,
    MultipleLines,
    InternetService,
    Contract,
    PaperlessBilling,
    PaymentMethod,
    MonthlyCharges,
    TRY_CONVERT(DECIMAL(10,2),
                NULLIF(LTRIM(RTRIM(TotalCharges)), ''))
                AS TotalCharges,
    Churn
INTO fact_CustomerChurn
FROM [dbo].[Telco-Customer-Churn];


----
SELECT COUNT(*) AS Total_Customers
FROM [dbo].[Telco-Customer-Churn];


---Overall churn performance.
SELECT
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
    SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END) AS Retained_Customers,
    ROUND( 100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2 ) AS Churn_Rate
FROM [dbo].[Telco-Customer-Churn];


---Churn by contract.
SELECT
    Contract,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2 ) AS Churn_Rate
FROM [dbo].[Telco-Customer-Churn]
GROUP BY Contract
ORDER BY Churn_Rate DESC;


---Revenue associated with churned customers.

SELECT Churn, COUNT(*) AS Customers,
 ROUND(SUM(TRY_CAST(MonthlyCharges AS DECIMAL(10,2))), 2) AS Monthly_Charges_Total,
 ROUND(AVG(TRY_CAST(MonthlyCharges AS DECIMAL(10,2))), 2) AS Average_Monthly_Charge
FROM [dbo].[Telco-Customer-Churn]
GROUP BY Churn;


---Customers with tenure below six months.
SELECT COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned
FROM [dbo].[Telco-Customer-Churn]
WHERE tenure <= 6;


---High monthly charges and churn.
SELECT CASE
WHEN TRY_CAST(MonthlyCharges AS DECIMAL(10,2)) < 35 THEN 'Low'
WHEN TRY_CAST(MonthlyCharges AS DECIMAL(10,2)) < 70 THEN 'Medium'
ELSE 'High' 
END AS Charge_Category,COUNT(*) AS Total_Customers,
SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0
END) AS Churned FROM [dbo].[Telco-Customer-Churn]
GROUP BY
CASE WHEN TRY_CAST(MonthlyCharges AS DECIMAL(10,2)) < 35 THEN 'Low'
     WHEN TRY_CAST(MonthlyCharges AS DECIMAL(10,2)) < 70 THEN 'Medium'
     ELSE 'High'
     END;
















