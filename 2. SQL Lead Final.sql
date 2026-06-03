CREATE TABLE leads (
    Cell_Type VARCHAR(255),
    City VARCHAR(255),
    Companion_Lead VARCHAR(255),
    Converted VARCHAR(50),
    Converted_Account_ID VARCHAR(255),
    Converted_Account_ID2 VARCHAR(255),
    Country VARCHAR(255),
    Create_in_Zendesk VARCHAR(50),
    Created_By_eContacts VARCHAR(50),
    Created_Date DATE,
    Dead_Reason VARCHAR(255),
    Email_Opt_Out VARCHAR(50),
    Industry VARCHAR(255),
    Key_Account VARCHAR(50),
    Last_Status_Change VARCHAR(255),
    Lead_Application VARCHAR(255),
    Lead_ID VARCHAR(255) PRIMARY KEY,
    Source_category VARCHAR(255),
    Lead_Source VARCHAR(255),
    Lead_Status_at_Conversion VARCHAR(255),
    Lead_Status_Automation_Override VARCHAR(50),
    Lead_Type VARCHAR(255),
    LeadConSource VARCHAR(50),
    LeadRecordType VARCHAR(255),
    LS_Team_Notified VARCHAR(50),
    Marketing_Segmentation VARCHAR(255),
    Mass_Spec_Manufacturer VARCHAR(255),
    Mass_Spec_Type VARCHAR(255),
    Media_Provider VARCHAR(255),
    Opted_Out_of_Email VARCHAR(50),
    Other_Dead_Reason VARCHAR(255),
    Other_Mass_Spec_Type VARCHAR(255),
    Other_Research_Area VARCHAR(255),
    Pardot_Conversion_Date VARCHAR(255),
    Pardot_Conversion_Object_Type VARCHAR(255),
    Pardot_Created_Date VARCHAR(255),
    Pardot_First_Activity VARCHAR(255),
    Pardot_First_Referrer_Query VARCHAR(255),
    Pardot_First_Referrer_Type VARCHAR(255),
    Pardot_Grade VARCHAR(50),
    Pardot_Hard_Bounced VARCHAR(50),
    Pardot_Last_Activity VARCHAR(255),
    Pardot_Last_Scored_At VARCHAR(255),
    Pre_Act_on_Working_Lead VARCHAR(50),
    Primary_Application VARCHAR(255),
    Product_Category VARCHAR(255),
    Record_Type_ID VARCHAR(255),
    Region VARCHAR(255),
    Research_Area VARCHAR(255),
    Secondary_Application VARCHAR(255),
    SS_Team_Notified VARCHAR(50),
    State_Province VARCHAR(255),
    Status VARCHAR(255),
    Status_Simplified VARCHAR(255),
    Trained VARCHAR(50),
    Web_Lead_Notification_Sent VARCHAR(50),
    Converted_Accounts INT,
    Converted_Opportunities INT,
    Campaign_Membership_Count INT,
    Conversion_Rate FLOAT,
    Lead_Score INT,
    Number_of_Records INT,
    Pardot_Score INT,
    Population_Density VARCHAR(255),
    Total_Leads INT
);


SHOW VARIABLES LIKE "secure_file_priv";

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/lead dashboard 2.csv' 
INTO TABLE leads 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    Cell_Type, City, Companion_Lead, Converted, Converted_Account_ID, 
    Converted_Account_ID2, Country, Create_in_Zendesk, Created_By_eContacts, 
    @var_created_date, -- We read the date into a variable first
    Dead_Reason, Email_Opt_Out, Industry, Key_Account, 
    Last_Status_Change, Lead_Application, Lead_ID, Source_category, 
    Lead_Source, Lead_Status_at_Conversion, Lead_Status_Automation_Override, 
    Lead_Type, LeadConSource, LeadRecordType, LS_Team_Notified, 
    Marketing_Segmentation, Mass_Spec_Manufacturer, Mass_Spec_Type, 
    Media_Provider, Opted_Out_of_Email, Other_Dead_Reason, 
    Other_Mass_Spec_Type, Other_Research_Area, Pardot_Conversion_Date, 
    Pardot_Conversion_Object_Type, Pardot_Created_Date, Pardot_First_Activity, 
    Pardot_First_Referrer_Query, Pardot_First_Referrer_Type, Pardot_Grade, 
    Pardot_Hard_Bounced, Pardot_Last_Activity, Pardot_Last_Scored_At, 
    Pre_Act_on_Working_Lead, Primary_Application, Product_Category, 
    Record_Type_ID, Region, Research_Area, Secondary_Application, 
    SS_Team_Notified, State_Province, Status, Status_Simplified, 
    Trained, Web_Lead_Notification_Sent, @var_conv_acc, 
    @var_conv_opp, Campaign_Membership_Count, Conversion_Rate, 
    Lead_Score, Number_of_Records, Pardot_Score, Population_Density, Total_Leads
)
SET 
    -- This logic handles the 'na' error:
    Created_Date = IF(@var_created_date = 'na' OR @var_created_date = '', NULL, STR_TO_DATE(@var_created_date, '%Y-%m-%d')),
    Converted_Accounts = IF(@var_conv_acc = 'na', 0, @var_conv_acc),
    Converted_Opportunities = IF(@var_conv_opp = 'na', 0, @var_conv_opp);
    
-- =============================================
    SELECT * FROM leads;
-- =============================================
-- QUERY 1: Total Leads
-- =============================================
SELECT COUNT(`Lead_ID`) AS Total_Leads 
FROM leads;



-- =============================================
-- QUERY 2: Expected Amount from Converted Leads
-- =============================================
SELECT SUM(`Expected_Amount`) AS Expected_Amount_Converted_Leads
FROM opportunities;


-- =============================================
-- QUERY 3: Conversion Rate
-- =============================================
SELECT 
    (COUNT(CASE WHEN Converted = 'TRUE' THEN 1 END) / COUNT(*)) * 100 AS Conversion_Rate_Percent
FROM leads;

-- =============================================
-- QUERY 4: Converted Accounts
-- =============================================
SELECT SUM(`Converted_Accounts`) AS Total_Converted_Accounts
FROM leads;

-- =============================================
-- QUERY 5: Converted Opportunities
-- =============================================
SELECT SUM(`Converted_Opportunities`) AS Total_Converted_Opportunities
FROM leads;

-- =============================================
-- QUERY 6: Lead By Source
-- =============================================
SELECT `Lead_Source`, COUNT(*) AS Lead_Count
FROM leads
GROUP BY `Lead_Source`
ORDER BY Lead_Count DESC;

-- =============================================
-- QUERY 7: Lead By Industry
-- =============================================
SELECT Industry, COUNT(*) AS Lead_Count
FROM leads
GROUP BY Industry
ORDER BY Lead_Count DESC;

-- =============================================
-- QUERY 8: Lead By Stage
-- =============================================

SELECT Status, COUNT(*) AS Lead_Count
FROM leads
GROUP BY Status
ORDER BY Lead_Count DESC;
