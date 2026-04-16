/*
===============================================================================
Report: Product 360 (Advanced Analytics View)
===============================================================================
Purpose:
    Provide a comprehensive view of product performance by combining:
    - Sales performance
    - Customer reach
    - Profitability
    - Time-based metrics
    - Contribution analysis (Pareto)

Business Value:
    - Identify top-performing and underperforming products
    - Analyze profitability and margins
    - Understand product lifecycle and demand trends
    - Support pricing and inventory decisions
===============================================================================
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

-- ============================================================
-- 1. BASE DATA
-- ============================================================
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    INNER JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

-- ============================================================
-- 2. PRODUCT AGGREGATION
-- ============================================================
product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,

        MIN(order_date) AS first_sale_date,
        MAX(order_date) AS last_sale_date,

        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,

        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity

    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
),

-- ============================================================
-- 3. DERIVED METRICS
-- ============================================================
metrics AS (
    SELECT *,
        DATEDIFF(DAY, last_sale_date, GETDATE()) AS recency_days,
        DATEDIFF(MONTH, first_sale_date, last_sale_date) + 1 AS lifespan_months,

        -- Pricing
        CASE 
            WHEN total_quantity = 0 THEN 0
            ELSE total_sales * 1.0 / total_quantity
        END AS avg_selling_price,

        -- Profit (basic approximation)
        (total_sales - (cost * total_quantity)) AS total_profit,

        CASE 
            WHEN total_sales = 0 THEN 0
            ELSE ((total_sales - (cost * total_quantity)) * 100.0 / total_sales)
        END AS profit_margin

    FROM product_aggregations
),

-- ============================================================
-- 4. CONTRIBUTION + RANKING
-- ============================================================
final AS (
    SELECT *,
        SUM(total_sales) OVER () AS overall_sales,

        -- % contribution
        (total_sales * 100.0 / SUM(total_sales) OVER ()) AS pct_of_total,

        -- cumulative %
        SUM(total_sales) OVER (ORDER BY total_sales DESC)
        * 100.0 / SUM(total_sales) OVER () AS cumulative_pct,

        -- ranking
        RANK() OVER (ORDER BY total_sales DESC) AS product_rank

    FROM metrics
)

-- ============================================================
-- FINAL OUTPUT
-- ============================================================
SELECT
    product_key,
    product_name,
    category,
    subcategory,

    -- Time
    first_sale_date,
    last_sale_date,
    recency_days,
    lifespan_months,

    -- Performance segmentation
    CASE
        WHEN total_sales > 50000 THEN 'High Performer'
        WHEN total_sales >= 10000 THEN 'Mid Range'
        ELSE 'Low Performer'
    END AS product_segment,

    -- Core metrics
    total_orders,
    total_customers,
    total_sales,
    total_quantity,

    -- Pricing & profit
    avg_selling_price,
    total_profit,
    profit_margin,

    -- KPIs
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    CASE
        WHEN lifespan_months = 0 THEN total_sales
        ELSE total_sales / lifespan_months
    END AS avg_monthly_revenue,

    -- Contribution analysis
    pct_of_total,
    cumulative_pct,
    product_rank,

    -- Pareto flag
    CASE 
        WHEN cumulative_pct <= 80 THEN 'Top 80% Revenue Drivers'
        ELSE 'Long Tail'
    END AS pareto_segment

FROM final;
GO

-- 
SELECT * FROM gold.report_products;