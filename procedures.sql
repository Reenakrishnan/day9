USE InsuranceDB;

SELECT * FROM policies
WHERE policy_id = 101;


USE InsuranceDB;

DELIMITER //

CREATE PROCEDURE sp_renew_policy(
    IN p_policy_id INT
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_old_premium DECIMAL(10,2);
    DECLARE v_new_premium DECIMAL(10,2);
    DECLARE v_count INT;

    -- Exit handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Check whether policy exists
    SELECT COUNT(*)
    INTO v_count
    FROM policies
    WHERE policy_id = p_policy_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Policy not found';
    END IF;

    -- Get policy details
    SELECT status, premium
    INTO v_status, v_old_premium
    FROM policies
    WHERE policy_id = p_policy_id
    FOR UPDATE;

    -- Check active status
    IF v_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Policy is not active';
    END IF;

    -- Check pending claims
    SELECT COUNT(*)
    INTO v_count
    FROM claims
    WHERE policy_id = p_policy_id
    AND claim_status = 'PENDING';

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pending claim exists';
    END IF;

    -- Recalculate premium by 5%
    SET v_new_premium = v_old_premium * 1.05;

    -- Update policy
    UPDATE policies
    SET premium = v_new_premium,
        renewal_date = DATE_ADD(
            renewal_date, INTERVAL 1 YEAR
        )
    WHERE policy_id = p_policy_id;

    -- Insert audit record
    INSERT INTO premium_audit
    (policy_id, old_premium, new_premium)
    VALUES
    (p_policy_id, v_old_premium, v_new_premium);

    COMMIT;

END //

DELIMITER ;

CALL sp_renew_policy(101);

SELECT * FROM policies
WHERE policy_id = 101;

CALL sp_renew_policy(102);

DELIMITER //