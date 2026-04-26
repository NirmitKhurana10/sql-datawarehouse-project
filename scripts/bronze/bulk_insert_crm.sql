/*
====================================================================================
Bulk Insert Script: Bulk Insert Bronze Tables for CRM data and log data in log table
====================================================================================
Script Purpose:
    This script bulk inserts the data in tables in the 'bronze' schema, while 
    truncating the existing data and adding the data as a fresh table.
	  Run this script to re-write the Data structure of 'bronze' Tables.
====================================================================================
*/


SET @batch_start = NOW();

INSERT INTO og_bronze.etl_process_log (process_step, status_message, created_at)
VALUES ('Bronze Layer Data Ingestion: CRM Data', 'Bulk Insert Start', @batch_start);


-- --------------------------------
-- Load Customer Info
-- --------------------------------
TRUNCATE TABLE og_bronze.crm_cust_info;

LOAD DATA LOCAL INFILE '/Users/nirmitkhurana/Desktop/Nirmit Docs/Projects/SQL/sql-datawarehouse-project_me/datasets/source_crm/cust_info.csv'
INTO TABLE og_bronze.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- --------------------------------
-- Load Product Info
-- --------------------------------
TRUNCATE TABLE og_bronze.crm_prd_info;

LOAD DATA LOCAL INFILE '/Users/nirmitkhurana/Desktop/Nirmit Docs/Projects/SQL/sql-datawarehouse-project_me/datasets/source_crm/prd_info.csv'
INTO TABLE og_bronze.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- --------------------------------
-- Load Sales Details
-- --------------------------------
TRUNCATE TABLE og_bronze.crm_sales_details;

LOAD DATA LOCAL INFILE '/Users/nirmitkhurana/Desktop/Nirmit Docs/Projects/SQL/sql-datawarehouse-project_me/datasets/source_crm/sales_details.csv'
INTO TABLE og_bronze.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- --------------------------------
-- Calculate Duration and Log Completion
-- --------------------------------
SET @batch_end = NOW();

SET @duration_seconds = TIMESTAMPDIFF(SECOND, @batch_start, @batch_end);

INSERT INTO og_bronze.etl_process_log (process_step, status_message, created_at ,end_at, duration_of_script_execution)
VALUES ('Bronze Layer Data Ingestion: CRM Data', 'Bulk Insert Complete', @batch_start, @batch_end, @duration_seconds);

-- select * from og_bronze.crm_cust_info cci ;
-- select * from og_bronze.crm_prd_info cpi ;
-- select * from og_bronze.crm_sales_details csd ;

