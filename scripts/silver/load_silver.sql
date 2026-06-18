
-- CLEANING AND LOADING CRM_CUST_INFO INTO SILVER LAYER
TRUNCATE TABLE  SDW_SILVER.CRM_CUST_INFO;
INSERT INTO SDW_SILVER.CRM_CUST_INFO
(   cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date )
SELECT 
    T.CST_ID,
    T.CST_KEY,
    TRIM(T.CST_FIRSTNAME),
    TRIM(T.CST_LASTNAME),
    CASE WHEN UPPER(TRIM(T.cst_marital_status)) = 'M' THEN 'Married'
         WHEN UPPER(TRIM(T.cst_marital_status)) = 'S' THEN 'Single'
         ELSE 'N/A' END cst_marital_status,
    CASE WHEN UPPER(TRIM(T.CST_GNDR)) = 'M' THEN 'Male'
         WHEN UPPER(TRIM(T.CST_GNDR)) = 'F' THEN 'Female'
         ELSE 'N/A' END CST_GNDR,
    T.CST_CREATE_DATE
FROM (
    SELECT 
    *,
    ROW_NUMBER() OVER(PARTITION BY P.CST_ID ORDER BY P.CST_CREATE_DATE DESC) ROW_NUM
    FROM sdw_bronze.crm_cust_info P WHERE P.CST_ID != 0 AND P.CST_ID IS NOT NULL
) T
WHERE T.ROW_NUM = 1;

-- CLEANING AND LOADING CRM_PRD_INFO INTO SILVER LAYER
TRUNCATE sdw_silver.crm_prd_info;
INSERT INTO sdw_silver.crm_prd_info
(
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)

SELECT
    prd_id,
    REPLACE(SUBSTR(TRIM(prd_key), 1, 5), '-', '_') cat_id,
    REPLACE(SUBSTR(TRIM(prd_key), 7), '-', '_')  prd_key,
    prd_nm,
    prd_cost,
    CASE 
    	WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'N/A'
    END AS prd_line,
    prd_start_dt prd_start_dt,
    DATE_SUB( LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) ,INTERVAL 1 DAY)  prd_end_dt
from sdw_bronze.crm_prd_info;

-- CLEANING AND LOADING CRM_SALES_DETAILS INTO SILVER LAYER
TRUNCATE sdw_silver.crm_sales_details;
INSERT INTO sdw_silver.crm_sales_details
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
	CASE 
		WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
		ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
	END AS sls_order_dt,
	CASE 
		WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
		ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
	END AS sls_ship_dt,
	CASE 
		WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
		ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
	END AS sls_due_dt,
	CASE 
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
	sls_quantity,
	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0 
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price  -- Derive price if original value is invalid
	END AS sls_price
FROM sdw_bronze.crm_sales_details;

-- CLEANING AND LOADING ERP_CUST_AZ12 INTO SILVER LAYER

TRUNCATE TABLE sdw_silver.erp_cust_az12;

INSERT INTO sdw_silver.erp_cust_az12 (
	cid,
	bdate,
	gen
)
SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) -- Remove 'NAS' prefix if present
		ELSE cid
	END AS cid, 
	
	CASE
		WHEN bdate > CURRENT_DATE() THEN NULL
		ELSE bdate
	END AS bdate, -- Set future birthdates to NULL
	
	CASE
        WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''),CHAR(10), ''))) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''),CHAR(10), ''))) IN ('M', 'MALE') THEN 'Male'
        ELSE 'N/A'
	END AS gender -- Normalize gender values and handle unknown cases
FROM sdw_bronze.erp_cust_az12;

-- CLEANING AND LOADING ERP_LOC_A101 INTO SILVER LAYER

TRUNCATE TABLE sdw_silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101 (
	cid,
	cntry
)
SELECT
	REPLACE(cid, '-', '') AS cid, 
	CASE
		WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''),CHAR(10), ''))) = 'DE' THEN 'Germany'
		WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''),CHAR(10), ''))) IN ('US', 'USA') THEN 'United States'
		WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''),CHAR(10), ''))) = '' OR cntry IS NULL THEN 'N/A'
		ELSE UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''),CHAR(10), '')))
	END AS cntry -- Normalize and Handle missing or blank country codes
FROM sdw_bronze.erp_loc_a101;

-- CLEANING AND LOADING ERP_PXCAT_G1V2 INTO SILVER LAYER

TRUNCATE TABLE sdw_silver.erp_pxcat_g1v2;
		
INSERT INTO sdw_silver.erp_pxcat_g1v2 (
	id,
	cat,
	subcat,
	maintenance
)
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM sdw_bronze.erp_pxcat_g1v2;