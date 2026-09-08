USE ecom;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    Employee_Name VARCHAR(100) NOT NULL,
    city VARCHAR(50) UNIQUE
    );
    
--     INSERT INTO employees (Employee_Name, city)
--     VALUES('Asad', 'Asansol');