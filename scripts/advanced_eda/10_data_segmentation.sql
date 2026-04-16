/*
===============================================================================
Script: Data Segmentation Analysis (Products & Customers)
===============================================================================
Purpose:
    Perform segmentation analysis to group products and customers into 
    meaningful categories for business insights.

Business Value:
    - Understand product pricing distribution
    - Identify high-value (VIP) customers
    - Support targeted marketing and retention strategies

Techniques Used:
    - CASE-based segmentation
    - Aggregations (SUM, COUNT, MIN, MAX)
    - CTEs for modular and readable logic
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================================================';
PRINT 'DATA SEGMENTATION ANALYSIS STARTED';
PRINT '================================================';

-- ============================================================
-- 1. PRODUCT SEGMENTATION (BY COST RANGE)
-- ============================================================
PRINT '1. Product Segmentation by Cost Range';

WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(*) AS total_products,
    ROUND(AVG(cost), 2) AS avg_cost
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

PRINT '-----------------------------------------------';

-- ============================================================
-- 2. CUSTOMER SEGMENTATION (BY BEHAVIOR)
-- ============================================================
PRINT '2. Customer Segmentation by Spending Behavior';

WITH customer_spending AS (
    SELECT
        f.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan_months
    FROM gold.fact_sales f
    GROUP BY f.customer_key
),

segmented_customers AS (
    SELECT
        customer_key,
        total_spending,
        lifespan_months,
        CASE 
            WHEN lifespan_months >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
)

SELECT 
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(total_spending), 2) AS avg_spending
FROM segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;

PRINT '================================================';
PRINT 'DATA SEGMENTATION ANALYSIS COMPLETED';
PRINT '================================================';