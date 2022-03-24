-------------------SQL SUBQUERIES AND TEMPORARY TABLES--------------------------
 /*SQL SUBQUERIES AND TEMPORARY TABLES*/ 
 
 /*Whenever we need to use existing tables to CREATE a new TABLE that we THEN want to query again, this is an indication that we will need to use some sort of subquery.*/
SELECT  channel
       ,AVG(events_count) avg_count
FROM
(
	SELECT  date_trunc('day',occurred_at)
	       ,channel
	       ,COUNT(*) events_count
	FROM web_events
	GROUP BY  1
	         ,2
) data
GROUP BY  1
ORDER BY 2 desc;

 /*In the first subquery you wrote ,you created a TABLE that you could THEN query again IN the
FROM statement.However, if you are only returning a single value, you might use that value IN a logical statement like WHERE, HAVING, or even
SELECT  - the value could be nested within a CASE statement.*/ /*the query below works because the results of the subquery is only one cell*/
SELECT  *
FROM orders
WHERE date_trunc('month', occurred_at) =(
SELECT  date_trunc('month',MIN(occurred_at)) min_month
FROM orders )
ORDER BY occurred_at

 /*Most conditional logic will work WITH subqueries containing one cell results but "IN" is the only type of conditional logic that will work WHEN the inner query contains multiple results*/
SELECT  AVG(standard_qty) avg_std
       ,AVG(gloss_qty) avg_gls
       ,AVG(poster_qty) avg_pst
       ,SUM(total_amt_usd)
FROM orders
WHERE date_trunc('month', occurred_at) =(
SELECT  date_trunc('month',MIN(occurred_at)) min_month
FROM orders )

 /*The average amount of standard paper, gloss paper AND poster paper sold
ON the first month that any order was placed IN the orders TABLE (in terms of quantity).*/
SELECT  AVG(standard_qty) avg_std
       ,AVG(gloss_qty) avg_gls
       ,AVG(poster_qty) avg_pst
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = (
SELECT  DATE_TRUNC('month',MIN(occurred_at))
FROM orders ); 

/*The total amount spent
ON all orders
ON the first month that any order was placed IN the orders TABLE (in terms of usd).*/
SELECT  SUM(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = (
SELECT  DATE_TRUNC('month',MIN(occurred_at))
FROM orders );
-----------------------------------------------------SUBQUERY MANIA QUIZ------------------------------------------ 

/*1:Provide the name of the sales_rep IN each region WITH the largest amount of total_amt_usd sales.*/ /*Essentially, this is a
JOIN of these two tables,
WHERE the region
AND amount match.*/
SELECT  t3.region_name
       ,t3.rep_name
       ,t3.total_amt
FROM
( /*Next, I pulled the max for each region, AND THEN we can use this to pull those rows IN our final result.*/
	SELECT  region_name
	       ,MAX(total_amt) total_amt
	FROM
	(
		SELECT  r.name region_name
		       ,s.name rep_name
		       ,SUM(o.total_amt_usd) total_amt
		FROM sales_reps s
		JOIN accounts a
		ON a.sales_rep_id = s.id
		JOIN orders o
		ON o.account_id = a.id
		JOIN region r
		ON r.id = s.region_id
		GROUP BY  1
		         ,2
	) t1
	GROUP BY  1
) t2
JOIN
( /*First, I wanted to find the total_amt_usd totals associated WITH each sales rep, AND I also wanted the region IN which they were located.*/
	SELECT  r.name region_name
	       ,s.name rep_name
	       ,SUM(o.total_amt_usd) total_amt
	FROM sales_reps s
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id = a.id
	JOIN region r
	ON r.id = s.region_id
	GROUP BY  1
	         ,2
	ORDER BY 3 DESC
) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;

 /*2:For the region WITH the largest (sum) of sales total_amt_usd, how many total (count) orders were placed ?*/
SELECT  r.name region
       ,SUM(o.total_amt_usd) total_amt
       ,COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY  1
ORDER BY 2 desc
LIMIT 1; 

/*3:How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime AS a customer ?*/
--and finally we just count all of them
SELECT  COUNT(*)
FROM
(
	--and then, we SELECT  all the accounts hat have more total purchases than this account
	SELECT  a.name account
	       ,SUM(o.total) total_purchases
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY  1
	HAVING SUM(o.total) >(
	--then we SELECT  his total purchases
	SELECT  SUM(o.total)
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	WHERE a.name = (
	SELECT  account
	FROM
	(
		--we first find out the account that spent the most standard_qty paper
		SELECT  a.name account
		       ,SUM(o.standard_qty) standard_total
		FROM accounts a
		JOIN orders o
		ON a.id = o.account_id
		GROUP BY  1
		ORDER BY 2 desc
		LIMIT 1
	) t1 ) )
) t2 
/*another solution of the question 3*/
SELECT  COUNT(*)
FROM
(
	SELECT  a.name
	FROM orders o
	JOIN accounts a
	ON a.id = o.account_id
	GROUP BY  1
	HAVING SUM(o.total) > (
	SELECT  total
	FROM
	(
		SELECT  a.name act_name
		       ,SUM(o.standard_qty) tot_std
		       ,SUM(o.total) total
		FROM accounts a
		JOIN orders o
		ON o.account_id = a.id
		GROUP BY  1
		ORDER BY 2 DESC
		LIMIT 1
	) inner_tab )
) counter_tab;

 /*4:For the customer that spent the most (in total over their lifetime AS a customer) total_amt_usd, how many web_events did they have for each channel ?*/

SELECT  c.account account
       ,t1.channel channel
       ,t1.count_web_events count_web_events
FROM
(
	--here, we first want to pull the customer WITH the most spent IN lifetime value
	SELECT  a.name account
	       ,SUM(o.total_amt_usd) total_spent
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY  1
	ORDER BY 2 desc
	LIMIT 1
) c
JOIN
(
	SELECT  a.name account
	       ,w.channel channel
	       ,COUNT(*) count_web_events
	FROM web_events w
	JOIN accounts a
	ON w.account_id = a.id
	GROUP BY  1
	         ,2
	ORDER BY 3 desc
) t1
ON c.account = t1.account

 /*5:What is the lifetime average amount spent IN terms of total_amt_usd for the top 10 total spending accounts ?*/
SELECT  AVG(total_spent)
FROM
(
	SELECT  a.name accounts
	       ,SUM(o.total_amt_usd) total_spent
	FROM accounts a
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY  1
	ORDER BY 2 desc
	LIMIT 10
) t2 

/*6:What is the lifetime average amount spent IN terms of total_amt_usd, including only the companies that spent more per order,
ON average, than the average of all orders.*/
--finally, we just want the average of these values
SELECT  AVG(avg_amt)
FROM
(
	--then we pull only the accounts WITH more than this average
	SELECT  o.account_id
	       ,AVG(o.total_amt_usd) avg_amt
	FROM orders o
	GROUP BY  1
	HAVING AVG(o.total_amt_usd) > (
	--first we we pull the average of all accounts IN terms of total_amt_usd
	SELECT  AVG(o.total_amt_usd) avg_all
	FROM orders o )
) temp_table; 

/*WRITTING COMMON TABLE EXPRESSION WITH 'WITH' STATEMENT WHEN creating multiple tables USING WITH, 
you add a comma after TABLE except the last TABLE leading to your final query The new TABLE name is always aliased USING AS, 
which is followed by your query nested BETWEEN parentheses WITH statement is more efficient, AS tables aren't recreated WITH each subquery portion*/

--Example: we can write this query below:
SELECT  channel
       ,AVG(events) AS average_events
FROM (
SELECT  DATE_TRUNC('day',occurred_at) AS day
       ,channel
       ,COUNT(*)                      AS events
FROM web_events
GROUP BY  1
         ,2) sub
GROUP BY  channel
ORDER BY 2 DESC;
--WITH the WITH statement
--This is the part we put IN the WITH statement. Notice, we are aliasing the TABLE AS events 
WITH events AS (
SELECT  DATE_TRUNC('day',occurred_at) AS day
       ,channel
       ,COUNT(*)                      AS events
FROM web_events
GROUP BY  1
         ,2)

--Now,we can use this newly created events TABLE AS if it is any other TABLE IN our database: 
WITH events AS (
SELECT  DATE_TRUNC('day',occurred_at) AS day
       ,channel
       ,COUNT(*)                      AS events
FROM web_events
GROUP BY  1
         ,2 )
SELECT  channel
       ,AVG(events) AS average_events
FROM events
GROUP BY  channel
ORDER BY 2 DESC;
--we can CREATE additionnal TABLE to pull from: 
WITH table1 AS (
SELECT  *
FROM web_events ), 
table2 AS (
SELECT  *
FROM accounts )
SELECT  *
FROM table1
JOIN table2
ON table1.account_id = table2.id; 

/*we are going to rewrite all the query we wrote IN the subquery Mania WITH the 'with' statement*/ /*1:Provide the name of the sales_rep IN each region WITH the largest amount of total_amt_usd sales.*/
WITH t1 AS
(
	SELECT  s.name rep_name
	       ,r.name region_name
	       ,SUM(o.total_amt_usd) total_amt
	FROM sales_reps s
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id = a.id
	JOIN region r
	ON r.id = s.region_id
	GROUP BY  1
	         ,2
	ORDER BY 3 DESC
) , 
t2 AS
(
	SELECT  region_name
	       ,MAX(total_amt) total_amt
	FROM t1
	GROUP BY  1
)
SELECT  t1.rep_name
       ,t1.region_name
       ,t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;

 /*2:For the region WITH the largest sales total_amt_usd, how many total orders were placed?*/ 
WITH t1 AS
(
	SELECT  r.name region_name
	       ,SUM(o.total_amt_usd) total_amt
	FROM sales_reps s
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id = a.id
	JOIN region r
	ON r.id = s.region_id
	GROUP BY  r.name
) , 
t2 AS
(
	SELECT  MAX(total_amt)
	FROM t1
)
SELECT  r.name
       ,COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY  r.name
HAVING SUM(o.total_amt_usd) = (
SELECT  *
FROM t2 );

/*3 :How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime AS a customer ? **/ 

WITH t1 AS
(
	SELECT  a.name account_name
	       ,SUM(o.standard_qty) total_std
	       ,SUM(o.total) total
	FROM accounts a
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY  1
	ORDER BY 2 DESC
	LIMIT 1
), 
t2 AS
(
	SELECT  a.name
	FROM orders o
	JOIN accounts a
	ON a.id = o.account_id
	GROUP BY  1
	HAVING SUM(o.total) > (
	SELECT  total
	FROM t1 )
)
SELECT  COUNT(*)
FROM t2;

 /*4:For the customer that spent the most (in total over their lifetime AS a customer) total_amt_usd, how many web_events did they have for each channel ?*/
WITH t1 AS
(
	SELECT  a.id
	       ,a.name
	       ,SUM(o.total_amt_usd) tot_spent
	FROM orders o
	JOIN accounts a
	ON a.id = o.account_id
	GROUP BY  a.id
	         ,a.name
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT  a.name
       ,w.channel
       ,COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id = (
SELECT  id
FROM t1 )
GROUP BY  1
         ,2
ORDER BY 3 DESC;

 /*5:What is the lifetime average amount spent IN terms of total_amt_usd for the top 10 total spending accounts ?*/
WITH t1 AS
(
	SELECT  a.id
	       ,a.name
	       ,SUM(o.total_amt_usd) tot_spent
	FROM orders o
	JOIN accounts a
	ON a.id = o.account_id
	GROUP BY  a.id
	         ,a.name
	ORDER BY 3 DESC
	LIMIT 10
)
SELECT  AVG(tot_spent)
FROM t1;

/*6:What is the lifetime average amount spent IN terms of total_amt_usd, including only the companies that spent more per order,
ON average, than the average of all orders.*/ 
WITH t1 AS
(
	SELECT  AVG(o.total_amt_usd) avg_all
	FROM orders o
	JOIN accounts a
	ON a.id = o.account_id
), 
t2 AS
(
	SELECT  o.account_id
	       ,AVG(o.total_amt_usd) avg_amt
	FROM orders o
	GROUP BY  1
	HAVING AVG(o.total_amt_usd) > (
	SELECT  *
	FROM t1 )
)
SELECT  AVG(avg_amt)
FROM t2;