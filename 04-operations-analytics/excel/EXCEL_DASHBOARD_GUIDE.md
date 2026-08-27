# Excel Dashboard Build Guide — Operations & On-Time Delivery

This is the exact build spec for the Excel dashboard. Follow it in Excel with data/shipments.csv loaded, then export a screenshot to screenshots/excel_dashboard.png.

## Step 1: Load and clean with Power Query

Go to Data > Get Data > From Text/CSV and load shipments.csv into Power Query. Set correct data types (Date on ship_date, Whole Number on promised_days/actual_days/distance_km, Text on the rest); trim whitespace on text columns; remove duplicate shipment_id rows; add a calculated column Delay Days = actual_days - promised_days; then Close & Load to a table named tbl_Shipments on a sheet called Data.

## Step 2: Carrier lookup table and XLOOKUP

On a sheet called Lookups, add a small CarrierTiers table (carrier, carrier_tier) with CarrierX = Preferred and CarrierY = Standard, matching the SQL script. On the Data sheet, add a column called Carrier Tier and use XLOOKUP(tbl_Shipments[carrier], CarrierTiers[carrier], CarrierTiers[carrier_tier]) to pull it in for every shipment.

## Step 3: SUMIFS KPI box

On a new sheet called Dashboard, build KPI cards using SUMIFS/COUNTIFS, for example: On-Time Shipments = COUNTIFS(tbl_Shipments[on_time], "Yes"); South On-Time Shipments = COUNTIFS(tbl_Shipments[warehouse], "South", tbl_Shipments[on_time], "Yes"); CarrierY Late Shipments = COUNTIFS(tbl_Shipments[carrier], "CarrierY", tbl_Shipments[on_time], "No"). Divide by the relevant COUNTIFS total to turn each into a percentage, and format as large KPI cards at the top of the sheet.

## Step 4: PivotTables and PivotCharts

Insert a PivotTable with Warehouse in Rows and Count of shipment_id plus a calculated on-time percentage in Values, and build a bar chart sorted ascending so South's low on-time rate stands out visually. Insert a second PivotTable with Carrier in Rows (Count and on-time percentage) and a matching bar chart. Insert a third PivotTable with Warehouse in Rows and Carrier in Columns, showing Count of shipment_id, to visualize the carrier-mix-by-warehouse story as a stacked bar chart. Insert a fourth PivotTable of delay_reason counts (filtered to on_time = No) as a pie or bar chart.

## Step 5: Slicers and layout

Insert slicers for Warehouse and Carrier and connect them to all four PivotTables (PivotTable Analyze > Filter Connections). Arrange the Dashboard sheet as: KPI cards across the top, the Warehouse and Carrier on-time bar charts side by side in the middle, the warehouse-by-carrier stacked bar chart below that, and the delay-reason chart plus slicers along the right-hand side.

## Step 6: Screenshot

Once built, save the workbook, take a full-sheet screenshot of the Dashboard tab, and save it as screenshots/excel_dashboard.png in this project folder, then reference it from the project README.
