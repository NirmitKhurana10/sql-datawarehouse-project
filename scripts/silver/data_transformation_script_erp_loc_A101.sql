
truncate table og_silver.erp_loc_A101;


INSERT INTO og_silver.erp_loc_A101
(
	cust_id, 
	c_entry
)

SELECT 
	REPLACE(TRIM(cust_id),'-','') as cust_id,
	CASE 
    WHEN REPLACE(TRIM(c_entry), '\r', '') = 'DE' THEN 'Germany'
    WHEN REPLACE(TRIM(c_entry), '\r', '') IN ('US', 'USA') THEN 'United States'
    WHEN REPLACE(TRIM(c_entry), '\r', '') = '' OR c_entry IS NULL THEN 'N/A'
    ELSE REPLACE(TRIM(c_entry), '\r', '')
	END as c_entry
FROM og_bronze.erp_loc_A101;

