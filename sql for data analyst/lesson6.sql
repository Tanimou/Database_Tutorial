--------------ADVANCED SQL WINDOW FUNCTIONS---------------------------
/*A window function performs a calculation across a set of table rows that are somehow related to the current row.
 This is comparable to the type of calculation that can be done with an aggregate function. 
 But unlike regular aggregate functions, use of a window function does not cause rows to become grouped into a single output row 
 — the rows retain their separate identities. Behind the scenes, the window function is able to access more than just the current row of the query result.
Here is an example that shows how to compare each employee's salary with the average salary in his or her department:*/

SELECT  depname
       ,empno
       ,salary
       ,AVG(salary) OVER (PARTITION BY depname)
FROM empsalary;

/*  depname  | empno | salary |          avg          
-----------+-------+--------+-----------------------
 develop   |    11 |   5200 | 5020.0000000000000000
 develop   |     7 |   4200 | 5020.0000000000000000
 develop   |     9 |   4500 | 5020.0000000000000000
 develop   |     8 |   6000 | 5020.0000000000000000
 develop   |    10 |   5200 | 5020.0000000000000000
 personnel |     5 |   3500 | 3700.0000000000000000
 personnel |     2 |   3900 | 3700.0000000000000000
 sales     |     3 |   4800 | 4866.6666666666666667
 sales     |     1 |   5000 | 4866.6666666666666667
 sales     |     4 |   4800 | 4866.6666666666666667
(10 rows)*/

/*The first three output columns come directly from the table empsalary, and there is one output row for each row in the table.
The fourth column represents an average taken across all the table rows that have the same depname value as the current row.
(This actually is the same function as the regular avg aggregate function,
but the OVER clause causes it to be treated as a window function and computed across an appropriate set of rows.)*/

/*A window function call always contains an OVER clause directly following the window function's name AND argument(s).
 This is what syntactically distinguishes it FROM a regular function or aggregate function.
 The OVER clause determines exactly how the rows of the query are split up for processing by the window function.
 The PARTITION BY list within OVER specifies dividing the rows into groups, or partitions, that share the same values of the PARTITION BY expression(s).
 For each row, the window function is computed across the rows that fall into the same partition AS the current row.*/

 /*You can also control the order in which rows are processed by window functions using ORDER BY within OVER.
  (The window ORDER BY does not even have to match the order in which the rows are output.) Here is an example:*/

SELECT  depname
       ,empno
       ,salary
       ,rank() OVER (PARTITION BY depname ORDER BY salary DESC)
FROM empsalary;

/*  depname  | empno | salary | rank 
-----------+-------+--------+------
 develop   |     8 |   6000 |    1
 develop   |    10 |   5200 |    2
 develop   |    11 |   5200 |    2
 develop   |     9 |   4500 |    4
 develop   |     7 |   4200 |    5
 personnel |     2 |   3900 |    1
 personnel |     5 |   3500 |    2
 sales     |     1 |   5000 |    1
 sales     |     4 |   4800 |    2
 sales     |     3 |   4800 |    2
(10 rows)*/

/*As shown here, the rank function produces a numerical rank within the current row's partition for each distinct ORDER BY value,
 in the order defined by the ORDER BY clause. rank needs no explicit parameter, because its behavior is entirely determined by the OVER clause.
 A query can contain multiple window functions that slice up the data in different ways by means of different OVER clauses,
 but they all act on the same collection of rows defined by this virtual table.*/

/*We already saw that ORDER BY can be omitted if the ordering of rows is not important. It is also possible to omit PARTITION BY,
 in which case there is just one partition containing all the rows.*/

/*There is another important concept associated with window functions: for each row, there is a set of rows within its partition called its window frame.
 Many (but not all) window functions act only on the rows of the window frame, rather than of the whole partition.
 By default, if ORDER BY is supplied then the frame consists of all rows from the start of the partition up through the current row,
 plus any following rows that are equal to the current row according to the ORDER BY clause.
 When ORDER BY is omitted the default frame consists of all rows in the partition.*/

 /*Here is an example using sum:*/

 SELECT  salary
       ,SUM(salary) OVER ()
FROM empsalary;

/* salary |  sum  
--------+-------
   5200 | 47100
   5000 | 47100
   3500 | 47100
   4800 | 47100
   3900 | 47100
   4200 | 47100
   4500 | 47100
   4800 | 47100
   6000 | 47100
   5200 | 47100
(10 rows)*/

/*Above, since there is no ORDER BY in the OVER clause, the window frame is the same as the partition, which for lack of PARTITION BY is the whole table;
 in other words each sum is taken over the whole table and so we get the same result for each output row.
  But if we add an ORDER BY clause, we get very different results:*/

SELECT  salary
       ,SUM(salary) OVER (ORDER BY salary)
FROM empsalary;

/* salary |  sum  
--------+-------
   3500 |  3500
   3900 |  7400
   4200 | 11600
   4500 | 16100
   4800 | 25700
   4800 | 25700
   5000 | 30700
   5200 | 41100
   5200 | 41100
   6000 | 47100
(10 rows)*/

/*Here the sum is taken from the first (lowest) salary up through the current one,
 including any duplicates of the current one (notice the results for the duplicated salaries).
 
 The ORDER BY clause is one of two clauses integral to window functions. The ORDER and PARTITION define what is referred to
 as the “window”—the ordered subset of data over which calculations are made. Removing ORDER BY just leaves an unordered partition;
  in our query's case, each column's value is simply an aggregation (e.g., sum, count, average, minimum, or maximum) of all the standard_qty values in its respective account_id.*/

/*Window functions are permitted only in the SELECT list and the ORDER BY clause of the query. They are forbidden elsewhere, such as in GROUP BY, HAVING and WHERE clauses.
This is because they logically execute after the processing of those clauses. Also, window functions execute after regular aggregate functions.
This means it is valid to include an aggregate function call in the arguments of a window function, but not vice versa.*/

/*When a query involves multiple window functions, it is possible to write out each one with a separate OVER clause,
 but this is duplicative and error-prone if the same windowing behavior is wanted for several functions. Instead, each windowing behavior can be named in a WINDOW clause and then referenced in OVER.
 For example:*/

SELECT  SUM(salary) OVER w
       ,AVG(salary) OVER w
FROM empsalary
WINDOW w AS
(PARTITION BY depname
	ORDER BY salary DESC
);

/*: create a running total of standard_amt_usd (in the orders table) over order time with no date truncation.
 Your final table should have two columns: one with the amount being added for each new row, and a second 
 with the running total.*/
SELECT  standard_amt_usd
       ,SUM(standard_amt_usd) over(order by occurred_at) AS running_total
FROM orders;

/*2:Now, modify your query from the previous quiz to include partitions.
 Still create a running total of standard_amt_usd (in the orders table) over order time,
 but this time, date truncate occurred_at by year and partition by that same year-truncated occurred_at variable.
 Your final table should have three columns: One with the amount being added for each row, one for the truncated date,
 and a final column with the running total within each year.*/
SELECT  standard_amt_usd
       ,date_trunc('year',occurred_at) years
       ,SUM(standard_amt_usd) over(partition by date_trunc('year',occurred_at) ORDER BY occurred_at) AS running_total
FROM orders

/*ROW_NUMBER AND RANK FUNCTION*/

/*row_number displays the number of a given rows within the window you define.it starts to 1 ans numbers the rows
according to the ORDER BY part of the window statement.
it doesn't require you to specify a variable within parentheses*/

SELECT  id
       ,account_id
       ,occurred_at
       ,row_number() over(order by occurred_at) AS row_num
FROM orders;

SELECT  id
       ,account_id
       ,occurred_at
       ,row_number() over(partition by account_id order by occurred_at) AS row_num
FROM orders;

/*there's another function that does something similar: rank() function*.
While this might look th same, there's a subtle difference. if 2 lines ina row have the same value for occurred_at, they're given the same rank.
Whereas row_number() gives them different numbers*/

SELECT  id
       ,account_id
       ,date_trunc('month',occurred_at)                                               AS month
       ,rank() over(partition by account_id ORDER BY date_trunc('month',occurred_at)) AS row_num
FROM orders;

/*the dense_rank() function doesn't skip values after assigning several rows with the sme rank*/

SELECT  id
       ,account_id
       ,date_trunc('month',occurred_at)                                               AS month
       ,dense_rank() over(partition by account_id ORDER BY date_trunc('month',occurred_at)) AS row_num
FROM orders;

/*Select the id, account_id, and total variable from the orders table, then create a column called total_rank that ranks this total amount of paper 
ordered (from highest to lowest) for each account using a partition. Your final table should have these four columns.*/

SELECT  id
       ,account_id
       ,total
       ,rank() over(partition by account_id ORDER BY total desc) AS total_rank
FROM orders;

/*LAG AND LEAD FUNCTION*/

/*LAG function
Purpose
It returns the value from a previous row to the current row in the table.
*/

SELECT  account_id
       ,standard_sum
       /*The LAG function creates a new column called lag as part of the outer query: LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag.
 This new column named lag uses the values from the ordered standard_sum*/
       ,LAG(standard_sum) OVER (ORDER BY standard_sum)                AS lag
       /*Each value in lag_difference is comparing the row values between the 2 columns (standard_sum and lag)*/
       ,standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference
FROM
(
	SELECT  account_id
	       ,SUM(standard_qty) AS standard_sum
	FROM orders
	GROUP BY  1
) sub

/*LEAD function
Purpose:
Return the value from the row following the current row in the table.*/

SELECT  account_id
       ,standard_sum
       /*The LEAD function in the Window Function statement creates a new column called lead as part of the outer query:*/
       ,LEAD(standard_sum) OVER (ORDER BY standard_sum)                AS lead
       /*Each value in lead_difference is comparing the row values between the 2 columns (standard_sum and lead*/
       ,LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM
(
	SELECT  account_id
	       ,SUM(standard_qty) AS standard_sum
	FROM orders
	GROUP BY  1
) sub

/*Scenarios for using LAG and LEAD functions
You can use LAG and LEAD functions whenever you are trying to compare the values in adjacent rows or rows that are offset by a certain number.*/

/*Imagine you're an analyst at Parch & Posey and you want to determine how the current order's total revenue ("total" meaning from sales of all types of paper)
 compares to the next order's total revenue.
 You'll need to use occurred_at and total_amt_usd in the orders table along with LEAD to do so. In your query results, there should be four columns: 
 occurred_at, total_amt_usd, lead, and lead_difference.*/
SELECT  occurred_at
       ,total_spent
       ,LEAD(total_spent) OVER (ORDER BY occurred_at)               AS lead
       ,LEAD(total_spent) OVER (ORDER BY occurred_at) - total_spent AS lead_difference
FROM
(
	SELECT  occurred_at
	       ,total_amt_usd AS total_spent
	FROM orders
) sub

/*NTILE FUNCTION*/

/*You can use window functions to identify what percentile (or quartile, or any other subdivision) a given row falls into.
 The syntax is NTILE(*# of buckets*). In this case, ORDER BY determines which column to use to determine the quartiles (or whatever number of ‘tiles you specify).*/

SELECT  id
       ,account_id
       ,standard_qty
       ,ntile(4) over (order by standard_qty)   AS quartile
       ,ntile(5) over (order by standard_qty)   AS quintile
       ,ntile(100) over (order by standard_qty) AS percentile
FROM orders
ORDER BY standard_qty desc

/*Imagine you're an analyst at Parch & Posey and you want to determine the largest orders (in terms of quantity) 
a specific customer has made to encourage them to order more similarly sized large orders. 
You only want to consider the NTILE for that customer's account_id.*/

/*Use the NTILE functionality to divide the accounts into 4 levels IN terms of the amount of standard_qty for their orders.
 Your resulting TABLE should have the account_id, the occurred_at time for each order, the total amount of standard_qty paper purchased, 
 AND one of four levels IN a standard_quartile column.*/
SELECT  account_id
       ,occurred_at
       ,standard_qty                                                  AS total_standard_paper
       ,ntile(4) over (partition by account_id ORDER BY standard_qty) AS standard_quartile
FROM orders
ORDER BY 1 desc

/*Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders. 
Your resulting table should have the account_id, the occurred_at time for each order, the total amount of gloss_qty paper purchased, 
and one of two levels in a gloss_half column.*/
SELECT  account_id
       ,occurred_at
       ,gloss_qty                                                     AS total_gloss_paper
       ,ntile(2) over (partition by account_id ORDER BY gloss_qty) AS gloss_half
FROM orders
ORDER BY 1 desc

/*Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders. 
Your resulting table should have the account_id, the occurred_at time for each order, the total amount of total_amt_usd paper purchased, 
and one of 100 levels in a total_percentile column.*/
SELECT  account_id
       ,occurred_at
       ,total_amt_usd                                                    AS total_spent
       ,ntile(100) over (partition by account_id ORDER BY total_amt_usd) AS total_percentile
FROM orders
ORDER BY 1 desc