-- what is database?
-- A database is a storage system that allows us to store, organize, and retrieve data easily.

-- whats database management system?  DBMS
-- A DBMS is software that helps you store, manage, and retrieve data easily from a database.
-- It is a tool that acts as a bridge between user and the database.

-- what is SQL?
-- SQL (Structured Query Language) is a language used to communicate with databases.
-- You use SQL to store, retrieve, update, and manage data in a database.

-- what is schema?
-- A schema is the structure or blueprint of a database.
-- It defines how the data is organized — tables, columns, relationships, etc.

-- sql commands - whats ddl,dml,dql, dcl, tcl
-- what is DDL 
-- Create or change the structure of the database.
-- DDL commands change the design of the database.
-- CREATE      -- make new table/database
-- ALTER       -- change table structure
-- DROP        -- delete table/database
-- TRUNCATE    -- delete all rows quickly
-- RENAME      -- rename table

-- what is DML
-- “Insert, update, or delete data inside tables.”
-- DML changes the actual data inside tables.
-- INSERT      -- add new data
-- UPDATE      -- modify existing data
-- DELETE      -- delete data

-- what is DQL
-- “Fetch data from the database.”
-- DQL is used only for retrieving (selecting) data.
-- SELECT      -- get data from tables

-- What is DCL
-- “Give or remove permissions to users.”
-- DCL manages who can access the data.
-- GRANT       -- give access
-- REVOKE      -- remove access

-- what is TCL
-- “Manage transactions (save or undo changes).”
-- Used after INSERT / UPDATE / DELETE to save or undo.
-- COMMIT       -- save changes permanently
-- ROLLBACK     -- undo changes
-- SAVEPOINT    -- mark a point to rollback to

# create a database
CREATE DATABASE company_db;

# Creating Tables
# CHAR : strings
# VARCHAR : strings + numbers
CREATE TABLE company_db.employees(id INT, name varchar(100));

select id from company_db.employees;

# INSERT values into the table
INSERT INTO company_db.employees(id, name) VALUES (1, 'Sahana');

select * from company_db.employees;

#Alter table

ALTER TABLE company_db.employees ADD (Email varchar(100));
ALTER TABLE company_db.employees RENAME COLUMN Email to email_id;

# SQL constraints are used to specify rules for data in a table.
# not null and  unique constraints 
drop table if exists company_db.Persons;

-- NOT NULL means the column cannot be empty.
-- UNIQUE means all values in that column must be different.
-- id INT PRIMARY KEY	Unique identifier (main key)
-- email UNIQUE	No 2 people share the same email
-- last_name NOT NULL	Cannot be empty
-- phone_number UNIQUE	No two people should share a number
-- age	Can be NULL (optional)

CREATE TABLE company_db.persons ( ID int NOT NULL unique,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Age int);
    
SELECT * FROM company_db.Persons;

INSERT INTO  company_db.Persons (ID, LastName, FirstName, Age)
VALUES (1, 'Smith', 'John', 30);

INSERT INTO  company_db.Persons (ID, LastName, FirstName, Age)
VALUES (2, 'Doe', NULL, NULL);  -- NULLs allowed for FirstName and Age

-- This will FAIL because ID = 1 already exists
INSERT INTO  company_db.Persons (ID, LastName, FirstName, Age)
VALUES (1, 'Brown', 'Charlie', 25);

-- This will FAIL because LastName is NOT NULL
INSERT INTO company_db.Persons (ID, LastName, FirstName, Age)
VALUES (3, null, 'Alice', 28);

#PRIMARY KEY 

ALTER TABLE  company_db.Persons
ADD PRIMARY KEY (ID);

-- AND CONSTRAINT_TYPE = 'PRIMARY KEY';-- 
-- information_schema is a special system database in MySQL.
-- It does not store your data, it stores metadata (information about your data).
-- The table TABLE_CONSTRAINTS contains one row per constraint on each table.
-- This table tells you what constraints (PRIMARY KEY, UNIQUE, FOREIGN KEY, etc.) exist on each table in all databases.
SELECT CONSTRAINT_NAME
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'company_db'
AND TABLE_NAME = 'persons';

ALTER TABLE company_db.Persons
DROP  PRIMARY key ;

-- “Modify the Persons table and add a primary key constraint named PK_Person on the ID column.”
ALTER TABLE company_db.Persons
ADD CONSTRAINT PK_Person PRIMARY KEY (ID);

#Foregin KEY
-- A FOREIGN KEY is a field (or collection of fields) in one table, that refers to the PRIMARY KEY in another table.
-- The table with the foreign key is called the child table, and the table with the primary key is called the referenced or parent table.

CREATE TABLE company_db.Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    PersonID INT,
    FOREIGN KEY (PersonID) REFERENCES Persons(ID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO company_db.Orders (OrderID, OrderDate, PersonID)
VALUES (1001, '2024-06-10', 1);

SELECT * FROM company_db.Orders;
SeLECT * FROM company_db.persons;
INSERT INTO company_db.Orders (OrderID, OrderDate, PersonID)
VALUES (1002, '2024-06-11', 999);  -- PersonID 999 doesn't exist

-- RESTRICT
-- This tells MySQL what to do if someone tries to delete a person from the Persons table who has orders in Orders.
DELETE FROM company_db.Persons WHERE ID = 1;

-- ON UPDATE CASCADE
-- This tells MySQL what to do if the ID of a person in Persons is updated/changed.
-- “If the ID in Persons changes, automatically update the PersonID in Orders also.
select * FROM company_db.persons;
SELECT * FROM company_db.Orders;

UPDATE company_db.Persons SET ID = 4 WHERE ID = 1;

-- CHECK is a rule that makes sure the value in a column satisfies a condition.
#check and default 
CREATE TABLE company_db.employee_new (
    ID int NOT NULL ,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Age int  CHECK (Age>=18),
	city varchar(255) DEFAULT 'new york'
);

SELECT * FROM company_db.employee_new;

INSERT INTO company_db.employee_new (ID, LastName, FirstName, Age,city)
VALUES (4, 'joey', 'tribiani', 21, 'texas');

# Difference between drop and delete 
-- drop : whole table will be droped
-- delete : only the data inside the table will  be deleted
select * FROM company_db.employees;

SET SQL_SAFE_UPDATES = 0;
DELETE from company_db.employees where id = 1; 

DROP TABLE company_db.employees;
DROP TABLE  company_db.employee_new;

-- DELETE : Removes selected rows
-- TRUNCATE : Removes all rows at once
truncate TABLE company_db.employees;

DROP TABLE company_db.persons;
DROP TABLE company_db.Orders;

drop database company_db;
