set search_path to public;


-- Total Revenue and Profit by Month
SELECT 
	TO_CHAR(DATE_TRUNC('month', order_date)::date, 'YYYY-MM') AS months,
	SUM(line_revenue) AS total_revenue,
	SUM(unit_cost) AS total_cost,
	SUM(line_profit) AS total_profit
FROM fact_orders o
INNER JOIN fact_order_items oi
	ON o.order_id = oi.order_id
WHERE o.status  = 'Delivered'
GROUP BY 1
ORDER BY 1;

-- Revenue by Region and Store
SELECT 
	store_name,
	region_name,
	SUM(line_revenue) AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_orders
FROM fact_orders o
INNER JOIN fact_order_items oi
	ON o.order_id = oi.order_id
INNER JOIN dim_stores ds
	ON ds.store_id = o.store_id
INNER JOIN dim_regions dr
	ON dr.region_id = ds.region_id
WHERE o.status = 'Delivered'
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Month-over-Month Revenue Growth
WITH current AS (
SELECT 
	TO_CHAR(DATE_TRUNC('Month', order_date)::DATE, 'YYYY-MM') AS months,
	SUM(line_revenue) AS current_revenue
FROM fact_orders o
INNER JOIN fact_order_items oi 
	ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY 1
),
previous AS (
SELECT
	months,
	current_revenue,
	LAG(current_revenue) OVER(ORDER BY months) AS previous_revenue
FROM current
)
SELECT
	*,
	ROUND((current_revenue - previous_revenue) / NULLIF(previous_revenue, 0) * 100.0, 2) AS mom_growth
FROM previous;

--Year-over-Year Comparison
WITH cte AS (
SELECT
	EXTRACT(MONTH FROM order_date) AS months,
	EXTRACT(YEAR FROM order_date) AS years,
	SUM(line_revenue) AS revenue
FROM fact_orders o
INNER JOIN fact_order_items oi 
	ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY 1, 2
)
SELECT
	months,
	SUM(CASE WHEN years = 2023 THEN revenue ELSE 0 END) AS "2023",
	SUM(CASE WHEN years = 2024 THEN revenue ELSE 0 END) AS "2024",
	SUM(CASE WHEN years = 2025 THEN revenue ELSE 0 END) AS "2025"
FROM cte
GROUP BY 1
ORDER BY 1;

-- Rolling 12-Month Revenue
WITH CTE AS (
SELECT
	DATE_TRUNC('month', order_date) AS month_date,
	SUM(oi.line_revenue) AS total_revenue
FROM fact_orders o
INNER JOIN fact_order_items oi 
	ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY 1
)
SELECT 
	TO_CHAR(month_date, 'YYYY-MM') AS month,
	total_revenue,
	SUM(total_revenue) OVER(
	ORDER BY month_date 
	ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
	) AS rolling_12_month_sum 
FROM cte
ORDER BY month_date;


SELECT
	e.employee_id,
	CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
	COALESCE(NULLIF(TRIM(CONCAT(m.first_name, ' ', m.last_name)), ''), 'N/A') AS manager_name
FROM dim_employees e
LEFT JOIN dim_employees m
	ON e.manager_id = m.employee_id;



-- Rank Stores by Revenue Within Each Region 
WITH CTE AS (
SELECT
	ds.store_name,
	dr.region_name,
	SUM(oi.line_revenue) AS total_revenue,
	RANK() OVER(PARTITION BY region_name ORDER BY SUM(oi.line_revenue) DESC) AS rnk	
FROM fact_orders o
INNER JOIN fact_order_items oi 
	ON oi.order_id = o.order_id
INNER JOIN dim_stores ds
	ON ds.store_id = o.store_id
INNER JOIN dim_regions dr
	ON dr.region_id = ds.region_id
GROUP BY 1, 2
)
SELECT
	store_name,
	region_name,
	total_revenue
FROM cte
WHERE rnk <= 1;


-- Revenue Lost to Discounts by Month
WITH CTE AS (
SELECT
	TO_CHAR(DATE_TRUNC('month', o.order_date)::DATE, 'YYYY-MM') AS months,
	SUM(oi.unit_price * oi.quantity) AS full_price,
	SUM(oi.line_revenue) AS total_revenue,
	SUM(oi.unit_price * oi.quantity) - SUM(oi.line_revenue) AS discount_loss
FROM fact_order_items oi
INNER JOIN fact_orders o
	ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY 1
)
SELECT
	*,
	ROUND(discount_loss / full_price * 100.0, 2) AS pct
FROM cte
ORDER BY 1;

-- Profit Margin by Tier
SELECT
	CASE
		WHEN discount_pct = 0 THEN '0%'
		WHEN discount_pct <= 10 THEN '1-10%'
		WHEN discount_pct <= 20 THEN '11-20%'
		ELSE '21+%'
	END AS discount_segment,
	COUNT(DISTINCT o.order_id) AS number_of_orders,	
	ROUND(SUM(oi.line_revenue) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value,
	SUM( oi.line_profit) AS total_profit,
	ROUND(SUM(oi.line_profit) / SUM(oi.line_revenue) * 100, 2) AS profit_margin
FROM fact_orders o
INNER JOIN fact_order_items oi
	ON oi.order_id = o.order_id
GROUP BY 1;




WITH metrics AS (
SELECT
	store_name,
	region_name,
	SUM(oi.line_revenue) AS total_revenue,
	SUM(oi.line_profit) AS total_profit,
	ROUND(SUM(oi.line_profit) / SUM(oi.line_revenue) * 100, 2) AS profit_margin,
	COUNT(DISTINCT o.order_id) AS number_of_orders,
	ROUND(SUM(oi.line_revenue) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM fact_orders o
INNER JOIN fact_order_items oi 
	ON oi.order_id = o.order_id
INNER JOIN dim_regions r
	ON r.region_id = o.region_id
INNER JOIN dim_stores s
	ON s.store_id = o.store_id
GROUP BY 1, 2
),
region_rank AS (
SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY region_name ORDER BY total_revenue DESC) AS rn
FROM metrics
)
SELECT
	store_name,
	region_name,
	total_revenue,
	total_profit,
	profit_margin,
	number_of_orders,
	avg_order_value,
	CASE
		WHEN rn = 1 THEN 'Top Performer'
		WHEN rn <= 3 THEN 'Strong'
		ELSE 'Average'
	END AS performance_label
FROM region_rank
ORDER BY 2, 3 DESC

	





