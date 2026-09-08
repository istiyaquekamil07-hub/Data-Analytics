USE ecom;
CREATE INDEX idx_orders_city
ON orders (city);

SELECT * FROM  orders WHERE city = "Delhi";

#Composite index (Multiple column indexes)
CREATE INDEX idx_orders_city_status
ON orders(city, order_status);
SELECT * FROM  orders WHERE city = "Delhi";

#Delete index

DROP INDEX idx_orders_city ON orders;
