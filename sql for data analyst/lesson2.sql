-------------------------------------SQL JOINS--------------------------------- 
/*Database Normalization WHEN creating a database, it is really important to think about how data will be stored.
This is known AS normalization, AND it is a huge part of most SQL classes.If you are IN charge of setting up a new database, 
it is important to have a thorough understanding of database normalization.
There are essentially three ideas that are aimed at database normalization: 
Are the tables storing logical groupings of the data ? 
Can I make changes IN a single location, rather than IN many tables for the same information ? 
Can I access AND manipulate data quickly AND efficiently ? However, most analysts are working WITH a database that was already

SET up WITH the necessary properties IN place.As analysts of data, you don 't really need to think too much about data normalization. You just need to be able to pull the data
FROM the database, so you can start making insights. This will be our focus IN this lesson. The whole purpose of JOIN statements is to allow us to pull data
FROM more than one TABLE at a time.Again - JOINs are useful for allowing us to pull data
FROM multiple tables.This is both simple AND powerful all at the same time.WITH the addition of the JOIN statement to our toolkit, we will also be adding the ON statement.
We use ON clause to specify a JOIN condition which is a logical statement to combine the TABLE in FROM AND
JOIN statements*/
SELECT  orders.*
FROM orders
JOIN accounts
ON orders.account_id = accounts.id ;

/*we can also write this above query with an implicite join as:*/
SELECT  o.*
FROM orders o, accounts a
WHERE o.account_id=a.id;

/*Above, we are only pulling data
FROM the orders TABLE since IN the
SELECT  statement we only reference columns
FROM the orders table.The ON statement holds the two columns that get linked across the two tables Additional Information If we wanted to only pull individual elements
FROM either the orders or accounts table, we can do this by USING the exact same information IN the FROM AND ON statements.
However, IN your SELECT  statement, you will need to know how to specify tables AND columns IN the
SELECT  statement: The TABLE name is always before the period.The column you want
FROM that TABLE is always after the period.
For example, if we want to pull only the account name AND the dates IN which that account placed an order, but none of the other columns, we can do this WITH the following query:*/
SELECT  accounts.name
       ,orders.occurred_at
FROM orders
JOIN accounts
ON orders.account_id = accounts.id ; 
/*another way to write the above query with an implicite join*/
SELECT  a.name
       ,o.occurred_at
FROM orders o, accounts a
WHERE o.account_id = a.id
/*This query only pulls two columns, not all the information IN these two tables.Alternatively, the below query pulls all the columns
FROM both the accounts AND orders table.*/
SELECT  *
FROM orders
JOIN accounts
ON orders.account_id = accounts.id ; 

/*Joining tables allows you access to each of the tables IN the
SELECT  statement through the TABLE name
       ,AND the columns will always follow after the TABLE name.*/
SELECT  orders.standard_qty
       ,orders.poster_qty
       ,orders.gloss_qty
       ,accounts.website
       ,accounts.primary_poc
FROM orders
JOIN accounts
ON orders.account_id = accounts.id ;

 /*Keys Primary Key (PK) A primary key is a unique column IN a particular table.This is the first column IN each of our tables.
 Here, those columns are all called id, but that doesn 't necessarily have to be the same. It is common that the primary key is the first column IN our tables IN most databases. 
 Foreign Key (FK) A foreign key is a column IN one TABLE that is a primary key IN a different table. Notice Notice our SQL query has the two tables we would like to
JOIN 
- one IN the FROM AND the other IN the JOIN.Then IN the ON, we will ALWAYs have the PK equal to the FK:The way we JOIN any two tables is IN this way: linking the PK AND FK
(generally IN an ON statement).*/ 

/*JOIN More than Two Tables 
This same logic can actually assist IN joining more than two tables together.*/
SELECT  *
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN orders
ON accounts.id = orders.account_id ;

--with an implicite join:
SELECT  *
FROM web_events w, accounts a, orders o
WHERE w.account_id=a.id
AND a.id=o.account_id;

--in the sqlite version, the syntax above will be:
SELECT  *
FROM web_events
JOIN accounts
JOIN orders
ON accounts.id = orders.account_id AND web_events.account_id = accounts.id ; 

/*Alternatively, we can CREATE a SELECT  statement that could pull specific columns FROM any of the three tables.
Again, our JOIN holds a table, AND ON is a link for our PK to equal the FK. Joining 2 tables without an ON clause gives all possible combinations of rows*/ 

/*ALIASES: 
WHEN we JOIN tables together, it is nice to give each TABLE an alias.Frequently an alias is just the first letter of the TABLE name.
You actually saw something similar for column names IN the Arithmetic Operators concept.Example:*/
FROM tablename AS t1
JOIN tablename2 AS t2 ;

 /*Frequently, you might also see these statements without the AS statement.Each of the above could be written IN the following way instead, AND they would still produce the exact same results:*/
FROM tablename t1
JOIN tablename2 t2 ;

 /*Aliases for Columns IN Resulting TABLE While aliasing tables is the most common use case .It can also be used to alias the columns selected to have the resulting TABLE reflect a more readable name. 
 Example:*/

SELECT  t1.column1 AS aliasname
       ,t2.column2 AS aliasname2
FROM tablename AS t1
JOIN tablename2 AS t2 ; 

/*The alias name fields will be what shows up IN the returned TABLE instead of t1.column1 AND t2.column2.We can simply write our alias directly after the column name
( IN the SELECT ) or TABLE name ( IN the FROM or JOIN ) by writing the alias directly following the column or TABLE we would like to alias.This will allow you to CREATE clear column names 
even if calculations are used to CREATE the column, AND you can be more efficient WITH your code by aliasing TABLE names*/
SELECT  accounts.primary_poc
       ,web_events.occurred_at
       ,web_events.channel
       ,accounts.name
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
WHERE accounts.name LIKE 'Walmart' ;

SELECT  r.name AS region
       ,s.name AS rep
       ,a.name AS account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY a.name ; 

SELECT  r.name AS region
       ,a.name AS account
       ,o.total_amt_usd / (o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id ; 

/*The types of relationships that exist IN a database matter less to analysts, but you do need to understand why you would perform different types of JOINs, AND what data you are pulling
FROM the database. You have had a bit of an introduction to these one - to - one AND one - to - many relationships WHEN we introduced PKs AND FKs.Notice, 
traditional databases do not allow for many - to - many relationships, AS these break the schema down pretty quickly*/ 

/*the LEFT JOIN includes all the data that are IN the left TABLE +the data that are common to both tables 
the RIGHT JOIN includes all the data that are common to the both tables + the data that are IN the right table*/ 

/*left outer JOIN is the same AS LEFT JOIN AND RIGHT OUTER JOIN is the same AS right join*/ 

/*a LEFT JOIN AND RIGHT JOIN do the same thing if we change the tables that are IN the FROM AND JOIN statements*/

SELECT  c.countryid
       ,c.countryName
       ,s.stateName
FROM Country c
LEFT JOIN State s
ON c.countryid = s.countryid ;

--1
SELECT  r.name AS region
       ,s.name AS sales_reps
       ,a.name AS account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest'
ORDER BY a.name ;

--2
SELECT  r.name AS region
       ,s.name AS sales_reps
       ,a.name AS account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE s.name LIKE 'S%'
AND r.name = 'Midwest'
ORDER BY a.name ;

--3
SELECT  r.name AS region
       ,s.name AS sales_reps
       ,a.name AS account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE s.name LIKE '% K%'
AND r.name = 'Midwest'
ORDER BY a.name ;

--4
SELECT  r.name AS region
       ,a.name AS account
       ,o.total_amt_usd / (o.total + 0.01) unit_price
FROM accounts a
JOIN orders o
ON a.id = o.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON s.region_id = r.id
WHERE o.standard_qty > 100 ;

--5
SELECT  r.name AS region
       ,a.name AS account
       ,o.total_amt_usd / (o.total + 0.01) unit_price
FROM accounts a
JOIN orders o
ON a.id = o.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON s.region_id = r.id
WHERE o.standard_qty > 100
AND o.poster_qty > 50
ORDER BY unit_price ;

--6
SELECT  r.name AS region
       ,a.name AS account
       ,o.total_amt_usd / (o.total + 0.01) unit_price
FROM accounts a
JOIN orders o
ON a.id = o.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON s.region_id = r.id
WHERE o.standard_qty > 100
AND o.poster_qty > 50
ORDER BY unit_price desc ;

--7
SELECT  DISTINCT a.name
       ,w.channel
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
WHERE a.id = 1001 ;

--8
SELECT  o.occurred_at
       ,a.name
       ,o.total
       ,o.total_amt_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at BETWEEN '2015-01-01' AND '2016-01-01'
ORDER BY o.occurred_at desc ;

 /*Recap 
 Primary AND Foreign Keys You learned a key element for JOINing tables IN a database has to do WITH primary
AND foreign keys: primary keys - are unique for every row IN a table.These are generally the first column IN our database ( like you saw WITH the id column for every TABLE IN the Parch & Posey database ).
foreign keys - are the primary key appearing IN another table, which allows the rows to be non - unique.
Choosing the SET up of data IN our database is very important, but not usually the job of a data analyst.This process is known AS Database Normalization.
JOINs 
IN this lesson, you learned how to combine data FROM multiple tables USING JOINs.The three JOIN statements you are most likely to use are:
JOIN 
- an INNER JOIN that only pulls data that exists IN both tables.
LEFT JOIN 
- pulls all the data that exists IN both tables, AS well AS all of the rows FROM the TABLE IN the FROM the table even if they do not exist IN the JOIN statement.
RIGHT JOIN 
- pulls all the data that exists IN both tables, AS well AS all of the rows
FROM the TABLE IN the JOIN even if they do not exist IN the FROM statement.

There are a few more advanced JOINs that we did not cover here, AND they are used IN very specific use cases. 
UNION AND UNION ALL, CROSS JOIN, AND the tricky SELF JOIN.
These are more advanced than this course will cover, but it is useful to be aware that they exist, AS they are useful IN special cases. 
Alias You learned that you can alias tables AND columns USING AS or not USING it.
This allows you to be more efficient IN the number of characters you need to write, while at the same time you can assure that your column headings are informative of the data IN your table.*/