# Excel Dashboard Build Guide — Retail Sales & Profitability

This is the exact build spec for the Excel dashboard. Follow it in Excel with data/sales_orders.csv loaded, then export a screenshot to screenshots/excel_dashboard.png.

## Step 1: Load and clean with Power Query

Open a new workbook, go to Data > Get Data > From Text/CSV, and load sales_orders.csv into Power Query. In the Power Query editor: set correct data types on every column (Date on order_date, Decimal Number on sales/discount/profit, Whole Number on quantity); trim whitespace on all text columns with Transform > Format > Trim; remove duplicate rows on order_id; add a calculated column named Margin Pct defined as profit divided by sales; then Close & Load to a table named tbl_Orders on a sheet called Data.

## Step 2: Build the lookup tables

On a sheet called Lookups, add two small tables: RegionManagers (region, manager_name) and CategoryTargets (category, target_margin_pct), matching the values in the SQL scripts (East/Priya Nair, West/Daniel Osei, Central/Maria Lopez; Furniture/10%, Office Supplies/12%, Technology/20%).

## Step 3: XLOOKUP the manager name onto every order

On the Data sheet, add a column called Manager and use XLOOKUP(so.region, RegionManagers[region], RegionManagers[manager_name]) to pull in the manager responsible for each order's region without a manual VLOOKUP table array.

## Step 4: SUMIFS KPI box

On a new sheet called Dashboard, build a small KPI box using SUMIFS, for example: Total Furniture Profit = SUMIFS(tbl_Orders[profit], tbl_Orders[category], "Furniture"); Total Technology Sales = SUMIFS(tbl_Orders[sales], tbl_Orders[category], "Technology"); Central Region Profit = SUMIFS(tbl_Orders[profit], tbl_Orders[region], "Central"). Format these as large KPI number cards at the top of the Dashboard sheet with a label above each number.

## Step 5: PivotTables and PivotCharts

Insert two PivotTables from tbl_Orders: one with Category in Rows and Sum of Sales / Sum of Profit in Values (add a calculated field for Margin = Profit / Sales), and one with Region in Rows and the same values. Build a clustered column PivotChart from each PivotTable (Sales vs Profit by Category, and by Region), plus a line chart showing profit by order_date for the running-total view.

## Step 6: Slicers and layout

Insert slicers for Category, Region, and Customer Segment and connect them to both PivotTables (PivotTable Analyze > Filter Connections). Arrange the Dashboard sheet as: KPI cards across the top, the Category and Region charts side by side in the middle, the profit-over-time line chart below that, and the slicers along the right-hand side so a viewer can filter the whole page without leaving the tab.

## Step 7: Screenshot

Once built, save the workbook, take a full-sheet screenshot of the Dashboard tab, and save it as screenshots/excel_dashboard.png in this project folder, then reference it from the project README.
