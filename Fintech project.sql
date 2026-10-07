CREATE DATABASE financial_operations;

USE financial_operations;

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(255),
    age INT,
    gender VARCHAR(20),
    city VARCHAR(100),
    account_type VARCHAR(50),
    customer_segment VARCHAR(50),
    kyc_status VARCHAR(30),
    onboarding_date DATE
);

CREATE TABLE transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    transaction_timestamp DATETIME,
    transaction_type VARCHAR(50),
    amount DECIMAL(14,2),
    merchant_category VARCHAR(100),
    payment_channel VARCHAR(50),
    transaction_status VARCHAR(50),
    is_international INT,
    failed_attempts INT
);

CREATE TABLE service_cases (
    case_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    transaction_id VARCHAR(20),
    created_at DATETIME,
    case_type VARCHAR(100),
    priority VARCHAR(30),
    status VARCHAR(50),
    resolution_time_hours DECIMAL(10,2),
    sla_breached BOOLEAN,
    channel VARCHAR(50),
    customer_query TEXT
);

CREATE TABLE fraud_alerts (
    alert_id VARCHAR(20) PRIMARY KEY,
    transaction_id VARCHAR(20),
    alert_timestamp DATETIME,
    anomaly_score DECIMAL(5,3),
    alert_type VARCHAR(100),
    risk_level VARCHAR(30),
    investigation_status VARCHAR(50),
    analyst_action VARCHAR(100)
);
SELECT * FROM customers LIMIT 10;

SELECT COUNT(*) FROM customers;

SELECT COUNT(*) FROM service_cases;

SELECT COUNT(*) FROM transactions;

SELECT COUNT(*) FROM fraud_alerts;


SELECT COUNT(*) AS customers
FROM customers;

SELECT COUNT(*) AS transactions
FROM transactions;

SELECT COUNT(*) AS service_cases
FROM service_cases;

SELECT COUNT(*) AS fraud_alerts
FROM fraud_alerts;

USE financial_operations;

SELECT COUNT(*) FROM service_cases;

DROP TABLE IF EXISTS service_cases;

CREATE TABLE service_cases (
    case_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    transaction_id VARCHAR(20),
    created_at DATE,
    case_type VARCHAR(100),
    priority VARCHAR(30),
    status VARCHAR(50),
    resolution_time_hours DECIMAL(10,2),
    sla_breached BOOLEAN,
    channel VARCHAR(50),
    customer_query TEXT
);


ALTER TABLE service_cases MODIFY column sla_breached VARCHAR(5);
SELECT COUNT(*) AS service_cases
FROM service_cases;

SHOW CREATE TABLE transactions;

SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
REFERENCED_TABLE_NAME,
REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'financial_operations'
AND REFERENCED_TABLE_NAME IS NOT NULL;
  
ALTER TABLE transactions
DROP FOREIGN KEY fk_transactions_customer_ref;

SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'financial_operations'
  AND REFERENCED_TABLE_NAME IS NOT NULL;
  
SELECT sc.customer_id
FROM service_cases sc
LEFT JOIN customers c
ON sc.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


SELECT sc.transaction_id
FROM service_cases sc
LEFT JOIN transactions t
ON sc.transaction_id = t.transaction_id
WHERE t.transaction_id IS NULL;

SELECT fa.transaction_id
FROM fraud_alerts fa
LEFT JOIN transactions t
    ON fa.transaction_id = t.transaction_id
WHERE t.transaction_id IS NULL;

SELECT fa.*
FROM fraud_alerts fa
LEFT JOIN transactions t
    ON fa.transaction_id = t.transaction_id
WHERE t.transaction_id IS NULL;

SELECT fa.*
FROM fraud_alerts fa
LEFT JOIN transactions t
    ON fa.transaction_id = t.transaction_id
WHERE t.transaction_id IS NULL;


ALTER TABLE fraud_alerts
ADD CONSTRAINT fk_fraud_transaction
FOREIGN KEY (transaction_id)
REFERENCES transactions(transaction_id);

SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'financial_operations'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

ALTER TABLE fraud_alerts
DROP FOREIGN KEY fk_fraud_transaction_ref;

SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'financial_operations'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- Data Quality Checks
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'fraud_alerts', COUNT(*) FROM fraud_alerts
UNION ALL
SELECT 'service_cases', COUNT(*) FROM service_cases;

-- Check NULL values

SELECT
    COUNT(*) AS total_rows,
    SUM(customer_id IS NULL) AS null_customer_id
FROM customers;

SELECT
    COUNT(*) AS total_rows,
    SUM(transaction_id IS NULL) AS null_transaction_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(amount IS NULL) AS null_amount
FROM transactions;

SELECT
    COUNT(*) AS total_rows,
    SUM(alert_id IS NULL) AS null_alert_id,
    SUM(transaction_id IS NULL) AS null_transaction_id
FROM fraud_alerts;

SELECT
    COUNT(*) AS total_rows,
    SUM(case_id IS NULL) AS null_case_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(transaction_id IS NULL) AS null_transaction_id
FROM service_cases;

-- Check duplicate primary keys

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT transaction_id, COUNT(*)
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

SELECT alert_id, COUNT(*)
FROM fraud_alerts
GROUP BY alert_id
HAVING COUNT(*) > 1;

SELECT case_id, COUNT(*)
FROM service_cases
GROUP BY case_id
HAVING COUNT(*) > 1;

-- Check invalid values
SELECT *
FROM transactions
WHERE amount < 0;

SELECT
    transaction_type,
    COUNT(*) AS total_transactions,
    MIN(amount) AS minimum_amount,
    MAX(amount) AS maximum_amount
FROM transactions
GROUP BY transaction_type;

SELECT *
FROM transactions
WHERE amount < 0;

UPDATE transactions
SET amount = ABS(amount)
WHERE transaction_id IN (
    SELECT transaction_id
    FROM (
        SELECT transaction_id
        FROM transactions
        WHERE amount < 0
    ) AS temp
);

SELECT *
FROM transactions
WHERE amount < 0;

SET SQL_SAFE_UPDATES = 0;
UPDATE transactions
SET amount = ABS(amount)
WHERE amount < 0;
SET SQL_SAFE_UPDATES = 1;







