SELECT 
	cci.cst_id, 
	cci.cst_key, 
	cci.cst_firstname, 
	cci.cst_lastname, 
	cci.cst_marital_status, 
	cci.cst_gndr, 
	cci.cst_create_date,
	eca.b_date,
	eca.gender,
	ela.c_entry 
FROM og_silver.crm_cust_info cci
left JOIN  og_silver.erp_cust_AZ12 eca  
on cci.cst_key = eca.cust_id 
left join og_silver.erp_loc_A101 ela 
on cci.cst_key = ela.cust_id 

-- ===================================================================
-- now we check the quality of join if the join has any duplicate rows 

select t.cst_key, 
		count(*)  
	from (
	SELECT 
		cci.cst_id, 
		cci.cst_key, 
		cci.cst_firstname, 
		cci.cst_lastname, 
		cci.cst_marital_status, 
		cci.cst_gndr, 
		cci.cst_create_date,
		eca.b_date,
		eca.gender,
		ela.c_entry 
	FROM og_silver.crm_cust_info cci
	left JOIN  og_silver.erp_cust_AZ12 eca  
	on cci.cst_key = eca.cust_id 
	left join og_silver.erp_loc_A101 ela 
	on cci.cst_key = ela.cust_id 
)t group by t.cst_key  
having count(*) > 1



-- we see there are 2 gneder columns, now we have to check the data integration. i.e if both of the columns are giving same results. 
-- If not we will have to perform data integration and make a combined derived column 



SELECT 
	DISTINCT cci.cst_gndr, 
	eca.gender,
	case when cci.cst_gndr != 'N/A' then cci.cst_gndr -- CRM is the master for gender info
	else COALESCE(eca.gender , 'N/A') -- If not in CRM, use ERP gender and if that is also null, put N/A for that 
	end as final_gender
FROM og_silver.crm_cust_info cci
left JOIN  og_silver.erp_cust_AZ12 eca  
on cci.cst_key = eca.cust_id 
left join og_silver.erp_loc_A101 ela 
on cci.cst_key = ela.cust_id 


-- Now we have done data integration to find the perfect gender, rewriting the total final script for making the view



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



















