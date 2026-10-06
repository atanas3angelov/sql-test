-- Postgre since date arithmetic with "-"
WITH streaks AS (
    SELECT
        user_id,
        record_date - CAST(
          ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY record_date) AS INT
        ) AS streak_group
    FROM sf_events
)
SELECT user_id
FROM streaks
GROUP BY user_id, streak_group
HAVING COUNT(*) >= 3;
