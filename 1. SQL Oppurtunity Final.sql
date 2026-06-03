-- =============================================
-------  Creation of table 2 Oppurtunities ---------------------

CREATE TABLE Opportunities (
    Account_ID VARCHAR(50),
    Backlog_Rev VARCHAR(50),
    Bio_Reactors_Used VARCHAR(100),
    BM_Test VARCHAR(50),
    Campaign_ID VARCHAR(50),
    Cell_Culture_Media VARCHAR(100),
    Cell_Type VARCHAR(100),
    Close_Date DATE,
    Closed VARCHAR(50),
    Closed_Lost_Reason TEXT,
    Contact_ID VARCHAR(50),
    COVID_Notes TEXT,
    COVID_Status VARCHAR(100),
    Created_By_ID VARCHAR(50),
    Created_by_Lead_Conversion VARCHAR(50),
    Created_Date DATE,
    Date_Opp_Closed VARCHAR(100), -- Kept as string due to "Not specified" values
    Deleted VARCHAR(50),
    DOR_Distributor VARCHAR(255),
    DOR_Expiration VARCHAR(100),
    Final_Quote VARCHAR(50),
    Fiscal_Period VARCHAR(50),
    Fiscal_Quarter INT,
    Fiscal_Year INT,
    Forecast_Category VARCHAR(50),
    Forecast_Category1 VARCHAR(50),
    Forecast_Q_Commit VARCHAR(50),
    Forecast_Q_Prior_Commit VARCHAR(50),
    Funding_Source VARCHAR(100),
    Has_Line_Item VARCHAR(50),
    Has_Open_Activity VARCHAR(50),
    Has_Overdue_Task VARCHAR(50),
    Industry VARCHAR(100),
    Install_This_Quarter VARCHAR(50),
    Interface_Type VARCHAR(100),
    Internal_Forecast VARCHAR(50),
    Last_Activity DATE,
    Last_Activity_Flag VARCHAR(10),
    Last_Modified_By_ID VARCHAR(50),
    Last_Modified_Date DATE,
    Last_Stage_Change_Date DATE,
    Last_Stage_Change_Date1 DATE,
    LDO VARCHAR(50),
    LDO_Priority VARCHAR(50),
    Lead_Application TEXT,
    Lead_Source VARCHAR(100),
    LS_Research_Area VARCHAR(100),
    Mass_Spec_Manufacturer VARCHAR(100),
    Mass_Spec_Type VARCHAR(100),
    Media_Provider VARCHAR(100),
    Opportunity_ID VARCHAR(50) PRIMARY KEY,
    Opportunity_Type VARCHAR(100),
    Order_Finalized VARCHAR(50),
    Other_Closed_Lost_Details TEXT,
    Other_Mass_Spec_Type VARCHAR(100),
    Other_Research_Area VARCHAR(100),
    Owner_ID VARCHAR(50),
    Price_Book_ID VARCHAR(50),
    Primary_Application TEXT,
    Primary_Application_FF TEXT,
    Primary_Contact VARCHAR(100),
    Product_Category VARCHAR(100),
    Product_of_Interest VARCHAR(255),
    Purchase_Agent VARCHAR(100),
    Quote_ID VARCHAR(50),
    Record_Type_ID VARCHAR(50),
    Registered_Vendor VARCHAR(50),
    Secondary_App_FF TEXT,
    Ship_This_Quarter VARCHAR(50),
    Ship_This_Quarter_List VARCHAR(100),
    Signing_Authority VARCHAR(100),
    Stage VARCHAR(100),
    Standard_Application VARCHAR(50),
    System_Modstamp VARCHAR(100),
    Technical_Owner VARCHAR(100),
    Validated_Needs VARCHAR(50),
    Won VARCHAR(50),
    Close_Date_Ext INT,
    Close_Date_Month_Ext INT,
    Amount DECIMAL(20,2),
    Days_Open INT,
    Expected_Amount DECIMAL(20,2),
    Probability INT,
    Push_Count INT
);

LOAD DATA LOCAL INFILE 'E:/DA- Classes/Projects/CRM Project/Data Cleaned/Oppertuninty Table 2_Clean.csv'
INTO TABLE Opportunities
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- =============================================
SELECT * FROM opportunities;

-- =============================================
-- QUERY 1: Total expected amount from all opportunities
-- =============================================
SELECT SUM(Expected_Amount) AS Total_Expected_Amount 
FROM Opportunities;

-- =============================================
-- QUERY 2: Count of active opportunities (excluding closed stages)
-- =============================================
SELECT COUNT(*) AS Active_Opportunities 
FROM Opportunities 
WHERE Stage NOT IN ('Closed Won', 'Closed Lost');

-- =============================================
-- QUERY 3: Conversion Rate
-- =============================================
SELECT 
    (SUM(CASE WHEN TRIM(UPPER(Won)) = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS Conversion_Rate
FROM Opportunities;

-- =============================================
-- QUERY 4: Win Rate
-- =============================================
SELECT 
    ROUND((SUM(CASE WHEN TRIM(UPPER(Won)) = 'TRUE' THEN 1 ELSE 0 END) / 
           NULLIF(SUM(CASE WHEN TRIM(UPPER(Closed)) = 'TRUE' THEN 1 ELSE 0 END), 0)) * 100, 2) AS Win_Rate_Percentage
FROM Opportunities;

-- =============================================
-- QUERY 5: Loss Rate
-- =============================================
SELECT 
    ROUND((SUM(CASE WHEN TRIM(UPPER(Closed)) = 'TRUE' AND TRIM(UPPER(Won)) = 'FALSE' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Loss_Rate_Percentage
FROM Opportunities;

-- =============================================
-- 6a) Expected VS Forecast Trend
-- =============================================
WITH MonthlyData AS (
    SELECT 
        DATE_FORMAT(`Created_Date`, '%Y-%m') AS Month_Period,
        SUM(`Expected_Amount`) AS Monthly_Expected,
        SUM(Amount) AS Monthly_Forecast
    FROM Opportunities
    GROUP BY Month_Period
)
SELECT 
    Month_Period,
    -- Running total of Expected Revenue
    ROUND(SUM(Monthly_Expected) OVER (ORDER BY Month_Period), 2) AS Cumulative_Expected,
    -- Running total of Forecasted Amount
    ROUND(SUM(Monthly_Forecast) OVER (ORDER BY Month_Period), 2) AS Cumulative_Forecast
FROM MonthlyData
ORDER BY Month_Period;
-- =============================================
-- 6b) Active Vs Total Oppurtunitues
-- =============================================

SELECT 
    -- 1. Format the date into Year-Month for grouping
    DATE_FORMAT(Created_Date, '%Y-%m') AS Month_Period,
    
    -- 2. Monthly Snapshots
    SUM(CASE WHEN Stage NOT IN ('Closed Won', 'Closed Lost') THEN 1 ELSE 0 END) AS Monthly_Active,
    COUNT(*) AS Monthly_Total,
    
    -- 3. Cumulative Trend (Running Totals)
    SUM(SUM(CASE WHEN Stage NOT IN ('Closed Won', 'Closed Lost') THEN 1 ELSE 0 END)) 
        OVER (ORDER BY DATE_FORMAT(Created_Date, '%Y-%m')) AS Cumulative_Active_Opportunities,
        
    SUM(COUNT(*)) 
        OVER (ORDER BY DATE_FORMAT(Created_Date, '%Y-%m')) AS Cumulative_Total_Opportunities

FROM Opportunities
-- Filter to prevent Error 1525 and remove 'garbage' data
WHERE Created_Date IS NOT NULL 
  AND Created_Date NOT IN ('', 'Unknown', 'NA', '00-00-0000')
GROUP BY Month_Period
ORDER BY Month_Period;

-- =============================================
-- 6c) Closed Won Vs Total Oppurtunities
-- =============================================
SELECT 
    -- 1. Format the date into Year-Month for grouping
    DATE_FORMAT(Created_Date, '%Y-%m') AS Month_Period,
    
    -- 2. Monthly Snapshots
    SUM(CASE WHEN Stage = 'Closed Won' THEN 1 ELSE 0 END) AS Monthly_Closed_Won,
    COUNT(*) AS Monthly_Total,
    
    -- 3. Cumulative Trend (Running Totals)
    SUM(SUM(CASE WHEN Stage = 'Closed Won' THEN 1 ELSE 0 END)) 
        OVER (ORDER BY DATE_FORMAT(Created_Date, '%Y-%m')) AS Cumulative_Closed_Won,
        
    SUM(COUNT(*)) 
        OVER (ORDER BY DATE_FORMAT(Created_Date, '%Y-%m')) AS Cumulative_Total_Opportunities

FROM Opportunities
-- Filter to prevent Error 1525 and remove 'garbage' data
WHERE Created_Date IS NOT NULL 
  AND Created_Date NOT IN ('', 'Unknown', 'NA', '00-00-0000')
GROUP BY Month_Period
ORDER BY Month_Period;

-- =============================================
-- 6d) Closed Won Vs Total Closed
-- =============================================

SELECT 
    -- 1. Format the date into Year-Month for grouping
    DATE_FORMAT(Created_Date, '%Y-%m') AS Month_Period,
    
    -- 2. Monthly Snapshots
    SUM(CASE WHEN Stage = 'Closed Won' THEN 1 ELSE 0 END) AS Monthly_Won,
    SUM(CASE WHEN Stage IN ('Closed Won', 'Closed Lost') THEN 1 ELSE 0 END) AS Monthly_Closed,
    
    -- 3. Cumulative Trend (Running Totals)
    -- Running total of successful deals
    SUM(SUM(CASE WHEN Stage = 'Closed Won' THEN 1 ELSE 0 END)) 
        OVER (ORDER BY DATE_FORMAT(Created_Date, '%Y-%m')) AS Cumulative_Closed_Won,
        
    -- Running total of all finalized deals (Won + Lost)
    SUM(SUM(CASE WHEN Stage IN ('Closed Won', 'Closed Lost') THEN 1 ELSE 0 END)) 
        OVER (ORDER BY DATE_FORMAT(Created_Date, '%Y-%m')) AS Cumulative_Total_Closed

FROM Opportunities
-- Filter to prevent Error 1525 and remove 'garbage' data
WHERE Created_Date IS NOT NULL 
  AND Created_Date NOT IN ('', 'Unknown', 'NA', '00-00-0000')
GROUP BY Month_Period
ORDER BY Month_Period;

-- =============================================
-- 7. Expected Amount by Oppurtunity 
-- =============================================

SELECT 
    Industry,
    -- 1. Numeric Sum (for the chart values)
    SUM(`Expected_Amount`) AS Total_Expected_Amount,
    
    -- 2. Formatted Sum (with commas for your report)
    FORMAT(SUM(`Expected_Amount`), 2) AS Formatted_Expected_Amount

FROM Opportunities
-- Cleaning: Exclude 'garbage' data from the report
WHERE Industry IS NOT NULL 
  AND Industry NOT IN ('Unknown', 'Not Specified', 'NA', '')
GROUP BY Industry
ORDER BY SUM(`Expected_Amount`) DESC;

-- =============================================
-- 8. Oppurtunities by Industry
-- =============================================
SELECT 
    Industry, 
    -- 1. Count the number of rows for each industry
    COUNT(*) AS Number_of_Opportunities  
FROM Opportunities
-- Cleaning: Filter out invalid or missing data
WHERE Industry IS NOT NULL 
  AND Industry NOT IN ('Unknown', 'Not Specified', 'NA', '')
GROUP BY Industry
-- Sort to show the busiest industries at the top
ORDER BY COUNT(*) DESC;

-- =============================================
-- Thank You
-- =============================================
