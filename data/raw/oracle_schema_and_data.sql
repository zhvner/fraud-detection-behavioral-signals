-- ============================================================================
-- Oracle DDL: Fraud Detection Database Schema
-- Project: Detecting Fraudulent Financial Activity Using Behavioral Signals
-- ============================================================================

-- Drop existing tables (if re-running)
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE fraud_transactions CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE customers CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ── CUSTOMERS TABLE ───────────────────────────────────────────────────────
CREATE TABLE customers (
    customer_id         VARCHAR2(20)   PRIMARY KEY,
    province            VARCHAR2(5)    NOT NULL,
    account_age_days    NUMBER(6)      NOT NULL,
    avg_monthly_spend   NUMBER(12,2),
    avg_txn_amount      NUMBER(12,2),
    typical_peak_hour   NUMBER(4,1),
    preferred_channel   VARCHAR2(20),
    preferred_device    VARCHAR2(20),
    risk_score_initial  NUMBER(6,4),
    created_at          TIMESTAMP      DEFAULT SYSTIMESTAMP
);

-- ── TRANSACTIONS TABLE ────────────────────────────────────────────────────
CREATE TABLE fraud_transactions (
    txn_id              NUMBER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id         VARCHAR2(20)   NOT NULL,
    txn_timestamp       TIMESTAMP      NOT NULL,
    amount              NUMBER(12,2)   NOT NULL,
    merchant_category   VARCHAR2(30),
    channel             VARCHAR2(20),
    device_type         VARCHAR2(20),
    txn_province        VARCHAR2(5),
    home_province       VARCHAR2(5),
    ip_velocity         NUMBER(5),
    session_duration_s  NUMBER(8),
    failed_auth_count   NUMBER(3),
    is_international    NUMBER(1)      DEFAULT 0,
    -- Engineered features
    hour_of_day         NUMBER(2),
    day_of_week         NUMBER(1),
    is_weekend          NUMBER(1),
    is_night            NUMBER(1),
    province_mismatch   NUMBER(1),
    amount_zscore       NUMBER(8,4),
    high_velocity_flag  NUMBER(1),
    short_session_flag  NUMBER(1),
    behavioral_risk_score NUMBER(6,4),
    -- Label
    is_fraud            NUMBER(1)      NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- ── INDEXES ───────────────────────────────────────────────────────────────
CREATE INDEX idx_txn_customer    ON fraud_transactions(customer_id);
CREATE INDEX idx_txn_timestamp   ON fraud_transactions(txn_timestamp);
CREATE INDEX idx_txn_fraud       ON fraud_transactions(is_fraud);
CREATE INDEX idx_txn_risk_score  ON fraud_transactions(behavioral_risk_score);
CREATE INDEX idx_txn_category    ON fraud_transactions(merchant_category);


-- ── SAMPLE CUSTOMER INSERTS ────────────────────────────────────────────
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000001', 'AB', 1125, 1631.69, 81.58, 13.6, 'mobile_app', 'ios', 0.3175);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000002', 'AB', 306, 753.27, 20.36, 15.6, 'web', 'ios', 0.2058);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000003', 'AB', 1297, 1309.84, 62.37, 11.7, 'mobile_app', 'android', 0.0866);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000004', 'ON', 805, 484.33, 12.75, 13.5, 'atm', 'ios', 0.0438);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000005', 'ON', 1324, 1306.24, 52.25, 16.6, 'mobile_app', 'ios', 0.1422);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000006', 'ON', 522, 373.4, 10.09, 11.4, 'pos_terminal', 'ios', 0.1961);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000007', 'MB', 1081, 929.15, 51.62, 12.1, 'web', 'ios', 0.1802);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000008', 'NB', 642, 2138.45, 213.84, 14.9, 'pos_terminal', 'android', 0.1325);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000009', 'AB', 893, 972.21, 34.72, 11.1, 'mobile_app', 'android', 0.1385);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000010', 'QC', 711, 574.33, 52.21, 12.5, 'web', 'desktop_browser', 0.1046);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000011', 'BC', 1336, 625.38, 18.39, 13.0, 'pos_terminal', 'desktop_browser', 0.1921);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000012', 'ON', 1427, 833.66, 34.74, 11.6, 'web', 'android', 0.1783);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000013', 'ON', 1134, 597.85, 18.12, 15.4, 'phone', 'android', 0.1824);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000014', 'AB', 1469, 148.56, 9.9, 18.4, 'mobile_app', 'ios', 0.3149);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000015', 'ON', 638, 2905.73, 116.23, 12.8, 'web', 'android', 0.1032);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000016', 'QC', 518, 714.13, 44.63, 17.3, 'mobile_app', 'desktop_browser', 0.1817);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000017', 'QC', 173, 824.36, 22.28, 15.7, 'web', 'android', 0.1527);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000018', 'QC', 845, 346.53, 28.88, 17.6, 'atm', 'android', 0.1805);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000019', 'ON', 986, 978.1, 81.51, 8.2, 'pos_terminal', 'ios', 0.3944);
INSERT INTO customers (customer_id, province, account_age_days, avg_monthly_spend, avg_txn_amount, typical_peak_hour, preferred_channel, preferred_device, risk_score_initial) VALUES ('CUST_000020', 'ON', 984, 2116.77, 100.8, 19.7, 'mobile_app', 'ios', 0.1535);

-- ── SAMPLE TRANSACTION INSERTS ─────────────────────────────────────────
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-01-04 10:01:02', 'YYYY-MM-DD HH24:MI:SS'), 15.63, 'gas_station', 'mobile_app', 'unknown', 'AB', 'AB', 1, 114, 0, 0, 10, 3, 0, 0, 0, -1.2645, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-02-03 17:26:08', 'YYYY-MM-DD HH24:MI:SS'), 69.27, 'electronics', 'mobile_app', 'ios', 'AB', 'AB', 4, 270, 0, 0, 17, 5, 1, 0, 0, -0.3091, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-02-10 14:58:38', 'YYYY-MM-DD HH24:MI:SS'), 98.78, 'travel', 'mobile_app', 'unknown', 'SK', 'AB', 2, 209, 0, 0, 14, 5, 1, 0, 1, 0.2166, 0, 0, 0.2, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-02-16 12:24:55', 'YYYY-MM-DD HH24:MI:SS'), 93.88, 'grocery', 'web', 'ios', 'AB', 'AB', 3, 252, 0, 0, 12, 4, 0, 0, 0, 0.1293, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-02-25 14:17:02', 'YYYY-MM-DD HH24:MI:SS'), 60.94, 'entertainment', 'mobile_app', 'unknown', 'AB', 'AB', 1, 92, 0, 0, 14, 6, 1, 0, 0, -0.4574, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-03-15 15:20:03', 'YYYY-MM-DD HH24:MI:SS'), 61.94, 'grocery', 'mobile_app', 'ios', 'AB', 'AB', 2, 170, 0, 0, 15, 4, 0, 0, 0, -0.4396, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-04-07 06:14:19', 'YYYY-MM-DD HH24:MI:SS'), 106.31, 'restaurant', 'mobile_app', 'ios', 'AB', 'AB', 1, 147, 0, 0, 6, 6, 1, 0, 0, 0.3507, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-04-08 10:44:28', 'YYYY-MM-DD HH24:MI:SS'), 47.49, 'online_retail', 'mobile_app', 'ios', 'AB', 'AB', 2, 275, 0, 0, 10, 0, 0, 0, 0, -0.697, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-05-14 14:49:45', 'YYYY-MM-DD HH24:MI:SS'), 101.97, 'restaurant', 'mobile_app', 'ios', 'AB', 'AB', 2, 154, 0, 0, 14, 1, 0, 0, 0, 0.2734, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-07-13 09:49:37', 'YYYY-MM-DD HH24:MI:SS'), 95.57, 'atm_withdrawal', 'mobile_app', 'ios', 'AB', 'AB', 1, 155, 0, 0, 9, 5, 1, 0, 0, 0.1594, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-07-15 08:56:50', 'YYYY-MM-DD HH24:MI:SS'), 26.77, 'restaurant', 'mobile_app', 'ios', 'AB', 'AB', 2, 217, 0, 0, 8, 0, 0, 0, 0, -1.0661, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-07-30 15:27:27', 'YYYY-MM-DD HH24:MI:SS'), 48.51, 'online_retail', 'mobile_app', 'ios', 'AB', 'AB', 1, 313, 0, 0, 15, 1, 0, 0, 0, -0.6788, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-08-04 12:51:46', 'YYYY-MM-DD HH24:MI:SS'), 87.16, 'online_retail', 'phone', 'ios', 'AB', 'AB', 2, 256, 0, 0, 12, 6, 1, 0, 0, 0.0096, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-08-11 10:28:24', 'YYYY-MM-DD HH24:MI:SS'), 130.88, 'restaurant', 'mobile_app', 'unknown', 'AB', 'AB', 2, 208, 0, 0, 10, 6, 1, 0, 0, 0.7884, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000001', TO_TIMESTAMP('2024-11-07 11:27:34', 'YYYY-MM-DD HH24:MI:SS'), 254.21, 'online_retail', 'mobile_app', 'ios', 'BC', 'AB', 1, 136, 0, 0, 11, 3, 0, 0, 1, 2.9852, 0, 0, 0.2, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-01-06 19:27:21', 'YYYY-MM-DD HH24:MI:SS'), 39.2, 'travel', 'web', 'ios', 'NS', 'AB', 1, 226, 0, 0, 19, 5, 1, 0, 1, 1.1239, 0, 0, 0.2, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-01-15 23:54:21', 'YYYY-MM-DD HH24:MI:SS'), 3.43, 'online_retail', 'web', 'unknown', 'NS', 'AB', 12, 17, 3, 1, 23, 0, 0, 1, 1, -1.5819, 1, 0, 0.9, 1);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-02-04 18:35:16', 'YYYY-MM-DD HH24:MI:SS'), 10.59, 'online_retail', 'web', 'ios', 'AB', 'AB', 3, 266, 0, 0, 18, 6, 1, 0, 0, -1.0403, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-02-15 16:43:51', 'YYYY-MM-DD HH24:MI:SS'), 13.41, 'entertainment', 'web', 'ios', 'AB', 'AB', 3, 213, 0, 0, 16, 3, 0, 0, 0, -0.827, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-03-15 17:38:08', 'YYYY-MM-DD HH24:MI:SS'), 24.67, 'gambling', 'web', 'ios', 'AB', 'AB', 2, 69, 0, 0, 17, 4, 0, 0, 0, 0.0248, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-04-11 15:53:01', 'YYYY-MM-DD HH24:MI:SS'), 16.22, 'investment', 'web', 'ios', 'ON', 'AB', 2, 239, 0, 0, 15, 3, 0, 0, 1, -0.6144, 0, 0, 0.2, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-04-20 15:36:42', 'YYYY-MM-DD HH24:MI:SS'), 41.52, 'gas_station', 'web', 'desktop_browser', 'AB', 'AB', 2, 171, 0, 0, 15, 5, 1, 0, 0, 1.2994, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-05-21 13:07:11', 'YYYY-MM-DD HH24:MI:SS'), 22.89, 'atm_withdrawal', 'web', 'unknown', 'AB', 'AB', 2, 10, 0, 0, 13, 1, 0, 0, 0, -0.1099, 0, 1, 0.1, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-06-30 14:38:29', 'YYYY-MM-DD HH24:MI:SS'), 20.56, 'atm_withdrawal', 'web', 'ios', 'AB', 'AB', 2, 278, 1, 0, 14, 6, 1, 0, 0, -0.2861, 0, 0, 0.2, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-07-17 15:41:31', 'YYYY-MM-DD HH24:MI:SS'), 13.43, 'online_retail', 'web', 'ios', 'AB', 'AB', 3, 178, 0, 0, 15, 2, 0, 0, 0, -0.8255, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-07-17 16:15:34', 'YYYY-MM-DD HH24:MI:SS'), 39.71, 'travel', 'phone', 'unknown', 'AB', 'AB', 1, 109, 0, 0, 16, 2, 0, 0, 0, 1.1625, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-07-25 17:48:31', 'YYYY-MM-DD HH24:MI:SS'), 8.21, 'grocery', 'web', 'ios', 'AB', 'AB', 3, 186, 0, 0, 17, 3, 0, 0, 0, -1.2203, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-08-05 16:52:55', 'YYYY-MM-DD HH24:MI:SS'), 36.6, 'entertainment', 'web', 'ios', 'AB', 'AB', 1, 194, 0, 0, 16, 0, 0, 0, 0, 0.9272, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-08-15 18:55:22', 'YYYY-MM-DD HH24:MI:SS'), 17.22, 'utilities', 'web', 'ios', 'NB', 'AB', 2, 90, 0, 0, 18, 3, 0, 0, 1, -0.5388, 0, 0, 0.2, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-08-31 21:58:40', 'YYYY-MM-DD HH24:MI:SS'), 19.59, 'online_retail', 'web', 'ios', 'AB', 'AB', 2, 92, 0, 0, 21, 5, 1, 0, 0, -0.3595, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-09-06 13:13:33', 'YYYY-MM-DD HH24:MI:SS'), 57.42, 'online_retail', 'web', 'ios', 'AB', 'AB', 2, 149, 0, 0, 13, 4, 0, 0, 0, 2.5022, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-09-07 19:37:15', 'YYYY-MM-DD HH24:MI:SS'), 26.21, 'online_retail', 'web', 'ios', 'QC', 'AB', 3, 207, 0, 0, 19, 5, 1, 0, 1, 0.1413, 0, 0, 0.2, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-09-11 15:35:34', 'YYYY-MM-DD HH24:MI:SS'), 15.55, 'atm_withdrawal', 'web', 'ios', 'AB', 'AB', 2, 195, 0, 0, 15, 2, 0, 0, 0, -0.6651, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-09-18 14:42:47', 'YYYY-MM-DD HH24:MI:SS'), 35.47, 'investment', 'web', 'ios', 'SK', 'AB', 5, 125, 0, 0, 14, 2, 0, 0, 1, 0.8418, 0, 0, 0.2, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-10-01 13:28:05', 'YYYY-MM-DD HH24:MI:SS'), 37.61, 'grocery', 'web', 'ios', 'AB', 'AB', 2, 120, 0, 0, 13, 1, 0, 0, 0, 1.0036, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-10-13 20:10:33', 'YYYY-MM-DD HH24:MI:SS'), 14.75, 'subscription', 'web', 'ios', 'AB', 'AB', 1, 257, 0, 0, 20, 6, 1, 0, 0, -0.7256, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-11-02 14:55:10', 'YYYY-MM-DD HH24:MI:SS'), 24.8, 'utilities', 'web', 'ios', 'AB', 'AB', 3, 251, 0, 0, 14, 5, 1, 0, 0, 0.0346, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-12-04 13:47:15', 'YYYY-MM-DD HH24:MI:SS'), 13.78, 'restaurant', 'web', 'ios', 'AB', 'AB', 1, 253, 0, 0, 13, 2, 0, 0, 0, -0.799, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-12-05 07:09:00', 'YYYY-MM-DD HH24:MI:SS'), 15.46, 'online_retail', 'web', 'ios', 'AB', 'AB', 1, 191, 0, 0, 7, 3, 0, 0, 0, -0.6719, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000002', TO_TIMESTAMP('2024-12-07 15:40:31', 'YYYY-MM-DD HH24:MI:SS'), 40.26, 'travel', 'mobile_app', 'ios', 'AB', 'AB', 3, 201, 0, 0, 15, 5, 1, 0, 0, 1.2041, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000003', TO_TIMESTAMP('2024-02-11 14:01:16', 'YYYY-MM-DD HH24:MI:SS'), 58.13, 'peer_transfer', 'phone', 'android', 'AB', 'AB', 2, 129, 1, 0, 14, 6, 1, 0, 0, 0.0067, 0, 0, 0.2, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000003', TO_TIMESTAMP('2024-02-26 09:56:13', 'YYYY-MM-DD HH24:MI:SS'), 61.6, 'online_retail', 'pos_terminal', 'desktop_browser', 'AB', 'AB', 2, 209, 0, 0, 9, 0, 0, 0, 0, 0.1286, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000003', TO_TIMESTAMP('2024-03-01 01:33:59', 'YYYY-MM-DD HH24:MI:SS'), 2.55, 'online_retail', 'web', 'unknown', 'QC', 'AB', 9, 14, 3, 0, 1, 4, 0, 1, 1, -1.9444, 1, 1, 0.9, 1);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000003', TO_TIMESTAMP('2024-03-03 05:02:35', 'YYYY-MM-DD HH24:MI:SS'), 70.45, 'online_retail', 'mobile_app', 'android', 'AB', 'AB', 1, 220, 0, 0, 5, 6, 1, 1, 0, 0.4392, 0, 0, 0.15, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000003', TO_TIMESTAMP('2024-03-09 11:25:35', 'YYYY-MM-DD HH24:MI:SS'), 84.6, 'restaurant', 'web', 'android', 'AB', 'AB', 2, 215, 0, 0, 11, 5, 1, 0, 0, 0.936, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000003', TO_TIMESTAMP('2024-03-27 11:31:16', 'YYYY-MM-DD HH24:MI:SS'), 98.52, 'electronics', 'mobile_app', 'android', 'SK', 'AB', 1, 205, 0, 0, 11, 2, 0, 0, 1, 1.4246, 0, 0, 0.2, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000003', TO_TIMESTAMP('2024-04-28 10:54:28', 'YYYY-MM-DD HH24:MI:SS'), 51.0, 'online_retail', 'mobile_app', 'android', 'AB', 'AB', 2, 185, 0, 0, 10, 6, 1, 0, 0, -0.2435, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000003', TO_TIMESTAMP('2024-05-29 11:00:19', 'YYYY-MM-DD HH24:MI:SS'), 71.45, 'grocery', 'mobile_app', 'android', 'AB', 'AB', 2, 175, 0, 0, 11, 2, 0, 0, 0, 0.4743, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000003', TO_TIMESTAMP('2024-06-15 15:51:31', 'YYYY-MM-DD HH24:MI:SS'), 67.08, 'gas_station', 'mobile_app', 'android', 'AB', 'AB', 1, 166, 0, 0, 15, 5, 1, 0, 0, 0.3209, 0, 0, 0.0, 0);
INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, merchant_category, channel, device_type, txn_province, home_province, ip_velocity, session_duration_s, failed_auth_count, is_international, hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, amount_zscore, high_velocity_flag, short_session_flag, behavioral_risk_score, is_fraud) VALUES ('CUST_000003', TO_TIMESTAMP('2024-06-26 10:36:22', 'YYYY-MM-DD HH24:MI:SS'), 48.72, 'electronics', 'mobile_app', 'android', 'AB', 'AB', 2, 267, 0, 0, 10, 2, 0, 0, 0, -0.3236, 0, 0, 0.0, 0);

-- ============================================================================
-- ANALYTICAL QUERIES FOR FRAUD DETECTION
-- ============================================================================

-- 1. Fraud rate by merchant category
SELECT merchant_category,
       COUNT(*) AS total_txns,
       SUM(is_fraud) AS fraud_txns,
       ROUND(SUM(is_fraud) / COUNT(*) * 100, 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY merchant_category
ORDER BY fraud_rate_pct DESC;

-- 2. Behavioral risk score distribution: fraud vs legit
SELECT is_fraud,
       ROUND(AVG(behavioral_risk_score), 4) AS avg_risk,
       ROUND(STDDEV(behavioral_risk_score), 4) AS std_risk,
       MIN(behavioral_risk_score) AS min_risk,
       MAX(behavioral_risk_score) AS max_risk
FROM fraud_transactions
GROUP BY is_fraud;

-- 3. Hourly fraud pattern
SELECT hour_of_day,
       COUNT(*) AS total_txns,
       SUM(is_fraud) AS fraud_count,
       ROUND(SUM(is_fraud) / COUNT(*) * 100, 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 4. High-risk transactions (candidates for review)
SELECT txn_id, customer_id, amount, txn_timestamp,
       behavioral_risk_score, is_fraud
FROM fraud_transactions
WHERE behavioral_risk_score >= 0.50
ORDER BY behavioral_risk_score DESC
FETCH FIRST 100 ROWS ONLY;

-- 5. Customer-level fraud summary
SELECT c.customer_id, c.province, c.avg_monthly_spend,
       COUNT(t.txn_id) AS total_txns,
       SUM(t.is_fraud) AS fraud_txns,
       ROUND(AVG(t.amount), 2) AS avg_txn_amount,
       ROUND(AVG(t.behavioral_risk_score), 4) AS avg_risk_score
FROM customers c
JOIN fraud_transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.province, c.avg_monthly_spend
HAVING SUM(t.is_fraud) > 0
ORDER BY fraud_txns DESC;

-- 6. Province mismatch analysis
SELECT province_mismatch, is_fraud,
       COUNT(*) AS txn_count,
       ROUND(AVG(amount), 2) AS avg_amount
FROM fraud_transactions
GROUP BY province_mismatch, is_fraud
ORDER BY province_mismatch, is_fraud;
