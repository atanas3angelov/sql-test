-- collapse multiple rows into 1 based on "highest severity" rule (when filtering with WHERE rn=1)
WITH ranked_inspections AS (
  SELECT 
    inspection_id, 
    inspection_type,
    risk_category,
    ROW_NUMBER() OVER (
      PARTITION BY inspection_id
      ORDER BY
        CASE risk_category
          WHEN 'High Risk' THEN 1
          WHEN 'Moderate Risk' THEN 2
          WHEN 'Low Risk' THEN 3
          ELSE 4
        END ASC
    ) AS rn
  FROM sf_restaurant_health_violations
),
-- partition collapsed table into counts for risk categories
inspection_type__risk_category AS (
  SELECT 
    inspection_type,
    SUM(CASE
          WHEN risk_category IS NULL THEN 1 ELSE 0
        END) AS no_risk_results,
    SUM(CASE
          WHEN risk_category = 'Low Risk' THEN 1 ELSE 0
        END) AS low_risk_results,
    SUM(CASE
          WHEN risk_category = 'Moderate Risk' THEN 1 ELSE 0
        END) AS moderate_risk_results,
    SUM(CASE
          WHEN risk_category = 'High Risk' THEN 1 ELSE 0
        END) AS high_risk_results,
    COUNT(*) AS total_inspections_of_that_type
  FROM ranked_inspections
  WHERE rn = 1
  GROUP BY inspection_type
)
SELECT * FROM inspection_type__risk_category
ORDER BY total_inspections_of_that_type DESC;

/* GEMINI: It's a super common roadblock—whenever you need to collapse multiple rows into one 
based on a specific business rule (like "highest severity," "most recent," or "maximum value"), 
ROW_NUMBER() combined with a PARTITION BY is almost always the cleanest way to break through.
*/
