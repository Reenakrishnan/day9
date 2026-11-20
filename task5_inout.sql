SET @count = 0;
CALL sp_lapse_with_count(@count);
SELECT @count AS processed_policies;