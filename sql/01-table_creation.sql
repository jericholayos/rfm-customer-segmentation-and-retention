CREATE TABLE dim_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(80),
    parent_category VARCHAR(80)
);

CREATE TABLE dim_regions (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(50),
    country CHAR(3)
);

CREATE TABLE dim_stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(50),
    region_id INT REFERENCES dim_regions(region_id),
    city VARCHAR(80),
    store_type VARCHAR(30),
    opened_date DATE,
    sq_footage INT,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE dim_products (
    product_id SERIAL PRIMARY KEY,
    sku VARCHAR(50),
    product_name VARCHAR(150),
    brand VARCHAR(80),
    category_id INT REFERENCES dim_categories(category_id),
    unit_price NUMERIC(10,2),
    unit_cost NUMERIC(10,2),
    weight_kg NUMERIC(6,2),
    is_active BOOLEAN DEFAULT TRUE,
    launch_date DATE
);

CREATE TABLE dim_customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(150),
    phone VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(30),
    city VARCHAR(50),
    region_id INT REFERENCES dim_regions(region_id),
    segment VARCHAR(20),
    acquisition_channel VARCHAR(40),
    joined_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    email_opt_in BOOLEAN DEFAULT FALSE
);

CREATE TABLE dim_employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(80),
    department VARCHAR(50),
    job_title VARCHAR(50),
    store_id INT REFERENCES dim_stores(store_id),
    region_id INT REFERENCES dim_regions(region_id),
    hire_date DATE,
    salary NUMERIC(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    manager_id INT REFERENCES dim_employees(employee_id)
);

CREATE TABLE fact_orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES dim_customers(customer_id),
    store_id INT REFERENCES dim_stores(store_id),
    employee_id INT REFERENCES dim_employees(employee_id),
    order_date DATE,
    ship_date DATE,
    delivery_date DATE,
    status VARCHAR(30),
    payment_method VARCHAR(30),
    shipping_method VARCHAR(30),
    discount_pct INT DEFAULT 0,
    region_id INT REFERENCES dim_regions(region_id)
);

CREATE TABLE fact_order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES fact_orders(order_id),
    product_id INT REFERENCES dim_products(product_id),
    quantity INT,
    unit_price NUMERIC(10,2),
    unit_cost NUMERIC(10,2),
    discount_amt NUMERIC(10,2) DEFAULT 0,
    line_revenue NUMERIC(10,2),
    line_cost NUMERIC(10,2),
    line_profit NUMERIC(10,2)
);

CREATE TABLE fact_returns (
    return_id SERIAL PRIMARY KEY,
    order_item_id INT REFERENCES fact_order_items(order_item_id),
    order_id INT REFERENCES fact_orders(order_id),
    product_id INT REFERENCES dim_products(product_id),
    return_date DATE,
    return_qty INT,
    return_reason VARCHAR(40),
    return_amount NUMERIC(10,2),
    restocked BOOLEAN DEFAULT FALSE
);

CREATE TABLE fact_inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES dim_products(product_id),
    store_id INT REFERENCES dim_stores(store_id),
    snapshot_date DATE,
    qty_on_hand INT DEFAULT 0,
    qty_reserved INT DEFAULT 0,
    reorder_point INT,
    reorder_qty INT
);

CREATE TABLE fact_campaigns (
    campaign_id SERIAL PRIMARY KEY,
    campaign_name VARCHAR(50),
    campaign_type VARCHAR(50),
    status VARCHAR(30),
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

CREATE TABLE fact_support_tickets (
    ticket_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES dim_customers(customer_id),
    category VARCHAR(50),
    priority VARCHAR(30),
    status VARCHAR(30),
    created_date DATE,
    resolved_date DATE,
    days_to_resolve INT,
    satisfaction_score INT,
    agent_id INT REFERENCES dim_employees(employee_id)
);