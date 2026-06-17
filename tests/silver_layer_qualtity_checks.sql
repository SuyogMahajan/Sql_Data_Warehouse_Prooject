# /*

Data Quality Checks - CRM Customer Information
Source Table: SDW_BRONZE.CRM_CUST_INFO
Target Table: SDW_SILVER.CRM_CUST_INFO
======================================

Purpose:
Perform data profiling and quality checks on the Bronze layer before loading
data into the Silver layer.

Checks Performed:

1. Null Values
2. Duplicate Records
3. Leading/Trailing Spaces
4. Domain Validation
5. Data Standardization Requirements
   ===============================================================================
   */

-- ============================================================================
-- cst_id
-- ============================================================================

-- Check for duplicate and null customer IDs
SELECT
c.cst_id,
COUNT(*) AS record_count
FROM SDW_BRONZE.CRM_CUST_INFO c
GROUP BY c.cst_id
HAVING COUNT(*) > 1
OR c.cst_id IS NULL;

/*
Findings:

* Duplicate customer IDs exist.
* Customer IDs with value 0 exist.
* Null customer IDs exist.

Action:

* Exclude NULL and 0 customer IDs.
* Retain the latest record based on CST_CREATE_DATE using ROW_NUMBER().
  */

-- ============================================================================
-- cst_key
-- ============================================================================

-- Check for leading/trailing spaces
SELECT *
FROM SDW_BRONZE.CRM_CUST_INFO
WHERE cst_key <> TRIM(cst_key);

/*
Findings:

* No leading or trailing spaces detected.
  */

-- Check for duplicate and null customer keys
SELECT
c.cst_key,
COUNT(*) AS record_count
FROM SDW_BRONZE.CRM_CUST_INFO c
GROUP BY c.cst_key
HAVING COUNT(*) > 1
OR c.cst_key IS NULL;

/*
Findings:

* No NULL customer keys found.
* Duplicate customer keys exist.
  */

-- Review duplicate records
SELECT *
FROM SDW_BRONZE.CRM_CUST_INFO
WHERE cst_key IN
(
'AW00029483',
'AW00029449',
'AW00029466',
'AW00029473'
);

/*
Findings:

* Duplicate records are differentiated by CST_CREATE_DATE.
* Newer records contain more complete information.

Action:

* Retain the latest record using ROW_NUMBER().
  */

-- ============================================================================
-- cst_firstname
-- ============================================================================

-- Check for leading/trailing spaces
SELECT *
FROM SDW_BRONZE.CRM_CUST_INFO
WHERE cst_firstname <> TRIM(cst_firstname);

/*
Findings:

* Leading/trailing spaces found.

Action:

* Apply TRIM() during Silver layer transformation.
  */

-- ============================================================================
-- cst_lastname
-- ============================================================================

-- Check for leading/trailing spaces
SELECT *
FROM SDW_BRONZE.CRM_CUST_INFO
WHERE cst_lastname <> TRIM(cst_lastname);

/*
Findings:

* Leading/trailing spaces found.

Action:

* Apply TRIM() during Silver layer transformation.
  */

-- ============================================================================
-- cst_marital_status
-- ============================================================================

-- Check for leading/trailing spaces
SELECT *
FROM SDW_BRONZE.CRM_CUST_INFO
WHERE cst_marital_status <> TRIM(cst_marital_status);

/*
Findings:

* No leading/trailing spaces found.
  */

-- Check distinct values
SELECT DISTINCT cst_marital_status
FROM SDW_BRONZE.CRM_CUST_INFO;

/*
Findings:

* Valid values: M, S
* NULL values present

Transformation Rule:
M -> Married
S -> Single
NULL/Other -> N/A
*/

-- ============================================================================
-- cst_gndr
-- ============================================================================

-- Check for leading/trailing spaces
SELECT *
FROM SDW_BRONZE.CRM_CUST_INFO
WHERE cst_gndr <> TRIM(cst_gndr);

/*
Findings:

* No leading/trailing spaces found.
  */

-- Check distinct values
SELECT DISTINCT cst_gndr
FROM SDW_BRONZE.CRM_CUST_INFO;

/*
Findings:

* Valid values: M, F
* NULL values present

Transformation Rule:
M -> Male
F -> Female
NULL/Other -> N/A
*/

-- ============================================================================
-- Summary
-- ============================================================================

/*
Data Quality Issues Identified:

1. Duplicate customer records exist.
2. NULL customer IDs exist.
3. Customer IDs with value 0 exist.
4. Leading/trailing spaces found in:

   * CST_FIRSTNAME
   * CST_LASTNAME
5. Marital Status requires standardization.
6. Gender requires standardization.

Silver Layer Actions:

✓ Remove records with NULL or 0 CST_ID.
✓ Keep latest record using ROW_NUMBER().
✓ Trim first and last names.
✓ Standardize marital status values.
✓ Standardize gender values.
*/





 /*

Data Quality Checks - CRM Product Information
Source Table: SDW_BRONZE.CRM_PRD_INFO
Target Table: SDW_SILVER.CRM_PRD_INFO
=====================================

Purpose:
Perform data profiling and quality checks on product data before loading
it into the Silver layer.

Checks Performed:

1. Null Values
2. Duplicate Records
3. Leading/Trailing Spaces
4. Domain Validation
5. Date Validation
   ===============================================================================
   */

-- ============================================================================
-- prd_id
-- ============================================================================

-- Check for duplicate product IDs
SELECT
prd_id,
COUNT(*) AS record_count
FROM SDW_BRONZE.CRM_PRD_INFO
GROUP BY prd_id
HAVING COUNT(*) > 1;

/*
Findings:

* No duplicate product IDs found.
  */

-- Check for NULL product IDs
SELECT *
FROM SDW_BRONZE.CRM_PRD_INFO
WHERE prd_id IS NULL;

/*
Findings:

* No NULL product IDs found.
  */

-- ============================================================================
-- prd_key
-- ============================================================================

-- Check for duplicate product keys
SELECT
prd_key,
COUNT(*) AS record_count
FROM SDW_BRONZE.CRM_PRD_INFO
GROUP BY prd_key
HAVING COUNT(*) > 1;

/*
Findings:

* Duplicate product keys exist.
  */

-- Review duplicate product records
SELECT *
FROM SDW_BRONZE.CRM_PRD_INFO
WHERE prd_key = 'CO-RF-FR-R92R-56';

/*
Findings:

* Duplicate product keys represent different versions of the same product.
* Product cost and validity periods differ across records.
* Expected behavior for historical product tracking.
  */

-- Check for NULL product keys
SELECT *
FROM SDW_BRONZE.CRM_PRD_INFO
WHERE prd_key IS NULL;

/*
Findings:

* No NULL product keys found.
  */

-- Check for leading/trailing spaces
SELECT *
FROM SDW_BRONZE.CRM_PRD_INFO
WHERE prd_key <> TRIM(prd_key);

/*
Findings:

* No leading/trailing spaces found.
  */

-- ============================================================================
-- prd_nm
-- ============================================================================

-- Check for NULL product names
SELECT *
FROM SDW_BRONZE.CRM_PRD_INFO
WHERE prd_nm IS NULL;

/*
Findings:

* No NULL product names found.
  */

-- Check for leading/trailing spaces
SELECT *
FROM SDW_BRONZE.CRM_PRD_INFO
WHERE prd_nm <> TRIM(prd_nm);

/*
Findings:

* No leading/trailing spaces found.
  */

-- ============================================================================
-- prd_cost
-- ============================================================================

-- Check for invalid product costs
SELECT *
FROM SDW_BRONZE.CRM_PRD_INFO
WHERE prd_cost IS NULL
OR prd_cost <= 0;

/*
Findings:

* No NULL, zero, or negative product costs found.
  */

-- ============================================================================
-- prd_line
-- ============================================================================

-- Check for leading/trailing spaces
SELECT *
FROM SDW_BRONZE.CRM_PRD_INFO
WHERE prd_line <> TRIM(prd_line);

/*
Findings:

* No leading/trailing spaces found.
  */

-- Review distinct product line values
SELECT DISTINCT prd_line
FROM SDW_BRONZE.CRM_PRD_INFO;

/*
Findings:

* Product line values:
  R = Road
  M = Mountain
  S = Other Sales
  T = Touring
  NULL/Blank = Unknown

Transformation Rule:
R -> Road
M -> Mountain
S -> Other Sales
T -> Touring
NULL/Blank -> N/A
*/

-- ============================================================================
-- prd_start_dt / prd_end_dt
-- ============================================================================

-- Check for invalid date ranges
SELECT *
FROM SDW_BRONZE.CRM_PRD_INFO
WHERE prd_end_dt < prd_start_dt;

/*
Findings:

* Multiple records found where PRD_END_DT is earlier than PRD_START_DT.

Analysis:

* Source system stores historical product versions.
* Existing PRD_END_DT values are unreliable for Silver layer processing.

Action:

* Recalculate PRD_END_DT using LEAD(PRD_START_DT)
  partitioned by PRD_KEY.
* Derive validity periods from product history.
  */

-- ============================================================================
-- Summary
-- ============================================================================

/*
Data Quality Issues Identified:

1. Duplicate product keys exist.
2. Historical product versions are stored for the same product key.
3. Product line codes require standardization.
4. Existing PRD_END_DT values are not reliable.
5. Product IDs, Names, and Costs are clean.

Silver Layer Actions:

✓ Standardize product line descriptions.
✓ Split product key into Category ID and Product Key.
✓ Recalculate PRD_END_DT using LEAD().
✓ Preserve historical product versions.
✓ Populate DWH_CREATE_DATE with CURRENT_TIMESTAMP.
*/
