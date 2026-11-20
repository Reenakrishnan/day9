USE InsuranceDB;

CREATE TABLE IF NOT EXISTS lapse_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_id INT,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE PROCEDURE sp_lapse_policies_cursor()

BEGIN

    DECLARE v_policy_id INT;
    DECLARE v_done INT DEFAULT 0;

    -- Declare cursor
    DECLARE policy_cursor CURSOR FOR
        SELECT policy_id
        FROM policies
        WHERE renewal_date < CURDATE()
        AND status = 'ACTIVE';

    -- NOT FOUND handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    OPEN policy_cursor;

    read_loop: LOOP

        FETCH policy_cursor INTO v_policy_id;

        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Update policy status
        UPDATE policies
        SET status = 'LAPSED'
        WHERE policy_id = v_policy_id;

        -- Insert audit record
        INSERT INTO lapse_audit
        (policy_id, old_status, new_status)
        VALUES
        (v_policy_id, 'ACTIVE', 'LAPSED');

    END LOOP;

    CLOSE policy_cursor;

END //

DELIMITER ;