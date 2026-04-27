-- ===================================== crm_cst_info ===========================================



-- Check for null and duplicates in Primary Key
-- Expectation: No Result



select 
	cci.cst_id, 
	count(*) as 'duplicate count' 
from 
	og_bronze.crm_cust_info cci
	group by cci.cst_id
	having count(*) > 1 or cci.cst_id = 0;


SELECT * from og_bronze.crm_cust_info cci where cci.cst_id = 0

-- ================================================================================


-- Check for unwanted spaces
-- Expectation: No Result


select 
	cci.cst_firstname
from 
	og_bronze.crm_cust_info cci 
where cci.cst_firstname != TRIM(cci.cst_firstname)


-- ================================================================================


-- Check for Data Standardisation and Consistency

select DISTINCT cci.cst_gndr from og_bronze.crm_cust_info cci 

select DISTINCT cci.cst_marital_status from og_bronze.crm_cust_info cci 



-- ===================================== crm_prd_info ===========================================


-- Check for null and duplicates in Primary Key
-- Expectation: No Result


select 
	cpi.prd_id, 
	count(*) as 'duplicate count' 
from 
	og_bronze.crm_prd_info cpi 
	group by cpi.prd_id 
	having count(*) > 1 or cpi.prd_id = 0;


SELECT * from og_bronze.crm_cust_info cci where cci.cst_id = 0