CREATE TABLE dim_categories (
	category_id SERIAL PRIMARY KEY,
	category_name VARCHAR(80) NOT NULL UNIQUE,
	parent_category VARCHAR(80) DEFAULT NULL
);


CREATE TABLE dim_regions (
	region_id SERIAL PRIMARY KEY,
	region_name VARCHAR(50) NOT NULL,
	country CHAR(3) NOT NULL
);


CREATE TABLE dim_stores (
	store_id SERIAL PRIMARY KEY,
	store_name VARCHAR(50) NOT NULL,
	region_id INT NOT NULL REFERENCES dim_regions(region_id),
	city VARCHAR(80),
	store_type VARCHAR(30),
	opened_date DATE,
	sq_footage INT,
	is_active BOOLEAN NOT NULL DEFAULT TRUE
);


CREATE TABLE dim_products (
	product_id SERIAL PRIMARY KEY,
	sku VARCHAR(50) NOT NULL UNIQUE,
	product_name VARCHAR(150) NOT NULL,
	brand VARCHAR(80),
	category_id INT NOT NULL REFERENCES dim_categories(category_id),
	unit_price NUMERIC(10,2) NOT NULL CHECK(unit_price >= 0),
	unit_cost NUMERIC(10,2) NOT NULL CHECK (unit_cost >= 0),
	weight_kg NUMERIC(6,2),
	is_active BOOLEAN NOT NULL DEFAULT TRUE,
	launch_date DATE
);

CREATE TABLE dim_customers(
	customer_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(150) NOT NULL UNIQUE,
	phone VARCHAR(50),
	date_of_birth DATE,
	gender VARCHAR(30),
	city VARCHAR(50),
	region_id INT REFERENCES dim_regions(region_id),
	segment VARCHAR(20) CHECK(SEGMENT IN('Bronze', 'Silver', 'Gold', 'Platinum')),
	acquisition_channel VARCHAR(40),
	joined_date DATE,
	is_active BOOLEAN NOT NULL DEFAULT TRUE,
	email_opt_in BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE dim_employees(
	employee_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(80) NOT NULL UNIQUE,
	department VARCHAR(50),
	job_title VARCHAR(50),
	store_id INT REFERENCES dim_stores(store_id),
	region_id INT REFERENCES dim_regions(region_id),
	hire_date DATE,
	salary NUMERIC(10,2) CHECK(salary >= 0),
	is_active BOOLEAN NOT NULL DEFAULT TRUE,
	manager_id INT REFERENCES dim_employees(employee_id)
);


CREATE TABLE fact_orders(
	order_id SERIAL PRIMARY KEY,
	customer_id INT NOT NULL REFERENCES dim_customers(customer_id),
	store_id INT NOT NULL REFERENCES dim_stores(store_id),
	employee_id INT NOT NULL REFERENCES dim_employees(employee_id),
	order_date DATE,
	ship_date DATE,
	delivery_date DATE,
	status VARCHAR(30) NOT NULL 
		CHECK(status 
			IN('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned')),
	payment_method VARCHAR(30),
	shipping_method VARCHAR(30),
	discount_pct INT DEFAULT 0 CHECK(discount_pct BETWEEN 0 AND 100),
	region_id INT REFERENCES dim_regions(region_id)
);


CREATE TABLE fact_order_items(
	order_item_id SERIAL PRIMARY KEY,
	order_id INT NOT NULL REFERENCES fact_orders(order_id) ON DELETE CASCADE,
	product_id INT NOT NULL REFERENCES dim_products(product_id),
	quantity INT NOT NULL CHECK(quantity > 0),
	unit_price NUMERIC(10,2) NOT NULL,
	unit_cost NUMERIC(10,2) NOT NULL,
	discount_amt NUMERIC(10,2) NOT NULL DEFAULT 0,
	line_revenue NUMERIC(10,2) NOT NULL,
	line_cost NUMERIC(10,2) NOT NULL,
	line_profit NUMERIC(10,2) NOT NULL
);

CREATE TABLE fact_returns(
	return_id SERIAL PRIMARY KEY,
	order_item_id INT REFERENCES fact_order_items(order_item_id),
	order_id INT NOT NULL REFERENCES fact_orders(order_id),
	product_id INT NOT NULL REFERENCES dim_products(product_id),
	return_date DATE NOT NULL,
	return_qty INT NOT NULL CHECK(return_qty > 0),
	return_reason VARCHAR(40),
	return_amount NUMERIC(10,2),
	restocked BOOLEAN NOT NULL DEFAULT FALSE
);


CREATE TABLE fact_inventory(
	inventory_id SERIAL PRIMARY KEY,
	product_id INT NOT NULL REFERENCES dim_products(product_id),
	store_id INT NOT NULL REFERENCES dim_stores(store_id),
	snapshot_date DATE NOT NULL,
	qty_on_hand INT NOT NULL DEFAULT 0,
	qty_reserved INT NOT NULL DEFAULT 0,
	reorder_point INT,
	reorder_qty INT
);


CREATE TABLE fact_campaigns(
	campaign_id SERIAL PRIMARY KEY,
	campaign_name VARCHAR(50) NOT NULL,
	campaign_type VARCHAR(50),
	status VARCHAR(30) CHECK(status IN('Planned', 'Active', 'Completed', 'Paused', 'Cancelled')),
	start_date DATE,
	end_date DATE,
	budget NUMERIC(12,2),
	actual_spend NUMERIC(12,2) DEFAULT 0,
	target_region_id INT REFERENCES dim_regions(region_id),
	target_segment VARCHAR(50),
	impressions BIGINT DEFAULT 0,
	clicks INT DEFAULT 0,
	conversions INT DEFAULT 0
);


CREATE TABLE fact_support_tickets(
	ticket_id SERIAL PRIMARY KEY,
	customer_id INT NOT NULL REFERENCES dim_customers(customer_id),
	category VARCHAR(50),
	priority VARCHAR(30) CHECK(priority IN('Low', 'Medium', 'High', 'Critical')) ,
	status VARCHAR(30) CHECK(status IN('Open', 'In Progress', 'Resolved', 'Closed', 'Escalated')) ,
	created_date DATE,
	resolved_date DATE,
	days_to_resolve INT CHECK(days_to_resolve >= 0),
	satisfaction_score INT CHECK(satisfaction_score BETWEEN 1 AND 5),
	agent_id INT REFERENCES dim_employees(employee_id)
);












