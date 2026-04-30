-- DATABASE exploration
SELECT * FROM INFORMATION_SCHEMA.TABLES;

SELECT 
	*
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

SELECT 
	*
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products'


--Dimension exploration
SELECT DISTINCT country FROM gold.dim_customers;

SELECT DISTINCT
	category, sub_categoty
FROM gold.dim_products;


SELECT DISTINCT
	category, sub_categoty, product_name
FROM gold.dim_products
ORDER BY 1,2,3


-- Date exploration 
SELECT
	MIN(order_date) AS oldest_order,
	MAX(order_date) AS recent_order,
	DATEDIFF(YEAR, MIN(order_date) , MAX(order_date)) AS lifespan
FROM gold.fact_sales;


SELECT
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_customer,
	DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_customer
FROM gold.dim_customers


-- Measure exploration
-- total sales
SELECT
	SUM(sales) AS total_sales,
	AVG(sales) AS avg_sales
FROM gold.fact_sales;

--total product sold
SELECT
	SUM(quantity) AS total_quantity
FROM gold.fact_sales;


-- Magnitude analysis
-- total num of customer by countries

SELECT
	COUNT(customer_key) AS customer_count,
	country
FROM gold.dim_customers
GROUP BY country;


-- Ranking analysis
-- top 5 product with higest revenue

SELECT TOP 5
	SUM(sales) AS total_sales,
	s.product_key,
	p.product_name
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.product_key
GROUP BY s.product_key, p.product_name
ORDER BY SUM(sales) DESC


-- worst 5 performing product
SELECT TOP 5
	SUM(sales) AS total_sales,
	s.product_key,
	p.product_name
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.product_key
GROUP BY s.product_key, p.product_name
ORDER BY SUM(sales)
