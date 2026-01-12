# ASSIGNMENT 1

# 1. Get all customers whose first name starts with 'J' and who are active.
SELECT first_name, last_name, active FROM sakila.customer 
WHERE active=1 and first_name LIKE 'J%';
 
# 2. Find all films where the title contains the word 'ACTION' or the description contains 'WAR'.
SELECT title, description FROM sakila.film 
WHERE title LIKE '%ACTION%' OR description LIKE '%WAR%';

# 3. List all customers whose last name is not 'SMITH' and whose first name ends with 'a'.
SELECT first_name, last_name FROM sakila.customer 
WHERE last_name != 'SMITH' AND first_name LIKE '%a';

# 4. Get all films where the rental rate is greater than 3.0 and the replacement cost is not null.
SELECT title, rental_rate, replacement_cost FROM sakila.film 
WHERE rental_rate>3.0 and replacement_cost IS NOT NULL; 

# 5. Count how many customers exist in each store who have active status = 1.
SELECT store_id, COUNT(*) FROM sakila.customer 
WHERE active=1 GROUP BY store_id;

# 6. Show distinct film ratings available in the film table.
SELECT DISTINCT rating from sakila.film;

# 7. Find the number of films for each rental duration where the average length is more than 100 minutes.
SELECT rental_duration, count(*) as total_film, avg(length) as avg_length
from sakila.film where (select avg(length) as avg_length from sakila.film) > 100 
group by rental_duration; 

SELECT rental_duration,
COUNT(*) AS total_film,
AVG(length) AS avg_length
FROM sakila.film 
group by rental_duration 
HAVING AVG(length) > 100;

# 8. List payment dates and total amount paid per date, but only include days where more than 100 payments were made.

select date(payment_date), sum(amount) as total_amount, COUNT(*) AS total_payments 
from sakila.payment group by DATE(payment_date)
HAVING COUNT(*) >100
ORDER BY DATE(payment_date);

# 9. Find customers whose email address is null or ends with '.org'.
select first_name, last_name, email from sakila.customer where email is null or email like '%org';

# 10. List all films with rating 'PG' or 'G', and order them by rental rate in descending order.
select title, rating, rental_rate from sakila.film where rating='PG' or rating='G' order by rental_rate desc;

# 11. Count how many films exist for each length where the film title starts with 'T' 
-- and the count is more than 5.

select length, count(*) from sakila.film where title like 'T%' group by length having count(*) >1;

# 12. List all actors who have appeared in more than 10 films.

select a.actor_id, a.first_name, a.last_name from sakila.actor a 
where a.actor_id in (select fa.actor_id 
from sakila.film_actor fa 
group by fa.actor_id 
having count(*) >10); 

# 13. Find the top 5 films with the highest rental rates and longest lengths combined, 
-- ordering by rental rate first and length second.

select title, rental_rate, length from sakila.film order by rental_rate desc, length desc limit 5;

# 14. Show all customers along with the total number of rentals they have made, 
-- ordered from most to least rentals.

select customer_id, count(*) as total_rentals 
from sakila.rental 
group by customer_id 
order by total_rentals desc;

-- OR

select c.customer_id, c.first_name, c.last_name, count(r.rental_id) as total_rentals 
from sakila.customer c inner join sakila.rental r
on c.customer_id = r.customer_id
group by r.customer_id
order by total_rentals desc;

# 15. List the film titles that have never been rented.

select distinct title, i.film_id, r.rental_id from sakila.film f 
left join sakila.inventory i on f.film_id = i.film_id
left join sakila.rental r on i.inventory_id = r.inventory_id
where r.rental_id is null;

# 16. Find all staff members along with the total payments they have processed,  
-- ordered by total payment amount in descending order.

select s.first_name, s.last_name , sum(p.amount) as total_payments
from sakila.staff s inner join sakila.payment p
where s.staff_id = p.staff_id
group by s.first_name, s.last_name
order by total_payments desc;

select * from sakila.staff;

# 17. Show the category name along with the total number of films in each category.

select c.name, c.category_id, count(fc.film_id) as total_films
from sakila.film_category fc  
inner join sakila.category c 
on fc.category_id = c.category_id 
group by c.category_id, c.name;

# 18. List the top 3 customers who have spent the most money in total.

select c.customer_id, c.first_name, c.last_name, sum(p.amount) as total_amount
from sakila.customer c inner join sakila.payment p 
on c.customer_id = p.customer_id
group by c.customer_id, c.first_name, c.last_name
order by total_amount desc limit 3;

# 19. Find all films that were rented in the month of May (any year) 
-- and have a rental duration greater than 5 days.

select f.film_id, f.rental_duration, f.title, r.rental_date
from sakila.film f 
inner join sakila.inventory i on f.film_id = i.film_id
inner join  sakila.rental r on i.inventory_id = r.inventory_id
where monthname(rental_date)='May' and rental_duration>5;

# 20. Get the average rental rate for each film category, but only include categories 
-- with more than 50 films.

SELECT 
    c.category_id,
    c.name AS category_name,
    AVG(f.rental_rate) AS avg_rental_rate,
    COUNT(f.film_id) AS total_films
FROM sakila.category c
JOIN sakila.film_category fc 
      ON c.category_id = fc.category_id
JOIN sakila.film f 
      ON fc.film_id = f.film_id
GROUP BY 
    c.category_id,
    c.name
HAVING 
    COUNT(f.film_id) > 50;





