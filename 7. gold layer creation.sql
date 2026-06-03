-- 1. gold_daily_sales_summary

CREATE TABLE IF NOT EXISTS VP_gold_daily_sales_summary (
    order_date DATE,

    total_orders INT,
    total_revenue DECIMAL(10,2),
    
    total_units_sold NUMBER,
    avg_order_value NUMBER(18,4),
    
    cancelled_orders INT,
    cancellation_rate NUMBER(10,3)
);

-------------------------------------------------------------------------------------

--2. gold_customer_lifetime_value
CREATE TABLE IF NOT EXISTS VP_gold_customer_lifetime_value (

    customer_id INT PRIMARY KEY,

    first_order_date DATE,
    last_order_date DATE,

    total_orders INT,
    total_revenue DECIMAL(18,2),
    total_profit DECIMAL(18,2),
    avg_order_value DECIMAL(18,2),

    customer_segment VARCHAR(20),

    is_active BOOLEAN,

    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table VP_gold_customer_lifetime_value;

-----------------------------------------------------------------------------------

-- gold_product_performance

CREATE TABLE IF NOT EXISTS VP_gold_product_performance (
    
    product_id STRING NOT NULL,
    product_name STRING,
    category STRING,

    total_orders NUMBER(18,0),
    total_units_sold NUMBER(18,2),

    total_revenue NUMBER(18,4),
    total_profit NUMBER(18,4),

    profit_margin NUMBER(10,4),
    avg_price NUMBER(18,4),

    last_updated_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_product PRIMARY KEY (product_id)
);


drop table VP_gold_product_performance;
-----------------------------------------------------------------------------------------------

--gold_customer_segment_trends

CREATE TABLE IF NOT EXISTS VP_gold_customer_segment_trends (

    snapshot_date DATE NOT NULL,
    customer_segment VARCHAR(20) NOT NULL,

    active_customers INT,
    new_customers INT,
    churned_customers INT,

    total_revenue DECIMAL(18,2),
    avg_revenue_per_customer DECIMAL(18,2),

    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (snapshot_date, customer_segment)
);
































