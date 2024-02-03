-- Challenge 5 : Pub Pricing Analysis -----------------
------------------- SANNIDHYA DAS ---------------
------------- Creating tables and loading data ----------

CREATE TABLE pubs (
pub_id INT PRIMARY KEY,
pub_name VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(50)
);
--------------------
-- Create the 'beverages' table
CREATE TABLE beverages (
beverage_id INT PRIMARY KEY,
beverage_name VARCHAR(50),
category VARCHAR(50),
alcohol_content FLOAT,
price_per_unit DECIMAL(8, 2)
);
--------------------
-- Create the 'sales' table
CREATE TABLE sales (
sale_id INT PRIMARY KEY,
pub_id INT,
beverage_id INT,
quantity INT,
transaction_date DATE,
FOREIGN KEY (pub_id) REFERENCES pubs(pub_id),
FOREIGN KEY (beverage_id) REFERENCES beverages(beverage_id)
);
--------------------
-- Create the 'ratings' table 
CREATE TABLE ratings ( rating_id INT PRIMARY KEY, pub_id INT, 
					  customer_name VARCHAR(50), rating FLOAT, 
		review TEXT, FOREIGN KEY (pub_id) REFERENCES pubs(pub_id) );
--------------------
-- Insert sample data into the 'pubs' table
INSERT INTO pubs (pub_id, pub_name, city, state, country)
VALUES
(1, 'The Red Lion', 'London', 'England', 'United Kingdom'),
(2, 'The Dubliner', 'Dublin', 'Dublin', 'Ireland'),
(3, 'The Cheers Bar', 'Boston', 'Massachusetts', 'United States'),
(4, 'La Cerveceria', 'Barcelona', 'Catalonia', 'Spain');
--------------------
-- Insert sample data into the 'beverages' table
INSERT INTO beverages (beverage_id, beverage_name, category, alcohol_content,
					   price_per_unit)
VALUES
(1, 'Guinness', 'Beer', 4.2, 5.99),
(2, 'Jameson', 'Whiskey', 40.0, 29.99),
(3, 'Mojito', 'Cocktail', 12.0, 8.99),
(4, 'Chardonnay', 'Wine', 13.5, 12.99),
(5, 'IPA', 'Beer', 6.8, 4.99),
(6, 'Tequila', 'Spirit', 38.0, 24.99);
--------------------
INSERT INTO sales (sale_id, pub_id, beverage_id, quantity, transaction_date)
VALUES
(1, 1, 1, 10, '2023-05-01'),
(2, 1, 2, 5, '2023-05-01'),
(3, 2, 1, 8, '2023-05-01'),
(4, 3, 3, 12, '2023-05-02'),
(5, 4, 4, 3, '2023-05-02'),
(6, 4, 6, 6, '2023-05-03'),
(7, 2, 3, 6, '2023-05-03'),
(8, 3, 1, 15, '2023-05-03'),
(9, 3, 4, 7, '2023-05-03'),
(10, 4, 1, 10, '2023-05-04'),
(11, 1, 3, 5, '2023-05-06'),
(12, 2, 2, 3, '2023-05-09'),
(13, 2, 5, 9, '2023-05-09'),
(14, 3, 6, 4, '2023-05-09'),
(15, 4, 3, 7, '2023-05-09'),
(16, 4, 4, 2, '2023-05-09'),
(17, 1, 4, 6, '2023-05-11'),
(18, 1, 6, 8, '2023-05-11'),
(19, 2, 1, 12, '2023-05-12'),
(20, 3, 5, 5, '2023-05-13');
--------------------
-- Insert sample data into the 'ratings' table
INSERT INTO ratings (rating_id, pub_id, customer_name, rating, review)
VALUES
(1, 1, 'John Smith', 4.5, 'Great pub with a wide selection of beers.'),
(2, 1, 'Emma Johnson', 4.8, 'Excellent service and cozy atmosphere.'),
(3, 2, 'Michael Brown', 4.2, 'Authentic atmosphere and great beers.'),
(4, 3, 'Sophia Davis', 4.6, 'The cocktails were amazing! Will definitely come back.'),
(5, 4, 'Oliver Wilson', 4.9, 'The wine selection here is outstanding.'),
(6, 4, 'Isabella Moore', 4.3, 'Had a great time trying different spirits.'),
(7, 1, 'Sophia Davis', 4.7, 'Loved the pub food! Great ambiance.'),
(8, 2, 'Ethan Johnson', 4.5, 'A good place to hang out with friends.'),
(9, 2, 'Olivia Taylor', 4.1, 'The whiskey tasting experience was fantastic.'),
(10, 3, 'William Miller', 4.4, 'Friendly staff and live music on weekends.');
--------------------

-- Questions and Answers------

-- Q1. How many pubs are located in each country?

SELECT country,COUNT(*) AS num_of_pubs
FROM pubs
GROUP BY country;

-- Q2. What is the total sales amount for each pub, including the beverage 
-- price and quantity sold?

WITH abc AS (
SELECT pub_name,ROUND(quantity*price_per_unit,2) AS total_sales
FROM pubs
JOIN sales ON pubs.pub_id=sales.pub_id
JOIN beverages ON sales.beverage_id=beverages.beverage_id
GROUP BY pub_name,sales.quantity,beverages.price_per_unit
)
SELECT pub_name,SUM(total_sales) AS total_sales
FROM abc 
GROUP BY pub_name
ORDER BY 1 DESC;

-- Q3. Which pub has the highest average rating?

SELECT pub_name,AVG(rating) AS avg_rating FROM pubs
JOIN ratings ON pubs.pub_id=ratings.pub_id
GROUP BY pubs.pub_name
ORDER BY 2 DESC;

--- but I want precision upto two digits 
-- So the alter code -----

SELECT pub_name,ROUND(CAST(AVG(rating)AS numeric),2) AS avg_rating
FROM pubs
JOIN ratings ON pubs.pub_id=ratings.pub_id
GROUP BY pubs.pub_name
ORDER BY 2 DESC
LIMIT 1;

-- Q4. What are the top 5 beverages by sales quantity across all pubs?

SELECT beverage_name,category,
SUM(quantity) AS total_purchased_quantity
FROM beverages 
JOIN sales ON beverages.beverage_id=sales.beverage_id
GROUP BY beverages.beverage_name,beverages.category
ORDER BY 3 DESC
LIMIT 5;

-- Q5. How many sales transactions occurred on each date?

SELECT DISTINCT(transaction_date),
COUNT(transaction_date) AS no_of_transactions
FROM sales
GROUP BY sales.transaction_date
ORDER BY 1 ASC;

-- Q6. Find the name of someone that had cocktails and which pub they had it in.

SELECT customer_name,pub_name FROM pubs
JOIN ratings ON pubs.pub_id=ratings.pub_id
WHERE ratings.review ILIKE '%cocktail%';

-- Q7. What is the average price per unit for each category of beverages,
-- excluding the category 'Spirit'? 

SELECT category,
       ROUND(AVG(price_per_unit), 2) AS avg_price_per_unit
FROM beverages
WHERE category <> 'Spirit'
GROUP BY category;

-- Q8. Which pubs have a rating higher than the average rating of all pubs?

WITH abc AS(
SELECT pubs.pub_id,pub_name,AVG(rating) AS pub_rating 
FROM pubs
JOIN ratings ON ratings.pub_id=pubs.pub_id
GROUP BY pubs.pub_id
)
SELECT * FROM abc 
WHERE pub_rating > (SELECT AVG(rating) FROM ratings)

-- Q9. What is the running total of sales amount for each pub, ordered by the 
-- transaction date?

WITH abcd AS(
SELECT pub_name,transaction_date,
ROUND(price_per_unit*quantity,2) AS total_sales
FROM pubs
JOIN sales ON pubs.pub_id=sales.pub_id
JOIN beverages ON sales.beverage_id=beverages.beverage_id
GROUP BY pub_name,transaction_date,price_per_unit,quantity
ORDER BY transaction_date
)
SELECT pub_name,transaction_date,SUM(total_sales) AS total_sales
FROM abcd
GROUP BY abcd.pub_name,abcd.transaction_date
ORDER BY 2

-- Q10. For each country, what is the average price per unit of beverages in
-- each category, and what is the overall average price per unit of beverages
-- across all categories?

-- 1st part
SELECT country,category,ROUND(AVG(price_per_unit),2) AS avg_price
FROM beverages
JOIN sales ON sales.beverage_id=beverages.beverage_id
JOIN pubs ON pubs.pub_id=sales.pub_id
GROUP BY pubs.country,category
ORDER BY 1 DESC;

-- 2nd part
WITH abcde AS (
SELECT country,category,ROUND(AVG(price_per_unit),2) AS avg_price
FROM beverages
JOIN sales ON sales.beverage_id=beverages.beverage_id
JOIN pubs ON pubs.pub_id=sales.pub_id
GROUP BY pubs.country,category
ORDER BY 1 DESC
)
SELECT country,ROUND(SUM(avg_price)/COUNT(category),2) AS avg_price_category
FROM abcde
GROUP BY abcde.country
ORDER BY 2 DESC;

-- Q11. For each pub, what is the percentage contribution of each category of 
-- beverages to the total sales amount, and what is the pub's overall sales 
-- amount?

WITH abc AS (
SELECT pub_name,category,
ROUND(quantity * price_per_unit, 2) AS total_sales 
FROM pubs
JOIN sales ON pubs.pub_id = sales.pub_id
JOIN beverages ON sales.beverage_id = beverages.beverage_id
ORDER BY 1	
)
SELECT pub_name,category,
    SUM(total_sales) AS category_wise_total_sales,
    ROUND((SUM(total_sales) * 100) / (
        SELECT SUM(total_sales)
        FROM abc AS sub_total
        WHERE sub_total.pub_name = abc.pub_name
    ),2) AS percentage_contribution,
    SUM(total_sales) AS overall_sales
FROM abc
GROUP BY pub_name,category
ORDER BY pub_name,category;

-- another way 

WITH abc AS(
SELECT pub_name,category,SUM(ROUND(quantity*price_per_unit,2)) 
	AS category_wise_total_sales
FROM pubs
JOIN sales ON pubs.pub_id=sales.pub_id
JOIN beverages ON sales.beverage_id=beverages.beverage_id

	GROUP BY pub_name,category
	ORDER BY pub_name
)
SELECT *,ROUND((category_wise_total_sales*100)/
			   (SELECT SUM(category_wise_total_sales)
			   FROM abc AS sub_total
        WHERE sub_total.pub_name = abc.pub_name)
,2) AS percentage_contribution
FROM abc
GROUP BY abc.pub_name,abc.category,
category_wise_total_sales
ORDER BY 1



---------------------------thank you -----------------------------