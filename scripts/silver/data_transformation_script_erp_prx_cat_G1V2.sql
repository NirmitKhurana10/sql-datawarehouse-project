INSERT INTO og_silver.erp_prx_cat_G1V2
(
	id, 
	cat, 
	sub_cat, 
	MAINTENANCE
)


SELECT 
	id, 
	cat, 
	sub_cat, 
	CASE TRIM(REPLACE(MAINTENANCE, '\r', ''))
    	WHEN 'Yes' THEN 'Yes'
    	WHEN 'No' THEN 'No'
    	ELSE 'N/A'
	END AS maintenance 
FROM og_bronze.erp_prx_cat_G1V2;
