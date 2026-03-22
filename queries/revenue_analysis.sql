-- =============================================================
-- Revenue Analysis Queries
-- E-Commerce Sales Analysis Project
-- =============================================================

-- 1. Total Revenue (all time)
SELECT
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id)   AS total_orders,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    ROUND(SUM(oi.line_total) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered';

-- 2. Monthly Revenue Trend
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id)         AS orders,
    ROUND(SUM(oi.line_total), 2)       AS revenue,
    ROUND(AVG(oi.line_total), 2)       AS avg_item_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY month
ORDER BY month;

-- 3. Quarterly Revenue Breakdown
SELECT
    YEAR(o.order_date)                        AS year,
    QUARTER(o.order_date)                     AS quarter,
    ROUND(SUM(oi.line_total), 2)              AS revenue,
    COUNT(DISTINCT o.order_id)                AS orders,
    ROUND(SUM(oi.line_total) /
          COUNT(DISTINCT o.order_id), 2)      AS aov
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY year, quarter
ORDER BY year, quarter;

-- 4. Revenue by Customer Segment
SELECT
    c.segment,
    COUNT(DISTINCT o.order_id)         AS orders,
    ROUND(SUM(oi.line_total), 2)       AS revenue,
    ROUND(AVG(oi.line_total), 2)       AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c    ON o.customer_id = c.customer_id
WHERE o.status = 'delivered'
GROUP BY c.segment
ORDER BY revenue DESC;

-- 5. Revenue by Shipping Mode
SELECT
    o.shipping_mode,
    COUNT(DISTINCT o.order_id)   AS orders,
    ROUND(SUM(oi.line_total), 2) AS revenue,
    ROUND(AVG(DATEDIFF(o.ship_date, o.order_date)), 1) AS avg_ship_days
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY o.shipping_mode
ORDER BY revenue DESC;

-- 6. Month-over-Month Revenue Growth
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100,
    2) AS mom_growth_pct
FROM (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        ROUND(SUM(oi.line_total), 2)       AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY month
) monthly
ORDER BY month;
