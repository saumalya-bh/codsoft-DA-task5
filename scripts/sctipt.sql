-- ============================================================
-- ApexPlanet Data Analytics Internship - Task 2
-- File: queries.sql
-- Description: SQL Queries for Data Extraction & Analysis
-- ============================================================

-- ------------------------------------------------------------
-- 1. BASIC QUERIES
-- ------------------------------------------------------------

-- Query 1: Total Record Count
SELECT COUNT(*) AS total_transactions 
FROM sales_data;

-- Query 2: View First 10 Transactions
SELECT * 
FROM sales_data 
LIMIT 10;

-- Query 3: Filter High-Value Orders (Sales > 500)
SELECT Order_ID, Customer_Name, Sales, Profit
FROM sales_data
WHERE Sales > 500
ORDER BY Sales DESC;


-- ------------------------------------------------------------
-- 2. AGGREGATIONS & GROUPING
-- ------------------------------------------------------------

-- Query 4: Total Revenue and Total Profit by Category
SELECT 
    Category,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales_data
GROUP BY Category
ORDER BY total_revenue DESC;

-- Query 5: Top 5 Best-Selling Products by Quantity
SELECT 
    Product_Name,
    SUM(Quantity) AS total_quantity_sold
FROM sales_data
GROUP BY Product_Name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- Query 6: Categories with Profit Margin Above $1,000 (HAVING clause)
SELECT 
    Category,
    SUM(Profit) AS total_profit
FROM sales_data
GROUP BY Category
HAVING total_profit > 1000;


-- ------------------------------------------------------------
-- 3. ADVANCED SQL (CTEs, Subqueries & Window Functions)
-- ------------------------------------------------------------

-- Query 7: Filter Orders with Sales Greater Than the Average Sale (Subquery)
SELECT 
    Order_ID, 
    Sales 
FROM sales_data
WHERE Sales > (SELECT AVG(Sales) FROM sales_data)
LIMIT 10;

-- Query 8: Calculate Customer Spend using Common Table Expression (CTE)
WITH CustomerSpend AS (
    SELECT 
        Customer_Name,
        SUM(Sales) AS total_spent
    FROM sales_data
    GROUP BY Customer_Name
)
SELECT 
    Customer_Name, 
    ROUND(total_spent, 2) AS total_spent
FROM CustomerSpend
WHERE total_spent > 2000
ORDER BY total_spent DESC;

-- Query 9: Rank Top Products Within Each Category (Window Function)
WITH RankedProducts AS (
    SELECT 
        Category,
        Product_Name,
        SUM(Sales) AS total_sales,
        DENSE_RANK() OVER (PARTITION BY Category ORDER BY SUM(Sales) DESC) as rank
    FROM sales_data
    GROUP BY Category, Product_Name
)
SELECT * 
FROM RankedProducts 
WHERE rank <= 3;

-- Query 10: Monthly Revenue Trend (Extracting Month & Year)
SELECT 
    strftime('%Y-%m', Order_Date) AS month_year,
    ROUND(SUM(Sales), 2) AS monthly_revenue
FROM sales_data
GROUP BY month_year
ORDER BY month_year ASC;