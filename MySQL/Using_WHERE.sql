-- SELECT * FROM  orders WHERE discount_percent >20;

-- SELECT customer_name, city, discount_percent FROM orders WHERE discount_percent <20

-- SELECT * FROM orders WHERE delivery_date IS NULL;

-- SELECT * FROM orders WHERE city = 'Delhi' or order_status = 'Delivered';

-- SELECT * FROM orders WHERE city = 'Delhi' and order_status = 'Delivered';

SELECT customer_name, order_date, price_per_unit FROM orders ORDER BY order_date DESC;