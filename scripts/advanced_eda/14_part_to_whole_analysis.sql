/*
===============================================================================
Script: Part-to-Whole Analysis (Category Contribution)
===============================================================================
Purpose:
    Analyze how each product category contributes to total revenue.

Business Value:
    - Identify top-performing categories
    - Understand revenue distribution
    - Support product and marketing strategy decisions

Techniques Used:
    - Aggregation (SUM)
    - Window functions (SUM() OVER())
    - Percentage contribution calculation
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================================================';
PRINT 'PART-TO-WHOLE ANALYSIS STARTED';
PRINT '================================================';

-- ============================================================
-- STEP 1: Aggregate sales by category
-- ============================================================
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    INNER JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category
)

-- ============================================================
-- STEP 2: Calculate contribution %
-- ============================================================
SELECT
    category,
    total_sales,

    -- Total across all categories
    SUM(total_sales) OVER () AS overall_sales,

    -- Percentage contribution
    ROUND(
        (total_sales * 100.0) / SUM(total_sales) OVER (),
        2
    ) AS percentage_of_total,
    
    -- running total across all the categories
    SUM(total_sales) OVER (ORDER BY total_sales DESC) AS cumulative_total,
    
    -- Cumulative percentage across all the categories
    SUM(total_sales) OVER (ORDER BY total_sales DESC) * 100.0
    / SUM(total_sales) OVER () AS cumulative_percentage,

    -- Ranking categories
    RANK() OVER (ORDER BY total_sales DESC) AS category_rank

FROM category_sales
ORDER BY total_sales DESC;

PRINT '================================================';
PRINT 'PART-TO-WHOLE ANALYSIS COMPLETED';
PRINT '================================================';