-- Project 1: Retail Sales & Profitability Analysis
-- Data Quality Checks -- run this before any analysis. Every check below should return 0 rows on clean data.

-- 1) Schema setup: self-contained so this script can be run on any SQL Server / PostgreSQL / MySQL instance.
CREATE TABLE sales_orders (
  order_id VARCHAR(20) PRIMARY KEY,
  order_date DATE,
  region VARCHAR(20),
  category VARCHAR(30),
  sub_category VARCHAR(30),
  product_name VARCHAR(100),
  sales DECIMAL(10,2),
  quantity INT,
  discount DECIMAL(4,2),
  profit DECIMAL(10,2),
  customer_segment VARCHAR(20)
  );

CREATE TABLE region_managers (
  region VARCHAR(20) PRIMARY KEY,
  manager_name VARCHAR(100)
  );

CREATE TABLE category_targets (
  category VARCHAR(30) PRIMARY KEY,
  target_margin_pct DECIMAL(5,2)
  );

INSERT INTO region_managers (region, manager_name) VALUES
('East', 'Priya Nair'),
('West', 'Daniel Osei'),
('Central', 'Maria Lopez');

INSERT INTO category_targets (category, target_margin_pct) VALUES
('Furniture', 10.0),
('Office Supplies', 12.0),
('Technology', 20.0);

-- Load sales_orders from data/sales_orders.csv using your database's bulk-import tool
-- (e.g. BULK INSERT in SQL Server, COPY in PostgreSQL, LOAD DATA in MySQL).

-- 2) Null checks on required fields
SELECT *
FROM sales_orders
WHERE sales IS NULL OR profit IS NULL OR region IS NULL OR category IS NULL;

-- 3) Duplicate order_id check
SELECT order_id, COUNT(*) AS row_count
FROM sales_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 4) Orphan region check: an order whose region has no matching region manager
SELECT so.order_id, so.region
FROM sales_orders so
LEFT JOIN region_managers rm ON so.region = rm.region
WHERE rm.region IS NULL;

-- 5) Orphan category check: an order whose category has no matching target
SELECT so.order_id, so.category
FROM sales_orders so
LEFT JOIN category_targets ct ON so.category = ct.category
WHERE ct.category IS NULL;

-- 6) Range / sanity checks: non-positive sales, discount outside 0-1, profit bigger than sales
SELECT *
FROM sales_orders
WHERE sales <= 0
OR discount < 0 OR discount > 1
OR ABS(profit) > sales;

-- If every query above returns zero rows, the dataset is clean and ready for 02_profitability_analysis.sql
