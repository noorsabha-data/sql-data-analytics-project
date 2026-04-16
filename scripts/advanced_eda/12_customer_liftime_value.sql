/*
===============================================================================
Script: Customer Lifetime Value (CLV)
===============================================================================
*/

SET NOCOUNT ON;

PRINT '================ CLV ANALYSIS STARTED ================';

WITH customer_metrics AS (
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

customer_lifespan AS (
    SELECT *,
        DATEDIFF(MONTH, first_order, last_order) + 1 AS lifespan_months
    FROM customer_metrics
)

SELECT
    customer_key,
    total_orders,
    total_revenue,
    avg_order_value,
    lifespan_months,

    -- CLV approximation
    total_revenue AS clv,

    -- Monthly value
    total_revenue / NULLIF(lifespan_months, 0) AS monthly_value

FROM customer_lifespan
ORDER BY clv DESC;

PRINT '================ CLV ANALYSIS COMPLETED ================';