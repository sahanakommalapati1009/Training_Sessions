# String functions in SQL
select title from sakila.film;

# RPAD(text, length, character), Right Padding
-- Add extra characters to the right side of the text until the total length becomes the given number.
-- RPAD adds extra characters on the right.
-- LPAD adds extra characters on the left.
# Example
-- masked credit card
-- masked employee ID
-- Barcodes
select title, LPAD(RPAD(title, 20, '*'), 25, '*') as left_padded from sakila.film limit 5;

select title, RPAD(title, 20, '#') as right_padded from sakila.film limit 5;

# SUBSTRING extracts a part of a string.
-- we choose : starting position and how many characters to take
-- Example : SUBSTRING(title, 3, 9)
-- Start from the 3rd character of the title and take 9 characters from there.
-- Real use case
-- Cleaning messy data, Extracting first or last name, Extracting part of a code, Masking sensitive data

select title, SUBSTRING(title, 3, 9) as substring_extract from sakila.film limit 5;

# CONCAT joins multiple strings together.
-- We use it to create combined text like full names, emails, product codes, or formatted output.
select CONCAT(first_name, '@', last_name, '@gmail.com') as gmail from sakila.actor;

# REVERSE(string) → returns the string in reverse order.
select title, reverse(title) from sakila.film limit 5;

# Length : Find the length of the variable
select title, length(title) as title_length from sakila.film where length(title)=8;

select email from sakila.customer;

# LOCATE('@', email) finds the position (index) of the @ symbol in the email.
select email, substring(email, locate('@', email) +1) as domain from sakila.customer;

# SUBSTRING_INDEX(string, delimiter, count)
-- Cuts a string using a delimiter and returns part of it.
-- string → the text you want to split
-- delimiter → the symbol to split by (@, ., -, /, etc.)
-- count: positive → take from LEFT, negative → take from RIGHT
-- SUBSTRING_INDEX: A piece based on known pattern
-- SUBSTRING: A piece based on fixed length	
select email, substring_index(substring(email, locate('@', email) +1), '.', -1) as domain from sakila.customer;
select substring_index(email,'@', -1) from sakila.customer;

-- Upper and Lower
SELECT first_name, Lower(first_name) AS lower_name FROM sakila.customer LIMIT 5;
SELECT first_name, Upper(first_name) AS upper_name FROM sakila.customer LIMIT 5;


SELECT title, UPPER(title),lower(title)
FROM sakila.film
WHERE UPPER(title) LIKE '%LOVELY%' OR UPPER(title) LIKE '%MAN';

-- left and right
-- from left that is beginning 3 letters
SELECT title, LEFT(title, 3) AS first_three_letters FROM sakila.film LIMIT 5;
-- from right 3 letters
SELECT title, Right(title, 3) AS first_three_letters FROM sakila.film LIMIT 5;

SELECT LEFT(title, 1) AS first_letter, right(title,1) as last_letter, COUNT(*) AS film_count
FROM sakila.film
GROUP BY LEFT(title, 1), right(title,1) 
ORDER BY film_count DESC;

-- CASE Function
SELECT last_name,
       CASE 
           WHEN LEFT(last_name, 1) BETWEEN 'A' AND 'M' THEN 'Group A-M'
           WHEN LEFT(last_name, 1) BETWEEN 'N' AND 'Z' THEN 'Group N-Z'
           ELSE 'Other'
       END AS group_label
FROM sakila.customer;

# REPLACE
SELECT title, REPLACE(title, 'A', 'x') AS cleaned_title
FROM sakila.film
WHERE title LIKE '% ' '%';

# Regular Expressions
-- ^ inside [], [^abc], NOT these characters
-- ^ outside [], ^abc, String starts with "abc"
-- not contains 3 consecutive vowels 
select customer_id, last_name from sakila.customer where last_name regexp '[^aeiouAEIOU]{3}';

-- ends with vowel
-- $ means "end of the string"
select title from sakila.film where title regexp '[aeiouAEIOU]$';

-- title ends with eE
select title, right(title, 2) as right_title from sakila.film where title regexp '[eE]$';

-- counts how many movie titles end with each vowel (A, E, I, O, U) by grouping titles based on their last character.
select right(title, 1) as right_title , count(*) from sakila.film where title regexp '[aeiouAEIOU]$' GROUP BY right_title;

-- Titles ending with eE
select title as ending, right(title, 1) from sakila.film where title regexp '[eE]$';

# math 
SELECT title, rental_rate, rental_rate ^ 3 AS double_rate   -- debug why its allwoing string + integer
FROM sakila.film;

# CAST 
-- CAST converts a value from one data type to another data type.
select amount,CAST(amount AS signed) AS amount_str from sakila.payment;

-- This query groups all payments by each customer. For every customer, it counts how many payments they made, calculates the total amount they paid, and then divides the total by the number of payments to get the average payment amount.
select customer_id, count(payment_id) total_payments, sum(amount) as total_amount, sum(amount)/count(payment_id) as average from sakila.payment group by customer_id;

ALTER table sakila.film add column cost_effiency_dup decimal(6,2);

SET SQL_SAFE_UPDATES = 0;

select POWER(4,2);

select rental_duration from sakila.film;

# UPDATE TABLE
update sakila.film set cost_effiency_dup = rental_duration * 2 where length is not null;

-- RAND() = generates a random decimal number between 0 and 1.
-- FLOOR(x) = gives the largest whole number LESS than or equal to x. ex:8.9 = 8
-- Generating random score for each customer id
select customer_id, floor(rand()*100) as random_number from sakila.customer;

-- POWER
select title, rental_duration, POWER(rental_duration , 2) as squared_rental from sakila.film limit 5;

-- MOD(a, b) = remainder when a is divided by b
-- CEIL(x) = the smallest whole number greater than or equal to x. ex: 2.1=3
-- ROUND(number, decimal_places)
-- ROUND(5.50,0) → 6, ROUND(3.14159,2) → 3.14
SELECT film_id,length, MOD(length, 60) AS minutes_over_hour
FROM sakila.film;
SELECT rental_rate, CEIL(rental_rate) AS ceil_value, FLOOR(rental_rate) AS floor_value
FROM sakila.film;
SELECT rental_rate, ROUND(replacement_cost / rental_rate, 0),ROUND(replacement_cost / rental_rate, 1) AS ratio
FROM sakila.film;

# Date diff 
-- calculates how many days each movie was rented for by subtracting the rental date from the 
-- return date using DATEDIFF
select rental_id, rental_date, return_date, datediff(return_date, rental_date) as date_diff from sakila.rental;

# date time 
select rental_date, month(rental_date), monthname(rental_date), year(rental_date), date(rental_date), week(rental_date), weekday(rental_date) from sakila.rental;

SELECT payment_date, date(payment_date) AS pay_date, SUM(amount) AS total_paid
FROM sakila.payment
GROUP BY DATE(payment_date),payment_date
ORDER BY pay_date DESC;

# Find Customers Who Paid in the Last 24 Hours
select now();
select  curdate();
select customer_id, payment_id from sakila.payment where payment_date >= now()-interval 1 day;

# Last transaction date
select max(payment_date) FROM sakila.payment;
select customer_id, payment_id, payment_date from sakila.payment where payment_date>= (select max(payment_date) -interval 1 day FROM sakila.payment);
select now()  - INTERVAL 1 week as yesterday;

SELECT CONCAT('Today is: ', CURDATE()) AS message;
SELECT CONCAT('Today is: ', now()) AS message;
SELECT NOW(), CURDATE(), CURRENT_TIME;

#casting 
SELECT CAST('2017-08-25' AS datetime);

select cast(amount as signed) from sakila.payment;
select amount from sakila.payment;



