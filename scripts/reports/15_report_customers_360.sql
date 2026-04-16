/*
===============================================================================
Report: Customer 360 (Advanced Analytics View)
===============================================================================
Purpose:
    Deliver a complete customer view combining:
    - Demographics
    - Transactional behavior
    - RFM segmentation
    - Customer Lifetime Value (CLV)
    - Cohort analysis
    - Activity status

Business Value:
    - Identify high-value customers (VIPs)
    - Detect churn risk
    - Enable targeted marketing strategies
    - Support retention and growth decisions
===============================================================================
*/

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

-- ============================================================
-- 1. BASE DATA
-- ============================================================
WITH base AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.birthdate,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
    FROM gold.fact_sales f
    INNER JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
),

-- ============================================================
-- 2. CUSTOMER AGGREGATION
-- ============================================================
agg AS (
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products
    FROM base
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
),

-- ============================================================
-- 3. DERIVED METRICS
-- ============================================================
metrics AS (
    SELECT *,
        DATEDIFF(DAY, last_order_date, GETDATE()) AS recency_days,
        DATEDIFF(MONTH, first_order_date, last_order_date) + 1 AS lifespan_months,
        DATETRUNC(MONTH, first_order_date) AS cohort_month
    FROM agg
),

-- ============================================================
-- 4. RFM SCORING
-- ============================================================
rfm AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY total_orders) AS f_score,
        NTILE(5) OVER (ORDER BY total_sales) AS m_score
    FROM metrics
),

-- ============================================================
-- 5. FINAL CLASSIFICATION
-- ============================================================
final AS (
    SELECT *,
        CASE
            WHEN r_score = 5 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 4 AND f_score >= 3 THEN 'Loyal Customers'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            ELSE 'Others'
        END AS customer_segment,

        CASE
            WHEN recency_days <= 30 THEN 'Active'
            WHEN recency_days BETWEEN 31 AND 90 THEN 'Warm'
            ELSE 'Cold'
        END AS activity_status
    FROM rfm
)

-- ============================================================
-- FINAL OUTPUT
-- ============================================================
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    -- Age segmentation
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END AS age_group,

    -- Cohort
    cohort_month,

    -- Behavior
    customer_segment,
    activity_status,

    -- RFM
    recency_days,
    total_orders AS frequency,
    total_sales AS monetary,
    r_score, f_score, m_score,

    -- KPIs
    total_quantity,
    total_products,
    lifespan_months,

    -- CLV
    total_sales AS clv,

    -- Averages
    CASE WHEN total_orders = 0 THEN 0
         ELSE total_sales / total_orders
    END AS avg_order_value,

    CASE WHEN lifespan_months = 0 THEN total_sales
         ELSE total_sales / lifespan_months
    END AS avg_monthly_spend

FROM final;
GO

-- 
SELECT * FROM gold.report_customers;