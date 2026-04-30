SELECT TOP 1000
	*
FROM gold.fact_sales;

-- Change over time

SELECT TOP 1000
	order_date,
	sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
ORDER BY order_date

-- daily change
SELECT TOP 1000
	order_date,
	SUM(sales) AS total_sales
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date

-- yearly change
SELECT
	DATEPART(YEAR, order_date) AS sale_year,
	SUM(sales) AS total_sales
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY DATEPART(YEAR, order_date)
ORDER BY DATEPART(YEAR, order_date)

-- adding more metrics in yeary change
SELECT
	DATEPART(YEAR, order_date) AS sale_year,
	SUM(sales) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY DATEPART(YEAR, order_date)
ORDER BY DATEPART(YEAR, order_date)


-- monthly changes seasionality ( lowest sales in feb month and highest sales in december)
SELECT
	DATEPART(MONTH, order_date) AS sale_month,
	SUM(sales) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY DATEPART(MONTH, order_date)
ORDER BY DATEPART(MONTH, order_date)

-- year and month
SELECT
	DATEPART(YEAR, order_date) AS sale_year,
	DATEPART(MONTH, order_date) AS sale_month,
	SUM(sales) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY DATEPART(YEAR, order_date), DATEPART(MONTH, order_date)
ORDER BY DATEPART(YEAR, order_date), DATEPART(MONTH, order_date)



-- Cummulative Analysis

SELECT TOP 1000
	order_date,
	sales
FROM gold.fact_sales

-- total sales per month

-- Running Total
SELECT
	order_month,
	total_sales,
	SUM (total_sales) OVER (ORDER BY order_month ) AS running_total -- default  window frame (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) will give us effect of running total
FROM (
	SELECT
		DATETRUNC(MONTH,order_date) AS order_month,
		SUM (sales) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH,order_date))t


	
-- total sales per month for each year

SELECT
	order_month,
	total_sales,
	SUM (total_sales) OVER ( PARTITION BY order_month ORDER BY order_month ) AS running_total -- default  window frame (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) will give us effect of running total
FROM (
	SELECT
		DATETRUNC(MONTH,order_date) AS order_month,
		SUM (sales) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH,order_date))t


	-- total sales per year for each year (but not make any sense)

SELECT
	order_month,
	total_sales,
	SUM (total_sales) OVER ( PARTITION BY order_month ORDER BY order_month ) AS running_total -- default  window frame (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) will give us effect of running total
FROM (
	SELECT
		DATETRUNC(YEAR,order_date) AS order_month,
		SUM (sales) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR,order_date))t




-- Moving avarage 
SELECT
	order_month,
	total_sales,
	SUM (total_sales) OVER (ORDER BY order_month ) AS running_total, -- default  window frame (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) will give us effect of running total
	AVG (avg_price) OVER (ORDER BY order_month ) AS moving_avg_price
FROM (
	SELECT
		DATETRUNC(YEAR,order_date) AS order_month,
		SUM (sales) AS total_sales,
		AVG (price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR,order_date))t



-- Performance analysis 

WITH CTE_yearly_product_sale AS (
SELECT
	DATEPART(YEAR,f.order_date) AS order_year,
	p.product_name,
	SUM(f.sales) AS current_sales
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY DATEPART(YEAR,f.order_date) , p.product_name)

SELECT 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name ) AS product_avg_sale,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name ) AS diff_avg,
	CASE
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name ) > 0 THEN 'Above'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name ) < 0 THEN 'Below'
		ELSE 'No change'
	END AS flag,
	-- year over year 
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year ) AS prev_year_sale,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year ) AS diff_last_year_sale
FROM CTE_yearly_product_sale
ORDER BY product_name, order_year




-- Part to whole analysis
WITH CTE_total_sale_by_cat AS (
SELECT
	p.category,
	SUM(f.sales) AS total_sale_by_cat
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
GROUP BY p.category)

SELECT
	category,
	total_sale_by_cat,
	SUM (total_sale_by_cat) OVER () AS total_sale,
	CONCAT(ROUND((CAST( total_sale_by_cat AS float)/SUM (total_sale_by_cat) OVER ()) ,4)*100  , '%')AS percentage_share
FROM CTE_total_sale_by_cat
ORDER BY total_sale_by_cat DESC



-- Data segmantation
WITH CTE_product_segmentation AS (
SELECT
	product_key,
	product_name,
	cost,
	CASE
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100  AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END AS product_segment
FROM gold.dim_products)

SELECT
	COUNT(*) AS total_product,
	product_segment
FROM CTE_product_segmentation
GROUP BY product_segment
ORDER BY COUNT(*) DESC
