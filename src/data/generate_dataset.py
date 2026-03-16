"""
============================================================================
Synthetic Fraud Detection Dataset Generator
============================================================================
Author: Zhanerke Zhumash
Project: Detecting Fraudulent Financial Activity Using Behavioral Signals
         and Machine Learning

Personal research project built from scratch, inspired by fraud detection
and anomaly analysis work during my Mastercard internship (internal hackathon).

Generates realistic financial transaction data with:
  - Behavioral signals (velocity, timing, amount patterns)
  - 5 fraud archetypes modeled from documented attack vectors
  - Oracle-compatible SQL DDL + INSERT statements
  - CSV export for ML pipelines

Approach:
  - Lognormal distributions for realistic spending profiles
  - Per-customer behavioral baselines (peak hours, preferred channels)
  - Fraud patterns with distinct behavioral anomaly signatures
  - Realistic class imbalance (~3.5% fraud rate)
============================================================================
"""

import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import random
import os
import json

# ── Configuration ──────────────────────────────────────────────────────────
np.random.seed(42)
random.seed(42)

NUM_CUSTOMERS    = 2000
NUM_TRANSACTIONS = 50000
FRAUD_RATE       = 0.035  # ~3.5% fraud rate (realistic for fintech)
START_DATE       = datetime(2024, 1, 1)
END_DATE         = datetime(2025, 1, 1)

MERCHANT_CATEGORIES = [
    'grocery', 'restaurant', 'online_retail', 'travel', 'gas_station',
    'entertainment', 'healthcare', 'utilities', 'electronics', 'atm_withdrawal',
    'peer_transfer', 'investment', 'subscription', 'luxury_goods', 'gambling'
]

CHANNELS = ['mobile_app', 'web', 'pos_terminal', 'atm', 'phone']

DEVICE_TYPES = ['ios', 'android', 'desktop_browser', 'unknown']

PROVINCES = ['ON', 'BC', 'AB', 'QC', 'MB', 'SK', 'NS', 'NB', 'NL', 'PE']


# ── Step 1: Generate Customer Profiles ─────────────────────────────────────
def generate_customers(n):
    """Create customer profiles with behavioral baselines."""
    customers = []
    for i in range(1, n + 1):
        avg_monthly_spend = np.random.lognormal(mean=7.0, sigma=0.8)
        avg_transaction   = avg_monthly_spend / np.random.randint(10, 40)
        peak_hour = np.random.normal(14, 3)
        account_age = np.random.randint(30, 1500)
        
        customers.append({
            'customer_id':        f'CUST_{i:06d}',
            'province':           np.random.choice(PROVINCES, p=[0.38, 0.14, 0.12, 0.22, 0.04, 0.03, 0.03, 0.02, 0.01, 0.01]),
            'account_age_days':   account_age,
            'avg_monthly_spend':  round(avg_monthly_spend, 2),
            'avg_txn_amount':     round(avg_transaction, 2),
            'typical_peak_hour':  round(np.clip(peak_hour, 0, 23), 1),
            'preferred_channel':  np.random.choice(CHANNELS, p=[0.40, 0.25, 0.20, 0.10, 0.05]),
            'preferred_device':   np.random.choice(DEVICE_TYPES, p=[0.40, 0.35, 0.20, 0.05]),
            'risk_score_initial': round(np.random.beta(2, 8), 4),
        })
    return pd.DataFrame(customers)


# ── Step 2: Generate Legitimate Transactions ───────────────────────────────
def generate_legitimate_transactions(customers_df, n_legit):
    """Generate normal transaction patterns based on customer profiles."""
    transactions = []
    date_range_seconds = (END_DATE - START_DATE).total_seconds()
    
    for _ in range(n_legit):
        cust = customers_df.sample(1).iloc[0]
        
        random_ts = START_DATE + timedelta(seconds=random.random() * date_range_seconds)
        hour_shift = np.random.normal(cust['typical_peak_hour'], 3)
        random_ts = random_ts.replace(hour=int(np.clip(hour_shift, 0, 23)))
        
        amount = np.random.lognormal(
            mean=np.log(cust['avg_txn_amount']),
            sigma=0.5
        )
        amount = round(np.clip(amount, 0.50, cust['avg_monthly_spend'] * 0.8), 2)
        
        category = np.random.choice(MERCHANT_CATEGORIES, 
            p=[0.20, 0.15, 0.15, 0.05, 0.08, 0.07, 0.05, 0.05, 0.05, 0.05, 0.04, 0.02, 0.02, 0.01, 0.01])
        
        if random.random() < 0.7:
            channel = cust['preferred_channel']
        else:
            channel = np.random.choice(CHANNELS)
        
        if random.random() < 0.75:
            device = cust['preferred_device']
        else:
            device = np.random.choice(DEVICE_TYPES)
        
        if random.random() < 0.85:
            txn_province = cust['province']
        else:
            txn_province = np.random.choice(PROVINCES)
        
        ip_velocity = np.random.poisson(1) + 1
        
        transactions.append({
            'customer_id':        cust['customer_id'],
            'timestamp':          random_ts,
            'amount':             amount,
            'merchant_category':  category,
            'channel':            channel,
            'device_type':        device,
            'txn_province':       txn_province,
            'home_province':      cust['province'],
            'ip_velocity':        ip_velocity,
            'session_duration_s': max(10, int(np.random.normal(180, 60))),
            'failed_auth_count':  np.random.choice([0, 0, 0, 0, 0, 1], p=[0.85, 0.03, 0.03, 0.03, 0.03, 0.03]),
            'is_international':   0,
            'is_fraud':           0
        })
    
    return transactions


# ── Step 3: Generate Fraudulent Transactions (Behavioral Anomalies) ────────
def generate_fraud_transactions(customers_df, n_fraud):
    """
    Generate fraud with realistic behavioral anomalies:
      - Unusual hours (late night)
      - High velocity bursts
      - Amount spikes
      - Geographic inconsistency
      - Channel/device switches
      - Multiple failed auth attempts
    """
    transactions = []
    date_range_seconds = (END_DATE - START_DATE).total_seconds()
    
    fraud_patterns = [
        'card_testing',       # Many small transactions in quick succession
        'account_takeover',   # Different device/location, large amounts
        'bust_out',           # Gradual escalation then large purchase
        'identity_theft',     # New device, unusual hours, different province
        'friendly_fraud',     # Normal-looking but disputed later
    ]
    
    for _ in range(n_fraud):
        cust = customers_df.sample(1).iloc[0]
        pattern = np.random.choice(fraud_patterns, p=[0.25, 0.30, 0.15, 0.20, 0.10])
        
        random_ts = START_DATE + timedelta(seconds=random.random() * date_range_seconds)
        
        if pattern == 'card_testing':
            amount = round(np.random.uniform(0.50, 5.00), 2)
            hour = np.random.choice([0, 1, 2, 3, 4, 5, 23])
            random_ts = random_ts.replace(hour=hour)
            ip_velocity = np.random.randint(8, 30)
            channel = 'web'
            device = 'unknown'
            txn_province = np.random.choice(PROVINCES)
            failed_auth = np.random.randint(2, 6)
            session_dur = np.random.randint(2, 20)
            is_international = np.random.choice([0, 1], p=[0.5, 0.5])
            
        elif pattern == 'account_takeover':
            amount = round(cust['avg_txn_amount'] * np.random.uniform(5, 20), 2)
            hour = np.random.randint(0, 24)
            random_ts = random_ts.replace(hour=hour % 24)
            ip_velocity = np.random.randint(3, 10)
            channel = np.random.choice(['web', 'mobile_app'])
            device = 'unknown' if random.random() < 0.6 else np.random.choice(DEVICE_TYPES)
            other_provinces = [p for p in PROVINCES if p != cust['province']]
            txn_province = np.random.choice(other_provinces)
            failed_auth = np.random.randint(1, 4)
            session_dur = np.random.randint(5, 45)
            is_international = np.random.choice([0, 1], p=[0.3, 0.7])
            
        elif pattern == 'bust_out':
            amount = round(cust['avg_monthly_spend'] * np.random.uniform(1.5, 4.0), 2)
            hour = np.random.randint(9, 22)
            random_ts = random_ts.replace(hour=hour)
            ip_velocity = np.random.randint(1, 4)
            channel = cust['preferred_channel']
            device = cust['preferred_device']
            txn_province = cust['province']
            failed_auth = 0
            session_dur = np.random.randint(30, 120)
            is_international = 0
            
        elif pattern == 'identity_theft':
            amount = round(np.random.uniform(100, 3000), 2)
            hour = np.random.choice([1, 2, 3, 4, 5, 22, 23])
            random_ts = random_ts.replace(hour=hour)
            ip_velocity = np.random.randint(2, 8)
            channel = np.random.choice(CHANNELS)
            device = 'unknown'
            other_provinces = [p for p in PROVINCES if p != cust['province']]
            txn_province = np.random.choice(other_provinces)
            failed_auth = np.random.randint(1, 5)
            session_dur = np.random.randint(5, 30)
            is_international = np.random.choice([0, 1], p=[0.4, 0.6])
            
        else:  # friendly_fraud
            amount = round(cust['avg_txn_amount'] * np.random.uniform(1.5, 4.0), 2)
            hour = int(np.clip(np.random.normal(cust['typical_peak_hour'], 4), 0, 23))
            random_ts = random_ts.replace(hour=hour)
            ip_velocity = np.random.poisson(1) + 1
            channel = cust['preferred_channel']
            device = cust['preferred_device']
            txn_province = cust['province']
            failed_auth = 0
            session_dur = max(10, int(np.random.normal(150, 50)))
            is_international = 0
        
        transactions.append({
            'customer_id':        cust['customer_id'],
            'timestamp':          random_ts,
            'amount':             amount,
            'merchant_category':  np.random.choice(
                ['online_retail', 'electronics', 'luxury_goods', 'gambling', 'peer_transfer', 'atm_withdrawal'],
                p=[0.25, 0.20, 0.15, 0.10, 0.15, 0.15]
            ),
            'channel':            channel,
            'device_type':        device,
            'txn_province':       txn_province,
            'home_province':      cust['province'],
            'ip_velocity':        ip_velocity,
            'session_duration_s': session_dur,
            'failed_auth_count':  failed_auth,
            'is_international':   is_international,
            'is_fraud':           1
        })
    
    return transactions


# ── Step 4: Engineer Behavioral Features ───────────────────────────────────
def engineer_features(df):
    """Add derived behavioral signal features."""
    df = df.sort_values(['customer_id', 'timestamp']).reset_index(drop=True)
    
    df['hour_of_day']    = df['timestamp'].dt.hour
    df['day_of_week']    = df['timestamp'].dt.dayofweek
    df['is_weekend']     = (df['day_of_week'] >= 5).astype(int)
    df['is_night']       = ((df['hour_of_day'] >= 22) | (df['hour_of_day'] <= 5)).astype(int)
    
    df['province_mismatch'] = (df['txn_province'] != df['home_province']).astype(int)
    
    customer_stats = df.groupby('customer_id')['amount'].agg(['mean', 'std']).reset_index()
    customer_stats.columns = ['customer_id', 'cust_avg_amount', 'cust_std_amount']
    customer_stats['cust_std_amount'] = customer_stats['cust_std_amount'].fillna(0)
    df = df.merge(customer_stats, on='customer_id', how='left')
    
    df['amount_zscore'] = np.where(
        df['cust_std_amount'] > 0,
        (df['amount'] - df['cust_avg_amount']) / df['cust_std_amount'],
        0
    )
    df['amount_zscore'] = df['amount_zscore'].round(4)
    
    df['high_velocity_flag'] = (df['ip_velocity'] > 5).astype(int)
    df['short_session_flag'] = (df['session_duration_s'] < 15).astype(int)
    
    df['behavioral_risk_score'] = (
        df['is_night'] * 0.15 +
        df['province_mismatch'] * 0.20 +
        df['high_velocity_flag'] * 0.25 +
        (df['failed_auth_count'] > 0).astype(int) * 0.20 +
        df['short_session_flag'] * 0.10 +
        df['is_international'] * 0.10
    ).round(4)
    
    return df


# ── Step 5: Generate Oracle-Compatible SQL ─────────────────────────────────
def generate_oracle_sql(customers_df, transactions_df, output_path):
    """Generate Oracle DDL + sample INSERT statements."""
    
    sql_lines = []
    sql_lines.append("""-- ============================================================================
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

""")
    
    # Sample INSERT statements for customers (first 20)
    sql_lines.append("-- ── SAMPLE CUSTOMER INSERTS ────────────────────────────────────────────")
    for _, row in customers_df.head(20).iterrows():
        sql_lines.append(
            f"INSERT INTO customers (customer_id, province, account_age_days, "
            f"avg_monthly_spend, avg_txn_amount, typical_peak_hour, "
            f"preferred_channel, preferred_device, risk_score_initial) VALUES ("
            f"'{row['customer_id']}', '{row['province']}', {row['account_age_days']}, "
            f"{row['avg_monthly_spend']}, {row['avg_txn_amount']}, {row['typical_peak_hour']}, "
            f"'{row['preferred_channel']}', '{row['preferred_device']}', {row['risk_score_initial']});"
        )
    
    # Sample INSERT statements for transactions (first 50)
    sql_lines.append("\n-- ── SAMPLE TRANSACTION INSERTS ─────────────────────────────────────────")
    for _, row in transactions_df.head(50).iterrows():
        ts = row['timestamp'].strftime('%Y-%m-%d %H:%M:%S')
        sql_lines.append(
            f"INSERT INTO fraud_transactions (customer_id, txn_timestamp, amount, "
            f"merchant_category, channel, device_type, txn_province, home_province, "
            f"ip_velocity, session_duration_s, failed_auth_count, is_international, "
            f"hour_of_day, day_of_week, is_weekend, is_night, province_mismatch, "
            f"amount_zscore, high_velocity_flag, short_session_flag, "
            f"behavioral_risk_score, is_fraud) VALUES ("
            f"'{row['customer_id']}', "
            f"TO_TIMESTAMP('{ts}', 'YYYY-MM-DD HH24:MI:SS'), "
            f"{row['amount']}, '{row['merchant_category']}', '{row['channel']}', "
            f"'{row['device_type']}', '{row['txn_province']}', '{row['home_province']}', "
            f"{row['ip_velocity']}, {row['session_duration_s']}, {row['failed_auth_count']}, "
            f"{row['is_international']}, {row['hour_of_day']}, {row['day_of_week']}, "
            f"{row['is_weekend']}, {row['is_night']}, {row['province_mismatch']}, "
            f"{row['amount_zscore']}, {row['high_velocity_flag']}, "
            f"{row['short_session_flag']}, {row['behavioral_risk_score']}, "
            f"{row['is_fraud']});"
        )
    
    # Analytical queries
    sql_lines.append("""
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
""")
    
    with open(output_path, 'w') as f:
        f.write('\n'.join(sql_lines))
    
    print(f"  Oracle SQL written to: {output_path}")


# ── Step 6: Generate Summary Report ───────────────────────────────────────
def print_dataset_summary(customers_df, transactions_df):
    """Print a comprehensive summary of the generated dataset."""
    
    total = len(transactions_df)
    fraud = transactions_df['is_fraud'].sum()
    legit = total - fraud
    
    print("\n" + "=" * 70)
    print("  SYNTHETIC FRAUD DETECTION DATASET — SUMMARY")
    print("=" * 70)
    
    print(f"\n  Customers:         {len(customers_df):,}")
    print(f"  Total Transactions:{total:,}")
    print(f"  Legitimate:        {legit:,}  ({legit/total*100:.1f}%)")
    print(f"  Fraudulent:        {fraud:,}  ({fraud/total*100:.1f}%)")
    print(f"  Date Range:        {START_DATE.date()} → {END_DATE.date()}")
    
    print(f"\n  ── Feature Columns ({len(transactions_df.columns)}) ──")
    for col in transactions_df.columns:
        dtype = transactions_df[col].dtype
        print(f"    • {col:30s}  {str(dtype):10s}")
    
    print("\n  ── Fraud vs Legit: Key Signal Comparison ──")
    for col in ['amount', 'ip_velocity', 'failed_auth_count', 'session_duration_s', 
                'behavioral_risk_score', 'amount_zscore']:
        fraud_mean = transactions_df[transactions_df['is_fraud']==1][col].mean()
        legit_mean = transactions_df[transactions_df['is_fraud']==0][col].mean()
        print(f"    {col:30s}  Fraud={fraud_mean:10.2f}  Legit={legit_mean:10.2f}")
    
    print("\n  ── Fraud Rate by Merchant Category ──")
    cat_fraud = transactions_df.groupby('merchant_category')['is_fraud'].agg(['sum', 'count'])
    cat_fraud['rate'] = (cat_fraud['sum'] / cat_fraud['count'] * 100).round(2)
    cat_fraud = cat_fraud.sort_values('rate', ascending=False)
    for cat, row in cat_fraud.iterrows():
        print(f"    {cat:20s}  {row['rate']:6.2f}%  ({int(row['sum'])} / {int(row['count'])})")
    
    print("\n" + "=" * 70)


# ══════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════
if __name__ == '__main__':
    
    OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../data/output')
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    print("\n[1/6] Generating customer profiles...")
    customers_df = generate_customers(NUM_CUSTOMERS)
    
    n_fraud = int(NUM_TRANSACTIONS * FRAUD_RATE)
    n_legit = NUM_TRANSACTIONS - n_fraud
    
    print(f"[2/6] Generating {n_legit:,} legitimate transactions...")
    legit_txns = generate_legitimate_transactions(customers_df, n_legit)
    
    print(f"[3/6] Generating {n_fraud:,} fraudulent transactions...")
    fraud_txns = generate_fraud_transactions(customers_df, n_fraud)
    
    print("[4/6] Combining and engineering features...")
    all_txns = legit_txns + fraud_txns
    transactions_df = pd.DataFrame(all_txns)
    transactions_df = transactions_df.sample(frac=1, random_state=42).reset_index(drop=True)
    
    transactions_df = engineer_features(transactions_df)
    
    print("[5/6] Saving outputs...")
    
    customers_csv = os.path.join(OUTPUT_DIR, 'customers.csv')
    transactions_csv = os.path.join(OUTPUT_DIR, 'transactions.csv')
    customers_df.to_csv(customers_csv, index=False)
    transactions_df.to_csv(transactions_csv, index=False)
    print(f"  CSV: {customers_csv}")
    print(f"  CSV: {transactions_csv}")
    
    oracle_sql_path = os.path.join(OUTPUT_DIR, 'oracle_schema_and_data.sql')
    generate_oracle_sql(customers_df, transactions_df, oracle_sql_path)
    
    data_dict = {
        "project": "Detecting Fraudulent Financial Activity Using Behavioral Signals and ML",
        "generated": datetime.now().isoformat(),
        "config": {
            "num_customers": NUM_CUSTOMERS,
            "num_transactions": NUM_TRANSACTIONS,
            "fraud_rate": FRAUD_RATE,
            "date_range": f"{START_DATE.date()} to {END_DATE.date()}"
        },
        "tables": {
            "customers": {
                "rows": len(customers_df),
                "columns": list(customers_df.columns)
            },
            "transactions": {
                "rows": len(transactions_df),
                "columns": list(transactions_df.columns),
                "label_column": "is_fraud",
                "fraud_count": int(transactions_df['is_fraud'].sum()),
                "legit_count": int((transactions_df['is_fraud'] == 0).sum())
            }
        },
        "feature_descriptions": {
            "amount":                "Transaction dollar amount",
            "merchant_category":     "Type of merchant (grocery, travel, etc.)",
            "channel":               "Transaction channel (mobile, web, POS, ATM, phone)",
            "device_type":           "Device used (ios, android, desktop, unknown)",
            "ip_velocity":           "Number of transactions from same IP in recent window",
            "session_duration_s":    "Duration of user session in seconds",
            "failed_auth_count":     "Number of failed authentication attempts before this txn",
            "is_international":      "Whether transaction originated internationally",
            "hour_of_day":           "Hour of transaction (0-23)",
            "day_of_week":           "Day of week (0=Monday, 6=Sunday)",
            "is_weekend":            "Binary flag for Saturday/Sunday",
            "is_night":              "Binary flag for 10pm-5am transactions",
            "province_mismatch":     "Binary flag: transaction province != home province",
            "amount_zscore":         "Z-score of amount relative to customer average",
            "high_velocity_flag":    "Binary flag: ip_velocity > 5",
            "short_session_flag":    "Binary flag: session < 15 seconds",
            "behavioral_risk_score": "Composite risk score (0-1) from behavioral signals"
        },
        "fraud_patterns": [
            "card_testing: Many small transactions, high velocity, unusual hours",
            "account_takeover: Different device/location, large amounts",
            "bust_out: Gradual escalation then large purchase",
            "identity_theft: New device, odd hours, different province",
            "friendly_fraud: Normal-looking but disputed later"
        ]
    }
    
    dict_path = os.path.join(OUTPUT_DIR, 'data_dictionary.json')
    with open(dict_path, 'w') as f:
        json.dump(data_dict, f, indent=2)
    print(f"  Data dictionary: {dict_path}")
    
    print("[6/6] Dataset summary:")
    print_dataset_summary(customers_df, transactions_df)
    
    print(f"\n  All files saved to: {OUTPUT_DIR}/")
    print("  Ready for ML pipeline and Oracle import!\n")
