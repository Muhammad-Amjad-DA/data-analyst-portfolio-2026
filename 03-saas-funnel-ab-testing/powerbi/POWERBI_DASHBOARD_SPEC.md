# Power BI Dashboard Spec — SaaS Signup Funnel & A/B Test

This is the exact build spec for the Power BI dashboard. Follow it in Power BI Desktop with data/funnel_events.csv loaded, then export a screenshot to screenshots/powerbi_dashboard.png.

## Data Model

Import funnel_events.csv as a single table. In Power Query, add three calculated columns if not already present: Stage Reached (text: "Subscribed" if subscribed=1, else "Activated" if activated=1, else "Signed Up" if signed_up=1, else "Visited Only"). No relationships are needed since this is a single flat table; keep it simple.

## DAX Measures

Create these measures: Total Visitors = COUNTROWS(funnel_events). Total Signed Up = SUM(funnel_events[signed_up]). Total Activated = SUM(funnel_events[activated]). Total Subscribed = SUM(funnel_events[subscribed]). Subscribe Rate = DIVIDE([Total Subscribed], [Total Visitors]). Variant A Subscribe Rate = CALCULATE([Subscribe Rate], funnel_events[variant] = "A"). Variant B Subscribe Rate = CALCULATE([Subscribe Rate], funnel_events[variant] = "B"). Lift (B vs A) = [Variant B Subscribe Rate] - [Variant A Subscribe Rate].

## Page Layout

Build one dashboard page called Funnel & Experiment Overview with three zones. Top zone: four KPI cards for Total Visitors, Total Signed Up, Total Activated, and Total Subscribed. Middle zone: a Funnel visual (Power BI's built-in Funnel chart) plotting Visited to Signed Up to Activated to Subscribed, so the drop-off shape is immediately visible. Bottom zone: a side-by-side bar chart comparing Variant A Subscribe Rate vs Variant B Subscribe Rate, with a text box underneath stating the z-test result from the Python script (z = 0.73, p = 0.46, not significant) so the dashboard doesn't visually overclaim a winner.

## Filters and Drill-Downs

Add a slicer for variant (A/B) that filters the funnel visual, so a viewer can see each variant's funnel shape independently. Add a table visual beneath the funnel listing user_id and visit_date for anyone with activated=1 and subscribed=0 (the re-engagement list from the SQL subquery), filterable by variant.

## Design Notes

Do not color the Variant B bar green just because it's numerically higher — since the lift is not statistically significant, use a neutral color for both variants and let the text box carry the statistical caveat. This is a deliberate design choice that shows judgment, not just chart-building skill.

## Screenshot

Once built, export or screenshot the report page and save it as screenshots/powerbi_dashboard.png in this project folder, then reference it from the project README.
