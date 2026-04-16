/*
===============================================================================
Script: Trend Analysis (Time-Based Insights)
===============================================================================
Purpose:
    Analyze business performance over time with advanced metrics.

    Provides:
    - Monthly revenue trends
    - Month-over-Month (MoM) growth
    - Year-over-Year (YoY) growth
    - Running total (cumulative revenue)
    - Moving average (trend smoothing)

Tables Used:
    - gold.fact_sales

Techniques:
    - DATETRUNC()
    - Window functions (LAG, SUM OVER, AVG OVER)
    - Temp tables for reuse
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================================================';
PRINT 'TREND ANALYSIS STARTED';
PRINT '================================================';

-- ============================================================
-- STEP 1: CREATE BASE MONTHLY DATA
-- ============================================================

IF OBJECT_ID('tempdb..#monthly_sales') IS NOT NULL
    DROP TABLE #monthly_sales;

SELECT
    DATETRUNC(month, order_date) AS month_start,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
INTO #monthly_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date);

PRINT 'Monthly dataset created';

-- ============================================================
-- STEP 2: BASIC TREND VIEW
-- ============================================================

PRINT '1. Monthly trend';

SELECT *
FROM #monthly_sales
ORDER BY month_start;

-- ============================================================
-- STEP 3: MONTH-OVER-MONTH (MoM) GROWTH 
-- ============================================================

PRINT '2. Month-over-Month growth';

SELECT
    month_start,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month_start) AS prev_month_sales,
    total_sales - LAG(total_sales) OVER (ORDER BY month_start) AS growth_value,
    ROUND(
        100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY month_start)) 
        / NULLIF(LAG(total_sales) OVER (ORDER BY month_start), 0),
        2
    ) AS growth_percent
FROM #monthly_sales
ORDER BY month_start;

PRINT 'Year-over-Year growth';
SELECT
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    LAG(SUM(sales_amount)) OVER (ORDER BY YEAR(order_date)) AS prev_year_sales,
    ROUND(
        100.0 * (
            SUM(sales_amount) - LAG(SUM(sales_amount)) OVER (ORDER BY YEAR(order_date))
        ) / NULLIF(LAG(SUM(sales_amount)) OVER (ORDER BY YEAR(order_date)), 0),
        2
    ) AS yoy_growth_percent
FROM gold.fact_sales
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- ============================================================
-- STEP 4: RUNNING TOTAL (CUMULATIVE REVENUE)
-- ============================================================

PRINT '3. Running total';

SELECT
    month_start,
    total_sales,
    SUM(total_sales) OVER (ORDER BY month_start) AS cumulative_sales
FROM #monthly_sales
ORDER BY month_start;

-- ============================================================
-- STEP 5: MOVING AVERAGE (TREND SMOOTHING)
-- ============================================================

PRINT '4. 3-Month Moving Average';

SELECT
    month_start,
    total_sales,
    AVG(total_sales) OVER (
        ORDER BY month_start 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_months
FROM #monthly_sales
ORDER BY month_start;

-- The running total of sales and moving avg of price over year 
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t

-- ============================================================
-- STEP 6: CUSTOMER TREND
-- ============================================================

PRINT '5. Customer growth trend';

SELECT
    month_start,
    total_customers,
    LAG(total_customers) OVER (ORDER BY month_start) AS prev_customers,
    total_customers - LAG(total_customers) OVER (ORDER BY month_start) AS customer_growth
FROM #monthly_sales
ORDER BY month_start;

-- ============================================================
-- CLEANUP
-- ============================================================

DROP TABLE #monthly_sales;

PRINT '================================================';
PRINT 'TREND ANALYSIS COMPLETED';
PRINT '================================================';