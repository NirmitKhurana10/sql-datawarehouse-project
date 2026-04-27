
truncate table og_silver.crm_cust_info;

-- Data Transformation Script



INSERT into og_silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_create_date,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr
)


select
	t.cst_id,
	t.cst_key,
	t.cst_create_date,
	TRIM(t.cst_firstname) AS 'First_Name', 
	TRIM(t.cst_lastname) AS 'Last_Name',
	CASE WHEN UPPER(TRIM(t.cst_marital_status)) = 'S' then 'Single'
		 WHEN UPPER(TRIM(t.cst_marital_status )) = 'M' then 'Married'
		 else 'N/A' -- Handle Missing Value
	END as 'Marital_Status', -- Data Normalization / Standardization
	CASE WHEN UPPER(TRIM(t.cst_gndr)) = 'F' then 'Female'
		 WHEN UPPER(TRIM(t.cst_gndr)) = 'M' then 'Male'
		 else 'N/A' -- 
	END as 'Gender'-- Data Normalization / Standardization
from (

	select *, 
		row_number() over (PARTITION BY cci.cst_id order by cci.cst_create_date desc) as flag_last 
	from 
		og_bronze.crm_cust_info cci 
	where 
		cci.cst_id != 0
)t where t.flag_last = 1 -- Selecting the most recent record per customer





