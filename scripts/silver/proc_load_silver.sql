DELIMITER $$

CREATE PROCEDURE load_silver_layer()
BEGIN

    -- =========================================================================
    -- CRM_CUST_INFO
    -- =========================================================================

    TRUNCATE TABLE sdw_silver.crm_cust_info;

    INSERT INTO sdw_silver.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        t.cst_id,
        t.cst_key,
        TRIM(t.cst_firstname),
        TRIM(t.cst_lastname),
        CASE
            WHEN UPPER(TRIM(t.cst_marital_status)) = 'M' THEN 'Married'
            WHEN UPPER(TRIM(t.cst_marital_status)) = 'S' THEN 'Single'
            ELSE 'N/A'
        END,
        CASE
            WHEN UPPER(TRIM(t.cst_gndr)) = 'M' THEN 'Male'
            WHEN UPPER(TRIM(t.cst_gndr)) = 'F' THEN 'Female'
            ELSE 'N/A'
        END,
        t.cst_create_date
    FROM
    (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY cst_id
                   ORDER BY cst_create_date DESC
               ) row_num
        FROM sdw_bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
          AND cst_id <> 0
    ) t
    WHERE t.row_num = 1;


    -- =========================================================================
    -- CRM_PRD_INFO
    -- =========================================================================

    TRUNCATE TABLE sdw_silver.crm_prd_info;

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
        REPLACE(SUBSTR(TRIM(prd_key),1,5),'-','_'),
        REPLACE(SUBSTR(TRIM(prd_key),7),'-','_'),
        prd_nm,
        prd_cost,
        CASE
            WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
            ELSE 'N/A'
        END,
        prd_start_dt,
        DATE_SUB(
            LEAD(prd_start_dt) OVER (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ),
            INTERVAL 1 DAY
        )
    FROM sdw_bronze.crm_prd_info;


    -- =========================================================================
    -- CRM_SALES_DETAILS
    -- =========================================================================

    TRUNCATE TABLE sdw_silver.crm_sales_details;

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
            WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) <> 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
        END,

        CASE
            WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) <> 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
        END,

        CASE
            WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) <> 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
        END,

        CASE
            WHEN sls_sales IS NULL
              OR sls_sales <= 0
              OR sls_sales <> sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END,

        sls_quantity,

        CASE
            WHEN sls_price IS NULL
              OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity,0)
            ELSE sls_price
        END
    FROM sdw_bronze.crm_sales_details;


    -- =========================================================================
    -- ERP_CUST_AZ12
    -- =========================================================================

    TRUNCATE TABLE sdw_silver.erp_cust_az12;

    INSERT INTO sdw_silver.erp_cust_az12
    (
        cid,
        bdate,
        gen
    )
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4)
            ELSE cid
        END,

        CASE
            WHEN bdate > CURRENT_DATE() THEN NULL
            ELSE bdate
        END,

        CASE
            WHEN UPPER(TRIM(REPLACE(REPLACE(gen,CHAR(13),''),CHAR(10),'')))
                 IN ('F','FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(REPLACE(REPLACE(gen,CHAR(13),''),CHAR(10),'')))
                 IN ('M','MALE') THEN 'Male'
            ELSE 'N/A'
        END
    FROM sdw_bronze.erp_cust_az12;


    -- =========================================================================
    -- ERP_LOC_A101
    -- =========================================================================

    TRUNCATE TABLE sdw_silver.erp_loc_a101;

    INSERT INTO sdw_silver.erp_loc_a101
    (
        cid,
        cntry
    )
    SELECT
        REPLACE(cid,'-',''),

        CASE
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry,CHAR(13),''),CHAR(10),''))) = 'DE'
                THEN 'Germany'
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry,CHAR(13),''),CHAR(10),'')))
                IN ('US','USA')
                THEN 'United States'
            WHEN cntry IS NULL
              OR TRIM(REPLACE(REPLACE(cntry,CHAR(13),''),CHAR(10),'')) = ''
                THEN 'N/A'
            ELSE UPPER(TRIM(REPLACE(REPLACE(cntry,CHAR(13),''),CHAR(10),'')))
        END
    FROM sdw_bronze.erp_loc_a101;


    -- =========================================================================
    -- ERP_PXCAT_G1V2
    -- =========================================================================

    TRUNCATE TABLE sdw_silver.erp_pxcat_g1v2;

    INSERT INTO sdw_silver.erp_pxcat_g1v2
    (
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

END$$

DELIMITER ;
CALL load_silver_layer();