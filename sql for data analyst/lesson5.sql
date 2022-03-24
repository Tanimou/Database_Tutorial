-----------------------------SQL DATA CLEANING------------------------------
/*LEFT, RIGHT, LENGTH FUNCTIONS*/

SELECT  first_name
       ,last_name
       ,phone_number
       ,left(phone_number,3)                       AS area_code
       ,right(phone_number,8)                      AS phone_number_only
       ,right(phone_number,length(phone_number)-4) AS phone_number_alt
FROM customer_data

/*LEFT pulls a specified number of characters for each row IN a specified column starting at the beginning (or
FROM the left). AS you saw here, you can pull the first three digits of a phone number USING LEFT(phone_number, 3).*/

/*RIGHT pulls a specified number of characters for each row IN a specified column starting at the end (or
FROM the right). AS you saw here, you can pull the last eight digits of a phone number USING RIGHT(phone_number, 8).*/

/*LENGTH provides the number of characters for each row of a specified column.Here,
you saw that we could use this to get the length of each phone number as LENGTH(phone_number).*/

-----------LEFT/RIFHT QUIZZES--------------------

/*1:In the accounts table,
there is a column holding the website for each company.The last three digits specify what type of web address they are using.Pull these extensions
and provide how many of each website type exist in the accounts table.*/

SELECT  right(website,3) AS extension
       ,COUNT(*) count_account
FROM accounts
GROUP BY  1
ORDER BY 2 desc;

/*2:Use the accounts TABLE to pull the first letter of each company name to see the distribution of company names that begin WITH each letter
( or number
).*/

select left(name, 1) as first_character,count(*) 
from accounts
group by 1 order by 2 desc;

/*3:Use the accounts TABLE AND a CASE statement to

CREATE two groups: one group of company names that start WITH a number AND a second group of those company names that start WITH a letter.What proportion of company names start WITH a letter ?*/

SELECT  SUM(num) nums
       ,SUM(letter) letters
FROM
(
	SELECT  name
	       ,CASE WHEN LEFT(UPPER(name),1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 1  ELSE 0 END AS num
	       ,CASE WHEN LEFT(UPPER(name),1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 0  ELSE 1 END AS letter
	FROM accounts
) t1;

/*4:Consider vowels AS a, e, i, o, AND u.What proportion of company names start WITH a vowel, AND what percent start WITH anything else ?*/

WITH t1 AS
(
	SELECT  name
	       ,CASE WHEN left(upper(name),1) IN ('A','E','I','O','U') THEN 1  ELSE 0 END     AS start_with_vowels
	       ,CASE WHEN left(upper(name),1) not IN ('A','E','I','O','U') THEN 1  ELSE 0 END AS not_start_with_vowels
	FROM accounts
	GROUP BY  1
	ORDER BY 1
)
SELECT  SUM(start_with_vowels) sum_sv
       ,SUM(not_start_with_vowels) sum_nsv
FROM t1;

/*POSITION AND STRPOS*/
/*POSITION takes a character AND a column, AND provides the index
WHERE that character is for each row.The index of the first position is 1 IN SQL.If you come
FROM another programming language, many begin indexing at 0.Here, you saw that you can pull the index of a comma AS POSITION
(',' IN city_state).
STRPOS provides the same result AS POSITION, but the syntax for achieving those results is a bit different AS shown here: STRPOS(city_state, ',').*/
SELECT  first_name
       ,last_name
       ,citty_state
       ,position(',' IN city_state)                    AS comma_position
       ,strpos(city_state,',')                         AS substr_comma_position
       ,left(city_state,position(',' IN city_state)-1) AS city
FROM customer_data;

/*Note, both POSITION AND STRPOS are case sensitive, so looking for A is different than looking for a.
 Therefore, if you want to pull an index regardless of the case of a letter, you might want to use LOWER or UPPER to make all of the characters lower or uppercase.*/

--------------------QUIZ---------------
/*1:Use the accounts TABLE to
CREATE first AND last name columns that hold the first AND last names for the primary_poc.*/
SELECT  left(primary_poc,strpos(primary_poc,' ')-1)                    AS first                             AS first
       ,right(primary_poc,length(primary_poc)-strpos(primary_poc,' ')) AS last
       ,primary_poc
FROM accounts;

/*2:Now see if you can do the same thing for every rep name IN the sales_reps table. Again provide first AND last name columns.*/
SELECT  left(name,strpos(name,' ')-1)                                AS first
       ,right(name,length(name)-strpos(name,' ')) AS last
       ,name
FROM sales_reps;

/*CONCATENATION*/

/*concat function combines values from several columns into one column.
we can add hardcores values by enclosing them in single quotes
we can use also '||' to concatenate
both concat and || can be used to concatenate strings together*/

SELECT  first_name
       ,last_name
       ,concat(first_name,' ',lastname) AS fullname
       ,first_name||' '||last_name      AS fullname_alt
FROM customer_data


---------------------QUIZ--------------------------
/*1:Each company IN the accounts TABLE wants to
CREATE an email address for each primary_poc. The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.*/

SELECT  primary_poc
        ,name
        ,left(primary_poc,strpos(primary_poc,' ')-1)||'.'||right(primary_poc,length(primary_poc)-strpos(primary_poc,' '))||'@'||name||'.com' AS email_account
FROM accounts

--another solution of question 1:
WITH t1 AS
(
	SELECT  LEFT(primary_poc,STRPOS(primary_poc,' ') -1 ) first_name
	       ,RIGHT(primary_poc,LENGTH(primary_poc) - STRPOS(primary_poc,' ')) last_name
	       ,name
	FROM accounts
)
SELECT  first_name
       ,last_name
       ,CONCAT(first_name,'.',last_name,'@',name,'.com')
FROM t1;

/*2:You may have noticed that IN the previous solution some of the company names include spaces, which will certainly not work IN an email address. See if you can
CREATE an email address that will work by removing all of the spaces IN the account name, but otherwise your solution should be just AS IN question 1*/

WITH t1 AS
(
	SELECT  LEFT(primary_poc,STRPOS(primary_poc,' ') -1 ) first_name
	       ,RIGHT(primary_poc,LENGTH(primary_poc) - STRPOS(primary_poc,' ')) last_name
	       ,CASE WHEN strpos(name,' ')=0 THEN name  ELSE replace(name,' ','') END AS name
	FROM accounts
)
SELECT  first_name
       ,last_name
       ,CONCAT(first_name,'.',last_name,'@',name,'.com')
FROM t1;

/*3:We would also like to
CREATE an initial password, which they will change after their first log in.
 The first password will be the first letter of the primary_poc's first name (lowercase),
  THEN the last letter of their first name (lowercase), 
  the first letter of their last name (lowercase), 
  the last letter of their last name (lowercase), the number of letters IN their first name, 
  the number of letters IN their last name, 
  AND THEN the name of the company they are working with, all capitalized WITH no spaces.*/

WITH t1 AS
(
	SELECT  LEFT(primary_poc,STRPOS(primary_poc,' ') -1 ) first_name
	       ,RIGHT(primary_poc,LENGTH(primary_poc) - STRPOS(primary_poc,' ')) last_name
	       ,CASE WHEN strpos(name,' ')=0 THEN name  ELSE replace(name,' ','') END AS name
	FROM accounts
)
SELECT  first_name
       ,last_name
       ,CONCAT(first_name,'.',last_name,'@',name,'.com') AS email
       ,concat(lower(substr(first_name,1,1)) ,lower(substr(first_name,length(first_name),1)) ,lower(substr(last_name,1,1)) ,lower(substr(last_name,length(last_name),1)) ,length(first_name),length(last_name) ,upper(name)) AS password
FROM t1;

/*CASTING*/

/*Cast function allows us to change columns from one data type to another*/
/*we can also add "::" to cast
it's useful for turning sring into numbers or date*/

SELECT  *
       ,date_part('month',to_date(month,'month'))                            AS clean_month
       ,year||'-'||date_part('month',to_date(month,'month'))||'-'||day       AS concatenated_date
       ,year||'-'||date_part('month',to_date(month,'month'))||'-'||day::date AS formatted_date
FROM ad_clicks

/*DATE_PART('month', TO_DATE(month, 'month')) here changed a month name into the number associated with that particular month.
*/

SELECT  date
       ,date_modified
       ,substr(date_modified,7,4)||'-'||substr(date_modified,1,2)||'-'||substr(date_modified,4,2) correct_format
       ,(substr(date_modified,7,4)||'-'||substr(date_modified,1,2)||'-'||substr(date_modified,4,2))::date AS new_date
FROM
(
	SELECT  date
	       ,replace(substr(date,1,strpos(date,' ')-1),'/','-') AS date_modified
	FROM sf_crime_data
) t1
LIMIT 10

/*COALESCE function*/

/*using coalesce we filled the null values and now get a value in every cell*/

SELECT  COUNT(primary_poc) regular_count
       ,COUNT(coalesce(primary_poc,'no poc')) modified_count
FROM accounts

/*the regular_count will count all the primary_poc with no null values
whereas the modified_count will count all the primary_poc, because we filled up the null values with coalesce function*/

SELECT  COALESCE(o.id,a.id) filled_id
       ,a.name
       ,a.website
       ,a.lat
       ,a.long
       ,a.primary_poc
       ,a.sales_rep_id
       ,COALESCE(o.account_id,a.id) account_id
       ,o.occurred_at
       ,COALESCE(o.standard_qty,0) standard_qty
       ,COALESCE(o.gloss_qty,0) gloss_qty
       ,COALESCE(o.poster_qty,0) poster_qty
       ,COALESCE(o.total,0) total
       ,COALESCE(o.standard_amt_usd,0) standard_amt_usd
       ,COALESCE(o.gloss_amt_usd,0) gloss_amt_usd
       ,COALESCE(o.poster_amt_usd,0) poster_amt_usd
       ,COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
