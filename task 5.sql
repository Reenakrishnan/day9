USE InsuranceDB;

DELIMITER //

CREATE PROCEDURE sp_lapse_with_count(INOUT p_processed_count INT)
BEGIN
    DECLARE v_policy_id INT;
    DECLARE done INT DEFAULT 0;

    DECLARE policy_cursor CURSOR FOR
        SELECT policy_id
        FROM policies
        WHERE renewal_date < CURDATE()
        AND status = 'ACTIVE';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    SET p_processed_count = 0;

    OPEN policy_cursor;

    read_loop: LOOP
        FETCH policy_cursor INTO v_policy_id;

        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        UPDATE policies
        SET status = 'LAPSED'
        WHERE policy_id = v_policy_id;

        INSERT INTO policy_update_log
            (policy_id, old_status, new_status)
        VALUES
            (v_policy_id, 'ACTIVE', 'LAPSED');

        SET p_processed_count = p_processed_count + 1;
    END LOOP;

    CLOSE policy_cursor;
END //

DELIMITER ;