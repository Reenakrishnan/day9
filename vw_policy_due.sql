CREATE OR REPLACE VIEW vw_policy_due AS
SELECT
    p.policy_id,
    p.policy_number,
    c.customer_name,
    c.email,
    c.phone,
    c.address,
    p.premium,
    p.renewal_date,
    p.status
FROM policies p
JOIN customers c
ON p.customer_id = c.customer_id
WHERE p.renewal_date BETWEEN CURDATE()
AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);

SELECT * FROM vw_policy_due;