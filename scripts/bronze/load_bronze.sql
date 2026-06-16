TRUNCATE TABLE  SDW_BRONZE.crm_cust_info;
LOAD DATA LOCAL INFILE 'C:\\Users\\mahaj\\MyData\\Projects\\Data Engineering\\Sql_Data_Warehouse_Prooject\\datasets\\source_crm\\cust_info.csv'
INTO TABLE SDW_BRONZE.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM SDW_BRONZE.crm_cust_info; -- 18494

TRUNCATE TABLE  SDW_BRONZE.CRM_PRD_INFO;
LOAD DATA LOCAL INFILE 'C:\\Users\\mahaj\\MyData\\Projects\\Data Engineering\\Sql_Data_Warehouse_Prooject\\datasets\\source_crm\\prd_info.csv'
INTO TABLE SDW_BRONZE.CRM_PRD_INFO
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM SDW_BRONZE.CRM_PRD_INFO; -- 397

TRUNCATE TABLE  SDW_BRONZE.CRM_SALES_DETAILS;
LOAD DATA LOCAL INFILE 'C:\\Users\\mahaj\\MyData\\Projects\\Data Engineering\\Sql_Data_Warehouse_Prooject\\datasets\\source_crm\\sales_details.csv'
INTO TABLE SDW_BRONZE.CRM_SALES_DETAILS
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM SDW_BRONZE.CRM_SALES_DETAILS; -- 60398

--------------------------------------------------------------------------------------

TRUNCATE TABLE  SDW_BRONZE.ERP_CUST_AZ12;
LOAD DATA LOCAL INFILE 'C:\\Users\\mahaj\\MyData\\Projects\\Data Engineering\\Sql_Data_Warehouse_Prooject\\datasets\\source_erp\\CUST_AZ12.csv'
INTO TABLE SDW_BRONZE.ERP_CUST_AZ12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM SDW_BRONZE.ERP_CUST_AZ12; -- 18484


TRUNCATE TABLE  SDW_BRONZE.ERP_LOC_A101;
LOAD DATA LOCAL INFILE 'C:\\Users\\mahaj\\MyData\\Projects\\Data Engineering\\Sql_Data_Warehouse_Prooject\\datasets\\source_erp\\LOC_A101.csv'
INTO TABLE SDW_BRONZE.ERP_LOC_A101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM SDW_BRONZE.ERP_LOC_A101; -- 18484


TRUNCATE TABLE  SDW_BRONZE.ERP_PXCAT_G1V2;
LOAD DATA LOCAL INFILE 'C:\\Users\\mahaj\\MyData\\Projects\\Data Engineering\\Sql_Data_Warehouse_Prooject\\datasets\\source_erp\\PX_CAT_G1V2.csv'
INTO TABLE SDW_BRONZE.ERP_PXCAT_G1V2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM SDW_BRONZE.ERP_PXCAT_G1V2; -- 37