USE ROLE ACCOUNTADMIN_ROLE;
USE WAREHOUSE HACKATHON_WH;
USE DATABASE NINJA_DB;
USE SCHEMA GOLD;

-- STEP 1 — DIMENSION TABLES 


-- DIM_CUSTOMERS

ALTER TABLE GOLD.DIM_CUSTOMERS
DROP COLUMN valid_to;


CREATE OR REPLACE TABLE GOLD.DIM_CUSTOMERS (
    customer_sk INT AUTOINCREMENT,
    customer_id STRING,
    name STRING,
    city STRING,
    signup_date DATE,

    valid_from TIMESTAMP,
    is_active BOOLEAN,

    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

MERGE INTO GOLD.DIM_CUSTOMERS tgt
USING NINJA_DB.SILVER.CUSTOMERS src
ON tgt.customer_id = src.customer_id AND tgt.is_active = TRUE

WHEN MATCHED AND (
    tgt.name <> src.name OR
    tgt.city <> src.city
)
THEN UPDATE SET
    tgt.is_active = FALSE,
    tgt.updated_at = CURRENT_TIMESTAMP()

WHEN NOT MATCHED THEN
INSERT (
    customer_id, name, city, signup_date,
    valid_from, is_active, created_at, updated_at
)
VALUES (
    src.customer_id, src.name, src.city, src.signup_date,
    CURRENT_TIMESTAMP(), TRUE,
    CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
);

-- DIM_PRODUCTS
ALTER TABLE GOLD.DIM_PRODUCTS
DROP COLUMN valid_to;

CREATE OR REPLACE TABLE GOLD.DIM_PRODUCTS (
    product_sk INT AUTOINCREMENT,
    product_id STRING,
    product_name STRING,
    category STRING,
    price NUMBER,

    valid_from TIMESTAMP,
    is_active BOOLEAN,

    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

MERGE INTO GOLD.DIM_PRODUCTS tgt
USING NINJA_DB.SILVER.PRODUCTS src
ON tgt.product_id = src.product_id AND tgt.is_active = TRUE

WHEN MATCHED AND (
    tgt.product_name <> src.product_name OR
    tgt.category <> src.category OR
    tgt.price <> src.price
)
THEN UPDATE SET
    tgt.is_active = FALSE,
    tgt.updated_at = CURRENT_TIMESTAMP()

WHEN NOT MATCHED THEN
INSERT (
    product_id, product_name, category, price,
    valid_from, is_active, created_at, updated_at
)
VALUES (
    src.product_id, src.product_name, src.category, src.price,
    CURRENT_TIMESTAMP(), TRUE,
    CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
);
-- STEP 2 — FACT TABLES

-- FACT_ORDERS
CREATE OR REPLACE TABLE GOLD.FACT_ORDERS (
    order_id STRING,
    customer_id STRING,
    order_date DATE,
    total_amount NUMBER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

MERGE INTO GOLD.FACT_ORDERS tgt
USING NINJA_DB.SILVER.ORDERS src
ON tgt.order_id = src.order_id

WHEN MATCHED THEN UPDATE SET
    tgt.customer_id = src.customer_id,
    tgt.order_date = src.order_date,
    tgt.total_amount = src.total_amount,
    tgt.updated_at = CURRENT_TIMESTAMP()

WHEN NOT MATCHED THEN
INSERT (
    order_id, customer_id, order_date,
    total_amount, created_at, updated_at
)
VALUES (
    src.order_id, src.customer_id, src.order_date,
    src.total_amount, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
);

-- FACT_ORDER_ITEMS


CREATE OR REPLACE TABLE GOLD.FACT_ORDER_ITEMS (
    order_item_id STRING,
    order_id STRING,
    product_id STRING,
    quantity NUMBER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

MERGE INTO GOLD.FACT_ORDER_ITEMS tgt
USING NINJA_DB.SILVER.ORDER_ITEMS src
ON tgt.order_item_id = src.order_item_id

WHEN MATCHED THEN UPDATE SET
    tgt.quantity = src.quantity,
    tgt.updated_at = CURRENT_TIMESTAMP()

WHEN NOT MATCHED THEN
INSERT (
    order_item_id,
    order_id,
    product_id,
    quantity,
    created_at,
    updated_at
)
VALUES (
    src.order_item_id,
    src.order_id,
    src.product_id,
    src.quantity,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
);


-- FACT_USER_ACTIVITY
CREATE OR REPLACE TABLE GOLD.FACT_USER_ACTIVITY (
    activity_id STRING,
    customer_id STRING,
    activity_type STRING,
    activity_time TIMESTAMP,
    created_at TIMESTAMP
);

MERGE INTO GOLD.FACT_USER_ACTIVITY tgt
USING NINJA_DB.SILVER.ACTIVITY src
ON tgt.activity_id = src.activity_id

WHEN NOT MATCHED THEN
INSERT (
    activity_id, customer_id, activity_type,
    activity_time, created_at
)
VALUES (
    src.activity_id, src.customer_id, src.activity_type,
    src.activity_time, CURRENT_TIMESTAMP()
);


-- DIM_DATE (Common Date Dimension for all facts)
CREATE OR REPLACE TABLE GOLD.DIM_DATE AS
SELECT DISTINCT
    d.date_value AS date,

    EXTRACT(YEAR FROM d.date_value) AS year,
    EXTRACT(MONTH FROM d.date_value) AS month,
    EXTRACT(DAY FROM d.date_value) AS day,
    EXTRACT(DAYOFWEEK FROM d.date_value) AS day_of_week,
    EXTRACT(WEEK FROM d.date_value) AS week_of_year,
    EXTRACT(QUARTER FROM d.date_value) AS quarter,

    TO_VARCHAR(d.date_value, 'DY') AS day_name,
    TO_VARCHAR(d.date_value, 'MON') AS month_name,

    CASE 
        WHEN EXTRACT(DAYOFWEEK FROM d.date_value) IN (6,7) THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END AS day_type

FROM (
    SELECT order_date AS date_value FROM GOLD.FACT_ORDERS
    UNION
    SELECT DATE(activity_time) FROM GOLD.FACT_USER_ACTIVITY
) d;

