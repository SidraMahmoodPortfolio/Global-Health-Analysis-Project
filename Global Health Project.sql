
-- Data Cleaning

SELECT *
INTO global_health_clean
FROM GlobalHealthProject..global_health;

SELECT *
FROM GlobalHealthProject..global_health_clean;

-- Check for Dupliactes

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Year,
             GDP_Per_Capita,
             Country,
             Life_Expectancy,
             Total_Population
             ORDER BY Country ) AS row_num
FROM GlobalHealthProject..global_health_clean;

WITH duplicates AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Year,
             GDP_Per_Capita,
             Country,
             Life_Expectancy,
             Total_Population
             ORDER BY Country ) AS row_num
FROM GlobalHealthProject..global_health_clean
)
SELECT *
FROM duplicates
WHERE row_num > 1;

-- Standardise Data

SELECT DISTINCT Country
FROM GlobalHealthProject..global_health_clean;

SELECT Distinct Country
FROM GlobalHealthProject..global_health_clean
WHERE Country Like '%,%';

SELECT DISTINCT Country,
       CASE
         WHEN CHARINDEX(',', Country)> 0 
         THEN LEFT(Country, CHARINDEX(',', Country)-1)
         ELSE Country
       END AS Counrty_Standarised
FROM GlobalHealthProject..global_health_clean;

UPDATE GlobalHealthProject..global_health_clean
SET Country = CASE
               WHEN CHARINDEX(',', Country)> 0 
               THEN LEFT(Country, CHARINDEX(',', Country)-1)
               ELSE Country
              END;

SELECT DISTINCT Country
FROM GlobalHealthProject..global_health_clean
WHERE Country LIKE 'Guinea%';

UPDATE GlobalHealthProject..global_health_clean
SET Country = 'Guinea'
WHERE Country LIKE 'Guinea%';

UPDATE GlobalHealthProject..global_health_clean
SET Country = 'Vietnam'
WHERE Country LIKE 'Viet%';

UPDATE GlobalHealthProject..global_health_clean
SET Country = 'Laos'
WHERE Country LIKE 'Lao%';

UPDATE GlobalHealthProject..global_health_clean
SET Life_Expectancy = ROUND([Life_Expectancy], 1);
UPDATE GlobalHealthProject..global_health_clean
SET [Life_Expectancy_Female] = ROUND([Life_Expectancy_Female], 1);
UPDATE GlobalHealthProject..global_health_clean
SET [Life_Expectancy_Male] = ROUND([Life_Expectancy_Male], 1);
UPDATE GlobalHealthProject..global_health_clean
SET [Unemployment_Rate] = ROUND([Unemployment_Rate], 1);
UPDATE GlobalHealthProject..global_health_clean
SET [Urban_Population_Percent] = ROUND([Urban_Population_Percent], 1);
UPDATE GlobalHealthProject..global_health_clean
SET [Water_Access_percent] = ROUND([Water_Access_percent], 1);
UPDATE GlobalHealthProject..global_health_clean
SET [GDP_Per_Capita] = ROUND([GDP_Per_Capita], 1);
UPDATE GlobalHealthProject..global_health_clean
SET [Sanitary_Expense_Per_GDP] = ROUND([Sanitary_Expense_Per_GDP], 1);
UPDATE GlobalHealthProject..global_health_clean
SET [CO2_Exposure_Percent] = ROUND([CO2_Exposure_Percent], 1);
UPDATE GlobalHealthProject..global_health_clean
SET [Air_Pollution] = ROUND([Air_Pollution], 1);
UPDATE GlobalHealthProject..global_health_clean
SET [Sanitary_Expense_Per_Capita] = ROUND([Sanitary_Expense_Per_Capita], 1);

-- Explaotory Data Analysis

SELECT *
FROM GlobalHealthProject..global_health_clean;

SELECT Country, AVG(Life_Expectancy) AS Avg_Life_Expectancy
FROM GlobalHealthProject..global_health_clean
GROUP BY Country
ORDER BY Avg_Life_Expectancy Desc;

SELECT Year, ROUND(AVG(Life_Expectancy),2) AS Avg_Life_Expectancy
FROM GlobalHealthProject..global_health_clean
GROUP BY Year
ORDER BY Year;

WITH rolling_total AS
(
SELECT Country,
       Year,
       Infant_Deaths
FROM GlobalHealthProject..global_health_clean
)
SELECT Country, 
       Year,
       Infant_Deaths,
       SUM(Infant_Deaths) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM rolling_total;

-- Tuberculosis Rate Yearly Change

SELECT Country,
       Year,
       Tuberculosis_per_100000,
ROUND(100 * (Tuberculosis_per_100000 - LAG(Tuberculosis_per_100000) OVER(
PARTITION BY Country ORDER BY Year))
/ NULLIF(LAG(Tuberculosis_per_100000) OVER(
PARTITION BY Country ORDER BY Year), 0), 2) AS tuberculosis_rate_change
FROM GlobalHealthProject..global_health_clean
ORDER BY 1;

-- Number of People of Unemployed per Country

SELECT Country, SUM(Total_Population) AS Sum_Population, SUM(Labour_Force_Total) AS Sum_Labour_Forces,
       ROUND(Labour_Force_Total * (Unemployment_Rate / 100), 0) AS Unemployed    
FROM GlobalHealthProject..global_health_clean
GROUP BY Country, Labour_Force_Total * (Unemployment_Rate / 100)
ORDER BY 1;

ALTER TABLE GlobalHealthProject..global_health_clean
ADD Unemployed INT;

UPDATE GlobalHealthProject..global_health_clean
SET Unemployed = ROUND(Labour_Force_Total * (Unemployment_Rate / 100), 0);

SELECT Country, SUM(Unemployed) AS Sum_Unemployed
FROM GlobalHealthProject..global_health_clean
GROUP BY Country
HAVING SUM(Unemployed) IS NOT NULL
ORDER BY 2;

-- Percentage of People Unemployed overall in each Country

WITH percent_unemployed_overall AS
(
SELECT Country, SUM(Labour_Force_Total) AS Sum_Labour_Forces, SUM(Unemployed) AS Sum_Unemployed
FROM GlobalHealthProject..global_health_clean
GROUP BY Country
)
SELECT Country, ROUND((Sum_Unemployed / Sum_Labour_Forces), 4) * 100 AS Percent_Unemployed_Overall
FROM percent_unemployed_overall
WHERE Sum_Labour_Forces IS NOT NULL
ORDER BY 2;

-- Total Number of Obese People per Country

SELECT Country, ROUND(SUM(Total_Population * (Obesity_rate_percent / 100)), 0) AS Obese_Population
FROM GlobalHealthProject..global_health_clean
GROUP BY Country
HAVING ROUND(SUM(Total_Population * (Obesity_rate_percent / 100)), 0) IS NOT NULL
ORDER BY 2;

-- Air Pollution

SELECT Country, ROUND(AVG(Air_pollution), 1) AS 'Avg_Air_Pollution(µg/m³)',
       CASE
           WHEN ROUND(AVG(Air_pollution), 1) <= 5 THEN 'Minimal/None'
           WHEN ROUND(AVG(Air_pollution), 1) <= 10 THEN 'Very Low'
           WHEN ROUND(AVG(Air_pollution), 1) <=25 THEN 'Moderate'
           WHEN ROUND(AVG(Air_pollution), 1) <= 35 THEN 'Unhealthy'
           WHEN ROUND(AVG(Air_pollution), 1) >35 THEN 'Very Unhealthy'
       END AS Health_Risk
FROM GlobalHealthProject..global_health_clean
GROUP BY Country
HAVING ROUND(AVG(Air_pollution), 1) IS NOT NULL
ORDER BY 2;

-- Obesity Rate Over Time

SELECT Country, Year, Obesity_Rate_Percent
FROM GlobalHealthProject..global_health_clean
WHERE Obesity_Rate_Percent IS NOT NULL
ORDER BY Country, Year;

-- Create Views

CREATE VIEW obesity_rate_over_time AS
SELECT Country, Year, Obesity_Rate_Percent
FROM GlobalHealthProject..global_health_clean
WHERE Obesity_Rate_Percent IS NOT NULL;

CREATE VIEW air_polution AS
SELECT Country, ROUND(AVG(Air_pollution), 1) AS 'Avg_Air_Pollution(µg/m³)'
FROM GlobalHealthProject..global_health_clean
GROUP BY Country
HAVING ROUND(AVG(Air_pollution), 1) IS NOT NULL;

CREATE VIEW overall_unemployment_percent AS
WITH percent_unemployed_overall AS
(
SELECT Country, SUM(Labour_Force_Total) AS Sum_Labour_Forces, SUM(Unemployed) AS Sum_Unemployed
FROM GlobalHealthProject..global_health_clean
GROUP BY Country
)
SELECT Country, ROUND((Sum_Unemployed / Sum_Labour_Forces), 4) * 100 AS Percent_Unemployed_Overall
FROM percent_unemployed_overall
WHERE Sum_Labour_Forces IS NOT NULL;

CREATE VIEW sum_umemploymemt AS
SELECT Country, SUM(Unemployed) AS Sum_Unemployed
FROM GlobalHealthProject..global_health_clean
GROUP BY Country
HAVING SUM(Unemployed) IS NOT NULL;

CREATE VIEW infant_deaths AS
WITH rolling_total AS
(
SELECT Country,
       Year,
       Infant_Deaths
FROM GlobalHealthProject..global_health_clean
)
SELECT Country, 
       Year,
       Infant_Deaths,
       SUM(Infant_Deaths) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM rolling_total;

CREATE VIEW avg_life_expectancy AS
SELECT Country, AVG(Life_Expectancy) AS Avg_Life_Expectancy
FROM GlobalHealthProject..global_health_clean
GROUP BY Country
HAVING AVG(Life_Expectancy) IS NOT NULL;

SELECT *
FROM GlobalHealthProject..global_health_Clean
