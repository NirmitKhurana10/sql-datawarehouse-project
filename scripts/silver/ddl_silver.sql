/*
===============================================================================
DDL Script: Create Silver Tables and log table
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/


drop table if exists og_silver.crm_cust_info;
create table og_silver.crm_cust_info(

	cst_id INT,
	cst_key VARCHAR(100),
	cst_firstname VARCHAR(100),
	cst_lastname VARCHAR(100),
	cst_marital_status VARCHAR(100),
	cst_gndr VARCHAR(100),
	cst_create_date DATE,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
	
);


drop table if exists og_silver.crm_prd_info;
create table og_silver.crm_prd_info(

	prd_id INT,
	prd_key VARCHAR(100),
	prd_nm VARCHAR(100),
	prd_cost INT,
	prd_line VARCHAR(100),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

drop table if exists og_silver.crm_sales_details;
create table og_silver.crm_sales_details(

	sls_ord_num VARCHAR(100),
	sls_prd_key VARCHAR(100),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);


DROP TABLE IF EXISTS og_silver.erp_cust_AZ12;
create table og_silver.erp_cust_AZ12(

	cust_id VARCHAR(100),
	b_date DATE,
	gender VARCHAR(100),
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
	
);

DROP TABLE IF EXISTS og_silver.erp_loc_A101;
create table og_silver.erp_loc_A101(

	cust_id VARCHAR(100),
	c_entry VARCHAR(100),
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
	
);


DROP TABLE IF EXISTS og_silver.erp_prx_cat_G1V2;
create table og_silver.erp_prx_cat_G1V2(

	id VARCHAR(100),
	cat VARCHAR(100),
	sub_cat VARCHAR(100),
	MAINTENANCE VARCHAR(100),
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
	
);


-- This log table will help us execute each log statement to track all the logs happening in our database for the ETL process

DROP table if exists og_silver.etl_process_log; 
CREATE TABLE IF NOT EXISTS og_silver.etl_process_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    process_step VARCHAR(100),
    status_message VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_at TIMESTAMP NULL,
    duration_of_script_execution INT COMMENT 'Duration in seconds'
);

