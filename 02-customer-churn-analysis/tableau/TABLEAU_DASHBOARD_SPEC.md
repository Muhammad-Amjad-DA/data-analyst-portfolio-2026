# Tableau Dashboard Spec — Customer Churn Analysis

This is the exact build spec for the Tableau dashboard. Follow it in Tableau Public or Tableau Desktop with data/customers.csv (joined to data/customer_regions.csv) as the data source, then export a screenshot to screenshots/tableau_dashboard.png.

## Data Source Setup

Connect Tableau to data/customers.csv, then add data/customer_regions.csv as a second connection and join them on customer_id (left join, customers as the primary table) so every row carries a region. Convert the churned field to a Boolean or keep it as a string dimension used for color encoding throughout.

## Calculated Fields

Create these calculated fields:
- Churn Rate: SUM(IF [churned] = "Yes" THEN 1 ELSE 0 END) / COUNT([customer_id])
- Is Churned (bool): [churned] = "Yes"
- Ticket Bucket: IF [support_tickets] = 0 THEN "0" ELSEIF [support_tickets] = 1 THEN "1" ELSEIF [support_tickets] = 2 THEN "2" ELSE "3+" END

## Dashboard Layout

Build one dashboard called Churn Overview with four elements. Top: three KPI cards/text tables showing Overall Churn Rate, Total Customers, and Avg Support Tickets (Churned vs Retained) using the Churn Rate calculated field and a quick table calculation. Left: a bar chart of Churn Rate by contract_type, sorted descending, colored red for Month-to-month and green for Two year to make the pattern immediate. Right: a bar chart of Churn Rate by Ticket Bucket, showing churn rate climbing as ticket count rises. Bottom: a highlight table or bar chart of Churn Rate by region, with a filter action so clicking a region cross-filters the other three charts.

## Filters and Drill-Downs

Add filter cards for contract_type, region, and payment_method to the right-hand side of the dashboard, applied to all sheets. Set up a dashboard action so clicking a bar in the contract_type chart filters the ticket-bucket and region charts to just that contract type, giving a simple drill-down path from "which contract churns most" to "why."

## Design Notes

Keep a consistent red-for-risk, green-for-healthy color rule across every sheet. Title the dashboard with the business question ("Which customers are about to churn, and why?") so a recruiter understands the purpose in the first five seconds.

## Screenshot / Publish

Once built, either publish the workbook to Tableau Public and add the public link to the project README, or export a screenshot of the dashboard and save it as screenshots/tableau_dashboard.png.
