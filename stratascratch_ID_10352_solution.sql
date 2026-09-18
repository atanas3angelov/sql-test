-- track the latest page_load for each day (for each user)
WITH latest_daily_session_started AS (
  SELECT user_id, DATE_TRUNC('day', timestamp) AS session_day, MAX(timestamp) AS latest_page_load
  FROM facebook_web_log
  WHERE action = 'page_load'
  GROUP BY user_id, DATE_TRUNC('day', timestamp)
),
-- track the earliest page_exit for each day (for each user)
earliest_daily_session_ended AS (
  SELECT user_id, DATE_TRUNC('day', timestamp) AS session_day, MIN(timestamp) AS earliest_page_exit
  FROM facebook_web_log
  WHERE action = 'page_exit'
  GROUP BY user_id, DATE_TRUNC('day', timestamp)
),
-- calculate session duration for each day (for each user)
daily_session_duration AS (
  SELECT e.user_id, e.session_day, earliest_page_exit - latest_page_load AS duration
  FROM latest_daily_session_started e
  JOIN earliest_daily_session_ended l
    ON e.user_id = l.user_id AND e.session_day = l.session_day
)
-- calculate average duration for all days (for each user)
SELECT user_id, AVG(duration) AS avg_session_duration FROM daily_session_duration
GROUP BY user_id;
