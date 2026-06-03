
--orders table
CREATE TABLE IF NOT EXISTS VP_bronze_orders(
order_id int,
customer_id int,
order_date DATE,
order_status VARCHAR(30),
total_amount DECIMAL(10,2),
payment_method VARCHAR(30),
created_at TIMESTAMP,

ingestion_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
source_file VARCHAR(255),
row_hash VARCHAR(64)
);
---------------------------------------------------------------------

--customers table
CREATE TABLE IF NOT EXISTS VP_bronze_customers (
    customer_id INT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    customer_segment VARCHAR(20),
    last_updated TIMESTAMP,

    ingestion_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    row_hash VARCHAR(64)
);


------------------------------------------------------------------------

--products table
CREATE TABLE IF NOT EXISTS VP_bronze_products (
    product_id INT,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10,2),
    cost DECIMAL(10,2),
    supplier_id INT,
    last_updated TIMESTAMP,

    ingestion_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    row_hash VARCHAR(64)
);

---------------------------------------------------------------------------------------

--order items tble
CREATE TABLE IF NOT EXISTS VP_bronze_order_items (
    order_item_id INT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    discount_percent DECIMAL(5,2),

    ingestion_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    row_hash VARCHAR(64)
);
-----------------------------------------------------------------------------------------

