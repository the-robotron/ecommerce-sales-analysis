-- =============================================================
-- E-Commerce Sales Analysis: Database Schema
-- Compatible with MySQL 8.0+ / PostgreSQL 15+
-- =============================================================

-- Drop tables if they exist (for re-runs)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS categories;

-- -------------------------------------------------------------
-- Table: categories
-- -------------------------------------------------------------
CREATE TABLE categories (
    category_id   INT           PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100)  NOT NULL,
    parent_id     INT           DEFAULT NULL,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- Table: products
-- -------------------------------------------------------------
CREATE TABLE products (
    product_id    INT           PRIMARY KEY AUTO_INCREMENT,
    product_name  VARCHAR(255)  NOT NULL,
    category_id   INT           NOT NULL,
    supplier      VARCHAR(100),
    unit_cost     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    list_price    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    stock_qty     INT           DEFAULT 0,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- -------------------------------------------------------------
-- Table: customers
-- -------------------------------------------------------------
CREATE TABLE customers (
    customer_id   INT           PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(100)  NOT NULL,
    last_name     VARCHAR(100)  NOT NULL,
    email         VARCHAR(255)  UNIQUE NOT NULL,
    phone         VARCHAR(20),
    city          VARCHAR(100),
    state         VARCHAR(100),
    country       VARCHAR(100)  DEFAULT 'India',
    segment       ENUM('Consumer','Corporate','Home Office') DEFAULT 'Consumer',
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- Table: orders
-- -------------------------------------------------------------
CREATE TABLE orders (
    order_id      INT           PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT           NOT NULL,
    order_date    DATE          NOT NULL,
    ship_date     DATE,
    status        ENUM('pending','processing','shipped','delivered','returned','cancelled')
                                DEFAULT 'pending',
    shipping_mode VARCHAR(50),
    total_amount  DECIMAL(12,2) DEFAULT 0.00,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- -------------------------------------------------------------
-- Table: order_items
-- -------------------------------------------------------------
CREATE TABLE order_items (
    item_id       INT           PRIMARY KEY AUTO_INCREMENT,
    order_id      INT           NOT NULL,
    product_id    INT           NOT NULL,
    quantity      INT           NOT NULL DEFAULT 1,
    unit_price    DECIMAL(10,2) NOT NULL,
    discount      DECIMAL(4,2)  DEFAULT 0.00,   -- e.g. 0.15 = 15%
    line_total    DECIMAL(12,2) GENERATED ALWAYS AS
                  (quantity * unit_price * (1 - discount)) STORED,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- -------------------------------------------------------------
-- Indexes for query performance
-- -------------------------------------------------------------
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_date       ON orders(order_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_prod  ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category_id);

SELECT 'Schema created successfully.' AS status;
