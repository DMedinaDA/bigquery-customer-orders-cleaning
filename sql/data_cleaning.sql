-- View the raw customer orders table
SELECT *
FROM dc-project-1-406502.customer_orders.customer;

-- 1. Standardize the order_status column
SELECT order_status,
  CASE 
    WHEN LOWER(order_status) LIKE '%deliver%' THEN 'Delivered'
    WHEN LOWER(order_status) LIKE '%return%' THEN 'Returned'
    WHEN LOWER(order_status) LIKE '%refund%' THEN 'Refunded'
    WHEN LOWER(order_status) LIKE '%pend%' THEN 'Pending'
    WHEN LOWER(order_status) LIKE '%ship%' THEN 'Shipped'
    ELSE 'Other'
  END AS cleaned_order_status
FROM dc-project-1-406502.customer_orders.customer;

-- 2. Standardize product names so similar values match one label
SELECT *,
  CASE 
    WHEN LOWER(product_name) LIKE '%apple watch%' THEN 'Apple Watch'
    WHEN LOWER(product_name) LIKE '%samsung galaxy s22%' THEN 'Samsung Galaxy S22'
    WHEN LOWER(product_name) LIKE '%google pixel%' THEN 'Google Pixel'
    WHEN LOWER(product_name) LIKE '%macbook pro%' THEN 'Macbook Pro'
    WHEN LOWER(product_name) LIKE '%iphone 14%' THEN 'Iphone 14'
    ELSE 'Other'
  END AS clean_product_name
FROM dc-project-1-406502.customer_orders.customer;

-- 3. Convert quantity values into a consistent numeric format
SELECT *,
  CASE 
    WHEN LOWER(quantity) = 'two' THEN 2
    ELSE CAST(quantity AS INT64)
  END AS clean_quantity
FROM dc-project-1-406502.customer_orders.customer;

-- 4. Clean customer names by applying proper capitalization
SELECT customer_name,
  INITCAP(customer_name) AS customer_name
FROM dc-project-1-406502.customer_orders.customer
WHERE customer_name IS NOT NULL;

-- 5. Remove duplicate records using email + product as the match key
SELECT *
FROM (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(email), LOWER(product_name)
      ORDER BY order_id
    ) AS rn
  FROM dc-project-1-406502.customer_orders.customer
)
WHERE rn = 1;

-- Final clean data set
WITH cleaned_data AS (
  SELECT
    order_id,
    -- Format customer names consistently
    INITCAP(customer_name) AS customer_name,
    email,

    -- Standardize order status values
    CASE 
      WHEN LOWER(order_status) LIKE '%deliver%' THEN 'Delivered'
      WHEN LOWER(order_status) LIKE '%return%' THEN 'Returned'
      WHEN LOWER(order_status) LIKE '%refund%' THEN 'Refunded'
      WHEN LOWER(order_status) LIKE '%pend%' THEN 'Pending'
      WHEN LOWER(order_status) LIKE '%ship%' THEN 'Shipped'
      ELSE 'Other'
    END AS cleaned_order_status,

    -- Clean and group product names into consistent labels
    CASE 
      WHEN LOWER(product_name) LIKE '%apple watch%' THEN 'Apple Watch'
      WHEN LOWER(product_name) LIKE '%samsung galaxy s22%' THEN 'Samsung Galaxy S22'
      WHEN LOWER(product_name) LIKE '%google pixel%' THEN 'Google Pixel'
      WHEN LOWER(product_name) LIKE '%macbook pro%' THEN 'Macbook Pro'
      WHEN LOWER(product_name) LIKE '%iphone 14%' THEN 'Iphone 14'
      ELSE 'Other'
    END AS clean_product_name,

    -- Convert quantity to numeric type for analysis
    CASE 
      WHEN LOWER(quantity) = 'two' THEN 2
      ELSE SAFE_CAST(quantity AS INT64)
    END AS clean_quantity,

    -- Keep the original order date for now
    order_date
  FROM dc-project-1-406502.customer_orders.customer
  WHERE customer_name IS NOT NULL
),

deduplicated_data AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(email), LOWER(clean_product_name)
      ORDER BY order_id
    ) AS rn
  FROM cleaned_data
),

final_table AS (
  SELECT *
  FROM deduplicated_data
  WHERE rn = 1
)

SELECT *
FROM final_table;


---Cleaner version 
-- Customer Orders Data Cleaning Project
-- Purpose: Standardize messy customer order data and remove duplicates

WITH cleaned_data AS (
  SELECT
    order_id,
    INITCAP(customer_name) AS customer_name,
    email,

    CASE 
      WHEN LOWER(order_status) LIKE '%deliver%' THEN 'Delivered'
      WHEN LOWER(order_status) LIKE '%return%' THEN 'Returned'
      WHEN LOWER(order_status) LIKE '%refund%' THEN 'Refunded'
      WHEN LOWER(order_status) LIKE '%pend%' THEN 'Pending'
      WHEN LOWER(order_status) LIKE '%ship%' THEN 'Shipped'
      ELSE 'Other'
    END AS cleaned_order_status,

    CASE 
      WHEN LOWER(product_name) LIKE '%apple watch%' THEN 'Apple Watch'
      WHEN LOWER(product_name) LIKE '%samsung galaxy s22%' THEN 'Samsung Galaxy S22'
      WHEN LOWER(product_name) LIKE '%google pixel%' THEN 'Google Pixel'
      WHEN LOWER(product_name) LIKE '%macbook pro%' THEN 'Macbook Pro'
      WHEN LOWER(product_name) LIKE '%iphone 14%' THEN 'Iphone 14'
      ELSE 'Other'
    END AS clean_product_name,

    CASE 
      WHEN LOWER(quantity) = 'two' THEN 2
      ELSE SAFE_CAST(quantity AS INT64)
    END AS clean_quantity,

    SAFE.PARSE_DATE('%Y-%m-%d', CAST(order_date AS STRING)) AS clean_order_date
  FROM dc-project-1-406502.customer_orders.customer
  WHERE customer_name IS NOT NULL
),

deduplicated_data AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(email), LOWER(clean_product_name)
      ORDER BY order_id
    ) AS rn
  FROM cleaned_data
)

SELECT
  order_id,
  customer_name,
  email,
  cleaned_order_status,
  clean_product_name,
  clean_quantity,
  clean_order_date
FROM deduplicated_data
WHERE rn = 1;

--It removes the extra test queries and keeps only the final version
-- The final SELECT only returns the cleaned columns you actually need
-- I used SAFE.PARSE_DATE for the final date field so it’s safer for messy data.
--I kept clean_product_name in the deduplication step since that is the standardized field.










