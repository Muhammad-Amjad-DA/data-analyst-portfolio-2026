# Project 1: Retail Sales & Profitability Analysis

**Tools:** SQL (SQL Server / PostgreSQL syntax) · Excel (Power Query, PivotTables, XLOOKUP, SUMIFS) · Power BI (DAX, KPI cards, drill-downs)

## Business Problem

A mid-size retailer sells across three regions (Central, East, West) and three product categories (Furniture, Office Supplies, Technology). Revenue has been growing, but leadership suspects that some of that revenue is not actually profitable. The Finance team asked: which categories and regions are generating real profit, versus just top-line sales, and which region managers need to rebalance their product mix? This project answers that question end to end: clean the raw order data, quantify margin by category and region in SQL, and present the findings in Excel and Power BI dashboards that a regional manager can act on.

## Dataset

`data/sales_orders.csv` is a 20-order illustrative sample built to demonstrate the analysis end to end (order id, date, region, category, sub-category, product, sales, quantity, discount, profit, customer segment). It is intentionally small so every number in this README can be traced back to a specific row. To turn this into a full portfolio piece, swap in a larger real-world extract (for example a 1,000+ row Superstore-style export) — every SQL query, Excel step, and Power BI measure below works unchanged on a bigger file with the same column structure. Two small lookup tables are also included: region_managers (who owns each region) and category_targets (the profit-margin target Finance set for each category).

## Data Cleaning (SQL)

Before any analysis, sql/01_data_quality_checks.sql runs a standard set of data-quality checks that every real dataset needs. It checks: null values on required fields (sales, profit, region, category); duplicate order_id rows using GROUP BY plus HAVING COUNT(*) greater than 1; orphan keys, meaning orders whose region does not exist in region_managers, found with a LEFT JOIN where the right-hand side is NULL; and range/sanity checks such as negative sales, discounts outside 0 to 1, or profit larger in magnitude than sales. Only after these checks pass does the analysis in sql/02_profitability_analysis.sql run.

## Analysis (SQL highlights)

sql/02_profitability_analysis.sql demonstrates the following techniques. CTEs build a clean category_summary and region_summary layer before the final report. JOINs connect orders to region_managers and category_targets. CASE statements flag each category as "Below Target" or "On/Above Target" margin. Aggregations (SUM, AVG, COUNT) are grouped by category and region. Window functions include RANK() OVER (ORDER BY total_profit DESC) to rank regions by profit, and SUM(profit) OVER (ORDER BY order_date) for a running profit total. A subquery pulls every order whose profit is below the company-wide average profit.

## Dashboard

Two dashboards were built from the same cleaned data. The Excel dashboard is documented step by step in excel/EXCEL_DASHBOARD_GUIDE.md, covering the PivotTable, XLOOKUP, SUMIFS, and Power Query build steps, with a screenshot at screenshots/excel_dashboard.png once built. The Power BI dashboard is documented in powerbi/POWERBI_DASHBOARD_SPEC.md, covering the data model, DAX measures, and page layout, with a screenshot at screenshots/powerbi_dashboard.png once built. Screenshots are placeholders in this repo — see the note at the bottom of this README for the one remaining manual step.

## Key Insights

Finding 1: Overall profit margin across all orders is 11.1% ($2,580 profit on $23,200 sales), but that average hides a big split by category.

Finding 2: Furniture carries a -15% margin (-$1,050 profit on $7,000 sales) even though it is the second-largest category by revenue — every Furniture order in this sample loses money after discount.

Finding 3: Technology is the most profitable category at a 25% margin ($3,000 profit on $12,000 sales) and should be prioritized in upsell and marketing spend.

Finding 4: Central region's profit margin (3.5%) is roughly 4.7x lower than East or West (16.5% each), despite generating comparable revenue — driven entirely by Central taking a disproportionate share of loss-making Furniture orders (5 of Central's 8 orders vs. 1 of 7 in East and West).

Finding 5: Furniture is the only category missing its Finance-set profit target; Office Supplies and Technology both meet or beat theirs.

## Business Recommendations

Recommendation 1: Cap or restructure Furniture discounting. At a 30% discount rate every Furniture order in the sample is unprofitable — renegotiate supplier cost or reduce the standard discount band before running further promotions on this category.

Recommendation 2: Reallocate Central's product mix. Central's manager should shift promotional focus toward Technology and Office Supplies, which post 16-25% margins, and away from Furniture until pricing is fixed.

Recommendation 3: Set a category-level margin gate, not just a revenue target, in future sales planning — this dataset shows revenue growth alone (Furniture's $7,000) can mask a loss-making product line.

## Files in This Folder

| File | Purpose |
|---|---|
| data/sales_orders.csv | Sample order-level dataset |
| sql/01_data_quality_checks.sql | Null/duplicate/orphan/range checks |
| sql/02_profitability_analysis.sql | CTEs, joins, CASE, aggregations, window functions, subqueries |
| excel/EXCEL_DASHBOARD_GUIDE.md | Step-by-step Excel dashboard build spec |
| powerbi/POWERBI_DASHBOARD_SPEC.md | Power BI data model, DAX measures, page layout |
| screenshots/ | Dashboard screenshots (add after building locally) |

## One Manual Step Left

The SQL, the data, and the exact build specs are all here — the only thing left is opening the CSV in Excel and Power BI Desktop, following the two guide files, and dropping screenshots into the screenshots/ folder. That turns this from code that proves I can do it into a dashboard a recruiter can see in 10 seconds.
