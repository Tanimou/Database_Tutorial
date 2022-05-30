--------------------------SQL AGGREGATIONS----------------------- 

/*NULLs are a datatype that specifies
WHERE no data exists IN SQL.They are often ignored IN our aggregation functions Notice that NULLs are different than a zero - they are cells
WHERE data does not exist. WHEN identifying NULLs IN a
WHERE clause, we write IS NULL or IS NOT NULL.We don 't use =, because NULL isn' t considered a value IN SQL.Rather, it is a property of the data.NULLs - Expert Tip There are two common ways IN which you are likely to encounter NULLs: NULLs frequently occur WHEN performing a LEFT or RIGHT JOIN.You saw IN the last lesson - WHEN some rows IN the left TABLE of a
LEFT JOIN are not matched WITH rows IN the right table, those rows will contain some NULL values IN the result set.NULLs can also occur
FROM simply missing data IN our database. COUNT the Number of Rows IN a TABLE Here is an example of finding all the rows IN the accounts table.*/
SELECT  COUNT(*)
FROM accounts ;

 /*But we could have just AS easily chosen a column to

DROP into the aggregation function:*/
SELECT  COUNT(accounts.id)
FROM accounts ;

 /*These two statements are equivalent, but this isn 't always the case We can use count function to any column of the table, including non numericals columns like texts. The count function is just looking for non Null data */ /*Unlike COUNT, you can only use SUM
ON numeric columns.However, SUM will ignore NULL values, AS do the other aggregation functions you will see IN the upcoming lessons.Aggregation Reminder An important thing to remember: aggregators only aggregate vertically - the values of a column.If you want to perform a calculation across rows, you would do this WITH simple arithmetic.*/
SELECT  SUM(standard_amt_usd) total_sau
       ,SUM(gloss_amt_usd) total_gau
FROM orders ; 

/*we can use both aggregation AND arithmetic operatoions*/

SELECT  SUM(standard_amt_usd) / SUM(standard_qty) AS standard_price_per_unit
FROM orders ; 

/*MIN AND MAX Functionally, MIN AND MAX are similar to COUNT IN that they can be used
ON non - numerical columns.Depending
ON the column type, MIN will return the lowest number, earliest date, or non - numerical value AS early IN the alphabet AS possible.As you might suspect, MAX does the opposite — it returns the highest number, the latest date, or the non - numerical value closest alphabetically to “ Z.”*/ /*AVG AVG returns the mean of the data - that is the sum of all of the values IN the column divided by the number of values IN a column.This aggregate function again ignores the NULL values IN both the numerator AND the denominator.If you want to count NULLs AS zero, you will need to use SUM AND COUNT.However, this is probably not a good idea if the NULL values truly just represent unknown values for a cell*/
SELECT  MIN(occurred_at)
FROM orders ; 

/*we can also write this query aboe like this:*/

SELECT  occurred_at
FROM orders
ORDER BY occurred_at
LIMIT 1 ; 

SELECT  AVG(standard_amt_usd) average_standard_amt_usd
       ,AVG(gloss_amt_usd) average_gloss_amt_usd
       ,AVG(poster_amt_usd) average_poster_amt_usd
       ,AVG(standard_qty) average_standard
       ,AVG(gloss_qty) average_gloss
       ,AVG(poster_qty) average_poster
FROM orders ; 

/*The
GROUP BY  clause
GROUP BY  can be used to aggregate data within subsets of the data.For example
         ,grouping for different accounts
         ,different regions
         ,or different sales representatives. Any column IN the
SELECT  statement that is not within an aggregator must be IN the
GROUP BY  clause. The
GROUP BY  always goes BETWEEN
WHERE
AND ORDER BY.
ORDER BY works like SORT IN spreadsheet software.
GROUP BY  - Expert Tip Before we dive deeper into aggregations USING
GROUP BY  statements
         ,it is worth noting that SQL evaluates the aggregations before the
LIMIT clause.If you don ’ t
GROUP BY  any columns
         ,you ’ ll get a 1 - row result — no problem there.If you
GROUP BY  a column WITH enough unique values that it exceeds the
LIMIT number, the aggregates will be calculated, AND THEN some rows will simply be omitted
FROM the results.This is actually a nice way to do things because you know you ’ re going to get the correct aggregates.If SQL cuts the TABLE down to 100 rows, THEN performed the aggregations, your results would be substantially different.The above query ’ s results exceed 100 rows, so it ’ s a perfect example.*/

--1
SELECT  a.name
       ,o.occurred_at
FROM orders o
JOIN accounts a
ON o.account_id = a.id
ORDER BY o.occurred_at
LIMIT 1 ;

--2
SELECT  a.name AS company_name
       ,SUM(o.total_amt_usd) total_sales
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY  a.name
ORDER BY total_sales ;

--3
SELECT  a.name    AS company_name
       ,w.channel AS channel
       ,w.occurred_at DATE
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
ORDER BY w.occurred_at desc
LIMIT 1 ;

--4
SELECT  w.channel AS channel
       ,COUNT(w.channel) numbers_times
FROM web_events w
GROUP BY  w.channel ;

--5
SELECT  a.primary_poc AS primary_contact
       ,w.occurred_at AS web_event_time
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
ORDER BY web_event_time
LIMIT 1 ;

--6
SELECT  a.name AS account
       ,MIN(o.total_amt_usd) total_amt_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY  account
ORDER BY total_amt_usd ;

--7
SELECT  r.name AS region
       ,COUNT(s.name) number_sales_reps
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
GROUP BY  r.name
ORDER BY number_sales_reps ; 

/*You can
GROUP BY  multiple columns at once
         ,AS we showed here.This is often useful to aggregate across a number of different segments. The order of columns listed IN the
ORDER BY clause does make a difference.You are ordering the columns
FROM left to right.
GROUP BY  - Expert Tips The order of column names IN your
GROUP BY  clause doesn ’ t matter — the results will be the same regardless.If we run the same query AND reverse the order IN the
GROUP BY  clause
         ,you can see we get the same results. AS WITH ORDER BY
         ,you can substitute numbers for column names IN the
GROUP BY  clause.It ’ s generally recommended to do this only WHEN you ’ re grouping many columns
         ,or if something else is causing the text IN the
GROUP BY  clause to be excessively long. A reminder here that any column that is not within an aggregation must show up IN your
GROUP BY  statement.If you forget
         ,you will likely get an error.However
         ,IN the off chance that your query does work
         ,you might not like the results !*/

--1
SELECT  a.name AS account
       ,AVG(o.standard_qty) mean_standard_qty
       ,AVG(o.gloss_qty) mean_gloss_qty
       ,AVG(o.poster_qty) mean_poster_qty
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY  account ;

--2
SELECT  s.name    AS sale_rep
       ,w.channel AS channel
       ,COUNT(w.channel) number_times
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY  sale_rep
         ,channel
ORDER BY number_times desc ;

--3
SELECT  r.name    AS region
       ,w.channel AS channel
       ,COUNT(w.channel) number_times
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON s.region_id = r.id
GROUP BY  region
         ,channel
ORDER BY number_times desc ; 

/*DISTINCT DISTINCT is always used IN

SELECT  statements
       ,AND it provides the unique rows for all columns written IN the
SELECT  statement.Therefore
       ,you only use DISTINCT once IN any particular
SELECT  statement.You could write:*/
SELECT  DISTINCT column1
       ,column2
       ,column3
FROM table1 ; 

/*which would return the unique ( or DISTINCT ) rows across all three columns. You would not write:*/

SELECT  DISTINCT column1
       ,DISTINCT column2
       ,DISTINCT column3
FROM table1 ; 

/*You can think of DISTINCT the same way you might think of the statement "unique". DISTINCT - Expert Tip It ’ s worth noting that USING DISTINCT, particularly IN aggregations, can slow your queries down quite a bit.*/

SELECT  DISTINCT a.name AS account
       ,r.name          AS region
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id ;

SELECT  s.id
       ,s.name
       ,COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY  s.id
         ,s.name
ORDER BY num_accounts ;

 /*Having
HAVING - Expert Tip
HAVING is the “ clean ” way to filter a query that has been aggregated, but this is also commonly done USING a subquery.Essentially, any time you want to perform a
WHERE
ON an element of your query that was created by an aggregate, you need to use
HAVING instead.
WHERE subsets the returned data based
ON a logical condition.
WHERE appears after FROM,JOIN,anD
ON clauses,but before GROUP BY.
HAVING appears after the
GROUP BY  clause
         ,but before the
ORDER BY clause
HAVING is like WHERE, but it works
ON logical statements involving aggregations*/

--1:How many of the sales reps have more than 5 accounts that they manage ?
SELECT  s.name AS sales_reps
       ,COUNT(a.name) number_account
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
GROUP BY  sales_reps
HAVING COUNT(a.name) > 5
ORDER BY number_account ;
 /*and technically, we can get this USING a SUBQUERY AS shown below.This same logic can be used for the other queries, but this will not be shown.*/

SELECT  COUNT(*) num_reps_above5
FROM (
SELECT  s.id
       ,s.name
       ,COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY  s.id
         ,s.name
HAVING COUNT(*) > 5 ORDER BY num_accounts ) Table1 ;

--2:How many accounts have more than 20 orders ?
SELECT  a.name AS account
       ,COUNT(o.id) number_orders
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY  account
HAVING COUNT(o.id) > 20
ORDER BY number_orders ;

--3:Which account has the most orders ?
SELECT  a.id
       ,a.name
       ,COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY  a.id
         ,a.name
ORDER BY num_orders DESC
LIMIT 1 ;

--4:Which accounts spent more than 30,000 usd total across all orders ?
SELECT  a.name AS account
       ,SUM(o.total_amt_usd) total
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY  account
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total ;

--6:Which account has spent the most WITH us ?
SELECT  a.name AS account
       ,SUM(o.total_amt_usd) total
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY  account
ORDER BY total desc
LIMIT 1 ;

--8:Which accounts used facebook AS a channel to contact customers more than 6 times ?
SELECT  a.id
       ,a.name    AS account
       ,w.channel AS channel
       ,COUNT(w.channel) num_times
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY  a.id
         ,account
         ,channel
HAVING channel = 'facebook' AND COUNT(w.channel) > 6
ORDER BY num_times ;

--9:Which account used facebook most AS a channel ?
SELECT  a.id
       ,a.name    AS account
       ,w.channel AS channel
       ,COUNT(w.channel) num_times
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY  a.id
         ,account
         ,channel
HAVING channel = 'facebook'
ORDER BY num_times desc
LIMIT 1 ;

--10:Which channel was most frequently used by most accounts ?
SELECT  w.channel AS channel
       ,a.name    AS account
       ,COUNT(w.channel) num_times
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY  channel
         ,account
ORDER BY num_times desc
LIMIT 10 ; 

/*DATE FUNCTIONS GROUPing BY a date column is not usually very useful IN SQL, AS these columns tend to have transaction data down to a second.Keeping date information at such a granular data is both a blessing AND a curse, AS it gives really precise information (a blessing), but it makes grouping information together directly difficult (a curse).Lucky for us, 
there are a number of built IN SQL functions that are aimed at helping us improve our experience IN working WITH dates.Here we saw that dates are stored IN year, month, day, hour, minute, second, which helps us IN truncating. The first function you are introduced to IN working WITH dates is DATE_TRUNC.
DATE_TRUNC allows you to truncate your date to a particular part of your date - time column.Common trunctions are day, month, AND year. DATE_PART can be useful for pulling a specific portion of a date, but notice pulling month or day of the week (dow) means that you are no longer keeping the years IN order.Rather you are grouping for certain components regardless of which year they belonged in. You can reference the columns IN your

SELECT  statement IN
GROUP BY  AND
ORDER BY clauses WITH numbers that follow the order they appear IN the
SELECT  statement.For example*/
SELECT  standard_qty
       ,COUNT(*)
FROM orders
GROUP BY  1 ( this 1 refers TO standard_qty since it IS the first OF the columns included IN the
SELECT  statement )
ORDER BY 2 ( this 2 refers TO COUNT(*) since it IS the SECOND OF the columns included IN the
SELECT  statement ) ;

SELECT  DATE_TRUNC('month',occurred_at) AS MONTH
FROM demo.web_events
WHERE occurred_at BETWEEN '2015-01-01' AND '2015-12-31 23:59:59';

SELECT  DATE_TRUNC('month',occurred_at) AS MONTH
       ,channel
       ,COUNT(id)                       AS visits
FROM demo.web_events
WHERE occurred_at BETWEEN '2015-01-01' AND '2015-12-31 23:59:59'
GROUP BY  1
         ,2
ORDER BY 1
         ,2 ;
         
          /*Finding events relative to the present time WITH NOW() AND CURRENT_DATE functions The NOW() date function returns the current timestamp IN UTC (if the time zone is unspecified). You can subtract intervals
FROM NOW() to pull events that happened within the last hour, the last day, the last week, etc. Running
SELECT  NOW() at 9:00am UTC
ON October 11th, 2016 would result IN 2016-10-11 09:00:00. The CURRENT_DATE function only returns the current date, not the whole timestamp. Running
SELECT  CURRENT_DATE at 9:00am UTC
ON October 11th, 2016 would return 2016-10-11.*/
SELECT  *
FROM demo.orders
WHERE occurred_at >= NOW() - INTERVAL '7 year' ;

SELECT  *
FROM demo.orders
WHERE DATE_TRUNC('day', occurred_at) = CURRENT_DATE - INTERVAL '7 year' ; 

/*Isolating hour - of - day
AND day - of - week WITH EXTRACT The EXTRACT date function allows you to isolate subfields such AS year or hour
FROM timestamps.Here 's the syntax: EXTRACT(subfield
FROM timestamp). Running EXTRACT(month
FROM ' 2015 -02 -12 ') would return a result of 2. Keep IN mind that while the example below focuses
ON the subfield hour (hour-of-day), you have many other subfields at your disposal ranging
FROM millennium to microsecond.*/
SELECT  EXTRACT( HOUR
FROM occurred_at ) HOUR, COUNT(*) orders
FROM demo.orders
GROUP BY  1
ORDER BY 1 ; 

/*Example: What 's the average weekday order volume? To determine the average volume of orders that occurred by weekday,use EXTRACT AND the dow (day of the week) subfield to isolate the day - of - week (
FROM 0 -6,
WHERE 0 is Sunday ) IN which an order occurred. Next, round the order timestamps by day WITH DATE_TRUNC.Taking a COUNT of orders grouped by dow AND day will return the number of orders placed each day along WITH the corresponding day - of - week. 
To find the average weekday order volume, use the previous query AS a subquery (aliased AS a).Take the average of orders (using the AVG() function), AND THEN use a
WHERE clause to filter out Saturdays
AND Sundays.*/
SELECT  AVG(orders) AS avg_orders_weekday
FROM (
SELECT  EXTRACT( dow
FROM occurred_at ) dow, DATE_TRUNC('day', occurred_at) DAY, COUNT(id) orders
FROM demo.orders
GROUP BY  1
         ,2 ) a
WHERE dow NOT IN (0, 6) ;

 /*Calculating time elapsed WITH AGE The AGE date function calculates how long ago an event occurred. The syntax is pretty straightforward: apply AGE() to a single timestamp,
AND your query will return the amount of time since that event took place. Running
SELECT  AGE('2010-01-01')
ON January 1st, 2011 would return a result of 1 years 0 months 0 days. AGE() can also determine how much time passed BETWEEN two events. Instead of putting a single timestamp inside the parentheses,
INSERT both timestamps (starting WITH the most recent timestamp) AND separate them WITH a comma. Running
SELECT  AGE('2012-12-01','2010-01-01') would return 2 years 11 months 0 days.Note that this application of the AGE function is equivalent to subtracting the timestamps:
SELECT  '2012-12-01' - '2010-01-01'.*/
SELECT  name
       ,AGE(created) AS account_age
FROM modeanalytics.customer_accounts ;

 /*Example: How long does it take users to complete their profile each month,
ON average ? To find the average time to complete a profile each month, start by finding the time it took each user to complete a profile AS well AS the month IN which the profile creation process was started.First, round the started_at timestamp by month, USING the DATE_TRUNC function.Next, find the time elapsed
FROM started_at to ended_at for each profile USING the AGE function. Find the average for each month by applying the AVG function to the elapsed time value (your AGE statement) AND grouping by month. */
SELECT  DATE_TRUNC('month',started_at) AS MONTH
       ,AVG(AGE(ended_at,started_at))  AS avg_time_to_complete
FROM modeanalytics.profile_creation_events
GROUP BY  1
ORDER BY 1 ;

--1:Find the sales IN terms of total dollars for all orders IN each year,
--ordered
--from greatest to least.Do you notice any trends IN the yearly sales totals ?
SELECT  SUM(total_amt_usd) total_dollars
       ,date_part('year',occurred_at) years
FROM orders
GROUP BY  2
ORDER BY 1 desc ;

--2:Which month did Parch & Posey have the greatest sales IN terms of total dollars ? Are all months evenly represented by the dataset ?
SELECT  SUM(total_amt_usd) total_dollars
       ,date_part('month',occurred_at) months
FROM orders
GROUP BY  2
ORDER BY 1 desc
LIMIT 1 ;

--3:Which year did Parch & Posey have the greatest sales IN terms of total number of orders ? Are all years evenly represented by the dataset ?
SELECT  COUNT(*) total_orders
       ,date_part('year',occurred_at) years
FROM orders
GROUP BY  2
ORDER BY 1 desc
LIMIT 1 ;

--4:Which month did Parch & Posey have the greatest sales IN terms of total number of orders ? Are all months evenly represented by the dataset ?
SELECT  COUNT(*) total_orders
       ,date_part('months',occurred_at) months
FROM orders
GROUP BY  2
ORDER BY 1 desc
LIMIT 1 ;

--5:In which month of which year did Walmart spend the most
ON gloss paper IN terms of dollars ?
SELECT  a.name AS account
       ,SUM(o.gloss_amt_usd) total_gloss_usd
       ,date_trunc('month',o.occurred_at) year_and_month
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY  1
         ,3
HAVING a.name = 'Walmart'
ORDER BY 2 desc
LIMIT 1 ; 

/*CASE STATEMENT CASE- Expert Tip The CASE statement always goes IN the

SELECT  clause. CASE must include the following components: WHEN
       ,THEN
       ,and END. ELSE is an optional component to catch cases that didn ’ t meet any of the other previous CASE conditions. You can make any conditional statement USING any conditional operator (like
WHERE ) BETWEEN WHEN AND THEN.This includes stringing together multiple conditional statements USING AND and OR. You can include multiple WHEN statements, AS well AS an ELSE statement again, to deal WITH any unaddressed conditions. case statement is a sql's way of handling "if" "then" logic*/
SELECT  id
       ,occurred_at
       ,channel
       ,CASE WHEN channel = 'facebook' THEN 'yes' END AS is_facebook
FROM web_events
ORDER BY 2 ;

SELECT  id
       ,occurred_at
       ,channel
       ,CASE WHEN channel = 'facebook' THEN 'yes'  ELSE 'no' END AS is_facebook
FROM web_events
ORDER BY 2;

SELECT  id
       ,occurred_at
       ,channel
       ,CASE WHEN channel = 'facebook' or channel = 'direct' THEN 'yes'  ELSE 'no' END AS is_facebook
FROM web_events
ORDER BY 2;

SELECT  account_id
       ,occurred_at
       ,total
       ,CASE WHEN total > 500 THEN 'over 500'
             WHEN total > 300 AND total<=500 THEN '301-500'
             WHEN total > 100 AND total<=300 THEN '101-300'  ELSE '100 or under' END AS total_group
FROM orders;

--1:Write a query to display for each order, the account ID,
--total amount of the order, AND the level of the order - ‘ Large ’
--or ’ Small ’ - depending
ON if the order is $3000 or more, or smaller than $3000.
SELECT  account_id
       ,total_amt_usd
       ,CASE WHEN o.total_amt_usd >= 3000 THEN 'Large'  ELSE 'Small' END AS order_level
FROM orders ;

--2:Write a query to display the number of orders IN each of three categories,
--based
ON the total number of items IN each order.The three categories are: 'At Least 2000',
--'Between 1000 AND 2000'
--and 'Less than 1000'.

SELECT  CASE WHEN total < 1000 THEN 'Less than 1000'
             WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 AND 2000'  ELSE 'At least 2000' END AS Categories
       ,COUNT(*) order_count
FROM orders
GROUP BY  1;

 /*3:We would like to understand 3 different levels of customers based
ON the amount associated WITH their purchases.The top level includes anyone WITH a Lifetime Value
(total sales of all orders
) greater than 200, 000 usd.The second level is BETWEEN 200, 000 AND 100, 000 usd.The lowest level is anyone under 100, 000 usd.Provide a TABLE that includes the level associated WITH each account.You should provide the account name, the total sales of all orders for the customer, AND the level.Order WITH the top spending customers listed first.*/

SELECT  a.name account
       ,SUM(o.total_amt_usd) total_sales
       ,CASE WHEN SUM(o.total_amt_usd) < 100000 THEN 'Under 100000'
             WHEN SUM(o.total_amt_usd) >= 100000 AND SUM(o.total_amt_usd) < 200000 THEN 'Betwwen 200000 AND 100000'  ELSE 'Greater than 200000' END AS level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY  1
ORDER BY 2 desc; 

/*4:We would now like to perform a similar calculation to the first
         ,but we want to obtain the total amount spent by customers only IN 2016 AND 2017.Keep the same levels AS IN the previous question.Order WITH the top spending customers listed first.*/
SELECT  a.name account
       ,SUM(o.total_amt_usd) total_sales
       ,date_part('year',o.occurred_at) years
       ,CASE WHEN SUM(o.total_amt_usd) < 100000 THEN 'Under 100000'
             WHEN SUM(o.total_amt_usd) >= 100000 AND SUM(o.total_amt_usd) < 200000 THEN 'Betwwen 200000 AND 100000'  ELSE 'Greater than 200000' END AS level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE date_part('year', o.occurred_at) BETWEEN 2016 AND 2017
GROUP BY  1
         ,3
ORDER BY 2 desc;

 /*5:We would like to identify top performing sales reps
         ,which are sales reps associated WITH more than 200 orders.Create a TABLE WITH the sales rep name
         ,the total number of orders
         ,AND a column WITH top or not depending
ON if they have more than 200 orders.Place the top sales people first IN your final table. */
SELECT  s.name sales_rep_name
       ,COUNT(o.*) total_orders
       ,CASE WHEN COUNT(o.*) > 200 THEN 'top'  ELSE 'not' END AS top_or_not
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY  1
ORDER BY 2 desc; 

/*6:The previous didn 't account for the middle,nor the dollar amount associated WITH the sales. Management decides they want to see these characteristics represented AS well. We would like to identify top performing sales reps,which are sales reps associated WITH more than 200 orders or more than 750000 IN total sales. The middle group has any rep WITH more than 150 orders or 500000 IN sales.

CREATE a TABLE WITH the sales rep name, the total number of orders, total sales across all orders, AND a column WITH top, middle, or low depending
ON this criteria. Place the top sales people based
ON dollar amount of sales first IN your final table. You might see a few upset sales people by this criteria!*/
SELECT  s.name sales_rep_name
       ,COUNT(o.*) total_orders
       ,SUM(o.total_amt_usd) total_sales
       ,CASE WHEN COUNT(o.*) > 200 or SUM(o.total_amt_usd) > 750000 THEN 'top'
             WHEN ( COUNT(o.*) > 150 AND COUNT(o.*) <= 200 ) or ( SUM(o.total_amt_usd) > 500000 AND SUM(o.total_amt_usd) <= 750000 ) THEN 'Middle'  ELSE 'low' END AS top_middle_low
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY  1
ORDER BY 3 desc;