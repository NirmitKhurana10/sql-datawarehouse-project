SELECT 
	cpi.prd_id, 
	cpi.cat_id, 
	cpi.prd_key, 
	cpi.prd_nm, 
	cpi.prd_cost, 
	cpi.prd_line, 
	cpi.prd_start_dt, 
	cpi.prd_end_dt,
	epcgv.cat,
	epcgv.sub_cat,
	epcgv.MAINTENANCE
FROM og_silver.crm_prd_info cpi
left join erp_prx_cat_G1V2 epcgv 
on cpi.cat_id = epcgv.id 


-- ===========================================================================
-- Now we can see that there are some products which have history, i.e. they have prod start date and end date
-- however accordinhg to business rule, we onlty need the current start date for the dimenson table
-- hence we will fileter out the rows whcih dont have an end date, i.e only getting product which are updated and currently running.


SELECT 
	cpi.prd_id, 
	cpi.cat_id, 
	cpi.prd_key, 
	cpi.prd_nm, 
	cpi.prd_cost, 
	cpi.prd_line, 
	cpi.prd_start_dt,
	epcgv.cat,
	epcgv.sub_cat,
	epcgv.MAINTENANCE
FROM og_silver.crm_prd_info cpi
left join erp_prx_cat_G1V2 epcgv 
on cpi.cat_id = epcgv.id 
where cpi.prd_end_dt is null -- Filter out all historical data

-- ===========================================================================
-- now we check for duplicate rows and columns if caused any by the join


select t.prd_id, count(*) from 
(SELECT 
	cpi.prd_id, 
	cpi.cat_id, 
	cpi.prd_key, 
	cpi.prd_nm, 
	cpi.prd_cost, 
	cpi.prd_line, 
	cpi.prd_start_dt,
	epcgv.cat,
	epcgv.sub_cat,
	epcgv.MAINTENANCE
FROM og_silver.crm_prd_info cpi
left join erp_prx_cat_G1V2 epcgv 
on cpi.cat_id = epcgv.id 
where cpi.prd_end_dt is null)t -- Filter out all historical data
GROUP by t.prd_id 
having count(*) >  1


-- we see there are no duplicate rows and columns, hence we proceed to data formatting with names and columns ordering

SELECT 
	cpi.prd_id as product_id,
	cpi.prd_key as product_key,
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
where cpi.prd_end_dt is null -- Filter out all historical data




-- adding a surrogate key for helping business join the tables together

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




-- Since there are alot of descriptions about a product, hence this is going to be a dimension table. 
