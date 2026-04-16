/*
===============================================================================
Script: Cohort Analysis (Customer Retention)
===============================================================================
Purpose:
    Analyze customer retention by grouping customers into cohorts based on 
    their first purchase month and tracking repeat activity over time.

Outputs:
    - Cohort month
    - Months since first purchase
    - Active customers per cohort
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================================================';
PRINT 'COHORT ANALYSIS STARTED';
PRINT '================================================';

-- ============================================================
-- STEP 1: CUSTOMER FIRST PURCHASE (COHORT)
-- ============================================================

IF OBJECT_ID('tempdb..#customer_cohort') IS NOT NULL
    DROP TABLE #customer_cohort;

SELECT
    customer_key,
    MIN(DATETRUNC(month, order_date)) AS cohort_month
INTO #customer_cohort
FROM gold.fact_sales
GROUP BY customer_key;

PRINT 'Customer cohorts created';

-- ============================================================
-- STEP 2: CUSTOMER ACTIVITY BY MONTH
-- ============================================================

IF OBJECT_ID('tempdb..#customer_activity') IS NOT NULL
    DROP TABLE #customer_activity;

SELECT
    f.customer_key,
    DATETRUNC(month, f.order_date) AS activity_month
INTO #customer_activity
FROM gold.fact_sales f
GROUP BY f.customer_key, DATETRUNC(month, f.order_date);

PRINT 'Customer activity table created';

-- ============================================================
-- STEP 3: COHORT INDEX (MONTH DIFFERENCE)
-- ============================================================

IF OBJECT_ID('tempdb..#cohort_data') IS NOT NULL
    DROP TABLE #cohort_data;

SELECT
    ca.customer_key,
    cc.cohort_month,
    ca.activity_month,
    DATEDIFF(MONTH, cc.cohort_month, ca.activity_month) AS cohort_index
INTO #cohort_data
FROM #customer_activity ca
JOIN #customer_cohort cc
    ON ca.customer_key = cc.customer_key;

PRINT 'Cohort index calculated';

-- list of customers with same cohort month and same cohort index
SELECT 
    customer_key,
    cohort_month,
    cohort_index
FROM #cohort_data
ORDER BY cohort_month, cohort_index;
-- ============================================================
-- STEP 4: COHORT RETENTION TABLE
-- ============================================================

SELECT
    
    cohort_month,
    cohort_index,
    COUNT(DISTINCT customer_key) AS active_customers
FROM #cohort_data
GROUP BY cohort_month, cohort_index
ORDER BY cohort_month, cohort_index;

PRINT '================================================';
PRINT 'COHORT ANALYSIS COMPLETED';
PRINT '================================================';