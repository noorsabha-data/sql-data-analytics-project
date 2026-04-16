/*
===============================================================================
Script: Customer 360 Analysis
===============================================================================
Purpose:
    Build a unified customer view combining:
    - RFM Segmentation
    - Customer Lifetime Value (CLV)
    - Cohort (first purchase)
    - Activity metrics

Business Value:
    - Identify high-value customers
    - Detect churn risk
    - Enable personalized marketing
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================ CUSTOMER 360 STARTED ================';

-- ============================================================
-- STEP 1: Base metrics
-- ============================================================
WITH base AS (
    SELECT
        customer_key,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_revenue,
        AVG(sales_amount) AS avg_order_value,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order
    FROM gold.fact_sales
    GROUP BY customer_key
),

-- ============================================================
-- STEP 2: Derived metrics
-- ============================================================
metrics AS (
    SELECT *,
        DATEDIFF(DAY, last_order, GETDATE()) AS recency,
        DATEDIFF(MONTH, first_order, last_order) + 1 AS lifespan_months,
        DATETRUNC(month, first_order) AS cohort_month
    FROM base
),

-- ============================================================
-- STEP 3: RFM scores
-- ============================================================
rfm AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY total_orders) AS f_score,
        NTILE(5) OVER (ORDER BY total_revenue) AS m_score
    FROM metrics
),

-- ============================================================
-- STEP 4: Final classification
-- ============================================================
final AS (
    SELECT *,
        CASE
            WHEN r_score = 5 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 4 AND f_score >= 3 THEN 'Loyal Customers'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            ELSE 'Others'
        END AS segment,

        CASE
            WHEN recency <= 30 THEN 'Active'
            WHEN recency BETWEEN 31 AND 90 THEN 'Warm'
            ELSE 'Cold'
        END AS activity_status
    FROM rfm
)

-- ============================================================
-- FINAL OUTPUT
-- ============================================================
SELECT
    customer_key,
    segment,
    activity_status,
    cohort_month,

    -- RFM
    recency,
    total_orders AS frequency,
    total_revenue AS monetary,
    r_score, f_score, m_score,

    -- CLV
    total_revenue AS clv,
    avg_order_value,
    lifespan_months

FROM final
ORDER BY clv DESC;

PRINT '================ CUSTOMER 360 COMPLETED ================';