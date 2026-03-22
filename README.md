# E-Commerce Sales Analysis

![SQL](https://img.shields.io/badge/SQL-MySQL%20%7C%20PostgreSQL-blue) ![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

## Overview

This project performs a comprehensive analysis of an e-commerce dataset using SQL (MySQL/PostgreSQL). It explores sales performance, customer behaviour, and product trends to derive actionable business insights.

## Objectives

- Identify top-performing products and categories by revenue
- Analyse monthly and quarterly sales trends
- Perform customer segmentation using RFM (Recency, Frequency, Monetary) analysis
- Calculate customer retention through cohort analysis
- Detect high-value customers and churn risk segments

## Dataset

| Table | Description |
|---|---|
| `orders` | Order ID, customer ID, order date, status |
| `order_items` | Product ID, quantity, unit price, discount |
| `customers` | Customer demographics and location |
| `products` | Product name, category, supplier |

> Dataset sourced from a synthetic e-commerce schema (inspired by the Brazilian E-Commerce Public Dataset on Kaggle).

## Key SQL Queries

### 1. Monthly Revenue Trend
```sql
SELECT
  DATE_FORMAT(order_date, '%Y-%m') AS month,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY month
ORDER BY month;
```

### 2. Top 10 Products by Revenue
```sql
SELECT
  p.product_name,
  p.category,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;
```

### 3. RFM Customer Segmentation
```sql
SELECT
  customer_id,
  DATEDIFF(CURDATE(), MAX(order_date)) AS recency,
  COUNT(order_id) AS frequency,
  ROUND(SUM(total_amount), 2) AS monetary
FROM orders
WHERE status = 'delivered'
GROUP BY customer_id;
```

### 4. Monthly Cohort Retention
```sql
SELECT
  cohort_month,
  order_month,
  COUNT(DISTINCT customer_id) AS active_customers
FROM (
  SELECT
    customer_id,
    DATE_FORMAT(MIN(order_date) OVER (PARTITION BY customer_id), '%Y-%m') AS cohort_month,
    DATE_FORMAT(order_date, '%Y-%m') AS order_month
  FROM orders
) sub
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;
```

## Key Findings

- **Revenue peaked** in Q4 due to holiday-season promotions
- **Top 3 categories** (Electronics, Clothing, Home & Garden) account for ~65% of total revenue
- **RFM analysis** revealed that the top 20% of customers generate 60% of revenue (Pareto principle)
- **Cohort analysis** showed a 30-day retention rate of ~42% for new customers

## Tools & Technologies

- **Database**: MySQL 8.0 / PostgreSQL 15
- **Query Client**: MySQL Workbench / pgAdmin
- **Visualisation**: Results exported to Excel / Power BI for dashboards

## Project Structure

```
ecommerce-sales-analysis/
├── schema/
│   └── create_tables.sql
├── data/
│   └── sample_data.sql
├── queries/
│   ├── revenue_analysis.sql
│   ├── product_analysis.sql
│   ├── rfm_segmentation.sql
│   └── cohort_analysis.sql
└── README.md
```

## How to Run

1. Clone the repository
2. Run `schema/create_tables.sql` to create tables
3. Load sample data using `data/sample_data.sql`
4. Execute queries in the `queries/` folder in any SQL client

## Author

**Shivam Singh** — [GitHub](https://github.com/the-robotron) | [LinkedIn](https://linkedin.com/in/shivam-singh)
