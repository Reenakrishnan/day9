
USE InsuranceDB;

-- Create audit table
CREATE TABLE IF NOT EXISTS policy_update_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_id INT,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Remove old procedure if it exists
DROP PROCEDURE IF EXISTS sp_lapse_cursor;

DELIMITER //

CREATE PROCEDURE sp_lapse_cursor()
BEGIN
    DECLARE v_policy_id INT;
    DECLARE v_old_status VARCHAR(20);
    DECLARE done INT DEFAULT 0;

    DECLARE policy_cursor CURSOR FOR
        SELECT policy_id, status
        FROM policies
        WHERE renewal_date < CURDATE()
        AND status = 'ACTIVE';

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET done = 1;

    OPEN policy_cursor;

    read_loop: LOOP
        FETCH policy_cursor
        INTO v_policy_id, v_old_status;

        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        UPDATE policies
        SET status = 'LAPSED'
        WHERE policy_id = v_policy_id;

        INSERT INTO policy_update_log
        (policy_id, old_status, new_status)
        VALUES
        (v_policy_id, v_old_status, 'LAPSED');

    END LOOP;

    CLOSE policy_cursor;
END //

DELIMITER ;

-- Execute procedure
CALL sp_lapse_cursor();

-- Check results
SELECT * FROM policies;

SELECT * FROM policy_update_log;
