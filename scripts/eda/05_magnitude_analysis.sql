/*
===============================================================================
Script: Magnitude Analysis (Aggregations & Distribution)
===============================================================================
Purpose:
    Analyze the magnitude and distribution of key business metrics across
    different dimensions such as geography, customer segments, and product
    categories.

    This helps:
    - Understand revenue distribution
    - Support business decision-making

Tables Used:
    - gold.fact_sales
    - gold.dim_customers
    - gold.dim_products

Techniques:
    - Aggregations (SUM, COUNT, AVG)
    - GROUP BY analysis
    - Ranking & segmentation
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================================================';
PRINT 'MAGNITUDE ANALYSIS STARTED';
PRINT '================================================';

-- ============================================================
-- 1. CUSTOMER DISTRIBUTION
-- ============================================================

PRINT '1. Customer distribution by country';

SELECT
    country,
    COUNT(*) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;


PRINT 'Customer distribution by gender';

SELECT
    gender,
    COUNT(*) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;


-- ============================================================
-- 2. PRODUCT DISTRIBUTION
-- ============================================================

PRINT '2. Product distribution';

SELECT
    category,
    COUNT(*) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- What is the average costs in each category?
SELECT
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;


-- ============================================================
-- 3. REVENUE DISTRIBUTION BY CATEGORY
-- ============================================================

PRINT '3. Revenue by product category';

SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue,
    COUNT(DISTINCT f.order_number) AS total_orders,
    SUM(f.sales_amount) * 1.0 / COUNT(DISTINCT f.order_number) AS avg_order_value
FROM gold.fact_sales f
JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;


-- ============================================================
-- 4. TOP CUSTOMERS (REVENUE CONTRIBUTION)
-- ============================================================

PRINT '4. Top customers by revenue';

SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;


-- ============================================================
-- 5. SALES DISTRIBUTION BY COUNTRY
-- ============================================================

PRINT '6. Sales distribution by country';

SELECT
    c.country,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_items_sold
FROM gold.fact_sales f
JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_revenue DESC;


PRINT '================================================';
PRINT 'MAGNITUDE ANALYSIS COMPLETED';
PRINT '================================================';