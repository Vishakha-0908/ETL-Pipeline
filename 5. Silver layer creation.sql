

-- customers table


CREATE TABLE IF NOT EXISTS VP_silver_customers (
    customer_key INT PRIMARY KEY IDENTITY(1,1), 
    customer_id INT NOT NULL,                     
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    customer_segment VARCHAR(20),
    
    effective_from_date DATE NOT NULL,
    effective_to_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    row_hash VARCHAR(64) NOT NULL,
    
    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_timestamp TIMESTAMP
);
----------------------------------------------------------------

--products table
CREATE TABLE IF NOT EXISTS VP_silver_products (
    product_key INT PRIMARY KEY IDENTITY,  
    product_id INT NOT NULL,        
    
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10,2),
    cost DECIMAL(10,2),
    supplier_id INT,

    effective_from_date DATE NOT NULL,
    effective_to_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    row_hash VARCHAR(64) NOT NULL,

    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_timestamp TIMESTAMP
);
-------------------------------------------------------------

--orders table

CREATE TABLE IF NOT EXISTS VP_silver_orders (

    order_sk INT IDENTITY(1,1) PRIMARY KEY,   -- surrogate key

    order_id INT NOT NULL,        -- business key
    customer_key INT,
    order_date DATE,

    status_key INT,
    order_status VARCHAR(20),

    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    created_at TIMESTAMP,

    effective_from_timestamp TIMESTAMP NOT NULL,
    effective_to_timestamp TIMESTAMP NOT NULL,
    is_current BOOLEAN NOT NULL,
    row_hash VARCHAR(64) NOT NULL,

    processed_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_key)
        REFERENCES VP_silver_customers(customer_key)
);



-------------------------------------------------------------------

-- order items table
CREATE TABLE IF NOT EXISTS VP_silver_order_items (
    order_item_id INT PRIMARY KEY,
    
    order_sk INT NOT NULL,
    product_key INT,

    quantity INT,
    unit_price DECIMAL(10,2),
    discount_percent DECIMAL(5,2),
    line_total DECIMAL(10,2),
   
    processed_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_orderitems_product
        FOREIGN KEY (product_key)
        REFERENCES VP_silver_products(product_key),

    CONSTRAINT fk_orderitems_orders
        FOREIGN KEY(order_sk)
        REFERENCES VP_silver_orders (order_sk)
    
);
------------------------------------------------------------
-- ORDER_STATUS TABLE

CREATE TABLE IF NOT EXISTS VP_order_status (
    status_key INT PRIMARY KEY,                 
    status_name VARCHAR(50)                           
);


INSERT INTO VP_order_status (status_key, status_name)
SELECT *
FROM VALUES
    (-1, 'UNKNOWN'),
    (1,  'NEW'),
    (2,  'PROCESSING'),
    (3,  'SHIPPED'),
    (4,  'DELIVERED'),
    (5,  'CANCELLED'),
    (6,  'RETURN')
AS src(status_key, status_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM VP_order_status tgt
    WHERE tgt.status_key = src.status_key
);


    -- select * from VP_order_status;
    -- drop table vp_order_status;

------------------------------------------------------------------------


