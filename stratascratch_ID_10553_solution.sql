WITH returning_users AS (
    SELECT
        *,
        CAST(created_at AS DATE)
        - LAG(CAST(created_at AS DATE)) OVER (PARTITION BY user_id ORDER BY created_at) AS prev_date
    FROM amazon_transactions
)
SELECT DISTINCT user_id
FROM returning_users
WHERE prev_date IS NOT NULL AND prev_date BETWEEN 1 AND 7;
