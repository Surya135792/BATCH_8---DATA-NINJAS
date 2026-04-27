USE SCHEMA ANALYTICS;
-- 1. CUSTOMER 360
CREATE OR REPLACE TABLE ANALYTICS.CUSTOMER_360 AS
SELECT
    c.customer_id,
    c.name,
    c.city,
    c.signup_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount),0) AS total_spent,
    COALESCE(AVG(o.total_amount),0) AS avg_order_value,
    MAX(o.order_date) AS last_order_date
FROM GOLD.DIM_CUSTOMERS c
LEFT JOIN NINJA_DB.GOLD.FACT_ORDERS o
    ON c.customer_id = o.customer_id
WHERE c.is_active = TRUE
GROUP BY c.customer_id, c.name, c.city, c.signup_date;

-- 2. CUSTOMER SEGMENTATION (RFM)
CREATE OR REPLACE TABLE ANALYTICS.CUSTOMER_SEGMENTATION AS
SELECT
    customer_id,
    DATEDIFF('day', MAX(order_date), CURRENT_DATE()) AS recency,
    COUNT(order_id) AS frequency,
    SUM(total_amount) AS monetary,
    CASE
        WHEN SUM(total_amount) > 10000 THEN 'HIGH_VALUE'
        WHEN SUM(total_amount) BETWEEN 5000 AND 10000 THEN 'MEDIUM_VALUE'
        ELSE 'LOW_VALUE'
    END AS segment
FROM GOLD.FACT_ORDERS
GROUP BY customer_id;

-- 3. SALES INSIGHTS
CREATE OR REPLACE TABLE ANALYTICS.SALES_INSIGHTS AS
SELECT
    order_date,
    SUM(total_amount) AS revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_amount) / COUNT(DISTINCT order_id) AS avg_order_value
FROM GOLD.FACT_ORDERS
GROUP BY order_date;

-- 4. CHURN IDENTIFICATION
CREATE OR REPLACE TABLE ANALYTICS.CUSTOMER_CHURN AS
SELECT
    customer_id,
    MAX(order_date) AS last_order_date,
    DATEDIFF('day', MAX(order_date), CURRENT_DATE()) AS days_inactive,
    CASE
        WHEN DATEDIFF('day', MAX(order_date), CURRENT_DATE()) > 90 THEN 'CHURNED'
        ELSE 'ACTIVE'
    END AS churn_status
FROM GOLD.FACT_ORDERS
GROUP BY customer_id;







--CUSTOMER 360 TASK
CREATE OR REPLACE TASK AUTOMATION.TASK_CUSTOMER_360
WAREHOUSE = HACKATHON_WH
AFTER AUTOMATION.TASK_FACT_ORDERS
AS

CREATE OR REPLACE TABLE GOLD.CUSTOMER_360 AS
SELECT
    c.customer_id,
    c.name,
    c.city,
    c.signup_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount),0) AS total_spent,
    COALESCE(AVG(o.total_amount),0) AS avg_order_value,
    MAX(o.order_date) AS last_order_date
FROM GOLD.DIM_CUSTOMERS c
LEFT JOIN GOLD.FACT_ORDERS o
    ON c.customer_id = o.customer_id
WHERE c.is_active = TRUE
GROUP BY c.customer_id, c.name, c.city, c.signup_date;



--CUSTOMER SEGMENTATION TASK
CREATE OR REPLACE TASK AUTOMATION.TASK_CUSTOMER_SEGMENT
WAREHOUSE = HACKATHON_WH
AFTER AUTOMATION.TASK_FACT_ORDERS
AS

CREATE OR REPLACE TABLE GOLD.CUSTOMER_SEGMENTATION AS
SELECT
    customer_id,
    DATEDIFF('day', MAX(order_date), CURRENT_DATE()) AS recency,
    COUNT(order_id) AS frequency,
    SUM(total_amount) AS monetary,
    CASE
        WHEN SUM(total_amount) > 10000 THEN 'HIGH_VALUE'
        WHEN SUM(total_amount) BETWEEN 5000 AND 10000 THEN 'MEDIUM_VALUE'
        ELSE 'LOW_VALUE'
    END AS segment
FROM GOLD.FACT_ORDERS
GROUP BY customer_id;



--3. SALES INSIGHTS TASK
CREATE OR REPLACE TASK AUTOMATION.TASK_SALES_INSIGHTS
WAREHOUSE = HACKATHON_WH
AFTER AUTOMATION.TASK_FACT_ORDERS
AS

CREATE OR REPLACE TABLE GOLD.SALES_INSIGHTS AS
SELECT
    d.date,
    d.month,
    d.year,
    SUM(f.total_amount) AS revenue,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.total_amount)/COUNT(DISTINCT f.order_id) AS avg_order_value
FROM GOLD.FACT_ORDERS f
JOIN GOLD.DIM_DATE d
    ON f.order_date = d.date
GROUP BY d.date, d.month, d.year;


--CUSTOMER CHURN TASK
CREATE OR REPLACE TASK AUTOMATION.TASK_CUSTOMER_CHURN
WAREHOUSE = HACKATHON_WH
AFTER AUTOMATION.TASK_FACT_ORDERS
AS

CREATE OR REPLACE TABLE GOLD.CUSTOMER_CHURN AS
SELECT
    customer_id,
    MAX(order_date) AS last_order_date,
    DATEDIFF('day', MAX(order_date), CURRENT_DATE()) AS days_inactive,
    CASE
        WHEN DATEDIFF('day', MAX(order_date), CURRENT_DATE()) > 90 THEN 'CHURNED'
        ELSE 'ACTIVE'
    END AS churn_status
FROM GOLD.FACT_ORDERS
GROUP BY customer_id;

