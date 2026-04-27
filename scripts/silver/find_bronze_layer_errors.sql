-- Here you have to pick a table first adn then go column by column to check each column and what type of 
-- transformation can and should be applied on that poarticulkar column. 

-- Example: 

-- Type (String) Column: Check for leading spaces
-- Type (Number) Column: Check for Nulls and negative numbers
-- Type (PRIMARY KEU): Check for null and duplicates in Primary Key

-- Check for Data Standardisation and Consistency where you first check all possible values in columns 
-- and then transform like (M -> Male)(F -> Female)(S -> Single) etc. 

-- For date columns check for start date > end date (if true, we need to transform it)



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



-- Check for unwanted spaces
-- Expectation: No Result


select 
	cci.cst_firstname
from 
	og_bronze.crm_cust_info cci 
where cci.cst_firstname != TRIM(cci.cst_firstname)



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


SELECT * from og_bronze.crm_prd_info cpi where cpi.prd_id = 0


-- Check for unwanted spaces
-- Expectation: No Result

select 
	cpi.prd_nm 
from og_bronze.crm_prd_info cpi
	where cpi.prd_nm != TRIM(cpi.prd_nm)
	

	
-- Check for numbers -ve or nulls
-- Expectation: No Result
	
select
	cpi.prd_cost 
from og_bronze.crm_prd_info cpi 
where cpi.prd_cost < 0 or cpi.prd_cost is null or cpi.prd_cost = ''


-- shows 2 empty spaces


-- Check for Data Standardisation and Consistency

select DISTINCT cpi.prd_line from og_bronze.crm_prd_info cpi 


-- Check for quality of Dates Columns
-- Here the data makes no sense as the start date is greater than end date, and there is multiple overlapping of date 
-- where the price is changing within the same range. So we will have to build the end date as a new column with certain rules. 


select 
	*
from og_bronze.crm_prd_info cpi 
where cpi.prd_start_dt > cpi.prd_end_dt 






-- ===================================== crm_sales_details ===========================================


-- Check for unwanted spaces
-- Expectation: No Result


select 
	csd.sls_ord_num 
from 
	og_bronze.crm_sales_details csd 
where csd.sls_ord_num != TRIM(csd.sls_ord_num)



select 
	csd.sls_prd_key  
FROM 
	og_bronze.crm_sales_details csd 
where csd.sls_prd_key != TRIM(csd.sls_prd_key)


-- We check if we can use sls_prd_key and sls_cst_id as foreign keys to join with crm_prd_info and crm_cst_info successfully as required in "data integration" diagram.
-- This will tell the usability of the 2 columns mentioned  

-- The below query shows that all the sls_cust_id are present in og_silver.crm_cust_info. Hence can be joined perfectly.


select 
	*
from og_bronze.crm_sales_details csd 
where csd.sls_cust_id not in (select cci.cst_id from og_silver.crm_cust_info cci )

-- Similarly the below query also shows that all the sls_prd_key are present in og_silver.crm_prd_info. Hence can be joined perfectly.

select 
	*
from og_bronze.crm_sales_details csd 
where csd.sls_prd_key not in (select cpi.prd_key from og_silver.crm_prd_info cpi )




-- Check for invalid Dates, < 0, outliers, not length of 8 (2025-01-01)

select 
	csd.sls_order_dt
from og_bronze.crm_sales_details csd 
where 
	csd.sls_order_dt <= 0 
	or length(csd.sls_order_dt) != 8 
	or csd.sls_order_dt > 20500101 
	or csd.sls_order_dt < 19000101



select 
	csd.sls_ship_dt 
from og_bronze.crm_sales_details csd 
where 
	csd.sls_ship_dt <= 0 
	or length(csd.sls_ship_dt) != 8 
	or csd.sls_ship_dt > 20500101 
	or csd.sls_ship_dt < 19000101

	
	
select 
	csd.sls_due_dt  
from og_bronze.crm_sales_details csd 
where 
	csd.sls_due_dt <= 0 
	or length(csd.sls_due_dt) != 8 
	or csd.sls_due_dt > 20500101 
	or csd.sls_due_dt < 19000101

-- Invalid date orders
	
select
	* 
from 
	og_bronze.crm_sales_details csd 
where csd.sls_order_dt > csd.sls_ship_dt or csd.sls_order_dt > csd.sls_due_dt 


-- Check data cionsistency between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must not be Null, Zero or Negative

Select 
	csd.sls_sales,
	csd.sls_quantity,
	csd.sls_price,
	case when csd.sls_sales <= 0 or csd.sls_sales is null or csd.sls_sales != csd.sls_quantity * ABS(csd.sls_price)
		then csd.sls_sales = csd.sls_quantity * ABS(csd.sls_price)
		else csd.sls_sales
	END AS sls_sales,
	case when csd.sls_price <=0 or csd.sls_price is null
		then csd.sls_sales/NULLIF(csd.sls_quantity, 0)
		else csd.sls_price
	END AS sls_price
from og_bronze.crm_sales_details csd 
where csd.sls_sales != (csd.sls_quantity * csd.sls_price)
or csd.sls_sales is Null or csd.sls_quantity is NULL or csd.sls_price is NULL
or csd.sls_sales <= 0 or csd.sls_quantity <=0 or csd.sls_price <= 0
	
-- Rules: 
--	1. If Sales is negative, zero or null, derive it using Quantity and Price.
--	2. If Price is zero or null, calculate it using sales and Quantity.
--	3. If Price is negative, convert it into a postive value.





-- ===================================== erp_cust_AZ12 ===========================================

-- Check for unwanted spaces and nulls
-- Expectation: No Result

select 
	eca.cust_id 
from og_bronze.erp_cust_AZ12 eca 
where eca.cust_id is NUll or eca.cust_id  != TRIM(eca.cust_id)



-- Check outliers for bdate

select 
	distinct eca.b_date  
from og_bronze.erp_cust_AZ12 eca 
where eca.b_date <= 1900-01-01 or eca.b_date >= CURRENT_DATE()


-- check cardinality and all possible values for gender

select 
	distinct eca.gender 
from og_bronze.erp_cust_AZ12 eca 


SELECT DISTINCT gender, HEX(gender), LENGTH(gender) 
FROM og_bronze.erp_cust_AZ12; --  finds the hexcode and length of every distinct gender value.