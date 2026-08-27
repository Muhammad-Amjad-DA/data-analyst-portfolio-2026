# Power BI Dashboard Spec — Retail Sales & Profitability

This is the exact build spec for the Power BI dashboard. Follow it in Power BI Desktop, then publish or export a screenshot to screenshots/powerbi_dashboard.png.

## Data Model

Import sales_orders.csv, plus the region_managers and category_targets lookup tables (recreate them as small tables in Power BI or load from the SQL source). Build a simple star schema: sales_orders is the fact table; region_managers and category_targets are dimension tables. Create relationships: region_managers[region] to sales_orders[region] (one-to-many), and category_targets[category] to sales_orders[category] (one-to-many). Mark sales_orders as the fact table in Model view.

## DAX Measures

Create these measures in a dedicated _Measures table: Total Sales = SUM(sales_orders[sales]). Total Profit = SUM(sales_orders[profit]). Profit Margin = DIVIDE([Total Profit], [Total Sales], 0). Target Margin = SELECTEDVALUE(category_targets[target_margin_pct]) / 100. Margin vs Target = [Profit Margin] - [Target Margin]. Orders Below Avg Profit = CALCULATE(COUNTROWS(sales_orders), sales_orders[profit] < CALCULATE(AVERAGE(sales_orders[profit]), ALL(sales_orders))).

## Page Layout

Build one dashboard page called Profitability Overview with four zones. Top zone: three KPI cards showing Total Sales, Total Profit, and Profit Margin (use the Card visual, with Margin vs Target conditionally colored red/green using data bars or a KPI visual). Middle-left zone: a clustered bar chart of Total Sales and Total Profit by Category, sorted descending by profit, with Margin vs Target CASE-style flag (Below Target / On Target) shown as a data label using the CASE logic already computed in SQL. Middle-right zone: a bar chart of Total Profit by Region, with a tooltip showing the region manager's name. Bottom zone: a line chart of running profit over order_date (matching the SQL running-total query) plus a table visual listing every order flagged Loss or Low Margin from the SQL margin_flag query, so a viewer can drill into exactly which orders are hurting profit.

## Filters and Drill-Downs

Add a filter pane (or in-canvas slicers) for Region, Category, and Customer Segment so any exec can slice the whole page instantly. Set up a drill-down hierarchy on the Category bar chart: Category to Sub-Category, so double-clicking a bar reveals which specific product lines (for example Bookcases vs Tables within Furniture) are driving the category's margin.

## Design Notes

Use a consistent color rule across every visual: red/orange for anything below its margin target, green for anything at or above target. Keep KPI cards and titles in one font size hierarchy so the page reads top-to-bottom in under 10 seconds. Add a page title and a one-line subtitle stating the business question this dashboard answers.

## Screenshot

Once built, use File > Export > Export to PDF or a direct screenshot of the report page, save it as screenshots/powerbi_dashboard.png in this project folder, and reference it from the project README. If you publish to the Power BI Service, add the published report link to the README as well.
