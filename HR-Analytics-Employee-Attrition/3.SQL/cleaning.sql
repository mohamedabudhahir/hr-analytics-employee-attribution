/* create database*/
create database hr_employee_db;
use hr_employee_db;
SHOW TABLES;
SELECT COUNT(*) FROM hr_comma_sep;
SELECT * FROM hr_comma_sep LIMIT 5;
/*
File Name  : cleaning.sql
Project    : HR Attrition Analytics
Purpose    : Data quality and cleaning checks
Author     : Dhanashri Borse
Table Name : hr_comma_sep
*/

# 1. CHECK TOTAL ROW COUNT
SELECT COUNT(*) AS total_records
FROM hr_comma_sep;


# 2. CHECK NULL VALUES (COLUMN-WISE)
SELECT
    SUM(CASE WHEN Satisfaction_Level IS NULL THEN 1 ELSE 0 END) AS null_satisfaction_level,
    SUM(CASE WHEN Last_Evaluation IS NULL THEN 1 ELSE 0 END) AS null_last_evaluation,
    SUM(CASE WHEN Number_Project IS NULL THEN 1 ELSE 0 END) AS null_number_project,
    SUM(CASE WHEN average_montly_hours IS NULL THEN 1 ELSE 0 END) AS null_avg_monthly_hours,
    SUM(CASE WHEN Time_Spend_Company IS NULL THEN 1 ELSE 0 END) AS null_time_spend_company,
    SUM(CASE WHEN Work_Accident IS NULL THEN 1 ELSE 0 END) AS null_work_accident,
    SUM(CASE WHEN `Left` IS NULL THEN 1 ELSE 0 END) AS null_left,
    SUM(CASE WHEN Promotion_Last_5Years IS NULL THEN 1 ELSE 0 END) AS null_promotion,
    SUM(CASE WHEN Department IS NULL THEN 1 ELSE 0 END) AS null_department,
    SUM(CASE WHEN Salary IS NULL THEN 1 ELSE 0 END) AS null_salary
FROM hr_comma_sep;


# 3. CHECK DUPLICATE RECORDS (No employee ID, so using all business columns)
SELECT COUNT(*) AS total_duplicate
FROM (
    SELECT
        Satisfaction_Level,
        Last_Evaluation,
        Number_Project,
        average_montly_hours,
        Time_Spend_Company,
        Work_Accident,
        `Left`,
        Promotion_Last_5Years,
        Department,
        Salary
    FROM hr_comma_sep
    GROUP BY
        Satisfaction_Level,
        Last_Evaluation,
        Number_Project,
        average_montly_hours,
        Time_Spend_Company,
        Work_Accident,
        `Left`,
        Promotion_Last_5Years,
        Department,
        Salary
    HAVING COUNT(*) > 1
) dup;


# 4. CHECK DATA TYPES
DESCRIBE hr_comma_sep;


# 5. DATA TYPE CORRECTIONS (IF REQUIRED)
ALTER TABLE hr_comma_sep
MODIFY Satisfaction_Level DECIMAL(3,2),
MODIFY Last_Evaluation DECIMAL(3,2),
MODIFY Number_Project INT,
MODIFY average_montly_hours INT,
MODIFY Time_Spend_Company INT,
MODIFY Work_Accident TINYINT,
MODIFY `Left` TINYINT,
MODIFY Promotion_Last_5Years TINYINT,
MODIFY Department VARCHAR(50),
MODIFY Salary VARCHAR(20);
DESCRIBE hr_comma_sep;





/*
File Name  : kpi_queries.sql
Project    : HR Attrition Analytics
Purpose    : Business KPI analysis using SQL
Author     : Dhanashri Borse
Table Name : hr_comma_sep
*/

# 1. OVERALL ATTRITION RATE
# Business Question:
# What percentage of employees left the company?

SELECT
    COUNT(*) AS total_employees,
    SUM(`Left`) AS employees_left,
    ROUND(SUM(`Left`) / COUNT(*) * 100, 2) AS attrition_rate_percent
FROM hr_comma_sep;


# 2. ATTRITION BY DEPARTMENT
# Business Question:
# Which departments have the highest attrition risk?

SELECT
    Department,
    COUNT(*) AS total_employees,
    SUM(`Left`) AS employees_left,
    ROUND(SUM(`Left`) / COUNT(*) * 100, 2) AS attrition_rate_percent
FROM hr_comma_sep
GROUP BY Department
ORDER BY attrition_rate_percent DESC;


# 3. AVERAGE SATISFACTION BY SALARY LEVEL
# Business Question:
# Does salary level impact employee satisfaction?

SELECT
    Salary,
    ROUND(AVG(Satisfaction_Level), 2) AS avg_satisfaction_level,
    COUNT(*) AS employee_count
FROM hr_comma_sep
GROUP BY Salary
ORDER BY avg_satisfaction_level;

SHOW COLUMNS FROM hr_comma_sep;

# 4. WORKLOAD ANALYSIS: LEFT VS STAYED
# Business Question:
# Do employees who leave work more hours?

SELECT
    `Left` AS attrition_flag,
    ROUND(AVG(Average_Monthly_Hours), 2) AS avg_monthly_hours,
    ROUND(AVG(Number_Project), 2) AS avg_projects
FROM hr_comma_sep
GROUP BY `Left`;


-- ==================================================
-- 5. TENURE VS ATTRITION
-- ==================================================
-- Business Question:
-- At what tenure do employees leave the most?

SELECT
    Time_Spend_Company AS years_at_company,
    COUNT(*) AS total_employees,
    SUM(`Left`) AS employees_left,
    ROUND(SUM(`Left`) / COUNT(*) * 100, 2) AS attrition_rate_percent
FROM hr_comma_sep
GROUP BY Time_Spend_Company
ORDER BY years_at_company;


-- ==================================================
-- 6. PROMOTION IMPACT ON ATTRITION
-- ==================================================
-- Business Question:
-- Does lack of promotion increase attrition?

SELECT
    Promotion_Last_5Years,
    COUNT(*) AS total_employees,
    SUM(`Left`) AS employees_left,
    ROUND(SUM(`Left`) / COUNT(*) * 100, 2) AS attrition_rate_percent
FROM hr_comma_sep
GROUP BY Promotion_Last_5Years;


-- ==================================================
-- 7. WORK ACCIDENT VS ATTRITION
-- ==================================================
-- Business Question:
-- Is attrition related to workplace accidents?

SELECT
    Work_Accident,
    COUNT(*) AS total_employees,
    SUM(`Left`) AS employees_left,
    ROUND(SUM(`Left`) / COUNT(*) * 100, 2) AS attrition_rate_percent
FROM hr_comma_sep
GROUP BY Work_Accident;
