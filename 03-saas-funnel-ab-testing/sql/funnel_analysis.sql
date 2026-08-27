-- Project 3: SaaS Signup Funnel & A/B Test Analysis
-- Funnel conversion analysis: CTEs, window functions, CASE, aggregations, subqueries

CREATE TABLE funnel_events (
    user_id VARCHAR(10) PRIMARY KEY,
    variant CHAR(1),
    visit_date DATE,
    signed_up INT,
    activated INT,
    subscribed INT
);

-- Load funnel_events from data/funnel_events.csv using your database's bulk-import tool.

-- 1) Overall funnel counts per stage (CTE + UNION ALL for a tidy stage table)
WITH funnel_counts AS (
    SELECT 'Visited' AS stage, 1 AS stage_order, COUNT(*) AS users FROM funnel_events
    UNION ALL
    SELECT 'Signed Up', 2, SUM(signed_up) FROM funnel_events
    UNION ALL
    SELECT 'Activated', 3, SUM(activated) FROM funnel_events
    UNION ALL
    SELECT 'Subscribed', 4, SUM(subscribed) FROM funnel_events
)
SELECT
    stage,
    users,
    LAG(users) OVER (ORDER BY stage_order) AS previous_stage_users,
    ROUND(users * 1.0 / LAG(users) OVER (ORDER BY stage_order) * 100, 1) AS pct_of_previous_stage,
    ROUND(users * 1.0 / FIRST_VALUE(users) OVER (ORDER BY stage_order) * 100, 1) AS pct_of_total_visitors
FROM funnel_counts
ORDER BY stage_order;

-- 2) Funnel by variant (CASE + aggregation), feeds the A/B comparison in Python
SELECT
    variant,
    COUNT(*) AS visited,
    SUM(signed_up) AS signed_up,
    SUM(activated) AS activated,
    SUM(subscribed) AS subscribed,
    ROUND(SUM(subscribed) * 1.0 / COUNT(*) * 100, 1) AS subscribe_rate_pct,
    CASE
        WHEN SUM(subscribed) * 1.0 / COUNT(*) >= 0.25 THEN 'Above 25% target'
        ELSE 'Below 25% target'
    END AS target_flag
FROM funnel_events
GROUP BY variant
ORDER BY variant;

-- 3) Stage-to-stage drop-off, ranked to find the leakiest step (CTE + window function)
WITH stage_totals AS (
    SELECT 'Visited-to-SignedUp' AS step, 1 AS step_order,
           COUNT(*) AS entered, SUM(signed_up) AS completed
    FROM funnel_events
    UNION ALL
    SELECT 'SignedUp-to-Activated', 2, SUM(signed_up), SUM(activated) FROM funnel_events
    UNION ALL
    SELECT 'Activated-to-Subscribed', 3, SUM(activated), SUM(subscribed) FROM funnel_events
)
SELECT
    step,
    entered,
    completed,
    entered - completed AS dropped,
    ROUND((entered - completed) * 1.0 / entered * 100, 1) AS drop_off_pct,
    RANK() OVER (ORDER BY (entered - completed) * 1.0 / entered DESC) AS leakiest_step_rank
FROM stage_totals
ORDER BY leakiest_step_rank;

-- 4) Subquery: users who signed up and activated but did not subscribe (re-engagement target list)
SELECT user_id, variant, visit_date
FROM funnel_events
WHERE activated = 1
AND subscribed = 0
AND user_id IN (SELECT user_id FROM funnel_events WHERE signed_up = 1);
