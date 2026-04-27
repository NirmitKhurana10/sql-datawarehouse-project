insert into og_silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	
)

select
	cpi.prd_id,
	-- Deriving new columns
	REPLACE(SUBSTRING(cpi.prd_key, 1,5),'-','_')as cat_id, -- Extract category id
	SUBSTRING(cpi.prd_key, 7, LENGTH(cpi.prd_key)) as prd_key, -- Extract Product Key
	cpi.prd_nm,
	case when cpi.prd_cost = '' then 0 
		 else cpi.prd_cost
		end as prd_cost, -- instead of empty space, we want to have a 0
	case upper(trim(cpi.prd_line)) 
		 when 'M' then 'Mountain' 
		 when 'R' then 'Road'	
		 when 'S' then 'Other Sales'
		 when 'T' then 'Touring'
		 else 'N/A' -- Data normalization and standardization
		end as prd_line,
-- 	here we take the last start date of the next record make it the end date of the previous record
--  also we subtract 1 day from end date to make sure that end date of older price is smaller than start date of new price
--  i.e end date = start date of new record - 1		
	CAST(cpi.prd_start_dt as DATE) as prd_start_dt, -- typecasting 
	CAST(LEAD(cpi.prd_start_dt) over (Partition by cpi.prd_key order by cpi.prd_start_dt) - interval 1 day as DATE) as prd_end_dt -- data enrichment + typecasting
from og_bronze.crm_prd_info cpi 