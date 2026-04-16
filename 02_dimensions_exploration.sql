/*
===============================================================================
Script: Dimension Exploration & Profiling
===============================================================================
Purpose:
    This script explores dimension tables in the Gold layer to understand:
    - Data distribution
    - Unique attribute values
    - Potential data quality issues
    - Business segmentation opportunities

Dimensions Covered:
    - gold.dim_customers
    - gold.dim_products

Usage:
    - Supports EDA and business analysis
    - Helps identify key segments (countries, categories, etc.)
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================================================';
PRINT 'DIMENSION EXPLORATION STARTED';
PRINT '================================================';

-- ============================================================
-- 1. CUSTOMER GEOGRAPHIC DISTRIBUTION
-- ============================================================

PRINT '1. Customer distribution by country';

SELECT 
    country,
    COUNT(*) AS customer_count
FROM gold.dim_customers
GROUP BY country
ORDER BY customer_count DESC;


-- ============================================================
-- 2. UNIQUE CUSTOMER ATTRIBUTES
-- ============================================================

PRINT '2. Unique customer attributes';

-- Marital status distribution
SELECT 
    marital_status,
    COUNT(*) AS count_customers
FROM gold.dim_customers
GROUP BY marital_status
ORDER BY count_customers DESC;

-- Gender distribution
SELECT 
    gender,
    COUNT(*) AS count_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY count_customers DESC;


-- ============================================================
-- 3. PRODUCT CATEGORY HIERARCHY
-- ============================================================

PRINT '3. Product category hierarchy';

SELECT DISTINCT 
    category,
    subcategory
FROM gold.dim_products
ORDER BY category, subcategory;


-- ============================================================
-- 4. PRODUCT DISTRIBUTION BY CATEGORY
-- ============================================================

PRINT '4. Number of products per category';

SELECT 
    category,
    COUNT(*) AS product_count
FROM gold.dim_products
GROUP BY category
ORDER BY product_count DESC;


-- ============================================================
-- 5. PRODUCT LINE DISTRIBUTION
-- ============================================================

PRINT '5. Product line distribution';

SELECT 
    product_line,
    COUNT(*) AS product_count
FROM gold.dim_products
GROUP BY product_line
ORDER BY product_count DESC;


-- ============================================================
-- 6. DATA QUALITY CHECKS (DIMENSIONS)
-- ============================================================

PRINT '6. Checking for NULL or unknown values';

-- Customers with missing country
SELECT COUNT(*) AS missing_country
FROM gold.dim_customers
WHERE country IS NULL OR country = 'n/a';

-- Products with missing category
SELECT COUNT(*) AS missing_category
FROM gold.dim_products
WHERE category IS NULL;


PRINT '================================================';
PRINT 'DIMENSION EXPLORATION COMPLETED';
PRINT '================================================';