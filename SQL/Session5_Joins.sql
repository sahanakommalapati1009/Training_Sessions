CREATE DATABASE practice_joins;
USE practice_joins;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50)
);

CREATE TABLE orders (
    order_id    INT PRIMARY KEY,
    customer_id INT NULL,
    order_date  DATE,
    amount      DECIMAL(10,2)
    -- Note: no FOREIGN KEY on purpose so we can have "orphan" rows for join practice
);

INSERT INTO customers (customer_id, first_name, last_name) VALUES
(1, 'Alice',   'Smith'),
(2, 'Bob',     'Johnson'),
(3, 'Charlie', 'Brown'),
(4, 'Diana',   'Lopez');   -- Diana will have NO orders (for LEFT JOIN practice)

INSERT INTO orders (order_id, customer_id, order_date, amount) VALUES
(101, 1, '2025-01-10', 50.00),   -- belongs to Alice
(102, 1, '2025-01-15', 75.00),   -- belongs to Alice
(103, 2, '2025-02-01', 20.00),   -- belongs to Bob
(104, NULL, '2025-02-05', 60.00),-- order with NO customer (for RIGHT/OUTER behavior)
(105, 5, '2025-02-10', 90.00);   -- customer_id 5 does NOT exist (for RIGHT/OUTER behavior)

select * from customers;
select * from  orders;

-- left join: A and B, A values + common values in A and B
-- Right Join: B values + common values in A and B
-- left outer join: A values -  common values of A and B values
-- right outer join: B values - common values of A and B values
-- Full Inner Join: common values
-- Full Outer join: without common values
-- Full join : Everything

-- Inner Join

SELECT c.customer_id, c.first_name, o.order_id, o.amount
FROM customers c INNER JOIN orders o ON c.customer_id = o.customer_id;

-- Left Join

SELECT c.customer_id, c.first_name, o.order_id, o.amount
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Right Join

SELECT c.customer_id, c.first_name, o.order_id, o.customer_id AS order_customer_id, o.amount
FROM customers c RIGHT JOIN orders o ON c.customer_id = o.customer_id;

SELECT c.customer_id, c.first_name, o.order_id, o.amount
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
UNION
SELECT c.customer_id, c.first_name, o.order_id, o.amount
FROM customers c RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- cross join
SELECT c.customer_id, c.first_name, o.order_id, o.amount
FROM customers c CROSS JOIN orders o;

-- Left Outer Join
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE o.order_id IS NULL;

-- Right Outer Join
select o.order_id,o.order_date,o.amount from customers c right join orders o 
on c.customer_id=o.customer_id where o.customer_id is null;

-- self join
SELECT c1.customer_id AS customer_1, c1.first_name  AS name_1, c2.customer_id AS customer_2, c2.first_name  AS name_2
FROM customers c1 JOIN customers c2 ON c1.customer_id <> c2.customer_id;