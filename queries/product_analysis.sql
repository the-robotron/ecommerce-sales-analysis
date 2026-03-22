-- =============================================================
-- Product Analysis Queries
-- E-Commerce Sales Analysis Project
-- =============================================================

-- 1. Top 10 Products by Revenue
SELECT
    p.product_name,
    cat.category_name,
    SUM(oi.quantity)             AS units_sold,
    ROUND(SUM(oi.line_total), 2) AS revenue,
    ROUND(AVG(oi.discount)*100, 1) AS avg_discount_pct
FROM order_items oi
JOIN products p     ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
JOIN orders o       ON oi.order_id   = o.order_id
WHERE o.status = 'delivered'
GROUP BY p.product_id, p.product_name, cat.category_name
ORDER BY revenue DESC
LIMIT 10;

-- 2. Revenue by Category
SELECT
    cat.category_name,
    COUNT(DISTINCT oi.order_id)  AS orders,
    SUM(oi.quantity)             AS units_sold,
    ROUND(SUM(oi.line_total), 2) AS revenue,
    ROUND(SUM(oi.line_total) * 100.0 /
          SUM(SUM(oi.line_total)) OVER (), 2) AS revenue_share_pct
FROM order_items oi
JOIN products p     ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
JOIN orders o       ON oi.order_id   = o.order_id
WHERE o.status = 'delivered'
GROUP BY cat.category_id, cat.category_name
ORDER BY revenue DESC;

-- 3. Product Profit Margin Analysis
SELECT
    p.product_name,
    ROUND(p.unit_cost, 2)         AS unit_cost,
    ROUND(p.list_price, 2)        AS list_price,
    ROUND((p.list_price - p.unit_cost) / p.list_price * 100, 2) AS gross_margin_pct,
    SUM(oi.quantity)              AS units_sold,
    ROUND(SUM((oi.unit_price * (1 - oi.discount) - p.unit_cost) * oi.quantity), 2) AS net_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o   ON oi.order_id   = o.order_id
WHERE o.status = 'delivered'
GROUP BY p.product_id, p.product_name, p.unit_cost, p.list_price
ORDER BY net_profit DESC;

-- 4. Products with Highest Discount Impact
SELECT
    p.product_name,
    ROUND(AVG(oi.discount) * 100, 1)  AS avg_discount_pct,
    ROUND(SUM(oi.unit_price * oi.quantity * oi.discount), 2) AS total_discount_given,
    ROUND(SUM(oi.line_total), 2)       AS actual_revenue,
    ROUND(SUM(oi.unit_price * oi.quantity), 2) AS gross_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o   ON oi.order_id   = o.order_id
WHERE o.status = 'delivered'
GROUP BY p.product_id, p.product_name
HAVING AVG(oi.discount) > 0
ORDER BY avg_discount_pct DESC;

-- 5. Low-Stock Alert (reorder candidates)
SELECT
    p.product_name,
    cat.category_name,
    p.stock_qty,
    COALESCE(SUM(oi.quantity), 0) AS total_units_ordered
FROM products p
LEFT JOIN categories cat ON p.category_id = cat.category_id
LEFT JOIN order_items oi ON p.product_id  = oi.product_id
GROUP BY p.product_id, p.product_name, cat.category_name, p.stock_qty
HAVING p.stock_qty < 100
ORDER BY p.stock_qty ASC;
