-- =============================================================
-- RFM Customer Segmentation
-- E-Commerce Sales Analysis Project
-- =============================================================
-- RFM = Recency, Frequency, Monetary
-- Segments customers into tiers based on their buying behaviour
-- =============================================================

-- Step 1: Calculate raw RFM values per customer
WITH rfm_raw AS (
    SELECT
        o.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.segment,
        c.city,
        DATEDIFF(CURDATE(), MAX(o.order_date))  AS recency_days,
        COUNT(DISTINCT o.order_id)              AS frequency,
        ROUND(SUM(oi.line_total), 2)            AS monetary
    FROM orders o
    JOIN order_items oi ON o.order_id   = oi.order_id
    JOIN customers c    ON o.customer_id = c.customer_id
    WHERE o.status = 'delivered'
    GROUP BY o.customer_id, customer_name, c.segment, c.city
),

-- Step 2: Score each dimension 1-5 using NTILE
rfm_scores AS (
    SELECT
        customer_id,
        customer_name,
        segment,
        city,
        recency_days,
        frequency,
        monetary,
        -- Lower recency = better = higher score
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score
    FROM rfm_raw
)

-- Step 3: Classify into named segments
SELECT
    customer_id,
    customer_name,
    segment,
    city,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2                  THEN 'Recent Customers'
        WHEN r_score >= 3 AND f_score <= 2 AND m_score >= 3 THEN 'Potential Loyalists'
        WHEN r_score <= 2 AND f_score >= 4                  THEN 'At Risk'
        WHEN r_score <= 2 AND f_score >= 2                  THEN 'Hibernating'
        WHEN r_score <= 1 AND f_score <= 1                  THEN 'Lost'
        ELSE 'Needs Attention'
    END AS rfm_segment
FROM rfm_scores
ORDER BY rfm_total DESC;

-- =============================================================
-- Summary: Count and Revenue by RFM Segment
-- =============================================================
WITH rfm_raw AS (
    SELECT
        o.customer_id,
        DATEDIFF(CURDATE(), MAX(o.order_date)) AS recency_days,
        COUNT(DISTINCT o.order_id)             AS frequency,
        ROUND(SUM(oi.line_total), 2)           AS monetary
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.customer_id
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score
    FROM rfm_raw
),
rfm_labelled AS (
    SELECT *,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2                  THEN 'Recent Customers'
            WHEN r_score >= 3 AND f_score <= 2 AND m_score >= 3 THEN 'Potential Loyalists'
            WHEN r_score <= 2 AND f_score >= 4                  THEN 'At Risk'
            WHEN r_score <= 2 AND f_score >= 2                  THEN 'Hibernating'
            WHEN r_score <= 1 AND f_score <= 1                  THEN 'Lost'
            ELSE 'Needs Attention'
        END AS rfm_segment
    FROM rfm_scores
)
SELECT
    rfm_segment,
    COUNT(*)                      AS customer_count,
    ROUND(SUM(monetary), 2)       AS total_revenue,
    ROUND(AVG(monetary), 2)       AS avg_revenue_per_customer,
    ROUND(AVG(frequency), 1)      AS avg_orders,
    ROUND(AVG(recency_days), 0)   AS avg_recency_days
FROM rfm_labelled
GROUP BY rfm_segment
ORDER BY total_revenue DESC;
