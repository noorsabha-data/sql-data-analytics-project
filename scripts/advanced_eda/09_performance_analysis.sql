/*
===============================================================================
Script: Performance Analysis (Year-over-Year & Benchmarking)
===============================================================================
Purpose:
    Analyze product performance over time by:
    - Comparing yearly sales against product-level averages
    - Measuring Year-over-Year (YoY) growth
    - Classifying trends (Above/Below Average, Increase/Decrease)

Business Value:
    - Identify consistently high-performing products
    - Detect declining or volatile products
    - Support strategic decisions (pricing, promotion, inventory)

Techniques Used:
    - Common Table Expressions (CTEs)
    - Window Functions: AVG(), LAG()
    - Conditional Logic: CASE
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================================================';
PRINT 'PERFORMANCE ANALYSIS STARTED';
PRINT '================================================';

-- ============================================================
-- STEP 1: Aggregate yearly sales per product
-- ============================================================
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    INNER JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
),

-- ============================================================
-- STEP 2: Add window calculations (avg + previous year)
-- ============================================================
enriched_sales AS (
    SELECT
        order_year,
        product_name,
        current_sales,

        -- Average sales per product across years
        AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,

        -- Previous year sales
        LAG(current_sales) OVER (
            PARTITION BY product_name 
            ORDER BY order_year
        ) AS py_sales

    FROM yearly_product_sales
)

-- ============================================================
-- STEP 3: Final analysis with derived metrics
-- ============================================================
SELECT
    order_year,
    product_name,
    current_sales,
    avg_sales,

    -- Difference from average
    current_sales - avg_sales AS diff_from_avg,

    CASE 
        WHEN current_sales > avg_sales THEN 'Above Average'
        WHEN current_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS avg_performance,

    -- Year-over-Year metrics
    py_sales,
    current_sales - py_sales AS yoy_change,

    CASE 
        WHEN py_sales IS NULL THEN 'No Prior Data'
        WHEN current_sales > py_sales THEN 'Growth'
        WHEN current_sales < py_sales THEN 'Decline'
        ELSE 'No Change'
    END AS yoy_trend

FROM enriched_sales
ORDER BY product_name, order_year;

PRINT '================================================';
PRINT 'PERFORMANCE ANALYSIS COMPLETED';
PRINT '================================================';