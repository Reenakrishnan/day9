USE InsuranceDB;

SHOW PROCEDURE STATUS
WHERE Db = 'InsuranceDB'
AND Name = 'sp_lapse_policies_cursor';