WITH guest_total_messages AS (
    SELECT
        id_guest,
        SUM(n_messages) AS total_messages
    FROM airbnb_contacts
    GROUP BY id_guest
)
SELECT
    id_guest,
    total_messages,
    DENSE_RANK() OVER (ORDER BY total_messages DESC) AS rn
FROM guest_total_messages
ORDER BY total_messages DESC;
