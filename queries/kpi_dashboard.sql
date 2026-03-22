-- ============================================================
-- EXECUTIVE KPI DASHBOARD VIEW — E-Commerce Sales Analysis
-- Author: Shivam Singh
-- Description: Single-query executive KPI summary. Run this to
--              get a snapshot of all critical business metrics.
-- ============================================================


-- ============================================================
-- EXECUTIVE SUMMARY — Single Row KPI Snapshot
-- ============================================================

SELECT
    -- Volume Metrics
    COUNT(DISTINCT o.order_id)                                           AS total_orders,
    COUNT(DISTINCT o.customer_id)                                        AS total_customers,
    SUM(oi.quantity)                                                     AS total_units_sold,

    -- Revenue Metrics
    ROUND(SUM(oi.quantity * oi.unit_price), 2)                           AS gross_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)       AS net_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * oi.discount), 2)             AS total_discount_given,

    -- Efficiency Metrics
    ROUND(SUM(oi.quantity * oi.unit_price) /
          COUNT(DISTINCT o.order_id), 2)                                 AS avg_order_value,
    ROUND(SUM(oi.quantity) / COUNT(DISTINCT o.order_id), 2)              AS avg_items_per_order,
    ROUND(SUM(oi.quantity * oi.unit_price) /
          COUNT(DISTINCT o.customer_id), 2)                              AS revenue_per_customer

FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered';


-- ============================================================
-- PERIOD-OVER-PERIOD COMPARISON (Current Quarter vs Previous)
-- ============================================================

WITH quarterly AS (
    SELECT
        QUARTER(o.order_date)                        AS qtr,
        YEAR(o.order_date)                           AS yr,
        COUNT(DISTINCT o.order_id)                   AS orders,
        COUNT(DISTINCT o.customer_id)                AS customers,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)   AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY yr, qtr
)
SELECT
    CONCAT(yr, ' Q', qtr)                           AS period,
    orders,
    customers,
    revenue,
    LAG(revenue) OVER (ORDER BY yr, qtr)             AS prev_quarter_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY yr, qtr)) * 100.0 /
        NULLIF(LAG(revenue) OVER (ORDER BY yr, qtr), 0), 2
    )                                                AS qoq_growth_pct
FROM quarterly
ORDER BY yr, qtr;


-- ============================================================
-- TOP 5 KPI METRICS FOR PORTFOLIO PRESENTATION
-- ============================================================
-- Run each metric separately to generate clean results:

-- 1. Total Revenue
SELECT ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered';

-- 2. Average Order Value
SELECT ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id), 2) AS aov
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered';

-- 3. Repeat Purchase Rate
SELECT
    ROUND(COUNT(DISTINCT CASE WHEN cnt > 1 THEN customer_id END) * 100.0 /
    COUNT(DISTINCT customer_id), 2) AS repeat_rate_pct
FROM (SELECT customer_id, COUNT(*) AS cnt FROM orders WHERE status='delivered' GROUP BY customer_id) t;

-- 4. Revenue Concentration (Top 20% customers = what % of revenue?)
WITH ranked AS (
    SELECT
        o.customer_id,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS cust_revenue,
        NTILE(5) OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS quintile
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.customer_id
)
SELECT
    quintile,
    COUNT(customer_id)                  AS customers,
    ROUND(SUM(cust_revenue), 2)         AS revenue,
    ROUND(SUM(cust_revenue) * 100.0 /
          SUM(SUM(cust_revenue)) OVER(), 2) AS revenue_share_pct
FROM ranked
GROUP BY quintile
ORDER BY quintile;

-- 5. Best-Performing Month (for resume/portfolio highlight)
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m')           AS best_month,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)   AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY best_month
ORDER BY revenue DESC
LIMIT 1;


-- ============================================================
-- IMPROVEMENT OPPORTUNITIES VIEW
-- ============================================================
-- Identifies categories and customers with high potential

-- Customers at churn risk (no orders in last 60 days)
SELECT
    customer_id,
    MAX(order_date) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(order_date)) AS days_since_last_order,
    COUNT(order_id) AS lifetime_orders,
    CASE
        WHEN DATEDIFF(CURDATE(), MAX(order_date)) > 90 THEN 'High Churn Risk'
        WHEN DATEDIFF(CURDATE(), MAX(order_date)) > 60 THEN 'Medium Churn Risk'
        ELSE 'Active'
    END AS churn_risk_label
FROM orders
WHERE status = 'delivered'
GROUP BY customer_id
HAVING days_since_last_order > 60
ORDER BY days_since_last_order DESC;

-- Underperforming categories (below average revenue per order)
SELECT
    p.category,
    COUNT(DISTINCT oi.order_id)                   AS orders,
    ROUND(AVG(oi.quantity * oi.unit_price), 2)    AS avg_revenue_per_order,
    (
        SELECT ROUND(AVG(oi2.quantity * oi2.unit_price), 2)
        FROM order_items oi2
        JOIN orders o2 ON oi2.order_id = o2.order_id
        WHERE o2.status = 'delivered'
    )                                              AS overall_avg_revenue,
    CASE
        WHEN AVG(oi.quantity * oi.unit_price) <
        (
            SELECT AVG(oi2.quantity * oi2.unit_price)
            FROM order_items oi2
            JOIN orders o2 ON oi2.order_id = o2.order_id
            WHERE o2.status = 'delivered'
        ) THEN 'Below Average — Needs Attention'
        ELSE 'At or Above Average'
    END AS performance_flag
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'delivered'
GROUP BY p.category
ORDER BY avg_revenue_per_order;
