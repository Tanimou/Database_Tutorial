-------------------------SQL ADVANCED JOINS AND PERFORMANCE TUNING-----------------------------

/*JOINS WITH COMPARISONS OPERATORS*/
/*in order to understand how effective our campaigns are,we want to look at all the actions that a customer took
prior to making their first paper purchase from parch and posey(we want to look at all the web traffic events 
that occurred before that account's first order)*/

SELECT  o.id
       ,o.occuured_at order_date
       ,events.*
FROM orders o
LEFT JOIN web_events w
ON w.account_id=o.account_id AND w.occurred_at<o.occurred_at
WHERE date_trunc('month', o.occurred_at)= (
SELECT  date_trunc('month',MIN(o.occurred_at))
FROM orders o)
ORDER BY o.id, o.occurred_at;


/*Say you're an analyst at Parch & Posey and you want to see:

1.each account who has a sales rep and each sales rep that has an account 
(all of the columns in these returned rows will be full)

2.but also each account that does not have a sales rep and each sales rep
that does not have an account (some of the columns in these returned rows will be empty)*/
SELECT  a.name account
       ,s.name sales_rep
FROM accounts a
FULL JOIN sales_reps s
ON s.id=a.sales_rep_id
--where s.id is null AND a.sales_rep_id is null

SELECT  a.name account
       ,a.primary_poc
       ,s.name sales_rep
FROM accounts a
LEFT JOIN sales_reps s
ON s.id=a.sales_rep_id AND a.primary_poc<s.name
;
/*SELF JOINS*/

/*sometimes it can be useful to join a table onto itself.Most of the time,you'll do this 
in order to find cases where two events both occur one after another.

For example, imagine you want to know which accounts made multiple orders within 30 days.
One way to do this, would be to join the orders table onto itself with an inequality join.*/

SELECT  o1.id          AS o1_id
       ,o1.account_id  AS o1_account_id
       ,o1.occurred_at AS o1_occurred_at
       ,o2.id          AS o2_id
       ,o2.account_id  AS o2_account_id
       ,o2.occurred_at AS o2_occurred_at
FROM orders o1
LEFT JOIN orders o2
--we want to make sure that we're joining on the same account:
ON o1.account_id = o2.account_id 
--since we want the records in o2 to be within 30 days after the records in o1,
--first, we're going to join where o2.occurred_at is greater than o1.occurred_at,
--so we're going to find orders that happened after the original order was placed:
AND o2.occurred_at > o1.occurred_at 
--and then,we're going to find orders where o2.occurred_at is less than or equal to 
--30 days after o1.occurred_at
AND o2.occurred_at <= o1.occurred_at+interval '30 days'
ORDER BY o1.account_id, o2.occurred_at;



SELECT  w1.id          AS w1_id
       ,w1.account_id  AS w1_account_id
       ,w1.channel     AS w1_channel
       ,w1.occurred_at AS w1_occurred_at
       ,w2.id          AS w2_id
       ,w2.account_id  AS w2_account_id
       ,w2.channel     AS w2_channel
       ,w2.occurred_at AS w2_occurred_at
FROM web_events w1
LEFT JOIN web_events w2

ON w1.account_id = w2.account_id

AND w2.occurred_at > w1.occurred_at

AND w2.occurred_at <= w1.occurred_at+interval '1 days'
ORDER BY w1.account_id, w2.occurred_at;

/*APPENDING DATA VIA UNION OPERATOR*/

/*UNION Use Case
The UNION operator is used to combine the result sets of 2 or more SELECT statements. 
It removes duplicate rows between the various SELECT statements.

Each SELECT statement within the UNION must have the same number of fields in the result sets with similar data types.*/

/*Typically, the use case for leveraging the UNION command in SQL is when a user wants to pull together distinct values 
of specified columns that are spread across multiple tables. 
For example, a chef wants to pull together the ingredients and respective aisle across three separate meals 
that are maintained in different tables.*/

/*Details of UNION
There must be the same number of expressions in both SELECT statements.

The corresponding expressions must have the same data type in the SELECT statements. 
For example: expression1 must be the same data type in both the first and second SELECT statement.*/

/*Expert Tip
UNION removes duplicate rows.

UNION ALL does not remove duplicate rows.*/

SELECT  *
FROM web_events 
union
SELECT  *
FROM web_events_2;

/*SQL's two strict rules for appending data:

Both tables must have the same number of columns.
Those columns must have the same data types in the same order as the first table.

A common misconception is that column names have to be the same. 
Column names, in fact, don't need to be the same to append two tables but you will find that they typically are.*/

/*since we're writting 2 separate select statements when we union,
we can treat them differently before appending.For example, we can filter them differently using different where clause
*/
SELECT  *
FROM web_events
WHERE channel='facebook' 
UNION ALL
SELECT  *
FROM web_events_2;

/*PERFORMING OPERATION ON A COMBINED DATASET*/
WITH web AS
(
	SELECT  *
	FROM web_events
	UNION ALL
	SELECT  *
	FROM web_events_2
)
SELECT  channel
       ,COUNT(*) AS sessions
FROM web_events
GROUP BY  1
ORDER BY 2 desc;

SELECT  *
FROM accounts
WHERE name='Walmart' 
UNION ALL
SELECT  *
FROM accounts
WHERE name='Disney' ;

WITH t1 AS
(
	SELECT  *
	FROM accounts
	UNION ALL
	SELECT  *
	FROM accounts
)
SELECT  name
       ,COUNT(name)
FROM t1
GROUP BY  1
ORDER BY 2 desc

/*THE INTERSECT OPERATOR*/
/*same rules as the union OPERATOR
The INTERSECT operator computes the set intersection of the rows returned by the involved SELECT statements. 
A row is in the intersection of two result sets if it appears in both result sets.
INTERSECT binds more tightly than UNION. That is, A UNION B INTERSECT C will be read as A UNION (B INTERSECT C).*/

SELECT  *
FROM web_events 
INTERSECT
SELECT  *
FROM web_events_2;

/*With ALL, a row that has m duplicates in the left table and n duplicates in the right table 
will appear min(m,n) times in the result set. DISTINCT can be written to explicitly specify
the default behavior of eliminating duplicate rows.*/
select_statement INTERSECT [ ALL | DISTINCT ] select_statement

/*THE EXCEPT OPERATOR*/
/*The EXCEPT operator computes the set of rows that are in the result of the left SELECT statement but not in the result of the right one.*/
WITH t1 AS
(
	SELECT  *
	FROM accounts
	EXCEPT
	SELECT  *
	FROM accounts
)
SELECT  name
       ,COUNT(name)
FROM t1
GROUP BY  1
ORDER BY 2 desc
/*The result of EXCEPT does not contain any duplicate rows unless the ALL option is specified. 
With ALL, a row that has m duplicates in the left table and n duplicates in the right table 
will appear max(m-n,0) times in the result set. DISTINCT can be written to explicitly specify the default behavior of eliminating duplicate rows.*/
select_statement EXCEPT [ ALL | DISTINCT ] select_statement
/*Multiple EXCEPT operators in the same SELECT statement are evaluated left to right, 
unless parentheses dictate otherwise. EXCEPT binds at the same level as UNION.*/

SELECT  film_id
       ,title
FROM film 
EXCEPT
SELECT  DISTINCT film_id
       ,title
FROM inventory
JOIN film
ON film.film_id = film
ORDER BY title