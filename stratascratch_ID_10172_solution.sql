-- Postgre since EXTRACT(MONTH...)
WITH ranked_total_sales AS (
    SELECT
        EXTRACT(MONTH FROM invoicedate) AS month,
        description,
        SUM(unitprice * quantity) AS total_paid,
        RANK() OVER(
          PARTITION BY EXTRACT(MONTH FROM invoicedate) 
          ORDER BY SUM(unitprice * quantity) DESC
        ) AS rn
    FROM online_retail
    WHERE unitprice > 0 AND quantity > 0 -- ignore returns / cancellations
    GROUP BY month, description
)
SELECT
    month,
    description,
    total_paid
FROM ranked_total_sales
WHERE rn = 1;
