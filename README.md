# Global-Health-Analysis-Project
Self-directed global health data project using SQL for analysis and Power BI for dashboard

Tools Used
`.SQL Server (Data Cleaning, Transformation, View Creation)
 .Power BI (Data Visualization, DAX, Conditional Formatting)
 .DAX (Custom calculations, measures)`

Data Cleaning & Transformation (SQL)
`.Removed duplicates using ROW_NUMBER() and CTEs
 .Standardized country names (e.g., “Guinea-Bissau” → “Guinea”)
 .Rounded numerical fields for clean and readable visuals
 .Created new columns (e.g., estimated unemployed population)
 .Created views to simplify Power BI integration`

Data Analysis (SQL)
 Aggregated data to analyze:
   .Average life expectancy by country and year
   .Total infant deaths and rolling totals
   .Tuberculosis rate change over years
   .Obesity and unemployment rates across regions
 Used SQL window functions (LAG(), OVER()) for deeper insights

Data Visualization & DAX (Power BI)
`.Created calculated fields and custom measures using DAX
 .Built rolling totals, average trends, and percent change metrics
 .Applied conditional formatting to highlight critical valueS
 .Enhanced visuals with tooltips, data labels, and slicers`

 Key Insights
`.Infant mortality remains critically high in South Asia and Sub-Saharan Africa
 .Life expectancy showed consistent improvement until 2019, then dropped, possibly due to COVID-19
 .Air pollution in Africa and Asia is at levels considered very unhealthy
 .Obesity rates have slightly declined globally over the last decade
 .Unemployment remains a significant issue, especially in Europe and Asia`


    
