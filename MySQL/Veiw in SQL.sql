USE ecom;

-- CREATE VIEW del_mum_clientss AS
-- SELECT * FROM orders
-- WHERE (city="Delhi" AND order_status="Delivered")
-- OR city="Mumbai";

-- SELECT * FROM del_mum_clientss

#Creating a view
CREATE VIEW delivered_orders AS
SELECT order_id,
       customer_name,
       city,
       product,
       price_per_unit,
       order_date
FROM orders
WHERE order_status = 'Delivered';

#Viewing a view
SELECT *
FROM delivered_orders;


#Updateing a view
UPDATE delivered_orders
SET price_per_unit = price_per_unit - 500
WHERE order_id = 1;

#Delete a view.
DROP VIEW delivered_orders;
