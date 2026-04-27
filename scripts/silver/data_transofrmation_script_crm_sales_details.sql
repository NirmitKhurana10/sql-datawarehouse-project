INSERT INTO og_silver.crm_sales_details
(
	sls_ord_num, 
	sls_prd_key, 
	sls_cust_id, 
	sls_order_dt, 
	sls_ship_dt, 
	sls_due_dt, 
	sls_sales, 
	sls_quantity, 
	sls_price
)

SELECT 
	sls_ord_num, 
	sls_prd_key, 
	sls_cust_id, 
	CASE WHEN sls_order_dt = 0 or length(sls_order_dt) != 8 then NULL 
		else CAST(CAST(sls_order_dt AS CHAR) AS DATE)
		end as sls_order_dt,
	CASE WHEN sls_ship_dt = 0 or length(sls_ship_dt) != 8 then NULL 
		else CAST(CAST(sls_ship_dt AS CHAR) AS DATE)
		end as sls_ship_dt,
	CASE WHEN sls_due_dt = 0 or length(sls_due_dt) != 8 then NULL 
		else CAST(CAST(sls_due_dt AS CHAR) AS DATE)
		end as sls_due_dt, 
	case when sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity * ABS(sls_price)
		then sls_sales = sls_quantity * ABS(sls_price)
		else sls_sales
	END AS sls_sales,
	sls_quantity,
	case when sls_price <=0 or sls_price is null
		then sls_sales/NULLIF(sls_quantity, 0)
		else sls_price
	END AS sls_price	 
FROM og_bronze.crm_sales_details;