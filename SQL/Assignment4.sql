# 1. Identify if there are duplicates in Customer table. 
-- Don't use customer id to check the duplicates

select first_name, last_name, email from sakila.customer 
group by first_name, last_name, email 
having count(*) >1;

# 2. Number of times letter 'a' is repeated in film descriptions
select description from sakila.film;
select (sum(length(description) - length(replace(lower(description), 'a', '')))) as no_of_as from sakila.film;




# 1. List all customers along with the films they have rented.

select c.customer_id, c.first_name, c.last_name, r.rental_id, f.title from sakila.customer c 
join sakila.rental r on c.customer_id=r.customer_id 
join sakila.inventory i on r.inventory_id = i.inventory_id
join sakila.film f on f.film_id = i.film_id order by customer_id;

# 2. List all customers and show their rental count, 
-- including those who haven't rented any films.

select c.first_name, c.last_name, count(r.rental_id) from sakila.customer c 
left join sakila.rental r on c.customer_id = r.customer_id
group by  c.first_name, c.last_name; 

# 3. Show all films along with their category. Include films that don't have a 
-- category assigned.
select f.title, fc.category_id, c.name from sakila.film f 
left join sakila.film_category fc on f.film_id = fc.film_id 
left join sakila.category c on fc.category_id = c.category_id;

# 4. Show all customers and staff emails from both customer and staff tables 
-- using a full outer join (simulate using LEFT + RIGHT + UNION).

select c.email as customer_email, s.email as staff_email from sakila.customer c 
left join sakila.staff s on c.email = s.email
union
select c.email as customer_email, s.email as staff_email from sakila.customer c 
right join sakila.staff s on c.email = s.email;

# 5. Find all actors who acted in the film "ACADEMY DINOSAUR".
select a.first_name, a.last_name, a.actor_id, f.title from sakila.actor a 
join sakila.film_actor fa on a.actor_id = fa.actor_id
join sakila.film f on fa.film_id = f.film_id where f.title = 'ACADEMY DINOSAUR';

# 6. List all stores and the total number of staff members working in each store, 
-- even if a store has no staff.

select s.store_id, count(ss.staff_id) as total_staff from sakila.store s 
left join sakila.staff ss on s.store_id = ss.store_id 
group by s.store_id;

# 7. List the customers who have rented films more than 5 times. 
-- Include their name and total rental count.
select c.first_name, c.last_name, count(rental_id) as rental_count
from sakila.customer c join sakila.rental r on c.customer_id = r.customer_id
group by  c.first_name, c.last_name
having count(*)>5;


