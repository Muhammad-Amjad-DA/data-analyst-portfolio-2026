# Project 4: Operations & On-Time Delivery Analytics

**Tools:** SQL (joins, CTEs, CASE, aggregations, window functions) · Excel (Power Query, PivotTables, XLOOKUP, SUMIFS, dashboard)

## Business Problem

A retailer ships from three warehouses (North, South, East) using two third-party carriers (CarrierX and CarrierY). Customer complaints about late deliveries have been rising, and the Operations team needs to know exactly which warehouse and which carrier are missing on-time SLAs, and why, before renegotiating carrier contracts. This project cleans and analyzes shipment-level data in SQL and presents the findings in an Excel dashboard the Operations team can use in their next carrier review meeting.

## Dataset

data/shipments.csv is a 30-shipment illustrative sample (shipment_id, warehouse, carrier, ship_date, promised_days, actual_days, distance_km, on_time, delay_reason). As with the other projects in this portfolio, the numbers are small and traceable to specific rows; swap in a larger real logistics export to scale this up, the SQL and Excel steps below work unchanged on a bigger file with the same columns.

## Data Cleaning (SQL)

sql/operations_analysis.sql opens with data-quality checks: null checks on warehouse, carrier, and actual_days; a duplicate shipment_id check with GROUP BY plus HAVING COUNT(*) > 1; and a consistency check confirming on_time is always "No" whenever actual_days exceeds promised_days (and "Yes" otherwise), catching any mislabeled rows before analysis.

## Analysis (SQL highlights)

The script then demonstrates: a CTE that summarizes on-time rate by warehouse and by carrier; a JOIN between a per-shipment CASE-flagged table and a carrier lookup to attach a carrier scorecard label; a window function using PERCENT_RANK() to rank warehouses by on-time rate; and a GROUP BY on delay_reason to quantify which failure mode dominates.

## Dashboard

The Excel dashboard is documented in excel/EXCEL_DASHBOARD_GUIDE.md, covering the PivotTable, XLOOKUP, SUMIFS, and Power Query build steps. A screenshot goes in screenshots/excel_dashboard.png once built.

## Key Insights

Finding 1: Overall on-time delivery rate across all three warehouses is 73.3% (22 of 30 shipments) — well short of a typical 95% SLA target.

Finding 2: On-time rate varies sharply by warehouse: North 90% (9 of 10), East 80% (8 of 10), and South only 50% (5 of 10) — South is the clear outlier.

Finding 3: CarrierX delivers on time 94.1% of the time (16 of 17 shipments) versus just 46.2% for CarrierY (6 of 13 shipments) — nearly a 2x gap in reliability between the two carriers.

Finding 4: South's poor performance is explained by carrier mix, not warehouse operations: South routes 60% of its shipments through CarrierY (6 of 10), compared to just 30% at North and 40% at East — South is simply more exposed to the unreliable carrier.

Finding 5: "Carrier Delay" is the single dominant failure reason, accounting for 6 of the 8 late shipments (75%); Weather and Customs Hold explain the rest, and only one delay (Warehouse Processing Delay) was actually caused by the warehouse itself.

## Business Recommendations

Recommendation 1: Rebalance South's carrier mix away from CarrierY toward CarrierX — since the root cause is carrier allocation, not warehouse process, this is a scheduling fix, not an operations overhaul.

Recommendation 2: Put CarrierY on a formal performance improvement plan (or renegotiate the contract) given its 46.2% on-time rate versus CarrierX's 94.1% — this is a contractual lever, not something Operations can fix internally.

Recommendation 3: Since only 1 of 8 delays was caused by the warehouse itself, do not invest in warehouse process changes to fix the SLA problem — the data points squarely at carrier selection as the highest-leverage fix.

## Files in This Folder

| File | Purpose |
|---|---|
| data/shipments.csv | Sample shipment-level dataset |
| sql/operations_analysis.sql | Data-quality checks, CTEs, JOIN, CASE, window functions |
| excel/EXCEL_DASHBOARD_GUIDE.md | Step-by-step Excel dashboard build spec |
| screenshots/ | Dashboard screenshot (add after building locally) |

## One Manual Step Left

Follow excel/EXCEL_DASHBOARD_GUIDE.md in Excel and drop a screenshot into screenshots/.
