--orders table



COPY INTO VP_bronze_orders (
    order_id,
    customer_id,
    order_date,
    order_status,
    total_amount,
    payment_method,
    created_at,
    ingestion_timestamp,
    source_file,
    row_hash
)
FROM (
    SELECT
        $1::INT,
        $2::INT,
        TRY_TO_DATE($3, 'DD-MM-YYYY')::DATE,
        $4::STRING,
        $5::DECIMAL(10,2),
        $6::STRING,
        TRY_TO_TIMESTAMP($7,'DD-MM-YYYY HH24:MI')::TIMESTAMP,

        CURRENT_TIMESTAMP AS ingestion_timestamp,
        METADATA$FILENAME AS source_file,
        MD5(
            CONCAT(
                $1, '|', $2, '|', $3, '|', $4, '|', $5, '|', $6, '|', $7)
        )
    FROM @vp_stage/incoming/
)
FILE_FORMAT = bronze_csv
PATTERN = 'orders_source_.._.._.{10}\.csv'
force = false
ON_ERROR = 'abort_statement';


select * from vp_bronze_orders;
--------------------------------------------------------------------------------------------------------


COPY FILES INTO @VP_STAGE/archived/
FROM @VP_STAGE/incoming/
PATTERN = '.*orders_source.*\.csv';


REMOVE @VP_STAGE/incoming/
PATTERN = 'orders_source_.._.._.{10}\.csv';



SELECT count(*) FROM VP_BRONZE_ORDERS;
------------------------------------------------------------------------------- 

--CUSTOMERS TABLE


COPY INTO VP_bronze_customers (
    customer_id,
    first_name,
    last_name,
    email,
    city,
    country,
    customer_segment,
    last_updated,

    ingestion_timestamp,
    source_file,
    row_hash
)
FROM (
    SELECT
        $1::INT,
        $2::STRING,
        $3::STRING,
        $4::STRING,
        $5::STRING,
        $6::STRING,
        $7::STRING,
        TRY_TO_TIMESTAMP($8,'DD-MM-YYYY HH24:MI')::TIMESTAMP,
        CURRENT_TIMESTAMP AS ingestion_timestamp,
        METADATA$FILENAME AS source_file,
        MD5(
            CONCAT(
                $1, '|', $2, '|', $3, '|', $4, '|',$5, '|', $6, '|', $7, '|', $8)
        ) AS row_hash
    FROM @vp_stage/incoming/
)
FILE_FORMAT = bronze_csv
PATTERN = 'customers_source_.._.._.{10}\.csv'
ON_ERROR = 'abort_statement'
force= false;

---------------------------------------------------------------------------
COPY FILES INTO @VP_STAGE/archived/
FROM @VP_STAGE/incoming/
PATTERN = '.*customers_source.*\.csv';

REMOVE @VP_STAGE/incoming/
PATTERN = 'customers_source_.._.._.{10}\.csv';



select count(*) from vp_bronze_customers;
--------------------------------------------------------------------------------------------------------

--products table

COPY INTO VP_bronze_products (
    product_id,
    product_name,
    category,
    price,
    cost,
    supplier_id,
    last_updated,
    ingestion_timestamp,
    source_file,
    row_hash
)
FROM (
    SELECT
        $1::INT,
        $2::STRING,
        $3::STRING,
        $4::DECIMAL(10,2),
        $5::DECIMAL(10,2),
        $6::INT,
        -- COALESCE(TRY_TO_TIMESTAMP($7,'DD-MM-YYYY HH24:MI:SS'),
                 TRY_TO_TIMESTAMP($7, 'DD-MM-YYYY HH24:MI:SS') AS last_updated,
        current_timestamp() AS ingestion_timestamp,
        METADATA$FILENAME AS source_file,
        MD5(
            CONCAT(
                $1, '|', $2, '|', $3, '|',
                $4, '|', $5, '|', $6, '|', $7
            )
        ) as row_hash
    FROM @vp_stage/incoming/
)
FILE_FORMAT = bronze_csv
PATTERN = 'products_source_.._.._.{10}\.csv'
force=false
ON_ERROR = 'abort_statement';

-----------------------------------------------------------------
COPY FILES INTO @VP_STAGE/archived/
FROM @VP_STAGE/incoming/
PATTERN = '.*products_source.*\.csv';

REMOVE @VP_STAGE/incoming/
PATTERN = 'products_source_.._.._.{10}\.csv';


select COUNT(*) from VP_BRONZE_PRODUCTS;
---------------------------------------------------------------------


--ORDER ITEMS


COPY INTO VP_bronze_order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_percent,
    ingestion_timestamp,
    source_file,
    row_hash
)
FROM (
    SELECT
        $1::INT,
        $2::INT,
        $3::INT,
        $4::INT,
        $5::DECIMAL(10,2),
        $6::DECIMAL(5,2),
        current_timestamp() as ingestion_timestamp,
        METADATA$FILENAME AS source_file,
        MD5(
            CONCAT(
                $1, '|', $2, '|', $3, '|', $4, '|', $5, '|', $6 )
        ) AS row_hash
    FROM @vp_stage/incoming/
)
FILE_FORMAT = bronze_csv
PATTERN = 'order_items_source_.._.._.{10}\.csv'
force=false
ON_ERROR = 'abort_statement';
------------------------------------------------------------------------------
COPY FILES INTO @VP_STAGE/archived/
FROM @VP_STAGE/incoming/
PATTERN = '.*order_items_source.*\.csv';

REMOVE @VP_STAGE/incoming/
PATTERN = 'order_items_source_.._.._.{10}\.csv';

SELECT COUNT(*) FROM VP_BRONZE_ORDER_ITEMS;

-------------------------------------------------------------------------------------------


