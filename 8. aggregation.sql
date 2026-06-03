-- 1. VP_gold_daily_sales_summary

MERGE INTO VP_gold_daily_sales_summary tgt
USING (

    WITH base_data AS (
        SELECT
            CAST(o.order_date AS DATE) AS order_date,
            o.order_id,
            o.order_sk,
            COALESCE(o.total_amount,0) AS total_amount,
            COALESCE(oi.quantity,0) AS quantity,
            COALESCE(oi.unit_price,0) AS unit_price,
            CASE 
                WHEN UPPER(o.order_status) = 'CANCELLED' 
                THEN 1 ELSE 0 
            END AS is_cancelled
        FROM VP_silver_orders o
        LEFT JOIN VP_silver_order_items oi
            ON o.order_sk = oi.order_sk

        -- Incremental Logic
        WHERE o.order_date ::DATE >= COALESCE(
            (SELECT MAX(order_date) FROM VP_gold_daily_sales_summary),
            DATE '1900-01-01'
        )
    )

    SELECT
        order_date,

        COUNT(DISTINCT order_id) AS total_orders,

        SUM(CASE WHEN is_cancelled = 0 
                 THEN total_amount ELSE 0 END) AS total_revenue,

        SUM(CASE WHEN is_cancelled = 0 
                 THEN quantity ELSE 0 END) AS total_units_sold,

        ROUND(
            SUM(CASE WHEN is_cancelled = 0 
                     THEN quantity * unit_price ELSE 0 END)
            /
            NULLIF(
                COUNT(DISTINCT CASE 
                    WHEN is_cancelled = 0 THEN order_id 
                END),0
            )
        ,4) AS avg_order_value,

        COUNT(DISTINCT CASE 
            WHEN is_cancelled = 1 THEN order_id 
        END) AS cancelled_orders,

        ROUND(
            COUNT(DISTINCT CASE 
                WHEN is_cancelled = 1 THEN order_id 
            END) * 100.0
            /
            NULLIF(COUNT(DISTINCT order_id),0)
        ,3) AS cancellation_rate

    FROM base_data
    GROUP BY order_date

) src

ON tgt.order_date = src.order_date

WHEN MATCHED THEN UPDATE SET
    total_orders      = COALESCE(src.total_orders,0),
    total_revenue     = COALESCE(src.total_revenue,0),
    total_units_sold  = COALESCE(src.total_units_sold,0),
    avg_order_value   = COALESCE(src.avg_order_value,0),
    cancelled_orders  = COALESCE(src.cancelled_orders,0),
    cancellation_rate = COALESCE(src.cancellation_rate,0)

WHEN NOT MATCHED THEN INSERT (
    order_date,
    total_orders,
    total_revenue,
    total_units_sold,
    avg_order_value,
    cancelled_orders,
    cancellation_rate
)
VALUES (
    src.order_date,
    COALESCE(src.total_orders,0),
    COALESCE(src.total_revenue,0),
    COALESCE(src.total_units_sold,0),
    COALESCE(src.avg_order_value,0),
    COALESCE(src.cancelled_orders,0),
    COALESCE(src.cancellation_rate,0)
);


select * from vp_gold_daily_sales_summary;
------------------------------------------------------------------------------------
-- 2. VP_gold_customer_lifetime_value

MERGE INTO VP_gold_customer_lifetime_value tgt
USING (

    WITH recent_customers AS (
        SELECT DISTINCT customer_key
        FROM VP_silver_orders
        WHERE is_current = TRUE
          AND order_date >= COALESCE(
                (SELECT MAX(last_order_date)
                 FROM VP_gold_customer_lifetime_value),
                DATE '1900-01-01'
          )
    ),

    base_data AS (
        SELECT
            c.customer_id,
            c.customer_segment,
            o.order_id,
            o.order_date,
            COALESCE(oi.line_total,0) AS line_total,
            COALESCE(p.cost,0) AS product_cost,
            COALESCE(oi.quantity,0) AS quantity
        FROM VP_silver_customers c

        LEFT JOIN VP_silver_orders o
            ON c.customer_key = o.customer_key
            AND o.is_current = TRUE

        LEFT JOIN VP_silver_order_items oi
            ON o.order_sk = oi.order_sk

        LEFT JOIN VP_silver_products p
            ON oi.product_key = p.product_key
            AND p.is_current = TRUE

        WHERE c.is_current = TRUE
          AND c.customer_key IN (SELECT customer_key FROM recent_customers)
    )

    SELECT
        customer_id,

        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,

        COUNT(DISTINCT order_id) AS total_orders,

        COALESCE(SUM(line_total),0) AS total_revenue,

        COALESCE(SUM(line_total - (product_cost * quantity)),0) AS total_profit,

        ROUND(
            COALESCE(SUM(line_total),0)
            /
            NULLIF(COUNT(DISTINCT order_id),0)
        ,4) AS avg_order_value,

        MAX(customer_segment) AS customer_segment,

        CASE 
            WHEN MAX(order_date) >= CURRENT_DATE - INTERVAL '90 DAY'
            THEN TRUE
            ELSE FALSE
        END AS is_active

    FROM base_data
    GROUP BY customer_id

) src

ON tgt.customer_id = src.customer_id

WHEN MATCHED THEN UPDATE SET
    first_order_date = src.first_order_date,
    last_order_date  = src.last_order_date,
    total_orders     = COALESCE(src.total_orders,0),
    total_revenue    = COALESCE(src.total_revenue,0),
    total_profit     = COALESCE(src.total_profit,0),
    avg_order_value  = COALESCE(src.avg_order_value,0),
    customer_segment = src.customer_segment,
    is_active        = src.is_active

WHEN NOT MATCHED THEN INSERT (
    customer_id,
    first_order_date,
    last_order_date,
    total_orders,
    total_revenue,
    total_profit,
    avg_order_value,
    customer_segment,
    is_active
)
VALUES (
    src.customer_id,
    src.first_order_date,
    src.last_order_date,
    COALESCE(src.total_orders,0),
    COALESCE(src.total_revenue,0),
    COALESCE(src.total_profit,0),
    COALESCE(src.avg_order_value,0),
    src.customer_segment,
    src.is_active
);


    

select * from VP_gold_customer_lifetime_value;



-----------------------------------------------------------------------
-- 3.VP_gold_product_performance

MERGE INTO VP_gold_product_performance tgt
USING (

    WITH last_run AS (
        SELECT COALESCE(
            MAX(last_updated_timestamp),
            TIMESTAMP '1900-01-01'
        ) AS watermark
        FROM VP_gold_product_performance
    ),

    impacted_products AS (
        SELECT DISTINCT oi.product_key
        FROM VP_silver_order_items oi
        WHERE oi.processed_timestamp >= (
            SELECT watermark FROM last_run
        )
    ),

    base_data AS (
        SELECT
            p.product_id,
            p.product_name,
            p.category,
            o.order_id,
            UPPER(o.order_status) AS order_status,
            COALESCE(oi.quantity,0) AS quantity,
            COALESCE(oi.line_total,0) AS line_total,
            COALESCE(p.cost,0) AS cost
        FROM impacted_products ip

        JOIN VP_silver_products p
            ON ip.product_key = p.product_key
            AND p.is_current = TRUE

        JOIN VP_silver_order_items oi
            ON p.product_key = oi.product_key

        JOIN VP_silver_orders o
            ON oi.order_sk = o.order_sk
            AND o.is_current = TRUE
    ),

    product_metrics AS (
        SELECT
            product_id,
            product_name,
            category,

            COUNT(DISTINCT order_id) AS total_orders,

            SUM(CASE 
                    WHEN order_status <> 'CANCELLED'
                    THEN quantity
                    ELSE 0
                END) AS total_units_sold,

            SUM(CASE 
                    WHEN order_status <> 'CANCELLED'
                    THEN line_total
                    ELSE 0
                END) AS total_revenue,

            SUM(CASE 
                    WHEN order_status <> 'CANCELLED'
                    THEN line_total - (cost * quantity)
                    ELSE 0
                END) AS total_profit

        FROM base_data
        GROUP BY product_id, product_name, category
    )

    SELECT
        product_id,
        product_name,
        category,

        COALESCE(total_orders,0)     AS total_orders,
        COALESCE(total_units_sold,0) AS total_units_sold,
        COALESCE(total_revenue,0)    AS total_revenue,
        COALESCE(total_profit,0)     AS total_profit,

        ROUND(
            COALESCE(total_profit,0) 
            / NULLIF(total_revenue,0)
        ,4) AS profit_margin,

        ROUND(
            COALESCE(total_revenue,0)
            / NULLIF(total_units_sold,0)
        ,4) AS avg_price,

        CURRENT_TIMESTAMP AS last_updated_timestamp

    FROM product_metrics

) src

ON tgt.product_id = src.product_id

WHEN MATCHED THEN UPDATE SET
    product_name     = src.product_name,
    category         = src.category,
    total_orders     = src.total_orders,
    total_units_sold = src.total_units_sold,
    total_revenue    = src.total_revenue,
    total_profit     = src.total_profit,
    profit_margin    = src.profit_margin,
    avg_price        = src.avg_price,
    last_updated_timestamp = src.last_updated_timestamp

WHEN NOT MATCHED THEN INSERT (
    product_id,
    product_name,
    category,
    total_orders,
    total_units_sold,
    total_revenue,
    total_profit,
    profit_margin,
    avg_price,
    last_updated_timestamp
)
VALUES (
    src.product_id,
    src.product_name,
    src.category,
    src.total_orders,
    src.total_units_sold,
    src.total_revenue,
    src.total_profit,
    src.profit_margin,
    src.avg_price,
    src.last_updated_timestamp
);


select * from VP_gold_product_performance;
----------------------------------------------------------

-- 4. gold_customer_segment_trends


MERGE INTO VP_gold_customer_segment_trends tgt
USING (

    -- Step 1: Get only new snapshot dates
    WITH new_dates AS (
        SELECT DISTINCT order_date AS snapshot_date
        FROM VP_silver_orders
        WHERE order_date > (
            SELECT COALESCE(MAX(snapshot_date), '2023-01-01')
            FROM VP_gold_customer_segment_trends
        )
    )

    SELECT
        d.snapshot_date,
        c.customer_segment,

        -- Active Customers
        COUNT(DISTINCT c.customer_id) AS active_customers,

         -- New Customers
        COUNT(DISTINCT CASE 
            WHEN c.effective_from_date = d.snapshot_date
            THEN c.customer_id END) AS new_customers,

        -- Churned Customers
        COUNT(DISTINCT CASE 
            WHEN c.effective_to_date = d.snapshot_date
            THEN c.customer_key END) AS churned_customers,

        -- Revenue
        COALESCE(SUM(o.total_amount), 0) AS total_revenue,

        -- Avg Revenue Per Active Customer 
        CASE
            WHEN COUNT(DISTINCT c.customer_id) = 0 THEN 0
            ELSE COALESCE(SUM(o.total_amount), 0)
                 / COUNT(DISTINCT c.customer_id)
        END AS avg_revenue_per_customer

    FROM new_dates d

    LEFT JOIN VP_silver_customers c
        ON c.effective_from_date <= d.snapshot_date
        AND (c.effective_to_date IS NULL
             OR c.effective_to_date > d.snapshot_date)

    LEFT JOIN VP_silver_orders o
        ON o.customer_key = c.customer_key
        AND o.order_date = d.snapshot_date
        AND o.is_current = TRUE

    GROUP BY
        d.snapshot_date,
        c.customer_segment

) src

ON tgt.snapshot_date = src.snapshot_date
AND tgt.customer_segment = src.customer_segment

WHEN NOT MATCHED THEN
INSERT (
    snapshot_date,
    customer_segment,
    active_customers,
    new_customers,
    churned_customers,
    total_revenue,
    avg_revenue_per_customer
)
VALUES (
    src.snapshot_date,
    src.customer_segment,
    src.active_customers,
    src.new_customers,
    src.churned_customers,
    src.total_revenue,
    src.avg_revenue_per_customer
);

SELECT * FROM VP_GOLD_CUSTOMER_SEGMENT_TRENDS;

-----------------------------------------------------------------------------------------

