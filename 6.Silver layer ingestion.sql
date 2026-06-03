
SELECT * FROM VP_SILVER_CUSTOMERS;

   --customers table

CREATE OR REPLACE PROCEDURE VP_LOAD_SILVER_CUSTOMERS()
RETURNS STRING
LANGUAGE SQL
AS
$$

DECLARE
    v_error_message STRING;

BEGIN

    -- Step 1: Create temporary source table
    CREATE OR REPLACE TEMP TABLE VP_TMP_CUSTOMER_SOURCE AS
    SELECT
        s.customer_id,
        s.first_name,
        s.last_name,
        s.email,
        s.city,
        s.country,
        s.customer_segment,
        s.ingestion_timestamp,
        s.last_updated,
        MD5(
            CONCAT_WS('|',
                COALESCE(s.customer_id::STRING,''),
                COALESCE(TRIM(LOWER(s.first_name)),''),
                COALESCE(TRIM(LOWER(s.last_name)),''),
                COALESCE(TRIM(LOWER(s.email)),''),
                COALESCE(TRIM(LOWER(s.city)),''),
                COALESCE(TRIM(LOWER(s.country)),''),
                COALESCE(TRIM(LOWER(s.customer_segment)),'')
            )
        ) AS row_hash
    FROM (
        SELECT *
        FROM VP_bronze_customers
        WHERE ingestion_timestamp >
              COALESCE(
                  (SELECT MAX(created_timestamp)
                   FROM VP_silver_customers),
                  '1900-01-01'
              )
        QUALIFY ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY ingestion_timestamp DESC
        ) = 1
    ) s;


    -- Step 2: Expire existing records
    MERGE INTO VP_silver_customers t
    USING VP_TMP_CUSTOMER_SOURCE s
    ON t.customer_id = s.customer_id
       AND t.is_current = TRUE
    WHEN MATCHED
         AND t.row_hash != s.row_hash
    THEN UPDATE SET
         effective_to_date = CURRENT_DATE - 1,
         is_current = FALSE,
         updated_timestamp = CURRENT_TIMESTAMP;


    -- Step 3: Insert new records
    INSERT INTO VP_silver_customers (
         customer_id,
         first_name,
         last_name,
         email,
         city,
         country,
         customer_segment,
         effective_from_date,
         effective_to_date,
         is_current,
         row_hash,
         created_timestamp
    )
    SELECT
         s.customer_id,
         s.first_name,
         s.last_name,
         s.email,
         s.city,
         s.country,
         s.customer_segment,
         s.last_updated,
         '9999-12-31',
         TRUE,
         s.row_hash,
         CURRENT_TIMESTAMP
    FROM VP_TMP_CUSTOMER_SOURCE s
    LEFT JOIN VP_silver_customers t
         ON s.customer_id = t.customer_id
         AND t.is_current = TRUE
    WHERE t.customer_id IS NULL
       OR t.row_hash != s.row_hash;

    RETURN 'SCD Type 2 Load Completed Successfully';


-- Exception Handling Block
EXCEPTION
    WHEN OTHER THEN
        v_error_message := 'Error: ' || SQLERRM;
        RETURN v_error_message;

END;

$$;

CALL VP_LOAD_SILVER_CUSTOMERS();
SELECT COUNT(*) FROM VP_SILVER_CUSTOMERS;


------------------------------------------------------------------
-- PRODUCTS TABLE

CREATE OR REPLACE PROCEDURE VP_LOAD_SILVER_PRODUCTS()
RETURNS STRING
LANGUAGE SQL
AS
$$

DECLARE 
    v_error_msg STRING;

BEGIN

CREATE OR REPLACE TEMP TABLE VP_TMP_PRODUCT_SOURCE AS
SELECT
    s.product_id,
    s.product_name,
    s.category,
    s.price,
    s.cost,
    s.supplier_id,
    s.last_updated,
    s.ingestion_timestamp,
    MD5(
        CONCAT_WS('|',
            COALESCE(s.product_id::STRING,''),
            COALESCE(TRIM(LOWER(s.product_name)),''),
            COALESCE(TRIM(LOWER(s.category)),''),
            COALESCE(s.price::STRING,''),
            COALESCE(s.cost::STRING,''),
            COALESCE(s.supplier_id::STRING,'')
        )
    ) AS row_hash
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY product_id
               ORDER BY ingestion_timestamp DESC
           ) AS rn
    FROM VP_bronze_products
    WHERE ingestion_timestamp >
          COALESCE(
              (SELECT MAX(created_timestamp)
               FROM VP_silver_products),
              '1900-01-01'
          )
) s
WHERE rn = 1;

MERGE INTO VP_silver_products t
USING VP_TMP_PRODUCT_SOURCE s
ON t.product_id = s.product_id
AND t.is_current = TRUE

WHEN MATCHED
     AND t.row_hash != s.row_hash
THEN UPDATE SET
     t.effective_to_date = CURRENT_DATE - 1,
     t.is_current = FALSE,
     t.updated_timestamp = CURRENT_TIMESTAMP;

INSERT INTO VP_silver_products (
     product_id,
     product_name,
     category,
     price,
     cost,
     supplier_id,
     effective_from_date,
     effective_to_date,
     is_current,
     row_hash,
     created_timestamp
)
SELECT
     s.product_id,
     s.product_name,
     s.category,
     s.price,
     s.cost,
     s.supplier_id,
    s.last_updated,
     '9999-12-31',
     TRUE,
     s.row_hash,
     CURRENT_TIMESTAMP
FROM VP_TMP_PRODUCT_SOURCE s
LEFT JOIN VP_silver_products t
     ON s.product_id = t.product_id
     AND t.is_current = TRUE
WHERE t.product_id IS NULL
   OR t.row_hash != s.row_hash;

RETURN 'SCD type 2 load successfully completed';



    EXCEPTION
        WHEN OTHER THEN
        v_error_msg := 'Error : ' || SQLERRM ;
        RETURN v_error_msg;

END;

$$;

CALL VP_LOAD_SILVER_PRODUCTS();
SELECT COUNT(*) FROM VP_SILVER_PRODUCTS;
SELECT * FROM VP_SILVER_PRODUCTS;

DESC TABLE VP_bronze_products;




------------------------------------------------
--orders table
----------------------------------------------------------------------------------------



CREATE OR REPLACE PROCEDURE VP_LOAD_SILVER_ORDERS()
RETURNS STRING
LANGUAGE SQL
AS
$$

DECLARE 
    v_error_msg STRING;

BEGIN

CREATE OR REPLACE TEMP TABLE VP_TMP_ORDERS_SOURCE AS
SELECT
    b.order_id,
    COALESCE(c.customer_key, -1) AS customer_key,
    b.order_date,
    COALESCE(s.status_key, -1) AS status_key,
    b.order_status,
    b.total_amount,
    b.payment_method,
    b.created_at,

    b.created_at AS effective_from_timestamp,

    MD5(
    CONCAT_WS('|',
        COALESCE(b.order_id::STRING,''),
        -- COALESCE(c.customer_key::STRING,''),
        COALESCE(b.order_date::STRING,''),
        COALESCE(s.status_key::STRING,''),
        COALESCE(b.order_status,''),   
        COALESCE(b.total_amount::STRING,''),
        COALESCE(b.payment_method,'')
    )
) AS row_hash

FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY ingestion_timestamp DESC NULLS LAST
           ) rn
    FROM VP_bronze_orders
) b

LEFT JOIN VP_silver_customers c
    ON b.customer_id = c.customer_id
    -- AND b.order_date BETWEEN c.effective_from_date
    --                      AND c.effective_to_date
       AND c.is_current = TRUE

LEFT JOIN VP_order_status s
    ON b.order_status = s.status_name

WHERE rn = 1;

UPDATE VP_silver_orders tgt
SET
    effective_to_timestamp = src.effective_from_timestamp,
    is_current = FALSE,
    processed_timestamp = CURRENT_TIMESTAMP
FROM VP_TMP_ORDERS_SOURCE src
WHERE tgt.order_id = src.order_id
  AND tgt.is_current = TRUE
  AND tgt.row_hash <> src.row_hash;


INSERT INTO VP_silver_orders (
    order_id,
    customer_key,
    order_date,
    status_key,
    order_status,
    total_amount,
    payment_method, 
    created_at,
    effective_from_timestamp,
    effective_to_timestamp,
    is_current,
    row_hash,
    processed_timestamp
)
SELECT
    src.order_id,
    src.customer_key,
    src.order_date,
    src.status_key,
    src.order_status,
    src.total_amount,
    src.payment_method,
    src.created_at,
    src.effective_from_timestamp,
    TIMESTAMP '9999-12-31 23:59:59',
    TRUE,
    src.row_hash,
    CURRENT_TIMESTAMP
FROM VP_TMP_ORDERS_SOURCE src
LEFT JOIN VP_silver_orders tgt
    ON src.order_id = tgt.order_id
    AND tgt.is_current = TRUE
WHERE tgt.order_id IS NULL
   OR tgt.row_hash <> src.row_hash;

RETURN 'SCD TYPE 2 load successfully completed !';

EXCEPTION 
    WHEN OTHER THEN 
    v_error_msg := 'ERROR :' || SQLERRM;
    RETURN v_error_msg;
    

END;
   
   
   
$$;

CALL VP_LOAD_SILVER_ORDERS();

select count(*) from vp_silver_orders;


-------------------------------------------------------------------
--order items table


----------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE VP_LOAD_SILVER_ORDER_ITEMS()
RETURNS STRING
LANGUAGE SQL
AS
$$

DECLARE 
    v_error_msg STRING;

BEGIN

MERGE INTO VP_silver_order_items t
USING (

    -- DEDUPED SOURCE (1 ROW PER ORDER_ITEM_ID)

    SELECT *
    FROM (
        SELECT
            oi.order_item_id,
            so.order_sk,
            p.product_key,
            oi.quantity,
            oi.unit_price,
            oi.discount_percent,
            COALESCE((oi.quantity * oi.unit_price) 
                * (1 - oi.discount_percent/100),0) AS line_total,

          
            ROW_NUMBER() OVER (
                PARTITION BY oi.order_item_id
                ORDER BY 
                    p.effective_from_date DESC NULLS LAST
            ) AS rn

 
        FROM VP_bronze_order_items oi

     
        LEFT JOIN (
            SELECT *
            FROM (
                SELECT *,
                       ROW_NUMBER() OVER (
                           PARTITION BY order_id
                           ORDER BY order_sk DESC
                       ) AS rn
                FROM VP_silver_orders
                WHERE is_current = TRUE
            )
            WHERE rn = 1
        ) so
        ON oi.order_id = so.order_id

      
        LEFT JOIN VP_bronze_orders o
            ON oi.order_id = o.order_id

        -- SCD TYPE 2 SAFE JOIN
        LEFT JOIN VP_silver_products p
            ON oi.product_id = p.product_id
            AND o.order_date BETWEEN 
                p.effective_from_date 
                AND COALESCE(p.effective_to_date, '9999-12-31')

    )
    WHERE rn = 1   -- GUARANTEES 1 ROW PER ORDER ITEM

) s

ON t.order_item_id = s.order_item_id

WHEN NOT MATCHED THEN
INSERT (
    order_item_id,
    order_sk,
    product_key,
    quantity,
    unit_price,
    discount_percent,
    line_total
)
VALUES (
    s.order_item_id,
    s.order_sk,
    s.product_key,
    s.quantity,
    s.unit_price,
    s.discount_percent,
    s.line_total
);

RETURN 'Load successfully completed!';

EXCEPTION 
    WHEN OTHER THEN 
        v_error_msg := 'ERROR: ' || SQLERRM;
        RETURN v_error_msg;

END;

$$;

CALL VP_LOAD_SILVER_ORDER_ITEMS();

SELECT * FROM VP_silver_order_items;










CALL VP_LOAD_SILVER_CUSTOMERS();
SELECT COUNT(*) FROM VP_SILVER_CUSTOMERS;

CALL VP_LOAD_SILVER_PRODUCTS();
SELECT COUNT(*) FROM VP_SILVER_PRODUCTS;



CALL VP_LOAD_SILVER_ORDERS();
select count(*) from vp_silver_orders;


CALL VP_LOAD_SILVER_ORDER_ITEMS();
SELECT * FROM VP_silver_order_items;


