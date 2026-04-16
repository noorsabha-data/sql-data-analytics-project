/*
===============================================================================
Script: Date Range & Temporal Analysis
===============================================================================
Purpose:
    Analyze the time coverage of the dataset and derive insights about:
    - Data availability
    - Business activity timeline
   

Tables Used:
    - gold.fact_sales
    - gold.dim_customers

Functions Used:
    - MIN(), MAX()
    - DATEDIFF()
    - GETDATE()

Usage:
    - Helps validate completeness of time-series data
    - Supports trend analysis 
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================================================';
PRINT 'DATE RANGE ANALYSIS STARTED';
PRINT '================================================';

-- ============================================================
-- 1. SALES DATE RANGE ANALYSIS
-- ============================================================

PRINT '1. Sales date range';

SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS total_months,
    DATEDIFF(DAY, MIN(order_date), MAX(order_date)) AS total_days
FROM gold.fact_sales;


-- ============================================================
-- 2. SALES ACTIVITY CONSISTENCY
-- ============================================================

PRINT '2. Monthly activity (check for missing months)';

SELECT 
    FORMAT(order_date, 'yyyy-MM') AS month,
    COUNT(*) AS total_orders
FROM gold.fact_sales
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY month;


-- ============================================================
-- 3. CUSTOMER AGE RANGE
-- ============================================================

PRINT '3. Customer age distribution';

SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age,
    AVG(DATEDIFF(YEAR, birthdate, GETDATE())) AS avg_age
FROM gold.dim_customers;



PRINT '================================================';
PRINT 'DATE RANGE ANALYSIS COMPLETED';
PRINT '================================================';