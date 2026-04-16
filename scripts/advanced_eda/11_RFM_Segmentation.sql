/*
===============================================================================
Script: RFM Segmentation
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================ RFM SEGMENTATION STARTED ================';

-- ============================================================
-- STEP 1: Base metrics
-- ============================================================
WITH rfm_base AS (
    SELECT
        customer_key,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_number) AS frequency,
        SUM(sales_amount) AS monetary
    FROM gold.fact_sales
    GROUP BY customer_key
),

-- ============================================================
-- STEP 2: Calculate Recency
-- ============================================================
rfm_calc AS (
    SELECT
        customer_key,
        DATEDIFF(DAY, last_order_date, GETDATE()) AS recency, -- days since last purchase
        frequency,
        monetary
    FROM rfm_base
),

-- ============================================================
-- STEP 3: Score (1–5 using NTILE)
-- ============================================================
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,   -- lower recency = better
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM rfm_calc
)

-- ============================================================
-- STEP 4: Final segmentation
-- ============================================================
SELECT
    customer_key,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,

    CASE
        WHEN r_score = 5 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Potential Loyalists'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        ELSE 'Others'
    END AS customer_segment

FROM rfm_scores
ORDER BY customer_segment;

PRINT '================ RFM SEGMENTATION COMPLETED ================';