SET @batch_start = NOW();

INSERT INTO og_bronze.etl_process_log (process_step, status_message, created_at)
VALUES ('Bronze Layer Data Ingestion: ERP Data', 'Bulk Insert', @batch_start);

-- --------------------------------
-- Load ERP Cust Info
-- --------------------------------


load data local infile '/Users/nirmitkhurana/Desktop/Nirmit Docs/Projects/SQL/Data-warehouse-project/exampleDatasets/source_erp/CUST_AZ12.csv'
into table og_bronze.erp_cust_AZ12
fields terminated by ','
lines terminated by '\n'
ignore 1 lines;

-- --------------------------------
-- Load Loc Info
-- --------------------------------

load data local infile '/Users/nirmitkhurana/Desktop/Nirmit Docs/Projects/SQL/Data-warehouse-project/exampleDatasets/source_erp/LOC_A101.csv'
into table og_bronze.erp_loc_A101
fields terminated by ','
lines terminated by '\n'
ignore 1 lines;

-- --------------------------------
-- Load Erp PRX Info
-- --------------------------------

load data local infile '/Users/nirmitkhurana/Desktop/Nirmit Docs/Projects/SQL/Data-warehouse-project/exampleDatasets/source_erp/PX_CAT_G1V2.csv'
into table og_bronze.erp_prx_cat_G1V2
fields terminated by ','
lines terminated by '\n'
ignore 1 lines;

-- --------------------------------
-- Calculate Duration and Log Completion
-- --------------------------------
SET @batch_end = NOW();

SET @duration_seconds = TIMESTAMPDIFF(SECOND, @batch_start, @batch_end);

INSERT INTO og_bronze.etl_process_log (process_step, status_message, created_at ,end_at, duration_of_script_execution)
VALUES ('Bronze Layer Data Ingestion: ERP Data', 'Bulk Insert Complete', @batch_start, @batch_end, @duration_seconds);

-- select * from og_bronze.erp_cust_AZ12 eca ;
-- select * from og_bronze.erp_loc_A101 ela ;
-- select * from og_bronze.erp_prx_cat_G1V2 epcgv ;
