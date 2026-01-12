select * from sakila.customer;

-- DISTINCT gives you unique values, removes duplicates
select distinct rating from sakila.film;

-- COUNT: Aggregate function which counts total number of films present in the database
select count(*) from sakila.film;
select count(title) from sakila.film;
select count(staff_id) from sakila.staff where staff_id=1;

-- Top N 
-- ORDER BY sorts the rows.
-- DESC from largest to smallest.
-- LIMIT
-- Top 10 Lengthy movies 
select * from sakila.film order by length limit 10;

-- WHERE : filter
-- ORDER BY : SORTING
-- number of movies whose duration more than or equal to 3 hours
select title, count(title) from sakila.film where length>=180;

-- Order By
-- Films ordered by A-Z
select film_id, title from sakila.film order by title;

-- using desc
select film_id, title from sakila.film order by title desc;

-- AND Operator
-- = : search for exact match
-- LIKE : check if a string starts with, ends with, or contains something.
-- Active customers whose firstname start with 'J'
select * from sakila.customer where active=1 and first_name LIKE 'J%';

-- OR Operator
-- Films with rating 'PG' OR 'R'
select * from sakila.film where rating='PG' or rating='R';

-- IN Operator
-- Films rating with 'PG' or 'R' or 'PG-13' 
select * from sakila.film where rating in ('PG','R','PG-13');

-- NOT IN Operator
SELECT film_id, title, rating FROM sakila.film
WHERE rating NOT IN ('G', 'PG');

-- LIKE Operator
SELECT film_id, title FROM sakila.film
WHERE title LIKE '%LOVE%';

-- IS NULL Operator
SELECT customer_id, first_name, last_name, email
FROM sakila.customer WHERE email IS NULL;

-- Between Operator
SELECT film_id, title, length FROM sakila.film
WHERE length BETWEEN 90 AND 120;

-- Group by and Having clause
-- Number of flims in each rating
-- WHERE : filter rows, Cannot use aggregate functions
-- GROUP BY : Make groups, Used with aggregate functions (COUNT, SUM, AVG)
-- HAVING : Filter groups
-- Usually used with aggregate functions (COUNT, SUM, AVG)
-- group by can have having funtion
SELECT rating, COUNT(*) AS film_count FROM sakila.film GROUP BY rating;

SELECT rating, COUNT(*) AS film_count
FROM sakila.film GROUP BY rating HAVING COUNT(*) > 200;