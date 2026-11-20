
USE InsuranceDB;

DROP PROCEDURE IF EXISTS sp_lapse_set_based;

DELIMITER //

CREATE PROCEDURE sp_lapse_set_based()
BEGIN

    -- Insert audit records
    INSERT INTO policy_update_log
    (policy_id, old_status, new_status)
    SELECT policy_id, status, 'LAPSED'
    FROM policies
    WHERE renewal_date < CURDATE()
    AND status = 'ACTIVE';

    -- Update expired policies
    UPDATE policies
    SET status = 'LAPSED'
    WHERE renewal_date < CURDATE()
    AND status = 'ACTIVE';

END //

DELIMITER ;

-- Execute procedure
CALL sp_lapse_set_based();

-- Check updated policies
SELECT * FROM policies;

-- Check audit records
SELECT * FROM policy_update_log;
