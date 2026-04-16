/*
===============================================================================
Script: Measures Exploration & KPI Summary
===============================================================================
Purpose:
    This script calculates key business metrics from the Gold layer to provide
    a high-level overview of business performance.

    It helps:
    - Understand revenue and sales volume
    - Measure customer and product activity
    - Support dashboard development

Tables Used:
    - gold.fact_sales
    - gold.dim_customers
    - gold.dim_products

Metrics Covered:
    - Revenue (Total Sales)
    - Sales Volume (Quantity)
    - Pricing (Average Price)
    - Orders (Total Orders)
    - Customers (Total & Active)
    - Products (Total)

Usage:
    - Initial business assessment
    - KPI validation before dashboarding
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================================================';
PRINT 'MEASURES & KPI ANALYSIS STARTED';
PRINT '================================================';

-- ============================================================
-- 1. CORE BUSINESS METRICS
-- ============================================================

PRINT '1. Core KPIs';

SELECT 
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    AVG(price) AS avg_price,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;


-- ============================================================
-- 2. CUSTOMER METRICS
-- ============================================================

PRINT '2. Customer metrics';

SELECT 
    COUNT(*) AS total_customers
FROM gold.dim_customers;

SELECT 
    COUNT(DISTINCT customer_key) AS active_customers
FROM gold.fact_sales;


-- ============================================================
-- 3. PRODUCT METRICS
-- ============================================================

PRINT '3. Product metrics';

SELECT 
    COUNT(*) AS total_products
FROM gold.dim_products;


-- ============================================================
-- 4. DERIVED BUSINESS KPIs
-- ============================================================

PRINT '4. Derived KPIs';

SELECT 
    SUM(sales_amount) * 1.0 / COUNT(DISTINCT order_number) AS avg_order_value,
    SUM(quantity) * 1.0 / COUNT(DISTINCT order_number) AS avg_items_per_order,
    SUM(sales_amount) * 1.0 / COUNT(DISTINCT customer_key) AS revenue_per_customer
FROM gold.fact_sales;


-- ============================================================
-- 5. CONSOLIDATED KPI REPORT (FOR DASHBOARDS)
-- ============================================================

PRINT '5. Consolidated KPI report';

SELECT 'Total Sales' AS metric, SUM(sales_amount) AS value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Customers', COUNT(*) FROM gold.dim_customers
UNION ALL
SELECT 'Active Customers', COUNT(DISTINCT customer_key) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(*) FROM gold.dim_products
UNION ALL
SELECT 'Average Order Value', 
       SUM(sales_amount) * 1.0 / COUNT(DISTINCT order_number)
FROM gold.fact_sales;


PRINT '================================================';
PRINT 'MEASURES & KPI ANALYSIS COMPLETED';
PRINT '================================================';


