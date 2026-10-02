-- Postgre since DATE_TRUNC used
/* join tables, filter out dates (while date is not trunced to start of month), 
   trunc date (SELECT happens after filtering - WHERE clause),
   group by month_start & country, calc total comments
*/
WITH country_comments_dec19_jan20 AS (
    SELECT
        country,
        DATE_TRUNC('month', created_at) AS month_start,
        SUM(number_of_comments) AS total_comments
    FROM fb_active_users AS a
    INNER JOIN fb_comments_count AS b ON a.user_id = b.user_id
    WHERE CAST(created_at AS DATE) BETWEEN DATE('2019-12-01') AND DATE('2020-01-31')
    GROUP BY month_start, country
    ORDER BY total_comments DESC
),
-- rank country comments partitioned into 2 months, ordered by total_comments DESC
ranked_country_comments AS (
    SELECT
        month_start,
        total_comments,
        country,
        DENSE_RANK() OVER (PARTITION BY month_start ORDER BY total_comments DESC) AS rn
    FROM country_comments_dec19_jan20
),
-- use LAG to calc each country's rank diff over the 2 months (negative, if rank improved)
ranked_country_diff AS (
    SELECT
        country,
        rn - LAG(rn) OVER (PARTITION BY country ORDER BY month_start) AS rank_diff
    FROM ranked_country_comments
)
-- filter out countries with improved (negative) rank diff
SELECT country FROM ranked_country_diff
WHERE rank_diff < 0;
