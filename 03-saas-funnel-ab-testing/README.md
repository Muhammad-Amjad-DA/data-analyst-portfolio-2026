# Project 3: SaaS Signup Funnel & A/B Test Analysis

**Tools:** SQL (CTEs, window functions, CASE, subqueries) · Python (pandas, scipy for A/B significance testing) · Power BI (KPI cards, funnel visual, drill-downs)

## Business Problem

A SaaS company's growth team ran a pricing-page A/B test (Variant A: old pricing, Variant B: new pricing) and wants two answers: where in the signup funnel (visit → sign up → activate → subscribe) are the most users lost, and did the new pricing page actually produce a statistically meaningful improvement, or does it just look better by chance on a small sample? This project builds the funnel analysis in SQL, tests the experiment result properly in Python, and presents both in a Power BI dashboard the growth team can review before deciding whether to ship Variant B.

## Dataset

data/funnel_events.csv is a 40-user illustrative sample (user_id, variant, visit_date, signed_up, activated, subscribed), split evenly 20/20 between Variant A and Variant B. Each flag is 1/0 and stage membership is nested (activated=1 always implies signed_up=1, subscribed=1 always implies activated=1), matching how real product-analytics event data behaves. Swap in a full experiment export to scale this up; every query and script below runs unchanged on a larger file with the same columns.

## Data Cleaning / Analysis (SQL)

sql/funnel_analysis.sql demonstrates: a CTE that UNIONs stage-level counts (Visited, Signed Up, Activated, Subscribed) into one tidy table; window functions LAG() and FIRST_VALUE() to compute each stage's conversion rate against the previous stage and against total visitors; a CASE statement flagging each variant as above or below a 25% subscribe-rate target; a second CTE plus RANK() OVER (ORDER BY drop-off DESC) to identify the single leakiest step in the funnel; and a subquery that pulls the exact list of users who activated but never subscribed, a ready-made re-engagement target list.

## Analysis (Python / statistics)

python/ab_test_analysis.py takes the SQL-level variant summary and answers the actual A/B testing question: is Variant B's lift real? It runs a two-proportion z-test (implemented directly with numpy/scipy, the same math behind most online A/B test calculators) comparing the subscribe rate between Variant A and Variant B, and reports the z-statistic and p-value rather than just eyeballing which bar is taller.

## Dashboard

The Power BI dashboard is documented in powerbi/POWERBI_DASHBOARD_SPEC.md, covering the data model, DAX measures, funnel visual, and A/B comparison layout. A screenshot goes in screenshots/powerbi_dashboard.png once built.

## Key Insights

Finding 1: Of 40 visitors, 30 signed up (75%), 18 activated (60% of signups, 45% of all visitors), and 10 subscribed (55.6% of activated users, 25% of all visitors) — a typical steep SaaS funnel.

Finding 2: The single leakiest step by percentage is Activated → Subscribed, losing 44.4% of activated users (8 of 18), while Signed Up → Activated loses the most users in absolute terms (12 people) — these are two different problems and both matter.

Finding 3: Variant B (new pricing) converted visitors to subscribers at 30% (6 of 20) versus 20% for Variant A (4 of 20) — a 10-point, 50% relative lift.

Finding 4: That lift is NOT statistically significant at the current sample size (two-proportion z-test: z = 0.73, p = 0.46, well above the 0.05 threshold) — with only 20 users per group, this result could easily be noise.

Finding 5: 8 users across both variants activated but never subscribed, and the SQL subquery identifies them by user_id — a concrete, ready-to-use re-engagement list.

## Business Recommendations

Recommendation 1: Do not ship Variant B yet. The +10-point lift is promising but not statistically significant at n=20 per group — continue the test until it reaches an adequately powered sample size (or run a sequential/Bayesian test) before rolling pricing changes out company-wide.

Recommendation 2: Fix the Signed Up → Activated step first, regardless of which pricing variant wins — it loses the most users in absolute terms (12 of 30) and is the highest-leverage lever in the entire funnel.

Recommendation 3: Launch a targeted re-engagement campaign immediately to the 8 activated-but-not-subscribed users identified by the SQL subquery — they are already past onboarding and are the cheapest conversions available today.

## Files in This Folder

| File | Purpose |
|---|---|
| data/funnel_events.csv | Sample user-level funnel + A/B variant dataset |
| sql/funnel_analysis.sql | CTEs, window functions, CASE, aggregations, subquery |
| python/ab_test_analysis.py | Two-proportion z-test for A/B significance |
| powerbi/POWERBI_DASHBOARD_SPEC.md | Power BI data model, DAX measures, funnel visual |
| screenshots/ | Dashboard screenshots (add after building locally) |

## One Manual Step Left

Run python/ab_test_analysis.py to confirm the z-test output, then follow powerbi/POWERBI_DASHBOARD_SPEC.md in Power BI Desktop and drop a screenshot into screenshots/.
