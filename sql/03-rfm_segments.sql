set search_path to public;

-- RFM Metrics
-- its filtered to 'Delivered', because anything else than delivered isn't counted as Revenue/complete order
WITH rfm_metrics AS (
SELECT 
	customer_id,
	DATE '2025-12-28' - MAX(order_date) AS recency,
	COUNT(DISTINCT o.order_id) AS frequency,
	SUM(oi.line_revenue) AS monetary
FROM fact_orders o
INNER JOIN fact_order_items oi 
	ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY 1
)
SELECT
	*,
	NTILE(5) OVER(ORDER BY recency DESC) AS r_score,
	NTILE(5) OVER(ORDER BY frequency) AS f_score,
	NTILE(5) OVER(ORDER BY monetary) AS m_score
FROM rfm_metrics
ORDER BY 1;

-- creating a table for RFM's scores
CREATE TABLE rfm_scores (
	customer_id INT,
	recency INT,
	frequency INT,
	monetary NUMERIC(10,2),
	r_score INT,
	f_score INT,
	m_score INT
);

-- populating the table with the previous query 
INSERT INTO rfm_scores
WITH rfm_metrics AS (
SELECT 
	customer_id,
	DATE '2025-12-28' - MAX(order_date) AS recency,
	COUNT(DISTINCT o.order_id) AS frequency,
	SUM(oi.line_revenue) AS monetary
FROM fact_orders o
INNER JOIN fact_order_items oi 
	ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY 1
)
SELECT
	*,
	NTILE(5) OVER(ORDER BY recency DESC) AS r_score,
	NTILE(5) OVER(ORDER BY frequency) AS f_score,
	NTILE(5) OVER(ORDER BY monetary) AS m_score
FROM rfm_metrics;

-- creating a view instead of a table for flexibility...
CREATE VIEW rfm_segments AS 
SELECT
	*,
	CASE
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
    WHEN r_score >= 4 AND f_score BETWEEN 2 AND 3 AND m_score >= 2 THEN 'Potential Loyalists'
    WHEN r_score <= 3 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
    ELSE 'Lost'
END AS segments
FROM rfm_scores
ORDER BY 1;


SELECT *
FROM rfm_scores














