set search_path to public;


-- min date is on 2022-01-01
-- max date is on 2025-12-28
SELECT
	MIN(order_date) AS min_date,
	MAX(order_date) AS max_date
FROM fact_orders;


-- no duplicates on fact_orders;order_id
-- its always 1 row per order on fact_orders
SELECT
	order_id,
	COUNT(*)
FROM fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- no duplicates on fact_order_items
SELECT 
	order_id,
	product_id,
	COUNT(*)
FROM fact_order_items
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- still no duplicates on fact_order items
SELECT 
	order_id,
	product_id,
	quantity,
	unit_price,
	COUNT(*)
FROM fact_order_items
GROUP BY 1,2,3,4
HAVING COUNT(*) > 1;

-- no null values in order_date
SELECT *
FROM fact_orders
WHERE order_date IS NULL;

-- no null values in revenues
SELECT *
FROM fact_order_items
WHERE line_revenue IS NULL;



-- orders table and order items table always have a matching row...
SELECT 
	*
FROM fact_orders o
LEFT JOIN fact_order_items oi 
	ON o.order_id = oi.order_id
WHERE o.order_id IS NULL;


-- segment has 4 values: bronze, silver, platinum, and gold
SELECT
	segment,
	COUNT(*)
FROM dim_customers
GROUP BY 1;


-- return are recorded at the order level using a status field in fact_orders,
-- where orders are marked as returned indicates the order has been returned...
SELECT *
FROM fact_orders
WHERE status = 'Returned';










