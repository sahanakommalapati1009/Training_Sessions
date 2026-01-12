-- Subqueries
-- I need the result of one query to use in another query.
-- You need to compare a value to an aggregate (AVG, MAX, MIN)

-- Type 1.Single Row Subquery (Returns one value)
-- example: max, min, avg
-- Films longer than the average length
select length from sakila.film;
select avg(length) from sakila.film;
select title, length from sakila.film where length>(select avg(length) from sakila.film);

-- Type 2.Multiple Row Subquery (Returns multiple rows)
-- Get all customers who have made at least one payment.
select customer_id from sakila.payment;
select first_name, last_name, customer_id from sakila.customer where customer_id in (select customer_id from sakila.payment);

-- Type 3.Multiple-Column Subquery (Returns multiple columns at once)
-- Films with same rental_rate AND length as another film
select title, rental_rate, length from sakila.film where (rental_rate, length) in 
(select rental_rate, length from sakila.film 
group by rental_rate, length 
having count(*)>1);

-- Type 4.Correlated subquery (Inner query depends on the outer query -> runs once per row.)
-- Get all rentals whose amount is greater than the average payment amount for that customer.

select rental_id, customer_id, amount from sakila.payment where amount > (select avg(amount) from sakila.payment);
SELECT p.rental_id,
       p.customer_id,
       p.amount
FROM sakila.payment p
WHERE p.amount > (
    SELECT AVG(p2.amount)
    FROM sakila.payment p2
    WHERE p2.customer_id = p.customer_id
);

SELECT r.rental_id,
       r.customer_id,
       p.amount
FROM sakila.rental r
JOIN sakila.payment p ON r.rental_id = p.rental_id
WHERE p.amount > (
    SELECT AVG(p2.amount)
    FROM sakila.payment p2
    WHERE p2.customer_id = r.customer_id
);

-- Customers who made more than 5 rentals

SELECT c.customer_id, c.first_name
FROM customer c
WHERE (
    SELECT COUNT(*)
    FROM rental r
    WHERE r.customer_id = c.customer_id
) > 5;



select customer_id from sakila.rental; 
select c.first_name, c.last_name, c.customer_id from customer c where customer_id in
(select customer_id from sakila.rental group by customer_id having count(*)>5);

-- Type 5.Subquery in SELECT Clause
-- Add total payments for each customer
select customer_id from sakila.payment;

select c.first_name, c.last_name, (select sum(amount) from sakila.payment p where p.customer_id = c.customer_id) as total_sum from sakila.customer c;

-- Type 6.Subquery in FROM Clause (Inline View / Derived Table)
-- Find avg payment per customer Inline View
select customer_id, avg_amount from (select customer_id, avg(amount) as avg_amount from sakila.payment group by customer_id) as t;

-- Type 7.EXISTS / NOT EXISTS Subquery
-- Customers who have never rented a movie

select customer_id from sakila.customer where NOT EXISTS(select DISTINCT customer_id from sakila.rental);


select title, length, (select avg(length) from sakila.film) as avg_length from sakila.film where length>(select avg(length) from sakila.film);