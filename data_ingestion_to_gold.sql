CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	cl.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE 
		WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
		ELSE COALESCE( ca.gen, 'N/A')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS cl
ON ci.cst_key = cl.cid 
GO


SELECT TOP 1000 * FROM silver.erp_px_cat_g1v2;
GO

CREATE VIEW gold.dim_products AS (
SELECT
	ROW_NUMBER () OVER (ORDER BY prd_id) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	cat.cat AS category,
	cat.subcat AS sub_categoty,
	cat.maintenance AS maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS cat
ON pn.cat_id = cat.id
WHERE pn.prd_end_dt IS NULL )
GO


CREATE VIEW gold.fact_sales AS (
SELECT
	sls_ord_num AS order_number,
	pr.product_key,
	cs.customer_key,
	sls_order_dt AS order_date,
	sls_ship_dt AS ship_date,
	sls_due_dt AS due_date,
	sls_sales AS sales,
	sls_quantity AS quantity,
	sls_price AS price
FROM silver.crm_sales_details AS csd
LEFT JOIN gold.dim_products AS pr
ON csd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cs
ON csd.sls_cust_id = cs.customer_id)
GO


-- foreign key integrity test

SELECT *
FROM gold.fact_sales  AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL





-- check after join
SELECT
	cst_id,
	COUNT(*)
FROM (
SELECT TOP 1000
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	cl.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS cl
ON ci.cst_key = cl.cid ) t

GROUP BY cst_id
HAVING COUNT(*) > 1


-- check for data integration
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE 
		WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
		ELSE COALESCE( ca.gen, 'N/A')
	END AS t_gender
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS cl
ON ci.cst_key = cl.cid
ORDER BY 1,2 
