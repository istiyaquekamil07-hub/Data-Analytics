use ecom;
SELECT city, COUNT(*) AS total_orders
FROM orders
GROUP BY city;

#
SELECT category, COUNT(*) AS total_orders, SUM(quantity * price_per_unit) AS total_sales
FROM orders
GROUP BY category;

#Two group by
SELECT city, order_status, COUNT(*) AS Count
FROM orders
GROUP BY city, order_status;

