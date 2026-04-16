/*
===============================================================================
Script: Ranking Analysis (Temp Table Optimized)
===============================================================================
Purpose:
    Identify top and bottom performers across products and customers using
    reusable temp tables for better performance and maintainability.

Key Improvements:
    - Eliminates CTE scope limitations
    - Reusable datasets across multiple queries
    - Faster execution for large datasets
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================================================';
PRINT 'RANKING ANALYSIS STARTED';
PRINT '================================================';

-- ============================================================
-- STEP 1: BUILD BASE DATASETS (TEMP TABLES)
-- ============================================================

PRINT 'Creating temp tables...';

-- Drop if exists (safe rerun)
IF OBJECT_ID('tempdb..#product_revenue') IS NOT NULL
    DROP TABLE #product_revenue;

IF OBJECT_ID('tempdb..#customer_revenue') IS NOT NULL
    DROP TABLE #customer_revenue;

-- Product Revenue
SELECT
    p.product_key,
    p.product_name,
    p.category,
    SUM(f.sales_amount) AS total_revenue
INTO #product_revenue
FROM gold.fact_sales f
JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_key, p.product_name, p.category;

-- Customer Revenue
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue,
    COUNT(DISTINCT f.order_number) AS total_orders
INTO #customer_revenue
FROM gold.fact_sales f
JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name;

PRINT 'Temp tables created successfully';

-- ============================================================
-- STEP 2: TOP 5 PRODUCTS
-- ============================================================

PRINT '1. Top 5 products by revenue';

SELECT TOP 5
    product_name,
    total_revenue
FROM #product_revenue
ORDER BY total_revenue DESC;

-- ============================================================
-- STEP 3: PRODUCT RANKING + % CONTRIBUTION
-- ============================================================

PRINT '2. Product ranking with revenue contribution';

SELECT
    product_name,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS rank_products,
    ROUND(100.0 * total_revenue / SUM(total_revenue) OVER (), 2) AS revenue_pct
FROM #product_revenue;

-- ============================================================
-- STEP 4: BOTTOM 5 PRODUCTS
-- ============================================================

PRINT '3. Bottom 5 products';

SELECT TOP 5
    product_name,
    total_revenue
FROM #product_revenue
ORDER BY total_revenue ASC;

-- ============================================================
-- STEP 5: TOP 10 CUSTOMERS
-- ============================================================

PRINT '4. Top 10 customers by revenue';

SELECT TOP 10
    customer_key,
    first_name,
    last_name,
    total_revenue
FROM #customer_revenue
ORDER BY total_revenue DESC;

-- ============================================================
-- STEP 6: CUSTOMER RANKING
-- ============================================================

PRINT '5. Customer ranking';

SELECT
    *,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS customer_rank
FROM #customer_revenue;

-- ============================================================
-- STEP 7: LOW ACTIVITY CUSTOMERS
-- ============================================================

PRINT '6-01. Lowest activity customers';

SELECT TOP 5
    customer_key,
    first_name,
    last_name,
    total_orders
FROM #customer_revenue
ORDER BY total_orders ASC;

-- Customers with only one order
PRINT '6-02. Customers with only one order';

SELECT 
    COUNT(*) AS customers_with_one_order
FROM #customer_revenue
WHERE total_orders = 1;

-- ============================================================
-- STEP 8: TOP PRODUCT PER CATEGORY (ADVANCED)
-- ============================================================

PRINT '7. Top product per category';

SELECT *
FROM (
    SELECT
        category,
        product_name,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY total_revenue DESC
        ) AS rn
    FROM #product_revenue
) t
WHERE rn = 1;

-- ============================================================
-- CLEANUP 
-- ============================================================

DROP TABLE #product_revenue;
DROP TABLE #customer_revenue;

PRINT '================================================';
PRINT 'RANKING ANALYSIS COMPLETED';
PRINT '================================================';