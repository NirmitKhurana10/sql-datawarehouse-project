create view og_gold.dim_customers as
SELECT 
	Row_number() over (order by cci.cst_id) as customer_key, -- this is a surrogate key to join tables, 
															 -- system generated unique identifier assigned to each record in the tables
															 -- that will be used only for connecting our data model.
	cci.cst_id as customer_id,
	cci.cst_key as customer_number,
	cci.cst_firstname as first_name,
	cci.cst_lastname as last_name,
	ela.c_entry as country,
	cci.cst_marital_status as marital_status, 
	case when cci.cst_gndr != 'N/A' then cci.cst_gndr -- CRM is the master for gender info
	else COALESCE(eca.gender , 'N/A') -- If not in CRM, use ERP gender and if that is also null, put N/A for that 
	end as gender,
	eca.b_date as birth_date,
	cci.cst_create_date as create_date
FROM og_silver.crm_cust_info cci
left JOIN  og_silver.erp_cust_AZ12 eca  
on cci.cst_key = eca.cust_id 
left join og_silver.erp_loc_A101 ela 
on cci.cst_key = ela.cust_id 



-- ==============================================================================

create view og_gold.dim_products as
SELECT 
	row_number() over (order by cpi.prd_start_dt, cpi.prd_key) as product_key,
	cpi.prd_id as product_id,
	cpi.prd_key as product_number,
	cpi.prd_nm as product_name, 
	cpi.cat_id as category_id, 
	epcgv.cat as category,
	epcgv.sub_cat as sub_category,
	epcgv.MAINTENANCE,
	cpi.prd_cost as product_cost, 
	cpi.prd_line as product_line, 
	cpi.prd_start_dt as product_start_date
FROM og_silver.crm_prd_info cpi
left join erp_prx_cat_G1V2 epcgv 
on cpi.cat_id = epcgv.id 
where cpi.prd_end_dt is null




-- ==============================================================================

-- Creating Fact table
-- Since it has multiple dimensions and transactions, hence it shows it will be a "fact" table


create view og_gold.fact_sales as
SELECT 
	csd.sls_ord_num as order_number, 
	dc.customer_key, 
	dp.product_key,
	csd.sls_order_dt as order_date,
	csd.sls_ship_dt as shipping_date, 
	csd.sls_due_dt as due_date, 
	csd.sls_sales as sales_amount,
	csd.sls_quantity as quantity, 
	csd.sls_price as price
FROM og_silver.crm_sales_details csd
left join og_gold.dim_customers dc 
on dc.customer_id = csd.sls_cust_id 
left join og_gold.dim_products dp 
on dp.product_number = csd.sls_prd_key 
