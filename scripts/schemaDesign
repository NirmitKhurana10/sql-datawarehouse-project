/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new schemas named 'bronze', 'silver', 'gold' after checking if they already exists. 
    If the database/schema exists, it is dropped and recreated.
    
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

-- Check if the Schemas (Databases) exist

SELECT 
    SCHEMA_NAME AS 'Layer Name',
    DEFAULT_CHARACTER_SET_NAME AS 'Encoding',
    'Created' AS 'Status'
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME IN ('bronze', 'silver', 'gold');

-- Drop schemas if found any and create new like following:

create schema bronze;
create schema silver;
create schema gold;
