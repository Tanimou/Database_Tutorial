--this sql syntax is a ppostgres version syntax
-----------------------------------------BASIC SQL--------------------------------
SELECT  *
FROM orders
LIMIT 15 ; 

/*if i want to retrive 15 orders starting from the third order for example, i can do that
by adding an offset*/
SELECT  *
FROM orders
LIMIT 15 offset 2;

/*The ORDER BY statement allows us to sort our results USING the data IN any column. If you are familiar WITH Excel or Google Sheets, USING ORDER BY is similar to sorting a sheet USING a column. 
A key difference, however, is that USING ORDER BY IN a SQL query only has temporary effects, for the results of that query, unlike sorting a sheet by column IN Excel or Sheets. 
IN other words, WHEN you use ORDER BY IN a SQL query, your output will be sorted that way, but THEN the next query you run will encounter the unsorted data again. 
It's important to keep IN mind that this is different than USING common spreadsheet software, WHERE sorting the spreadsheet by column actually alters the data IN that sheet until you undo or change that sorting. 
This highlights the meaning AND function of a SQL "query." The ORDER BY statement always comes IN a query after the SELECT  AND FROM statements, but before the LIMIT statement. 
If you are USING the LIMIT statement, it will always appear last. AS you learn additional commands, the order of these statements will matter more 
Pro Tip 
Remember DESC can be added after the column IN your ORDER BY statement to sort IN descending order, AS the default is to sort IN ascending order.*/

SELECT  id
       ,occurred_at
       ,total_amt_usd
FROM orders
LIMIT 10 ;

SELECT  id
       ,account_id
       ,total_amt_usd
FROM orders
ORDER BY total_amt_usd desc
LIMIT 5 ;

SELECT  id
       ,account_id
       ,total_amt_usd
FROM orders
ORDER BY total_amt_usd
LIMIT 20 ; 

/*Here,we saw that we can ORDER BY more than one column at a time. WHEN you provide a list of columns IN an ORDER BY command, the sorting occurs USING the leftmost column IN your list first, THEN the next column
FROM the left, AND so on.We still have the ability to flip the way we order USING DESC.*/
SELECT  id
       ,account_id
       ,total_amt_usd
FROM orders
ORDER BY total_amt_usd, account_id desc ;

SELECT  id
       ,account_id
       ,total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd desc ;

/*Using the WHERE statement, we can display subsets of tables based ON conditions that must be met.You can also think of the WHERE command AS filtering the data,AND IN the upcoming concepts, 
you will learn some common operators that are useful WITH the WHERE ' statement. 
Common symbols used IN WHERE statements include: > (greater than) < (less than) >= (greater than or equal to) <= (less than or equal to) = (equal to) != (not equal to)*/
SELECT  *
FROM orders
WHERE gloss_amt_usd >= 1000
LIMIT 5 ;

SELECT  *
FROM orders
WHERE account_id = 4253
ORDER BY occurred_at
LIMIT 10 ; 

/*The WHERE statement can also be used WITH non - numeric data.
We can use the = AND != operators here.You need to be sure to use single quotes 
( just be careful if you have quotes IN the original text) WITH the text data, not double quotes.Commonly WHEN we are USING
WHERE WITH non - numeric data fields, we use the LIKE, NOT, or IN operators.We will see those before the end of this lesson !*/
SELECT  name
       ,website
       ,primary_poc
FROM accounts
WHERE name = 'Exxon Mobil' ;

 /*Derived Columns Creating a new column that is a combination of existing columns is known AS a derived column ( or "calculated" or "computed" column ).
 Usually you want to give a name, or "alias, " to your new column USING the AS keyword.This derived column,AND its alias, are generally only temporary, existing just for the duration of your query.
 The next time you run a query AND access this table, the new column will not be there.If you are deriving the new column FROM existing columns USING a mathematical expression, 
 THEN these familiar mathematical operators will be useful: *
(Multiplication) + (Addition) - (Subtraction) / (Division) Consider this example: */
SELECT  id
       ,(standard_amt_usd / total_amt_usd) * 100 AS std_percent
       ,total_amt_usd
FROM orders
LIMIT 10 ; 

/*Here we divide the standard paper dollar amount by the total order amount to find the standard paper percent for the order, AND use the AS keyword to name this new column "std_percent."*/

SELECT  id
       ,account_id
       ,(standard_amt_usd / standard_qty) AS unit_price
FROM orders
LIMIT 10 ;

SELECT  id
       ,account_id
       ,poster_amt_usd / (standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS post_per
FROM orders
LIMIT 10 ;

 /*Notice, the above operators combine information across columns for the same row.
 If you want to combine values of a particular column, across multiple rows, we will do this WITH aggregations.*/ 
 
 /*Introduction to Logical Operators 
 IN the next concepts, you will be learning about Logical Operators.Logical Operators include: 

 LIKE 
 This allows you to perform operations similar to USING WHERE AND =, but for cases WHEN you might not know exactly what you are looking for.

 IN 
 This allows you to perform operations similar to USING WHERE AND =, but for more than one condition.

 NOT 
 This is used WITH IN AND LIKE to SELECT  all of the rows NOT LIKE or NOT IN a certain condition. 

 AND & BETWEEN 
 These allow you to combine operations WHERE all combined conditions must be true. 

 OR 
 This allows you to combine operations WHERE at least one of the combined conditions must be true.*/ 
 
 /*The LIKE operator is extremely useful for working WITH text.You will use LIKE within a WHERE clause.
 The LIKE operator is frequently used WITH %. The % tells us that we might want any number of characters leading up to a particular SET of characters or following a certain SET of characters, 
 AS we saw WITH the google syntax above.
 Remember you will need to use single quotes for the text you pass to the LIKE operator, because of this lower AND uppercase letters are not the same within the string.
 Searching for 'T' is not the same AS searching for 't'.In other SQL environments (outside the classroom), you can use either single or double quotes.*/
SELECT  *
FROM web_events_full
WHERE referrer_url LIKE '%google%' ;

SELECT  *
FROM accounts
WHERE name LIKE 'C%' ;

SELECT  *
FROM accounts
WHERE name LIKE '%one%' ; 

/*The IN operator is useful for working WITH both numeric AND text columns.This operator allows you to use an =, but for more than one item of that particular column.
We can check one, two or many column values for which we want to pull data, but all within the same query.
In the upcoming concepts, you will see the OR operator that would also allow us to perform these tasks, but the IN operator is a cleaner way to write these queries.

Expert Tip 
IN most SQL environments, although not IN our Udacity 's classroom, you can use single or double quotation marks -
AND you may NEED to use double quotation marks if you have an apostrophe within the text you are attempting to pull. 
IN our Udacity SQL workspaces, note you can include an apostrophe by putting two single quotes together. For example, Macy' s IN our workspace would be 'Macy''s'.*/
SELECT  name
       ,primary_poc
       ,sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom') ;

 /*The NOT operator is an extremely useful operator for working WITH the previous two operators we introduced: IN
AND LIKE.By specifying NOT LIKE or NOT IN, we can grab all of the rows that do not meet a particular criteria.*/
SELECT  *
FROM accounts
WHERE name NOT LIKE 'C%' ;

SELECT  name
       ,primary_poc
       ,sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom') ; 

/*The AND operator is used within a WHERE statement to consider more than one logical clause at a time.
Each time you link a new statement WITH an AND, you will need to specify the column you are interested IN looking at.
You may link AS many statements AS you would like to consider at the same time.This operator works WITH all of the operations we have seen so far including arithmetic operators 
(+, *, -, /).
LIKE, IN, AND NOT logic can also be linked together USING the AND operator 

BETWEEN Operator 
Sometimes we can make a cleaner statement USING BETWEEN than we can USING AND.Particularly this is true WHEN we are USING the same column for different parts of our AND statement Instead of writing:
WHERE column >= 6 AND column <= 10 we can instead write, equivalently:
WHERE column BETWEEN 6 AND 10 BETWEEN operator IN sql is inclusive*/
SELECT  *
FROM orders
WHERE standard_qty > 1000
AND poster_qty = 0
AND gloss_qty = 0 ;

SELECT  *
FROM accounts
WHERE name NOT LIKE 'C%'
AND name LIKE '%s' ;

SELECT  occurred_at
       ,gloss_qty
FROM orders
WHERE gloss_qty BETWEEN 24 AND 29 ;

SELECT  *
FROM web_events
WHERE channel IN ('organic', 'adwords')
AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC ; 

/*Similar to the AND operator, the OR operator can combine multiple statements.Each time you link a new statement WITH an OR, you will need to specify the column you are interested IN looking at.
You may link AS many statements AS you would like to consider at the same time.This operator works WITH all of the operations we have seen so far including arithmetic operators (+, *, -, /), 
LIKE, IN, NOT,AND,and BETWEEN logic can all be linked together USING the OR operator. 
WHEN combining multiple of these operations, we frequently might need to use parentheses to assure that logic we want to perform is being executed correctly*/
SELECT  id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000 ;

SELECT  *
FROM orders
WHERE standard_qty = 0
AND ( gloss_qty > 1000 OR poster_qty > 1000 ) ; 