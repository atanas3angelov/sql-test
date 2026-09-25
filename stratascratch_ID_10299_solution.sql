WITH ranked_salaries AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY id ORDER BY salary DESC) AS rn
    FROM ms_employee_salary
)
SELECT
    id,
    first_name,
    last_name,
    department_id,
    salary
FROM ranked_salaries
WHERE rn = 1;
