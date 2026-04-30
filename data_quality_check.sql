-- ==================================================================
-- ================= Common checks for data cleaning ================
-- ==================================================================


-- Column details 
EXEC sp_help 'bronze.erp_cust_az12';




-- Primary key null check and duplicate check
-- Expectation : No result

SELECT
	prd_id,
	COUNT(*) AS flag
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- Relationshiop check with other tables (foreign key validation)
-- Expectation : No Result
SELECT
	sls_cust_id 
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);




-- Check for unwanted spaces
-- Expectation : No result

SELECT
	sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key)


-- Check for negative and null number acccording to columns
-- Should be align with column use case

SELECT
	prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


-- Check the consistancy of values in low cardinality columns (data standardization and consistancy)
-- Expectation : should be meaningful and standard


SELECT DISTINCT
	prd_line
FROM bronze.crm_prd_info;

SELECT DISTINCT
	cst_marital_status
FROM silver.crm_cust_info

-- Date related checks
-- Check valid dates in date columns
-- Expectation : no result
SELECT prd_end_dt, *
FROM silver.crm_prd_info
WHERE TRY_CAST(prd_end_dt AS DATE) IS NULL  -- It failed the test...
  AND prd_end_dt IS NOT NULL;               -- ...but it wasn't empty to begin with!




-- ==================================================================
-- ========================= project specific checks ================
-- ==================================================================

SELECT 
	*
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt


SELECT
	prd_id,
	prd_key,
	prd_nm,
	prd_start_dt,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS test_end_date,
	prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R','AC-HE-HL-U509')


SELECT
    NULLIF (sls_due_dt,0) sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0 OR LEN(sls_due_dt) != 8


SELECT
    *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt> sls_due_dt;



SELECT DISTINCT 
    sls_sales,
	sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price;

SELECT TOP 2000 * FROM silver.crm_sales_details;


-- for bronze.erp_cust_az12

SELECT * FROM silver.erp_cust_az12
WHERE bdate > GETDATE()

SELECT DISTINCT gen FROM silver.erp_cust_az12;

SELECT TOP 1000 * FROM silver.erp_cust_az12;

-- bronze.erp_loc_a101
SELECT TOP 1000 * FROM bronze.erp_loc_a101;

SELECT DISTINCT *
FROM silver.erp_loc_a101;

-- TL
INSERT INTO silver.erp_loc_a101 (
	cid,
	cntry
)
SELECT
	REPLACE(cid, '-', '') AS cid,
	CASE
		WHEN TRIM(cntry) IN ( 'DE', 'Germany') THEN 'Germany'
		WHEN TRIM(cntry) IN ('USA', 'United States', 'US' ) THEN 'United States'
		WHEN cntry  IS NULL OR LEN(TRIM(cntry)) = 0 THEN 'N/A'
		ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101


-- bronze.erp_px_cat_g1v2
SELECT TOP 1000 * FROM bronze.erp_px_cat_g1v2

-- checks

-- ddl inspection
EXEC sp_help 'bronze.erp_px_cat_g1v2';



-- -- relationship id check 
SELECT 
	*
FROM bronze.erp_px_cat_g1v2 
WHERE id NOT IN (
SELECT cat_id FROM silver.crm_prd_info)



-- unwanted spaces check
-- Result : all coulums OK
SELECT
	maintenance
FROM bronze.erp_px_cat_g1v2
WHERE maintenance  != TRIM(maintenance)

-- data standardization consistancy
-- Rsult : all coulumns are OK

SELECT DISTINCT
	maintenance
FROM bronze.erp_px_cat_g1v2


-- all coulmn query
INSERT INTO silver.erp_px_cat_g1v2 (
	id,
	cat,
	subcat,
	maintenance)
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2

SELECT * FROM silver.erp_px_cat_g1v2;




