-- ============================================================================
-- Fraud Analysis Queries — Oracle
-- Author: Zhanerke Zhumash
-- Project: Fraud Detection with Behavioral Signals
-- ============================================================================

-- 1. Fraud rate by merchant category
SELECT merchant_category,
       COUNT(*) AS total_txns,
       SUM(is_fraud) AS fraud_txns,
       ROUND(SUM(is_fraud) / COUNT(*) * 100, 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY merchant_category
ORDER BY fraud_rate_pct DESC;

-- 2. Behavioral risk score: fraud vs legit
SELECT is_fraud,
       ROUND(AVG(behavioral_risk_score), 4) AS avg_risk,
       ROUND(STDDEV(behavioral_risk_score), 4) AS std_risk,
       MIN(behavioral_risk_score) AS min_risk,
       MAX(behavioral_risk_score) AS max_risk
FROM fraud_transactions
GROUP BY is_fraud;

-- 3. Hourly fraud distribution
SELECT hour_of_day,
       COUNT(*) AS total_txns,
       SUM(is_fraud) AS fraud_count,
       ROUND(SUM(is_fraud) / COUNT(*) * 100, 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 4. High-risk transactions for analyst review
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

-- 6. Province mismatch vs fraud correlation
SELECT province_mismatch, is_fraud,
       COUNT(*) AS txn_count,
       ROUND(AVG(amount), 2) AS avg_amount
FROM fraud_transactions
GROUP BY province_mismatch, is_fraud
ORDER BY province_mismatch, is_fraud;

-- 7. Fraud by channel and device (cross-tab)
SELECT channel, device_type,
       COUNT(*) AS total,
       SUM(is_fraud) AS fraud_count,
       ROUND(SUM(is_fraud) / COUNT(*) * 100, 2) AS fraud_pct
FROM fraud_transactions
GROUP BY channel, device_type
ORDER BY fraud_pct DESC;

-- 8. Velocity-based fraud detection performance
SELECT 
    CASE 
        WHEN ip_velocity <= 2 THEN 'low (1-2)'
        WHEN ip_velocity <= 5 THEN 'medium (3-5)'
        WHEN ip_velocity <= 10 THEN 'high (6-10)'
        ELSE 'extreme (10+)'
    END AS velocity_bucket,
    COUNT(*) AS total,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) / COUNT(*) * 100, 2) AS fraud_pct
FROM fraud_transactions
GROUP BY 
    CASE 
        WHEN ip_velocity <= 2 THEN 'low (1-2)'
        WHEN ip_velocity <= 5 THEN 'medium (3-5)'
        WHEN ip_velocity <= 10 THEN 'high (6-10)'
        ELSE 'extreme (10+)'
    END
ORDER BY fraud_pct DESC;
