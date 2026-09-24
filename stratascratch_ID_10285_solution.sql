WITH requests_sent AS (
  SELECT * FROM fb_friend_requests WHERE action = 'sent'
),
requests_accepted AS (
  SELECT * FROM fb_friend_requests WHERE action = 'accepted'
)
SELECT
  s.date AS sent_date,
  COUNT(CASE WHEN a.action = 'accepted' THEN 1 END)::DECIMAL / 
    NULLIF(COUNT(*), 0) AS acceptance_rate
FROM requests_sent s
-- with LEFT JOIN we get NULLs for no corresponding accepts
LEFT JOIN requests_accepted a
  ON s.user_id_sender = a.user_id_sender AND 
  s.user_id_receiver = a.user_id_receiver
GROUP BY s.date
ORDER BY sent_date;
