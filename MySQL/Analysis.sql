USE tbf;
SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM payments;

-- SELECT SUM(amount) AS total_revenue FROM payments;

SELECT p.product_name, SUM(oi.quantity * p.price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status ="Delivered"
GROUP BY p.product_name
ORDER BY revenue DESC;

