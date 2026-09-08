-- USE ecom;

-- UPDATE orders SET seller_id=NULL WHERE order_id IN (11,12,13,14,15);

-- SELECT * FROM orders;

#INNER_JOIN

-- SELECT 
-- o.order_id, o.product, o.city As customer_city,  #selecting desired feilds from both tables.
-- s.seller_name, s.city AS seller_city

-- FROM orders o #consider orders table as o
-- INNER JOIN sellers s #consider sellers table as s
-- ON o.seller_id = s.seller_id # connecting  with common value in both table

#LEFT_JOIN
SELECT 
    o.order_id,
    o.product,
    s.seller_name
FROM orders o
LEFT JOIN sellers s
ON o.seller_id = s.seller_id;

#Right Join
SELECT 
    s.seller_name,
    o.order_id,
    o.product
FROM orders o
RIGHT JOIN sellers s
ON o.seller_id = s.seller_id;




