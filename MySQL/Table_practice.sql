CREATE TABLE customers (
customer_id INT PRIMARY KEY  AUTO_INCREMENT,
name VARCHAR(100),
email VARCHAR(100),
age INT,
phone VARCHAR(12),
is_active BOOLEAN,
signup_date DATE,
created_at DATETIME,
total_spent DECIMAL(10,2)
);

ALTER TABLE customers RENAME TO Clients;


-- DROP TABLE customers;

