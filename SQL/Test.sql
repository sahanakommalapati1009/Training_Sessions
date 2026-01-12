-- using temp table store customers  with more than 20 rentals and list there total paid

select first_name, last_name from sakila.customer;
select rental_id from sakila.rental r join sakila.customer c on r.customer_id=c.customer_id;
select sum(amount) as total_amount from sakila.payment;

-- find films that are avialable in one store not in another store
select title from sakila.film;

select film_id, store_id from sakila.inventory;
select store_id from sakila.store;

# join film and inventory
# join film and store

select f.title, f.film_id, i.store_id 
from sakila.film f join sakila.inventory i1 
on f.film_id = i1.film_id 
join sakila.store s on s.store_id = f.store_id
where f.film_id not in s.store_id;

SELECT DISTINCT f.film_id, f.title FROM film f

JOIN inventory i1 ON f.film_id = i1.film_id

WHERE i1.store_id = 1

  AND f.film_id NOT IN (

        SELECT film_id FROM inventory

        WHERE store_id = 2

  );
  
# show film title and their replacement cost categorised as high medium and low, where RC>20 high, RCin between 10 to 20, RC less than 10 low

select title, replacement_cost, 
case when replacement_cost>20 then 'HIGH' 
when replacement_cost between 10 and 20 then 'MEDIUM'
else 'LOW' end as replacement_cost from sakila.film;

# using cte show the average rental duration and list films that are longer than average rental duration
select title, rental_duration from sakila.film where rental_duration > (select avg(rental_duration) as avg_rental from sakila.film);

select avg(rental_duration) as avg_rental from sakila.film;

# show the 10 longest films that have been never rented

select distinct f.title, f.length, i.film_id, r.rental_id from sakila.film f 
left join sakila.inventory i on f.film_id = i.film_id
left join sakila.rental r on i.inventory_id = r.inventory_id
where r.rental_id is null
order by length desc
limit 10;

# find the customers who have rented the film more than once

select first_name, last_name, rental_id, count(rental_id) as total_rentals from sakila.customer c 
inner join sakila.rental r on c.customer_id = r.customer_id
group by rental_id;

select rental_id, count(*) from sakila.rental group by rental_id;

# list all the actors whose first_name and last name satrts with the same letter using wild card

select first_name, last_name from sakila.actor
where left(first_name,1) = left(last_name,1);

# OR

SELECT 
    actor_id,
    first_name,
    last_name
FROM sakila.actor
WHERE first_name LIKE CONCAT(LEFT(last_name, 1), '%');

-- count rentals per week day and then show whoch weekday prints the highest revenue

select dayname(rental_date) as rental_day, count(rental_id) from sakila.rental group by dayname(rental_date);

