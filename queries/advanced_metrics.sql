-- ============================================================
-- ADVANCED BUSINESS METRICS — E-Commerce Sales Analysis
-- Author: Shivam Singh
-- Description: Advanced KPIs including AOV, CLV, basket analysis,
--              win-back rate, repeat purchase rate, and more.
-- ============================================================


-- ============================================================
-- 1. AVERAGE ORDER VALUE (AOV) — Overall & Monthly
-- ============================================================
-- AOV = Total Revenue / Number of Orders
-- Target: AOV > $75 is considered healthy for mid-market e-commerce

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY month
ORDER BY month;


-- ============================================================
-- 2. CUSTOMER LIFETIME VALUE (CLV / LTV)
-- ============================================================
-- CLV = AOV x Purchase Frequency x Customer Lifespan (months)
-- Simple historical CLV per customer

SELECT
    c.customer_id,
    c.name,
    c.city,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)        AS total_revenue,
    ROUND(AVG(oi.quantity * oi.unit_price), 2)        AS avg_order_value,
    DATEDIFF(MAX(o.order_date), MIN(o.order_date))    AS customer_lifespan_days,
    ROUND(
        SUM(oi.quantity * oi.unit_price) /
        NULLIF(DATEDIFF(MAX(o.order_date), MIN(o.order_date)) / 30, 0)
    , 2)                                               AS monthly_clv
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.name, c.city
HAVING total_orders > 1
ORDER BY monthly_clv DESC
LIMIT 20;


-- ============================================================
-- 3. REPEAT PURCHASE RATE
-- ============================================================
-- % of customers who made more than one purchase
-- Benchmark: 25-30% repeat purchase rate is healthy

SELECT
    COUNT(DISTINCT customer_id)                        AS total_customers,
    COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) AS repeat_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) * 100.0 /
        COUNT(DISTINCT customer_id), 2
    )                                                  AS repeat_purchase_rate_pct
FROM (
    SELECT customer_id, COUNT(order_id) AS order_count
    FROM orders
    WHERE status = 'delivered'
    GROUP BY customer_id
) order_counts;


-- ============================================================
-- 4. CUSTOMER WIN-BACK RATE (Lapsed Customer Recovery)
-- ============================================================
-- Customers who had no orders for 90+ days but then purchased again

WITH customer_gaps AS (
    SELECT
        customer_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
        DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_gap
    FROM orders
    WHERE status = 'delivered'
)
SELECT
    COUNT(DISTINCT customer_id)                          AS total_customers,
    COUNT(DISTINCT CASE WHEN days_gap >= 90 THEN customer_id END) AS winback_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN days_gap >= 90 THEN customer_id END) * 100.0 /
        COUNT(DISTINCT customer_id), 2
    )                                                    AS winback_rate_pct
FROM customer_gaps
WHERE days_gap IS NOT NULL;


-- ============================================================
-- 5. BASKET SIZE ANALYSIS (Items per Order)
-- ============================================================
-- Avg number of items per order — higher basket size = better upsell

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m')           AS month,
    COUNT(DISTINCT o.order_id)                   AS total_orders,
    SUM(oi.quantity)                             AS total_items_sold,
    ROUND(SUM(oi.quantity) / COUNT(DISTINCT o.order_id), 2) AS avg_basket_size,
    ROUND(AVG(oi.unit_price), 2)                 AS avg_item_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY month
ORDER BY month;


-- ============================================================
-- 6. CART ABANDONMENT RATE
-- ============================================================
-- Orders that were created but never delivered (proxy for abandonment)
-- Formula: (pending + cancelled) / total_orders * 100

SELECT
    status,
    COUNT(order_id)                              AS order_count,
    ROUND(COUNT(order_id) * 100.0 / SUM(COUNT(order_id)) OVER(), 2) AS pct_of_total
FROM orders
GROUP BY status
ORDER BY order_count DESC;


-- ============================================================
-- 7. REVENUE PER CUSTOMER SEGMENT (by City / Region)
-- ============================================================

SELECT
    c.city,
    COUNT(DISTINCT c.customer_id)                 AS customers,
    COUNT(DISTINCT o.order_id)                    AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)    AS total_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price) /
          COUNT(DISTINCT c.customer_id), 2)        AS revenue_per_customer
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY c.city
ORDER BY total_revenue DESC
LIMIT 15;


-- ============================================================
-- 8. PRODUCT RETURN RATE (if return data is available)
-- ============================================================
-- Cancelled orders as proxy for returns/dissatisfaction
-- High return rate (>5%) signals quality or expectation issues

SELECT
    p.category,
    COUNT(DISTINCT oi.order_id)                   AS total_orders,
    COUNT(DISTINCT CASE WHEN o.status = 'cancelled' THEN oi.order_id END) AS cancelled_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.status = 'cancelled' THEN oi.order_id END) * 100.0 /
        COUNT(DISTINCT oi.order_id), 2
    )                                             AS cancellation_rate_pct
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY cancellation_rate_pct DESC;


-- ============================================================
-- 9. MONTH-OVER-MONTH REVENUE GROWTH RATE
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m')               AS month,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)       AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)              AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0 /
        NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2
    )                                               AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;


-- ============================================================
-- 10. DISCOUNT EFFECTIVENESS — Revenue vs Discount Impact
-- ============================================================
-- Measures whether discounts actually drive higher quantities

SELECT
    CASE
        WHEN oi.discount = 0          THEN '0% - No Discount'
        WHEN oi.discount <= 0.10      THEN '1-10%'
        WHEN oi.discount <= 0.20      THEN '11-20%'
        WHEN oi.discount <= 0.30      THEN '21-30%'
        ELSE '31%+'
    END                                             AS discount_band,
    COUNT(DISTINCT oi.order_id)                     AS orders,
    ROUND(AVG(oi.quantity), 2)                      AS avg_qty_per_order,
    ROUND(AVG(oi.unit_price * oi.quantity), 2)      AS avg_revenue_per_order,
    ROUND(AVG(oi.unit_price * oi.quantity * oi.discount), 2) AS avg_discount_given
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
GROUP BY discount_band
ORDER BY MIN(oi.discount);
