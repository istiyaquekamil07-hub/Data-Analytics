USE ecom;
-- SELECT * FROM orders 
-- WHERE payment_mode NOT IN ('Cash','UPI'); 

-- SELECT * FROM orders 
-- WHERE price_per_unit BETWEEN 2000 AND 10000;

-- SELECT * FROM orders 
-- WHERE price_per_unit NOT BETWEEN 1000 AND 10000; 

SELECT * FROM orders 
WHERE city LIKE 'A%';