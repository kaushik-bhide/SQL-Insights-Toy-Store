/*1.) Exploring the products */
SELECT *
FROM products
LIMIT 10;
/*How Many Unique Products are there? */
SELECT 
	COUNT(DISTINCT(product_name))
FROM
	products
	
/*How Many Unique Categories are there? */	
SELECT 
	COUNT(DISTINCT(product_category))
FROM
	products
	
/* What are the different Categories */	
SELECT 
	DISTINCT(product_category)
FROM
	products
	
/* What is Max Purchase Price & Product Price? */

/* Converting purchase price to Numeric & reomving $ */
SELECT (REPLACE(product_cost,'$','')::NUMERIC) AS prod
FROM products

/* Removing $ from prod_cost */
UPDATE 
	products
SET 
	product_cost = REPLACE(product_cost,'$',''),
	product_price = REPLACE(product_price,'$','')

		
/* Converting both column as Numeric */
ALTER TABLE products
ALTER COLUMN product_cost TYPE NUMERIC USING(product_cost::NUMERIC),
ALTER COLUMN product_price TYPE NUMERIC USING(product_price::NUMERIC)

/* What is the Minimum & Maximum purchase cost? */
SELECT 
	MAX(product_cost)		/*Max*/
FROM
	products
	
SELECT 
	MIN(product_cost)		/*Min*/
FROM
	products

/* What is the Minimum & Maximum product price? */
SELECT 
	MAX(product_price)		/*Max*/
FROM
	products
	
SELECT 
	MIN(product_price)		/*Min*/
FROM
	products

/*Which Category has the maximum purchase cost? */
SELECT
	product_category,SUM(product_cost)
FROM
	products
GROUP BY
	product_category
ORDER BY 
	2 DESC;
	
	
/*Which Category has the maximum product price? */
SELECT
	product_category,SUM(product_price)
FROM
	products
GROUP BY
	product_category
ORDER BY 
	2 DESC;
	
/* Is there any product with purchase cost > selling cost? */
SELECT 
	product_name
FROM
	products
WHERE product_cost > product_price
	
SELECT *
FROM stores
