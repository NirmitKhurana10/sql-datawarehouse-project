CREATE PROCEDURE og_silver.sp_load_silver_layer()
BEGIN
    -- Error handling variables
    DECLARE v_batch_start DATETIME;
    DECLARE v_batch_end DATETIME;
    DECLARE v_duration INT;
    DECLARE v_error_message VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('ERROR: Procedure failed and rolled back. Reason: ', v_error_message) AS status;
    END;

    START TRANSACTION;
    SET v_batch_start = NOW();
    SELECT '>> Silver Layer Load Started...' AS status;

    -- --------------------------------
    -- crm_cust_info
    -- --------------------------------
    SELECT '>> Truncating og_silver.crm_cust_info...' AS status;
    TRUNCATE TABLE og_silver.crm_cust_info;

    SELECT '>> Inserting into og_silver.crm_cust_info...' AS status;
    INSERT INTO og_silver.crm_cust_info (
        cst_id, cst_key, cst_create_date, cst_firstname,
        cst_lastname, cst_marital_status, cst_gndr
    )
    SELECT
        t.cst_id,
        t.cst_key,
        t.cst_create_date,
        TRIM(t.cst_firstname),
        TRIM(t.cst_lastname),
        CASE WHEN UPPER(TRIM(t.cst_marital_status)) = 'S' THEN 'Single'
             WHEN UPPER(TRIM(t.cst_marital_status)) = 'M' THEN 'Married'
             ELSE 'N/A'
        END,
        CASE WHEN UPPER(TRIM(t.cst_gndr)) = 'F' THEN 'Female'
             WHEN UPPER(TRIM(t.cst_gndr)) = 'M' THEN 'Male'
             ELSE 'N/A'
        END
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM og_bronze.crm_cust_info
        WHERE cst_id != 0
    ) t WHERE t.flag_last = 1;
    SELECT '>> og_silver.crm_cust_info loaded successfully.' AS status;

    -- --------------------------------
    -- crm_prd_info
    -- --------------------------------
    SELECT '>> Truncating og_silver.crm_prd_info...' AS status;
    TRUNCATE TABLE og_silver.crm_prd_info;

    SELECT '>> Inserting into og_silver.crm_prd_info...' AS status;
    INSERT INTO og_silver.crm_prd_info (
        prd_id, cat_id, prd_key, prd_nm,
        prd_cost, prd_line, prd_start_dt, prd_end_dt
    )
    SELECT
        cpi.prd_id,
        REPLACE(SUBSTRING(cpi.prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(cpi.prd_key, 7, LENGTH(cpi.prd_key)) AS prd_key,
        cpi.prd_nm,
        CASE WHEN cpi.prd_cost = '' THEN 0 ELSE cpi.prd_cost END,
        CASE UPPER(TRIM(cpi.prd_line))
             WHEN 'M' THEN 'Mountain'
             WHEN 'R' THEN 'Road'
             WHEN 'S' THEN 'Other Sales'
             WHEN 'T' THEN 'Touring'
             ELSE 'N/A'
        END,
        CAST(cpi.prd_start_dt AS DATE),
        CAST(LEAD(cpi.prd_start_dt) OVER (PARTITION BY cpi.prd_key ORDER BY cpi.prd_start_dt) - INTERVAL 1 DAY AS DATE)
    FROM og_bronze.crm_prd_info cpi;
    SELECT '>> og_silver.crm_prd_info loaded successfully.' AS status;

    -- --------------------------------
    -- crm_sales_details
    -- --------------------------------
    SELECT '>> Truncating og_silver.crm_sales_details...' AS status;
    TRUNCATE TABLE og_silver.crm_sales_details;

    SELECT '>> Inserting into og_silver.crm_sales_details...' AS status;
    INSERT INTO og_silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt,
        sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
             ELSE CAST(CAST(sls_order_dt AS CHAR) AS DATE)
        END,
        CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
             ELSE CAST(CAST(sls_ship_dt AS CHAR) AS DATE)
        END,
        CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
             ELSE CAST(CAST(sls_due_dt AS CHAR) AS DATE)
        END,
        CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
             THEN sls_quantity * ABS(sls_price)
             ELSE sls_sales
        END,
        sls_quantity,
        CASE WHEN sls_price <= 0 OR sls_price IS NULL
             THEN sls_sales / NULLIF(sls_quantity, 0)
             ELSE sls_price
        END
    FROM og_bronze.crm_sales_details;
    SELECT '>> og_silver.crm_sales_details loaded successfully.' AS status;

    -- --------------------------------
    -- erp_cust_AZ12
    -- --------------------------------
    SELECT '>> Truncating og_silver.erp_cust_AZ12...' AS status;
    TRUNCATE TABLE og_silver.erp_cust_AZ12;

    SELECT '>> Inserting into og_silver.erp_cust_AZ12...' AS status;
    INSERT INTO og_silver.erp_cust_AZ12 (cust_id, b_date, gender)
    SELECT
        CASE WHEN cust_id LIKE 'NAS%' THEN SUBSTRING(cust_id, 4, LENGTH(cust_id))
             ELSE cust_id
        END,
        CASE WHEN b_date > CURRENT_DATE() THEN NULL ELSE b_date END,
        CASE WHEN UPPER(TRIM(REPLACE(gender, '\r', ''))) IN ('F', 'FEMALE') THEN 'Female'
             WHEN UPPER(TRIM(REPLACE(gender, '\r', ''))) IN ('M', 'MALE') THEN 'Male'
             ELSE 'N/A'
        END
    FROM og_bronze.erp_cust_AZ12;
    SELECT '>> og_silver.erp_cust_AZ12 loaded successfully.' AS status;

    -- --------------------------------
    -- erp_loc_A101
    -- --------------------------------
    SELECT '>> Truncating og_silver.erp_loc_A101...' AS status;
    TRUNCATE TABLE og_silver.erp_loc_A101;

    SELECT '>> Inserting into og_silver.erp_loc_A101...' AS status;
    INSERT INTO og_silver.erp_loc_A101 (cust_id, c_entry)
    SELECT
        REPLACE(TRIM(cust_id), '-', ''),
        CASE
            WHEN REPLACE(TRIM(c_entry), '\r', '') = 'DE' THEN 'Germany'
            WHEN REPLACE(TRIM(c_entry), '\r', '') IN ('US', 'USA') THEN 'United States'
            WHEN REPLACE(TRIM(c_entry), '\r', '') = '' OR c_entry IS NULL THEN 'N/A'
            ELSE REPLACE(TRIM(c_entry), '\r', '')
        END
    FROM og_bronze.erp_loc_A101;
    SELECT '>> og_silver.erp_loc_A101 loaded successfully.' AS status;

    -- --------------------------------
    -- erp_prx_cat_G1V2
    -- --------------------------------
    SELECT '>> Truncating og_silver.erp_prx_cat_G1V2...' AS status;
    TRUNCATE TABLE og_silver.erp_prx_cat_G1V2;

    SELECT '>> Inserting into og_silver.erp_prx_cat_G1V2...' AS status;
    INSERT INTO og_silver.erp_prx_cat_G1V2 (id, cat, sub_cat, MAINTENANCE)
    SELECT
        id,
        cat,
        sub_cat,
        CASE TRIM(REPLACE(MAINTENANCE, '\r', ''))
             WHEN 'Yes' THEN 'Yes'
             WHEN 'No' THEN 'No'
             ELSE 'N/A'
        END
    FROM og_bronze.erp_prx_cat_G1V2;
    SELECT '>> og_silver.erp_prx_cat_G1V2 loaded successfully.' AS status;

    -- --------------------------------
    -- Wrap up
    -- --------------------------------
    COMMIT;
    SET v_batch_end = NOW();
    SET v_duration = TIMESTAMPDIFF(SECOND, v_batch_start, v_batch_end);
    SELECT CONCAT('>> Silver Layer Load Complete! Duration: ', v_duration, ' seconds') AS status;

END