-- =============================================================
-- Cohort Retention Analysis
-- E-Commerce Sales Analysis Project
-- =============================================================
-- Groups customers by their first purchase month (cohort)
-- and tracks how many return in subsequent months
-- =============================================================

-- Step 1: Identify each customer's cohort (first order month)
WITH customer_cohort AS (
    SELECT
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    WHERE status = 'delivered'
    GROUP BY customer_id
),

-- Step 2: Get all (customer, order_month) pairs
customer_activity AS (
    SELECT DISTINCT
        o.customer_id,
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month
    FROM orders o
    WHERE o.status = 'delivered'
),

-- Step 3: Join to get cohort_month and period offset
cohort_data AS (
    SELECT
        cc.cohort_month,
        ca.order_month,
        ca.customer_id,
        -- Period index: 0 = acquisition month, 1 = 1 month later, etc.
        PERIOD_DIFF(
            EXTRACT(YEAR_MONTH FROM STR_TO_DATE(CONCAT(ca.order_month, '-01'), '%Y-%m-%d')),
            EXTRACT(YEAR_MONTH FROM STR_TO_DATE(CONCAT(cc.cohort_month, '-01'), '%Y-%m-%d'))
        ) AS period_number
    FROM customer_cohort cc
    JOIN customer_activity ca ON cc.customer_id = ca.customer_id
)

-- Step 4: Pivot into cohort retention table
SELECT
    cohort_month,
    COUNT(DISTINCT CASE WHEN period_number = 0 THEN customer_id END) AS month_0,
    COUNT(DISTINCT CASE WHEN period_number = 1 THEN customer_id END) AS month_1,
    COUNT(DISTINCT CASE WHEN period_number = 2 THEN customer_id END) AS month_2,
    COUNT(DISTINCT CASE WHEN period_number = 3 THEN customer_id END) AS month_3,
    COUNT(DISTINCT CASE WHEN period_number = 4 THEN customer_id END) AS month_4,
    COUNT(DISTINCT CASE WHEN period_number = 5 THEN customer_id END) AS month_5,
    COUNT(DISTINCT CASE WHEN period_number = 6 THEN customer_id END) AS month_6
FROM cohort_data
GROUP BY cohort_month
ORDER BY cohort_month;

-- =============================================================
-- Retention Rate % (relative to cohort size)
-- =============================================================
WITH customer_cohort AS (
    SELECT customer_id,
           DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders WHERE status = 'delivered'
    GROUP BY customer_id
),
customer_activity AS (
    SELECT DISTINCT customer_id,
           DATE_FORMAT(order_date, '%Y-%m') AS order_month
    FROM orders WHERE status = 'delivered'
),
cohort_data AS (
    SELECT cc.cohort_month, ca.customer_id,
        PERIOD_DIFF(
            EXTRACT(YEAR_MONTH FROM STR_TO_DATE(CONCAT(ca.order_month,'-01'),'%Y-%m-%d')),
            EXTRACT(YEAR_MONTH FROM STR_TO_DATE(CONCAT(cc.cohort_month,'-01'),'%Y-%m-%d'))
        ) AS period_number
    FROM customer_cohort cc
    JOIN customer_activity ca ON cc.customer_id = ca.customer_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
    FROM cohort_data WHERE period_number = 0
    GROUP BY cohort_month
)
SELECT
    cd.cohort_month,
    cs.cohort_customers,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN period_number = 0 THEN cd.customer_id END) / cs.cohort_customers, 1) AS ret_m0,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN period_number = 1 THEN cd.customer_id END) / cs.cohort_customers, 1) AS ret_m1,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN period_number = 2 THEN cd.customer_id END) / cs.cohort_customers, 1) AS ret_m2,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN period_number = 3 THEN cd.customer_id END) / cs.cohort_customers, 1) AS ret_m3,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN period_number = 4 THEN cd.customer_id END) / cs.cohort_customers, 1) AS ret_m4,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN period_number = 5 THEN cd.customer_id END) / cs.cohort_customers, 1) AS ret_m5,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN period_number = 6 THEN cd.customer_id END) / cs.cohort_customers, 1) AS ret_m6
FROM cohort_data cd
JOIN cohort_size cs ON cd.cohort_month = cs.cohort_month
GROUP BY cd.cohort_month, cs.cohort_customers
ORDER BY cd.cohort_month;
