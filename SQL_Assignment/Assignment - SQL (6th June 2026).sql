CREATE DATABASE DataBank;
GO
USE DataBank;
GO
CREATE TABLE regions (
    region_id INT,
    region_name VARCHAR(20)
);

CREATE TABLE customer_nodes (
    customer_id INT,
    region_id INT,
    node_id INT,
    start_date DATE,
    end_date DATE
);

CREATE TABLE customer_transactions (
    customer_id INT,
    txn_date DATE,
    txn_type VARCHAR(20),
    txn_amount INT
);
INSERT INTO regions VALUES
(1,'Africa'),
(2,'America'),
(3,'Asia'),
(4,'Europe'),
(5,'Oceania');
SELECT COUNT(*) FROM customer_nodes;
SELECT COUNT(*) FROM customer_transactions;

-- A1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;


-- A2. What is the number of nodes per region?
SELECT
    r.region_name,
    COUNT(DISTINCT cn.node_id) AS number_of_nodes
FROM customer_nodes cn
JOIN regions r
    ON cn.region_id = r.region_id
GROUP BY r.region_name
ORDER BY r.region_name;


-- A3. How many customers are allocated to each region?
SELECT
    r.region_name,
    COUNT(DISTINCT cn.customer_id) AS customer_count
FROM customer_nodes cn
JOIN regions r
    ON cn.region_id = r.region_id
GROUP BY r.region_name
ORDER BY r.region_name;

-- =========================================
-- A4. How many days on average are customers
-- reallocated to a different node?
-- =========================================
SELECT
    AVG(DATEDIFF(DAY, start_date, end_date) * 1.0) AS avg_reallocation_days
FROM customer_nodes
WHERE end_date <> '9999-12-31';
-- =========================================
-- A5. Median, 80th and 95th percentile
-- reallocation days for each region
-- =========================================
WITH node_days AS (
    SELECT
        region_id,
        DATEDIFF(DAY, start_date, end_date) AS reallocation_days
    FROM customer_nodes
    WHERE end_date <> '9999-12-31'
)

SELECT DISTINCT
    r.region_name,

    PERCENTILE_CONT(0.5)
    WITHIN GROUP (ORDER BY reallocation_days)
    OVER (PARTITION BY nd.region_id) AS median,

    PERCENTILE_CONT(0.80)
    WITHIN GROUP (ORDER BY reallocation_days)
    OVER (PARTITION BY nd.region_id) AS percentile_80,

    PERCENTILE_CONT(0.95)
    WITHIN GROUP (ORDER BY reallocation_days)
    OVER (PARTITION BY nd.region_id) AS percentile_95

FROM node_days nd
JOIN regions r
    ON nd.region_id = r.region_id;

--B. Customer Transactions
-- =========================================
-- B1. Unique count and total amount
-- for each transaction type
-- =========================================
SELECT
    txn_type,
    COUNT(*) AS transaction_count,
    SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;
-- =========================================
-- B2. Average total historical deposit
-- counts and amounts for all customers
-- =========================================
WITH deposits AS (
    SELECT
        customer_id,
        COUNT(*) AS deposit_count,
        SUM(txn_amount) AS deposit_amount
    FROM customer_transactions
    WHERE txn_type = 'deposit'
    GROUP BY customer_id
)
SELECT
    AVG(CAST(deposit_count AS FLOAT)) AS avg_deposit_count,
    AVG(CAST(deposit_amount AS FLOAT)) AS avg_deposit_amount
FROM deposits;

-- =========================================
-- B3. For each month:
-- customers making >1 deposit AND
-- at least 1 purchase or 1 withdrawal
-- =========================================
WITH monthly_txns AS (
    SELECT
        customer_id,
        MONTH(txn_date) AS month_number,

        SUM(CASE WHEN txn_type='deposit' THEN 1 ELSE 0 END) AS deposits,
        SUM(CASE WHEN txn_type='purchase' THEN 1 ELSE 0 END) AS purchases,
        SUM(CASE WHEN txn_type='withdrawal' THEN 1 ELSE 0 END) AS withdrawals

    FROM customer_transactions
    GROUP BY customer_id, MONTH(txn_date)
)

SELECT
    month_number,
    COUNT(*) AS customer_count
FROM monthly_txns
WHERE deposits > 1
AND (purchases >= 1 OR withdrawals >= 1)
GROUP BY month_number
ORDER BY month_number;

-- =========================================
-- B4. What is the closing balance for each customer
-- at the end of the month?
-- =========================================
WITH monthly_balance AS (
    SELECT
        customer_id,
        YEAR(txn_date) AS year_num,
        MONTH(txn_date) AS month_num,

        SUM(
            CASE
                WHEN txn_type = 'deposit' THEN txn_amount
                WHEN txn_type IN ('purchase','withdrawal') THEN -txn_amount
                ELSE 0
            END
        ) AS net_balance
    FROM customer_transactions
    GROUP BY customer_id, YEAR(txn_date), MONTH(txn_date)
)
SELECT *
FROM monthly_balance
ORDER BY customer_id, year_num, month_num;

-- =========================================
-- B5. Percentage of customers who increase
-- closing balance by more than 5%
-- =========================================
WITH monthly_balance AS (
    SELECT
        customer_id,
        YEAR(txn_date) AS year_num,
        MONTH(txn_date) AS month_num,

        SUM(
            CASE
                WHEN txn_type='deposit' THEN txn_amount
                ELSE -txn_amount
            END
        ) AS balance
    FROM customer_transactions
    GROUP BY customer_id, YEAR(txn_date), MONTH(txn_date)
),
growth AS (
    SELECT
        customer_id,
        month_num,
        balance,
        LAG(balance) OVER (
            PARTITION BY customer_id
            ORDER BY year_num, month_num
        ) AS prev_balance
    FROM monthly_balance
)

SELECT
    100.0 *
    COUNT(CASE
        WHEN prev_balance IS NOT NULL
        AND balance > prev_balance * 1.05
        THEN 1
    END)
    / COUNT(*) AS percentage_increase
FROM growth;