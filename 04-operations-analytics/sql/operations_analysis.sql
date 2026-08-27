-- Project 4: Operations & On-Time Delivery Analytics
-- Data quality checks, CTEs, JOIN, CASE, aggregations, window functions

CREATE TABLE shipments (
    shipment_id VARCHAR(10) PRIMARY KEY,
    warehouse VARCHAR(20),
    carrier VARCHAR(20),
    ship_date DATE,
    promised_days INT,
    actual_days INT,
    distance_km INT,
    on_time VARCHAR(3),
    delay_reason VARCHAR(50)
);

CREATE TABLE carrier_lookup (
    carrier VARCHAR(20) PRIMARY KEY,
    carrier_tier VARCHAR(20)
);

INSERT INTO carrier_lookup (carrier, carrier_tier) VALUES
('CarrierX', 'Preferred'),
('CarrierY', 'Standard');

-- Load shipments from data/shipments.csv using your database's bulk-import tool.

-- 1) Data quality checks (should return 0 rows each on clean data)
SELECT * FROM shipments
WHERE warehouse IS NULL OR carrier IS NULL OR actual_days IS NULL;

SELECT shipment_id, COUNT(*) AS row_count
FROM shipments
GROUP BY shipment_id
HAVING COUNT(*) > 1;

-- Consistency check: on_time flag should match the promised vs actual days
SELECT *
FROM shipments
WHERE (actual_days > promised_days AND on_time = 'Yes')
OR (actual_days <= promised_days AND on_time = 'No');

-- 2) On-time rate by warehouse (CTE + aggregation)
WITH warehouse_summary AS (
    SELECT
        warehouse,
        COUNT(*) AS total_shipments,
        SUM(CASE WHEN on_time = 'Yes' THEN 1 ELSE 0 END) AS on_time_shipments
    FROM shipments
    GROUP BY warehouse
)
SELECT
    warehouse,
    total_shipments,
    on_time_shipments,
    ROUND(on_time_shipments * 1.0 / total_shipments * 100, 1) AS on_time_pct,
    PERCENT_RANK() OVER (ORDER BY on_time_shipments * 1.0 / total_shipments) AS percent_rank_worst_first
FROM warehouse_summary
ORDER BY on_time_pct;

-- 3) On-time rate by carrier, joined to a carrier scorecard tier (JOIN + CASE)
SELECT
    s.carrier,
    cl.carrier_tier,
    COUNT(*) AS total_shipments,
    SUM(CASE WHEN s.on_time = 'Yes' THEN 1 ELSE 0 END) AS on_time_shipments,
    ROUND(SUM(CASE WHEN s.on_time = 'Yes' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) * 100, 1) AS on_time_pct,
    CASE
        WHEN SUM(CASE WHEN s.on_time = 'Yes' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) >= 0.90 THEN 'Meets SLA'
        ELSE 'Below SLA'
    END AS sla_status
FROM shipments s
JOIN carrier_lookup cl ON s.carrier = cl.carrier
GROUP BY s.carrier, cl.carrier_tier
ORDER BY on_time_pct DESC;

-- 4) Carrier mix by warehouse - explains WHY South underperforms (aggregation)
SELECT
    warehouse,
    carrier,
    COUNT(*) AS shipment_count,
    ROUND(COUNT(*) * 1.0 / SUM(COUNT(*)) OVER (PARTITION BY warehouse) * 100, 1) AS pct_of_warehouse_shipments
FROM shipments
GROUP BY warehouse, carrier
ORDER BY warehouse, shipment_count DESC;

-- 5) Delay reason breakdown for all late shipments (aggregation)
SELECT
    delay_reason,
    COUNT(*) AS late_shipments,
    ROUND(COUNT(*) * 1.0 / (SELECT COUNT(*) FROM shipments WHERE on_time = 'No') * 100, 1) AS pct_of_all_delays
FROM shipments
WHERE on_time = 'No'
GROUP BY delay_reason
ORDER BY late_shipments DESC;
