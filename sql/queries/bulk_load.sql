-- ============================================================================
-- Oracle Bulk Load Script
-- Load CSVs into Oracle using External Tables
-- ============================================================================

-- Step 1: Create an Oracle directory pointing to your CSV location
-- (Run as SYSDBA or a user with CREATE DIRECTORY privilege)
CREATE OR REPLACE DIRECTORY fraud_data_dir AS '/path/to/your/data/raw';
GRANT READ ON DIRECTORY fraud_data_dir TO fraud_user;

-- Step 2: External table for customers CSV
CREATE TABLE customers_ext (
    customer_id         VARCHAR2(20),
    province            VARCHAR2(5),
    account_age_days    NUMBER(6),
    avg_monthly_spend   NUMBER(12,2),
    avg_txn_amount      NUMBER(12,2),
    typical_peak_hour   NUMBER(4,1),
    preferred_channel   VARCHAR2(20),
    preferred_device    VARCHAR2(20),
    risk_score_initial  NUMBER(6,4)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY fraud_data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1  -- skip CSV header
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('customers.csv')
)
REJECT LIMIT UNLIMITED;

-- Step 3: Load customers from external table
INSERT INTO customers (
    customer_id, province, account_age_days,
    avg_monthly_spend, avg_txn_amount, typical_peak_hour,
    preferred_channel, preferred_device, risk_score_initial
)
SELECT * FROM customers_ext;
COMMIT;

-- Step 4: External table for transactions CSV
CREATE TABLE transactions_ext (
    customer_id         VARCHAR2(20),
    txn_timestamp_str   VARCHAR2(30),
    amount              NUMBER(12,2),
    merchant_category   VARCHAR2(30),
    channel             VARCHAR2(20),
    device_type         VARCHAR2(20),
    txn_province        VARCHAR2(5),
    home_province       VARCHAR2(5),
    ip_velocity         NUMBER(5),
    session_duration_s  NUMBER(8),
    failed_auth_count   NUMBER(3),
    is_international    NUMBER(1),
    is_fraud            NUMBER(1),
    hour_of_day         NUMBER(2),
    day_of_week         NUMBER(1),
    is_weekend          NUMBER(1),
    is_night            NUMBER(1),
    province_mismatch   NUMBER(1),
    cust_avg_amount     NUMBER(12,2),
    cust_std_amount     NUMBER(12,2),
    amount_zscore       NUMBER(8,4),
    high_velocity_flag  NUMBER(1),
    short_session_flag  NUMBER(1),
    behavioral_risk_score NUMBER(6,4)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY fraud_data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('transactions.csv')
)
REJECT LIMIT UNLIMITED;

-- Step 5: Load transactions with timestamp conversion
INSERT INTO fraud_transactions (
    customer_id, txn_timestamp, amount,
    merchant_category, channel, device_type,
    txn_province, home_province, ip_velocity,
    session_duration_s, failed_auth_count, is_international,
    hour_of_day, day_of_week, is_weekend, is_night,
    province_mismatch, amount_zscore, high_velocity_flag,
    short_session_flag, behavioral_risk_score, is_fraud
)
SELECT 
    customer_id,
    TO_TIMESTAMP(txn_timestamp_str, 'YYYY-MM-DD HH24:MI:SS'),
    amount,
    merchant_category, channel, device_type,
    txn_province, home_province, ip_velocity,
    session_duration_s, failed_auth_count, is_international,
    hour_of_day, day_of_week, is_weekend, is_night,
    province_mismatch, amount_zscore, high_velocity_flag,
    short_session_flag, behavioral_risk_score, is_fraud
FROM transactions_ext;
COMMIT;

-- Step 6: Verify load
SELECT 'customers' AS tbl, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'transactions', COUNT(*) FROM fraud_transactions;

-- Step 7: Cleanup external tables (optional)
-- DROP TABLE customers_ext;
-- DROP TABLE transactions_ext;

-- ============================================================================
-- ALTERNATIVE: SQL*Loader control file (save as customers.ctl)
-- ============================================================================
-- 
-- LOAD DATA
-- INFILE 'customers.csv'
-- INTO TABLE customers
-- FIELDS TERMINATED BY ','
-- OPTIONALLY ENCLOSED BY '"'
-- TRAILING NULLCOLS
-- (
--     customer_id,
--     province,
--     account_age_days,
--     avg_monthly_spend,
--     avg_txn_amount,
--     typical_peak_hour,
--     preferred_channel,
--     preferred_device,
--     risk_score_initial
-- )
