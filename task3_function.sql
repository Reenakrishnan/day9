
SELECT
    p.policy_id,
    p.policy_number,
    c.customer_name,
    p.premium AS original_premium,
    fn_premium_with_no_claim_discount(
        p.policy_id
    ) AS discounted_premium
FROM policies p
JOIN customers c
ON p.customer_id = c.customer_id;
