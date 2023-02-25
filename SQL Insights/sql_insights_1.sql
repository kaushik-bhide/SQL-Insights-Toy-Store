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
	MAX(product_cost) AS max_cost ,MIN(product_cost) AS min_cost	
FROM
	products

/* What is the Minimum & Maximum product price? */
SELECT 
	MAX(product_price) AS max_product_price,MIN(product_price) AS min_product_price		/*Max*/
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
	
/*Which Product is most profitable? */

SELECT product_name,(product_price - product_cost) AS profit
FROM products
ORDER BY profit DESC

ALTER TABLE products
ADD COLUMN profit NUMERIC

UPDATE products
SET profit = product_price - product_cost

SELECT product_name,profit
FROM products
ORDER BY profit DESC
LIMIT 1

--OR--

SELECT product_name,product_category,profit
FROM products
WHERE profit = (SELECT MAX(profit) FROM products)


/* Which Category is the Most Profitable? */
SELECT product_category,SUM(profit)
FROM products
GROUP BY product_category
ORDER BY 2 DESC


/* Which Category is the Least Profitable ? */
SELECT product_category,SUM(profit)
FROM products
GROUP BY product_category
ORDER BY 2 ASC

/*Which Product is the least profitable? */
SELECT product_name,product_category,profit
FROM products
WHERE profit = (SELECT MIN(profit) FROM products)

/*What is the Average Profit? */
SELECT AVG(profit)::INT
FROM products

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


/* Which product has the most stock availaible? */
SELECT product_id,SUM(stock_on_hand) 
FROM inventory
GROUP BY product_id
ORDER BY 2 DESC
LIMIT 1

SELECT p.product_name,i.product_id,SUM(i.stock_on_hand) AS total_no_of_stock 
FROM products p
JOIN inventory i
ON p.product_id = i.product_id
GROUP BY product_name,i.product_id
ORDER BY 3 DESC
LIMIT 1



/* Which product has the least stock availaible? */

SELECT p.product_name,i.product_id,SUM(i.stock_on_hand) AS sum_of_stock 
FROM products p
JOIN inventory i
ON p.product_id = i.product_id
GROUP BY product_name,i.product_id
ORDER BY 3 ASC
LIMIT 1

/* Which Category has the most stock avaialble? */
SELECT p.product_category,SUM(i.stock_on_hand) AS sum_of_stock 
FROM products p
JOIN inventory i
ON p.product_id = i.product_id
GROUP BY 1
ORDER BY 2 DESC



/* What is the total stock for products that have profit greater than the average profit? */ 
SELECT p.product_name,i.product_id,SUM(i.stock_on_hand) AS sum_of_stock,p.profit
FROM products p
JOIN inventory i
ON p.product_id = i.product_id
GROUP By p.product_name,i.product_id,p.profit



SELECT product_id,profit
FROM products
GROUP BY product_id,profit
HAVING profit > AVG(profit)::INT

/* What is the total stock for products that have profit greater than the average profit? */ 
SELECT i.product_id,p.product_name,SUM(stock_on_hand) AS tot_stock_availaible,p.profit
FROM inventory i
JOIN products p
ON i.product_id = p.product_id
GROUP BY i.product_id,p.product_name,p.profit
HAVING i.product_id IN (select product_id from products where profit > (select avg(profit)::INT from products))
ORDER BY 3 DESC

/*Which Products are profitable considering the availaible stock? */
SELECT i.product_id,p.product_name,SUM(stock_on_hand) AS tot_stock_availaible,p.profit,(SUM(stock_on_hand)*profit) AS tot_stock_profit
FROM inventory i
JOIN products p
ON i.product_id = p.product_id
GROUP BY i.product_id,p.product_name,p.profit
HAVING i.product_id IN (select product_id from products where profit > (select avg(profit)::INT from products))
ORDER BY 5 DESC

/*What is total profit by each category ?*/
SELECT *,
SUM(profit) OVER(partition by product_category  ) AS tot_profit_cat
FROM products
ORDER BY tot_profit_cat DESC

/*What is avg profit by each category ? */
SELECT *,
ROUND(AVG(profit) OVER(partition by product_category)) AS tot_profit_cat
FROM products
ORDER BY tot_profit_cat DESC


/* Which 2 Products were published first in each category (Note : Product Id indicates the ranking of the product published) */
SELECT * 
FROM(SELECT *,
	ROW_NUMBER() OVER(partition BY product_category order by product_id) AS rn 
	FROM products
)x
WHERE x.rn <= 2

/*Which is/are the 6th most profitable product/products? */
SELECT *
FROM
(SELECT *,DENSE_RANK() OVER(ORDER BY profit DESC) AS dns_rnk
FROM products)a
WHERE dns_rnk = 6

/*2.) Exploring Product Sales & Stores*/
SELECT *
FROM sales

SELECT * 
from stores
/* What is the date range for the sales */

SELECT MIN(date),MAX(date)
FROM sales

/* What total sales for the products ? */
SELECT p.product_name,SUM(s.units) AS tot_units
FROM products p
JOIN sales s
ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY 2 DESC

/*For which Store & date  was the highest sale during 2017-01-01 to 2017-01-01 */
SELECT *
FROM
(SELECT store_id,SUM(units) AS tot_sale,date,DENSE_RANK() OVER (PARTITION BY store_id ORDER BY SUM(units) DESC) AS dns_rnk
FROM sales
WHERE date BETWEEN '2017-01-01' AND '2017-01-07'
GROUP BY store_id,date)a
WHERE dns_rnk = 1
ORDER BY tot_sale DESC
LIMIT 1
/*How many stores are there? */
SELECT DISTINCT(LEFT(store_name,-1)) AS store_name
FROM
stores

SELECT COUNT(DISTINCT(LEFT(store_name,-1))) AS store_count
FROM
stores
/*How many cities are there ?*/
SELECT COUNT(DISTINCT store_city)
FROM stores


/* What is total_profit & total_sale for each store? */
SELECT s.store_name,SUM(s2.units) AS total_sale,SUM(p.profit) AS total_profit
FROM products p
JOIN sales s2
ON  p.product_id = s2.product_id
JOIN stores s
ON s.store_id = s2.store_id
GROUP BY s.store_name
ORDER BY 3 DESC

/* Which Stores sold the most profitable product? */
SELECT s.store_name,p.product_name
FROM stores s
JOIN inventory i 
ON i.store_id = s.store_id
JOIN products p
ON p.product_id =i.product_id
WHERE p.profit = (SELECT MAX(profit) FROM products ) 

/* Which Area sold the most profitable product? */

SELECT s.store_location,p.product_name,COUNT(s.store_location) AS store_count
FROM stores s
JOIN inventory i 
ON i.store_id = s.store_id
JOIN products p
ON p.product_id =i.product_id
WHERE p.profit = (SELECT MAX(profit) FROM products )
GROUP BY s.store_location,2
ORDER BY 3 DESC

/*What is the total sale by Years? */

SELECT EXTRACT(Year FROM date) AS Year, (SUM(units)) AS tot_sale
FROM sales
GROUP BY Year




/*Which Year has the maximum sale?*/

SELECT EXTRACT(Year FROM date) AS Year, (SUM(units)) AS tot_sale
FROM sales
GROUP BY Year
HAVING SUM(units) = (SELECT MAX(tot_sale)
			FROM( SELECT EXTRACT(Year FROM date) AS Year,(SUM(units)) AS tot_sale
			FROM sales
			GROUP BY Year)tmp)

SELECT *
FROM stores
SELECT *
FROM sales

/*Find stores who's sales were better than average sales across all stores */
-- Total Sales of all stores
SELECT st.store_name,SUM(sa.units) AS tot_sales
FROM stores st
JOIN sales sa 
ON sa.store_id = st.store_id
GROUP BY 1

--Average Sale with respect to all stores
SELECT avg(tot_sales)::INT AS avg_sale
FROM (SELECT st.store_name,SUM(sa.units) AS tot_sales
FROM stores st
JOIN sales sa 
ON sa.store_id = st.store_id
GROUP BY 1)tmp


-- Stores with total_sales > avg_sales
WITH total_sales(store_name,total_sales_per_store) AS
(SELECT st.store_name,SUM(sa.units) AS tot_sales
FROM stores st
JOIN sales sa 
ON sa.store_id = st.store_id
GROUP BY 1),
avg_sales(avg_sales_for_all_stores) as
(SELECT avg(total_sales_per_store)::INT AS avg_sale
FROM total_sales)

SELECT *
FROM total_sales ts
JOIN avg_sales av
ON ts.total_sales_per_store > av.avg_sales_for_all_stores

/* What is sale difference between 2018 vs 2017 by Quarters */

WITH quarter AS (SELECT EXTRACT(year FROM date) AS year, EXTRACT(MONTH FROM date) AS month, SUM(units) AS tot_sale
FROM sales
GROUP BY 1,2)

SELECT *, tot_sale - prev_year_sale AS sale_diff,
CASE
	WHEN month IN (1,2,3) THEN 'Q1'
	WHEN month IN (4,5,6) THEN 'Q2'
	WHEN month IN (7,8,9) THEN 'Q3'
	WHEN month IN (10,11,12) THEN 'Q4'
END AS Quarter
FROM
(SELECT *, LAG(tot_sale,12) OVER() AS prev_year_sale
FROM quarter
)x
WHERE prev_year_sale IS NOT NULL


/* What is Min & Max sales by quarters? */
WITH quarter AS (SELECT EXTRACT(year FROM date) AS year, EXTRACT(MONTH FROM date) AS month, SUM(units) AS tot_sale
FROM sales
GROUP BY 1,2)

SELECT MIN(sale_diff),MAX(sale_diff),quarter
FROM
(SELECT *, tot_sale - prev_year_sale AS sale_diff,
CASE
	WHEN month IN (1,2,3) THEN 'Q1'
	WHEN month IN (4,5,6) THEN 'Q2'
	WHEN month IN (7,8,9) THEN 'Q3'
	WHEN month IN (10,11,12) THEN 'Q4'
END AS Quarter
FROM
(SELECT *, LAG(tot_sale,12) OVER() AS prev_year_sale
FROM quarter
)x
WHERE prev_year_sale IS NOT NULL)z
GROUP BY quarter

/* What is sale difference between 2018 vs 2017 by quarters for stores? */

WITH quarter AS (SELECT store_id,EXTRACT(year FROM date) AS year, EXTRACT(MONTH FROM date) AS month, SUM(units) AS tot_sale
FROM sales
GROUP BY 1,2,3)

SELECT *, tot_sale - prev_year_sale AS sale_diff,
CASE
	WHEN month IN (1,2,3) THEN 'Q1'
	WHEN month IN (4,5,6) THEN 'Q2'
	WHEN month IN (7,8,9) THEN 'Q3'
	WHEN month IN (10,11,12) THEN 'Q4'
END AS Quarter
FROM
(SELECT store_name,year,month,tot_sale,LAG(tot_sale,12) OVER(PARTITION BY store_name ) AS prev_year_sale
FROM
stores s
JOIN quarter q 
ON q.store_id = s.store_id
GROUP BY 1,2,3,4)a
WHERE prev_year_sale IS NOT NULL

/*Which store had poorly performed as compared to last year & in which  quarter? */
WITH quarter AS (SELECT store_id,EXTRACT(year FROM date) AS year, EXTRACT(MONTH FROM date) AS month, SUM(units) AS tot_sale
FROM sales
GROUP BY 1,2,3)

SELECT store_name,Quarter,MIN(sale_diff) AS min_sale_diff
FROM
(SELECT *, tot_sale - prev_year_sale AS sale_diff,
CASE
	WHEN month IN (1,2,3) THEN 'Q1'
	WHEN month IN (4,5,6) THEN 'Q2'
	WHEN month IN (7,8,9) THEN 'Q3'
	WHEN month IN (10,11,12) THEN 'Q4'
END AS Quarter
FROM
(SELECT store_name,year,month,tot_sale,LAG(tot_sale,12) OVER(PARTITION BY store_name ) AS prev_year_sale
FROM
stores s
JOIN quarter q 
ON q.store_id = s.store_id
GROUP BY 1,2,3,4)a
WHERE prev_year_sale IS NOT NULL)b
GROUP BY 1,2
ORDER BY 3 ASC
LIMIT 1

/*Which store performed better than last year and in which quarter?*/
WITH quarter AS (SELECT store_id,EXTRACT(year FROM date) AS year, EXTRACT(MONTH FROM date) AS month, SUM(units) AS tot_sale
FROM sales
GROUP BY 1,2,3)

SELECT store_name,Quarter,MAX(sale_diff) AS max_sale_diff
FROM
(SELECT *, tot_sale - prev_year_sale AS sale_diff,
CASE
	WHEN month IN (1,2,3) THEN 'Q1'
	WHEN month IN (4,5,6) THEN 'Q2'
	WHEN month IN (7,8,9) THEN 'Q3'
	WHEN month IN (10,11,12) THEN 'Q4'
END AS Quarter
FROM
(SELECT store_name,year,month,tot_sale,LAG(tot_sale,12) OVER(PARTITION BY store_name ) AS prev_year_sale
FROM
stores s
JOIN quarter q 
ON q.store_id = s.store_id
GROUP BY 1,2,3,4)a
WHERE prev_year_sale IS NOT NULL)b
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1


WITH quarter AS (SELECT store_id, EXTRACT(year FROM date) AS year, EXTRACT(month FROM date) AS month, SUM(units) AS tot_sale
FROM sales
GROUP BY 1, 2, 3),
quarter_diff AS (
SELECT store_name,
year,
month,
tot_sale,
LAG(tot_sale, 12) OVER (PARTITION BY store_name) AS prev_year_sale
FROM stores s
JOIN quarter q
ON q.store_id = s.store_id
WHERE prev_year_sale IS NOT NULL
),
quarter_diff_labeled AS (
SELECT store_name,
tot_sale - prev_year_sale AS sale_diff,
CASE
WHEN month IN (1, 2, 3) THEN 'Q1'
WHEN month IN (4, 5, 6) THEN 'Q2'
WHEN month IN (7, 8, 9) THEN 'Q3'
WHEN month IN (10, 11, 12) THEN 'Q4'
END AS Quarter,
sale_diff
FROM quarter_diff
)
SELECT store_name, Quarter, MAX(sale_diff) AS max_sale_diff
FROM quarter_diff_labeled
GROUP BY store_name, Quarter
ORDER BY max_sale_diff DESC
LIMIT 1;