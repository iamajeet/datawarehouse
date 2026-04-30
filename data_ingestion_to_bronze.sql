CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	PRINT('==================================');
	PRINT('Loading bronze Layer');
	PRINT('==================================');


	PRINT('----------------------------------');
	PRINT('Loading CRM Tables');
	PRINT('----------------------------------');
	TRUNCATE TABLE bronze.crm_cust_info
	BULK INSERT bronze.crm_cust_info
	FROM 'C:\Users\AjeetY\datawarehouse\project_1\source_system\source_crm\cust_info.csv'
	WITH (
		FIRSTROW= 2,
		FIELDTERMINATOR= ',',
		TABLOCK
	);


	-- prd_info

	TRUNCATE TABLE bronze.crm_prd_info
	BULK INSERT bronze.crm_prd_info
	FROM 'C:\Users\AjeetY\datawarehouse\project_1\source_system\source_crm\prd_info.csv'
	WITH (
		FIRSTROW= 2,
		FIELDTERMINATOR= ',',
		TABLOCK
	);


	-- sales_details

	TRUNCATE TABLE bronze.crm_sales_details
	BULK INSERT bronze.crm_sales_details
	FROM 'C:\Users\AjeetY\datawarehouse\project_1\source_system\source_crm\sales_details.csv'
	WITH (
		FIRSTROW= 2,
		FIELDTERMINATOR= ',',
		TABLOCK
	);


	-- erp
	-- CUST_AZ12

	PRINT('----------------------------------');
	PRINT('Loading ERP Tables');
	PRINT('----------------------------------');
	TRUNCATE TABLE bronze.erp_cust_az12
	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\Users\AjeetY\datawarehouse\project_1\source_system\source_erp\CUST_AZ12.csv'
	WITH (
		FIRSTROW= 2,
		FIELDTERMINATOR= ',',
		TABLOCK
	);


	-- LOC_A101

	TRUNCATE TABLE bronze.erp_loc_a101
	BULK INSERT bronze.erp_loc_a101
	FROM 'C:\Users\AjeetY\datawarehouse\project_1\source_system\source_erp\LOC_A101.csv'
	WITH (
		FIRSTROW= 2,
		FIELDTERMINATOR= ',',
		TABLOCK
	);


	-- PX_CAT_G1V2

	TRUNCATE TABLE bronze.erp_px_cat_g1v2
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'C:\Users\AjeetY\datawarehouse\project_1\source_system\source_erp\PX_CAT_G1V2.csv'
	WITH (
		FIRSTROW= 2,
		FIELDTERMINATOR= ',',
		TABLOCK
	);


	/*
	-- validate data
	SELECT TOP 100 * FROM bronze.crm_cust_info;
	-- check all data loaded or not
	SELECT COUNT(*) FROM bronze.crm_cust_info



	SELECT TOP 100 * FROM bronze.crm_prd_info;
	SELECT COUNT(*) FROM bronze.crm_prd_info;


	SELECT TOP 100 * FROM bronze.crm_sales_details;
	SELECT COUNT(*) FROM bronze.crm_sales_details;


	SELECT TOP 100 * FROM bronze.erp_cust_az12;
	SELECT COUNT(*) FROM bronze.erp_cust_az12;


	SELECT TOP 100 * FROM bronze.erp_loc_a101;
	SELECT COUNT(*) FROM bronze.erp_loc_a101;


	SELECT TOP 100 * FROM bronze.erp_px_cat_g1v2;
	SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;
	*/
	PRINT('==================================');
	PRINT('Loading bronze Layer completed !!!');
	PRINT('==================================');
END
