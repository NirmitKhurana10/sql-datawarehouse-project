INSERT INTO og_silver.erp_cust_AZ12
(
	cust_id, 
	b_date, 
	gender
)


SELECT 
	CASE WHEN cust_id like 'NAS%' THEN SUBSTRING(cust_id,4, LENGTH(cust_id))
	ELSE cust_id  -- removed 'NAS' prefix if present to join it with table 
	END AS cust_id,
	Case when b_date > CURRENT_DATE() THEN NULL
	ELSE b_date  -- set future birthdates to Null
	end as b_date, 
	CASE WHEN UPPER(TRIM(REPLACE(gender,'\r',''))) in ('F', 'FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(REPLACE(gender,'\r',''))) in ('M', 'MALE') THEN 'Male'
		 else 'N/A' -- The \r (carriage return) is coming from Windows-style line endings in  CSV (\r\n instead of \n). 
		 			-- TRIM() doesn't remove \r, only spaces. Fix — use TRIM + remove \r:
	end as gender
FROM og_bronze.erp_cust_AZ12;


