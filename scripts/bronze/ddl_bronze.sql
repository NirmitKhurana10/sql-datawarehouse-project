/*
===============================================================================
DDL Script: Create Bronze Tables and log table
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/


drop table if exists og_bronze.crm_cust_info;
create table og_bronze.crm_cust_info(

	cst_id INT,
	cst_key VARCHAR(100),
	cst_firstname VARCHAR(100),
	cst_lastname VARCHAR(100),
	cst_marital_status VARCHAR(100),
	cst_gndr VARCHAR(100),
	cst_create_date VARCHAR(100)
);


drop table if exists og_bronze.crm_prd_info;
create table og_bronze.crm_prd_info(

	prd_id INT,
	prd_key VARCHAR(100),
	prd_nm VARCHAR(100),
	prd_cost VARCHAR(100),
	prd_line VARCHAR(100),
	prd_start_dt VARCHAR(100),
	prd_end_dt VARCHAR(100)
);

drop table if exists og_bronze.crm_sales_details;
create table og_bronze.crm_sales_details(

	sls_ord_num VARCHAR(100),
	sls_prd_key VARCHAR(100),
	sls_cust_id VARCHAR(100),
	sls_order_dt VARCHAR(100),
	sls_ship_dt VARCHAR(100),
	sls_due_dt VARCHAR(100),
	sls_sales VARCHAR(100),
	sls_quantity INT,
	sls_price double
);


DROP TABLE IF EXISTS og_bronze.erp_cust_AZ12;
create table og_bronze.erp_cust_AZ12(

	cust_id VARCHAR(100),
	b_date VARCHAR(100),
	gender VARCHAR(100)
	
);

DROP TABLE IF EXISTS og_bronze.erp_loc_A101;
create table og_bronze.erp_loc_A101(

	cust_id VARCHAR(100),
	c_entry VARCHAR(100)
	
);


DROP TABLE IF EXISTS og_bronze.erp_prx_cat_G1V2;
create table og_bronze.erp_prx_cat_G1V2(

	id VARCHAR(100),
	cat VARCHAR(100),
	sub_cat VARCHAR(100),
	MAINTENANCE VARCHAR(100)
	
);


-- This log table will help us execute each log statement to track all the logs happening in our database for the ETL process

DROP table if exists og_bronze.etl_process_log; 
CREATE TABLE IF NOT EXISTS og_bronze.etl_process_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    process_step VARCHAR(100),
    status_message VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_at TIMESTAMP NULL,
    duration_of_script_execution INT COMMENT 'Duration in seconds'
);

