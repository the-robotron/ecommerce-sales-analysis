-- =============================================================
-- E-Commerce Sales Analysis: Sample Data
-- Run AFTER schema/create_tables.sql
-- =============================================================

-- Categories
INSERT INTO categories (category_name, parent_id) VALUES
('Electronics',    NULL),
('Clothing',       NULL),
('Home & Garden',  NULL),
('Books',          NULL),
('Sports',         NULL),
('Smartphones',    1),
('Laptops',        1),
('Accessories',    1),
('Men\'s Wear',   2),
('Women\'s Wear', 2);

-- Products
INSERT INTO products (product_name, category_id, supplier, unit_cost, list_price, stock_qty) VALUES
('iPhone 15 Pro',           6, 'Apple Inc.',       65000.00, 89999.00, 120),
('Samsung Galaxy S24',      6, 'Samsung India',    45000.00, 69999.00, 200),
('Dell Inspiron 15',        7, 'Dell Technologies',42000.00, 65000.00,  80),
('MacBook Air M2',          7, 'Apple Inc.',       75000.00,114900.00,  50),
('Lenovo IdeaPad Slim 5',   7, 'Lenovo India',     38000.00, 55000.00,  90),
('Bluetooth Earbuds Pro',   8, 'boAt Lifestyle',    1200.00,  3499.00, 500),
('USB-C Hub 7-in-1',        8, 'Zebronics',          500.00,  1299.00, 350),
('Men\'s Formal Shirt',    9, 'Arrow Fashion',      400.00,  1299.00, 800),
('Women\'s Kurti Set',    10, 'W for Woman',        350.00,   999.00, 600),
('Garden Watering Set',     3, 'Green Thumb Co.',    250.00,   799.00, 150),
('Python Crash Course',     4, 'No Starch Press',    350.00,   599.00, 300),
('Yoga Mat Premium',        5, 'Boldfit',            450.00,  1199.00, 250);

-- Customers
INSERT INTO customers (first_name, last_name, email, phone, city, state, segment) VALUES
('Aarav',   'Sharma',    'aarav.sharma@email.com',   '9812345678', 'Mumbai',     'Maharashtra',  'Consumer'),
('Priya',   'Patel',     'priya.patel@email.com',    '9823456789', 'Ahmedabad',  'Gujarat',      'Corporate'),
('Rohan',   'Gupta',     'rohan.gupta@email.com',    '9834567890', 'Delhi',      'Delhi',        'Consumer'),
('Sneha',   'Verma',     'sneha.verma@email.com',    '9845678901', 'Bangalore',  'Karnataka',    'Home Office'),
('Vikram',  'Singh',     'vikram.singh@email.com',   '9856789012', 'Chennai',    'Tamil Nadu',   'Corporate'),
('Kavya',   'Reddy',     'kavya.reddy@email.com',    '9867890123', 'Hyderabad',  'Telangana',    'Consumer'),
('Arjun',   'Nair',      'arjun.nair@email.com',     '9878901234', 'Kochi',      'Kerala',       'Consumer'),
('Meera',   'Iyer',      'meera.iyer@email.com',     '9889012345', 'Pune',       'Maharashtra',  'Home Office'),
('Rahul',   'Mishra',    'rahul.mishra@email.com',   '9890123456', 'Lucknow',    'Uttar Pradesh','Consumer'),
('Ananya',  'Das',       'ananya.das@email.com',     '9901234567', 'Kolkata',    'West Bengal',  'Corporate');

-- Orders
INSERT INTO orders (customer_id, order_date, ship_date, status, shipping_mode, total_amount) VALUES
(1, '2024-01-05', '2024-01-07', 'delivered', 'Standard',  89999.00),
(2, '2024-01-12', '2024-01-14', 'delivered', 'Express',  130000.00),
(3, '2024-01-18', '2024-01-20', 'delivered', 'Standard',   3499.00),
(4, '2024-02-02', '2024-02-05', 'delivered', 'Express',   55000.00),
(5, '2024-02-14', '2024-02-16', 'delivered', 'Standard',  69999.00),
(6, '2024-02-20', '2024-02-22', 'delivered', 'Standard',   1299.00),
(7, '2024-03-01', '2024-03-03', 'delivered', 'Express',   114900.00),
(8, '2024-03-10', '2024-03-13', 'delivered', 'Standard',    999.00),
(9, '2024-03-22', '2024-03-25', 'returned',  'Standard',   1299.00),
(10,'2024-04-05', '2024-04-08', 'delivered', 'Express',   65000.00),
(1, '2024-04-18', '2024-04-20', 'delivered', 'Standard',   3499.00),
(3, '2024-05-02', '2024-05-04', 'delivered', 'Standard',    599.00),
(5, '2024-05-15', '2024-05-17', 'delivered', 'Express',   114900.00),
(2, '2024-06-01', '2024-06-03', 'delivered', 'Standard',   1199.00),
(6, '2024-06-20', '2024-06-22', 'delivered', 'Express',   89999.00),
(4, '2024-07-04', '2024-07-06', 'delivered', 'Standard',    799.00),
(8, '2024-07-19', '2024-07-21', 'delivered', 'Express',   55000.00),
(9, '2024-08-03', '2024-08-05', 'delivered', 'Standard',   3499.00),
(7, '2024-08-22', '2024-08-25', 'delivered', 'Standard',   1299.00),
(10,'2024-09-10', '2024-09-12', 'delivered', 'Express',   69999.00);

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount) VALUES
(1,  1, 1, 89999.00, 0.00),
(2,  4, 1,114900.00, 0.00),
(2,  6, 2,  3499.00, 0.10),
(3,  6, 1,  3499.00, 0.00),
(4,  5, 1, 55000.00, 0.00),
(5,  2, 1, 69999.00, 0.00),
(6,  7, 1,  1299.00, 0.00),
(7,  4, 1,114900.00, 0.00),
(8,  9, 1,   999.00, 0.00),
(9,  8, 1,  1299.00, 0.00),
(10, 3, 1, 65000.00, 0.00),
(11, 6, 1,  3499.00, 0.00),
(12,11, 1,   599.00, 0.00),
(13, 4, 1,114900.00, 0.00),
(14,12, 1,  1199.00, 0.00),
(15, 1, 1, 89999.00, 0.00),
(16,10, 1,   799.00, 0.00),
(17, 5, 1, 55000.00, 0.00),
(18, 6, 1,  3499.00, 0.00),
(19, 7, 1,  1299.00, 0.00),
(20, 2, 1, 69999.00, 0.00);

-- Update order totals (convenience)
UPDATE orders o
SET total_amount = (
    SELECT COALESCE(SUM(line_total), 0)
    FROM order_items
    WHERE order_id = o.order_id
);

SELECT 'Sample data loaded successfully.' AS status;
SELECT COUNT(*) AS total_orders   FROM orders;
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_products  FROM products;
