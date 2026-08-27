-- Project 1: Retail Sales & Profitability Analysis
-- Core analysis: CTEs, JOINs, CASE, aggregations, window functions, subqueries
-- Assumes sales_orders, region_managers, and category_targets from 01_data_quality_checks.sql already exist and are clean.

-- 1) Category-level summary with margin and target comparison (CTE + JOIN + CASE)
WITH category_summary AS (
  SELECT
  category,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  SUM(profit) * 1.0 / SUM(sales) AS profit_margin
  FROM sales_orders
  GROUP BY category
  )
SELECT
cs.category,
cs.total_sales,
cs.total_profit,
ROUND(cs.profit_margin * 100, 1) AS margin_pct,
ct.target_margin_pct,
CASE
WHEN cs.profit_margin * 100 >= ct.target_margin_pct THEN 'On/Above Target'
ELSE 'Below Target'
END AS target_status
FROM category_summary cs
JOIN category_targets ct ON cs.category = ct.category
ORDER BY cs.total_profit DESC;

-- 2) Region-level summary joined to the manager who owns each region, ranked by profit (CTE + JOIN + window function)
WITH region_summary AS (
  SELECT
  region,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  SUM(profit) * 1.0 / SUM(sales) AS profit_margin
  FROM sales_orders
  GROUP BY region
  )
SELECT
rs.region,
rm.manager_name,
rs.total_sales,
rs.total_profit,
ROUND(rs.profit_margin * 100, 1) AS margin_pct,
RANK() OVER (ORDER BY rs.total_profit DESC) AS profit_rank
FROM region_summary rs
JOIN region_managers rm ON rs.region = rm.region
ORDER BY profit_rank;

-- 3) Running total of profit over time (window function)
SELECT
order_id,
order_date,
profit,
SUM(profit) OVER (ORDER BY order_date, order_id) AS running_profit_total
FROM sales_orders
ORDER BY order_date, order_id;

-- 4) Region x category mix: what share of each region's orders is the loss-making Furniture category (window function)
SELECT
region,
category,
COUNT(*) AS order_count,
COUNT(*) * 1.0 / SUM(COUNT(*)) OVER (PARTITION BY region) AS pct_of_region_orders
FROM sales_orders
GROUP BY region, category
ORDER BY region, order_count DESC;

-- 5) Subquery: every order performing worse than the company-wide average profit
SELECT *
FROM sales_orders
WHERE profit < (SELECT AVG(profit) FROM sales_orders)
ORDER BY profit ASC;

-- 6) Order-level margin flag for a Power BI detail table (CASE)
SELECT
order_id,
category,
region,
sales,
profit,
CASE
WHEN profit < 0 THEN 'Loss'
WHEN profit * 1.0 / sales < 0.10 THEN 'Low Margin'
ELSE 'Healthy Margin'
END AS margin_flag
FROM sales_orders
ORDER BY profit ASC;
