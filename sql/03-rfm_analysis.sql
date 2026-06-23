set search_path to public;


SELECT
	*
FROM fact_order_items;


SELECT
	return_reason,
	SUM(DISTINCT return_amount)
FROM fact_orders o
INNER JOIN fact_returns r
	ON o.order_id = r.order_id
GROUP BY 1



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
FROM rfm_metrics;

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
FROM rfm_scores;

SELECT
	segments,
	SUM(monetary)
FROM rfm_segments
GROUP BY 1
ORDER BY 2 DESC;

SELECT segments, COUNT(*) 
FROM rfm_segments 
GROUP BY 1 
ORDER BY 2 DESC;











-- Customer Distribution Rate %
SELECT 
	segments,
	COUNT(*),
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1)
FROM rfm_segments
GROUP BY 1
ORDER BY 2 DESC;

-- Churn Rate %
SELECT
	ROUND(
		SUM(CASE WHEN segments IN ('Lost', 'At Risk') THEN 1 ELSE 0 END) * 100
		/ COUNT(*),
	2) AS churn_rate
FROM rfm_segments;


-- which acquisition channel did champions was brought
SELECT 
	acquisition_channel,
	segments,
	COUNT(*)
FROM rfm_segments rs
INNER JOIN dim_customers dc
	ON dc.customer_id = rs.customer_id
WHERE segments = 'Champions'
GROUP BY 1, 2
ORDER BY 3 DESC;


-- West is the most concentrated region in terms of at risk segment at 29.7%
SELECT 	
	region_name,
	ROUND(SUM(CASE WHEN segments = 'At Risk' THEN 1 ELSE 0 END) * 100.0
	/ COUNT(DISTINCT dc.customer_id), 2) AS pct_rate
FROM rfm_segments rs
INNER JOIN dim_customers dc
	ON dc.customer_id = rs.customer_id
INNER JOIN dim_regions dr
	ON dr.region_id = dc.region_id
GROUP BY 1
ORDER BY 2 DESC;

-- gender distribution
SELECT
	gender,
	COUNT(*) AS total_count,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS gender_distribution
FROM rfm_segments s
INNER JOIN dim_customers c
	ON c.customer_id = s.customer_id
GROUP BY 1
ORDER BY 3 DESC;


-- potential loyalists have higher tenure only 15 days differential compared to champions
SELECT 
	rs.segments,
	ROUND(AVG(DATE '2025-12-31' - c.joined_date), 2) AS tenure
FROM rfm_segments rs
INNER JOIN dim_customers c
	ON rs.customer_id = c.customer_id
GROUP BY 1;

-- early tenure (3-6 months) is not a strong predictor of which segment a customer ends up with
SELECT
	CASE
		WHEN DATE '2025-12-31' - dc.joined_date < 90 THEN '0-3 Months'
		WHEN DATE '2025-12-31' - dc.joined_date < 180 THEN '3-6 Months'
		WHEN DATE '2025-12-31' - dc.joined_date < 365 THEN '6-12 Months'
		ELSE '1 year +'
	END AS tenure_buckets,
	rs.segments,
	COUNT(*) AS customer_count
FROM rfm_segments rs
INNER JOIN dim_customers dc
	ON dc.customer_id = rs.customer_id
GROUP BY 1, 2
ORDER BY 2, 3;



-- High Value Segments (Champion and Loyal Customers) have low return rates, both at 7%,
-- compared to the other 3 segments which range from 9% to 11.3%,
-- which also suggests that high spend does not come with high returns''
WITH CTE AS (
SELECT
	o.order_id,
	customer_id,
	status,
	SUM(oi.line_revenue) AS total_revenue
FROM fact_order_items oi
INNER JOIN fact_orders o
	ON oi.order_id = o.order_id
GROUP BY 1, 2, 3
)
SELECT
	rs.segments,
	COUNT(DISTINCT fr.return_id) AS total_returns,
	ROUND(COUNT(DISTINCT fr.return_id) * 100.0 / NULLIF(COUNT(DISTINCT c.order_id), 0), 2) AS return_rate,
	COUNT(DISTINCT c.order_id) AS total_orders,
	ROUND(SUM(fr.return_amount), 0) AS total_refund_amount,
	ROUND(SUM(CASE WHEN c.status = 'Delivered' THEN c.total_revenue END), 0) AS total_revenue
FROM rfm_segments rs
LEFT JOIN cte c
	ON c.customer_id = rs.customer_id
LEFT JOIN fact_returns fr
	ON fr.order_id = c.order_id
GROUP BY 1
ORDER BY 6 DESC;

-- total return amount by segment check
SELECT
	segments,
	SUM(return_amount)
FROM fact_returns r
LEFT JOIN fact_orders o
	ON o.order_id = r.order_id
LEFT JOIN rfm_segments rs
	ON rs.customer_id = o.customer_id
WHERE segments IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC








-- potential loyalist has the smallest percentage at 12.8%
-- at risk (26%) and champions (24%) has the 2 highest percentages
SELECT
	rs.segments,
	ROUND(SUM(oi.line_revenue), 0) AS total_revenue,
	ROUND(SUM(oi.line_revenue) * 100.0 / SUM(SUM(oi.line_revenue)) OVER(), 2) AS revenue_distr
FROM rfm_segments rs
LEFT JOIN fact_orders o
	ON rs.customer_id = o.customer_id
LEFT JOIN fact_order_items oi
	ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY 1
ORDER BY 2 DESC;


-- social media produces the most champions at 17%
-- all acquisition channel has near equal percentages, at 14.9% to 16.9% in all channels...
SELECT
	acquisition_channel,
	SUM(CASE WHEN segments = 'Champions' THEN 1 ELSE 0 END) AS champion_count,
	COUNT(*) AS total_customers,
	ROUND((SUM(CASE WHEN segments = 'Champions' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 1) AS pct
FROM dim_customers c 
INNER JOIN rfm_segments s
	ON c.customer_id = s.customer_id
GROUP BY 1
ORDER BY 3 DESC;


-- online has the highest share of lost customers at 33.1%
-- even though in store has the highest count of lost customers at 304 total
SELECT
	acquisition_channel,
	SUM(CASE WHEN segments = 'Lost' THEN 1 ELSE 0 END) AS lost_count,
	COUNT(*) AS total_customers,
	ROUND((SUM(CASE WHEN segments = 'Lost' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS pct
FROM dim_customers c 
INNER JOIN rfm_segments s
	ON c.customer_id = s.customer_id
GROUP BY 1
ORDER BY 4 DESC;


SELECT
	segments,
	COUNT(*) AS total_customers,
	AVG(monetary) AS avg_lifetime_spend,
	AVG(monetary / frequency) AS avg_order_value,
	AVG(frequency) AS avg_number_of_orde
FROM rfm_segments







