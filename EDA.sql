/* ============================================================
   Project: Sales Data Exploration (EDA)
   Author: [Raghad Alwafi]

   Description:
   This script performs Exploratory Data Analysis (EDA) on the
   sales data warehouse. The goal is to explore dimensions,
   measures, and key business metrics to understand.

 Key Analysis Sections:
   1. Database Exploration
   2. Dimension Exploration
   3. Data Exploration
   4. Measures Exploration
   5. Magnitude Exploration
   6. Ranking Analysis
============================================================ */


/* ============================================================
   SECTION 1: DATABASE EXPLORATION
   Explore tables and columns in the database
============================================================ */

-- View all tables in the database
SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- View all columns for the customer dimension table
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';



/* ============================================================
   SECTION 2: DIMENSION EXPLORATION
   Explore categorical values and hierarchies
============================================================ */

-- Explore distinct customer countries
SELECT DISTINCT country
FROM gold.dim_customers;

-- Explore product hierarchy
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;



/* ============================================================
   SECTION 3: DATA EXPLORATION
   Analyze date ranges and demographic information
============================================================ */

-- Determine order date range
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years
FROM gold.fact_sales;


-- Analyze customer birthdates
-- Determine oldest and youngest customers
SELECT
    MIN(birthdate) AS oldest_customer_birthdate,
    DATEDIFF(year, MIN(birthdate), GETDATE()) AS age_of_oldest_customer,
    MAX(birthdate) AS youngest_customer_birthdate,
    DATEDIFF(year, MAX(birthdate), GETDATE()) AS age_of_youngest_customer
FROM gold.dim_customers;



/* ============================================================
   SECTION 4: MEASURES EXPLORATION
   Calculate key numerical metrics
============================================================ */

-- Total sales revenue
SELECT SUM(sales) AS total_sales
FROM gold.fact_sales;

-- Total quantity of items sold
SELECT SUM(quantity) AS total_quantity
FROM gold.fact_sales;

-- Average selling price
SELECT AVG(price) AS average_price
FROM gold.fact_sales;

-- Total number of orders
SELECT COUNT(order_number) AS total_orders
FROM gold.fact_sales;

-- Accurate number of unique orders
SELECT COUNT(DISTINCT order_number) AS unique_orders
FROM gold.fact_sales;

-- Total number of products
SELECT COUNT(product_number) AS total_products
FROM gold.dim_products;

SELECT COUNT(DISTINCT product_number) AS unique_products
FROM gold.dim_products;

-- Total number of customers
SELECT COUNT(customer_key) AS total_customers
FROM gold.dim_customers;

SELECT COUNT(DISTINCT customer_number) AS unique_customers
FROM gold.dim_customers;

-- Total number of customers who placed at least one order
SELECT COUNT(customer_key) AS customer_orders
FROM gold.fact_sales;

SELECT COUNT(DISTINCT customer_key) AS unique_customers_with_orders
FROM gold.fact_sales;



/* ============================================================
   SECTION 5: BUSINESS KPI REPORT
   Generate a single report with key business metrics
============================================================ */

SELECT 'Total Sales' AS measure_name, SUM(sales) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT 'Total Quantity', SUM(quantity)
FROM gold.fact_sales

UNION ALL

SELECT 'Average Price', AVG(price)
FROM gold.fact_sales

UNION ALL

SELECT 'Total Number of Orders', COUNT(DISTINCT order_number)
FROM gold.fact_sales

UNION ALL

SELECT 'Total Number of Customers', COUNT(customer_key)
FROM gold.dim_customers

UNION ALL

SELECT 'Total Number of Products', COUNT(product_number)
FROM gold.dim_products;



/* ============================================================
   SECTION 6: MAGNITUDE EXPLORATION
   Analyze distributions and aggregated metrics
============================================================ */

-- Total customers by country
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Total customers by gender
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Total products by category
SELECT
    category,
    COUNT(product_name) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Average product cost per category
SELECT
    category,
    AVG(cost) AS average_cost
FROM gold.dim_products
GROUP BY category
ORDER BY average_cost DESC;

-- Total revenue generated by each product category
SELECT
    p.category,
    SUM(f.sales) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Total revenue generated by each customer
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(f.sales) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- Distribution of sold items across countries
SELECT
    c.country,
    SUM(f.quantity) AS total_items_sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_items_sold DESC;



/* ============================================================
   SECTION 7: RANKING ANALYSIS
   Identify top and bottom performers
============================================================ */

-- Top 5 products generating the highest revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Bottom 5 products generating the lowest revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

-- Top 10 customers generating the highest revenue
SELECT *
FROM (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(f.sales) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(f.sales) DESC) AS revenue_rank
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
) ranked_customers
WHERE revenue_rank <= 10;

-- Three customers with the fewest orders placed
SELECT TOP 3
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_orders ASC;
