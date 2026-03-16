"""
Unit tests for data generation and feature engineering.
"""

import pytest
import pandas as pd
import numpy as np
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))


class TestDataGeneration:
    """Tests for the synthetic dataset generator."""

    def test_csv_files_exist(self):
        root = Path(__file__).resolve().parent.parent
        assert (root / "data" / "raw" / "customers.csv").exists()
        assert (root / "data" / "raw" / "transactions.csv").exists()

    def test_customers_schema(self):
        root = Path(__file__).resolve().parent.parent
        df = pd.read_csv(root / "data" / "raw" / "customers.csv")
        expected_cols = [
            'customer_id', 'province', 'account_age_days',
            'avg_monthly_spend', 'avg_txn_amount', 'typical_peak_hour',
            'preferred_channel', 'preferred_device', 'risk_score_initial'
        ]
        for col in expected_cols:
            assert col in df.columns, f"Missing column: {col}"

    def test_transactions_schema(self):
        root = Path(__file__).resolve().parent.parent
        df = pd.read_csv(root / "data" / "raw" / "transactions.csv")
        assert 'is_fraud' in df.columns
        assert 'amount' in df.columns
        assert 'behavioral_risk_score' in df.columns

    def test_fraud_rate_reasonable(self):
        root = Path(__file__).resolve().parent.parent
        df = pd.read_csv(root / "data" / "raw" / "transactions.csv")
        fraud_rate = df['is_fraud'].mean()
        assert 0.01 < fraud_rate < 0.10, f"Fraud rate {fraud_rate} outside expected range"

    def test_no_null_labels(self):
        root = Path(__file__).resolve().parent.parent
        df = pd.read_csv(root / "data" / "raw" / "transactions.csv")
        assert df['is_fraud'].isnull().sum() == 0

    def test_amounts_positive(self):
        root = Path(__file__).resolve().parent.parent
        df = pd.read_csv(root / "data" / "raw" / "transactions.csv")
        assert (df['amount'] > 0).all()

    def test_behavioral_risk_score_bounded(self):
        root = Path(__file__).resolve().parent.parent
        df = pd.read_csv(root / "data" / "raw" / "transactions.csv")
        assert df['behavioral_risk_score'].min() >= 0.0
        assert df['behavioral_risk_score'].max() <= 1.0

    def test_fraud_has_higher_risk_on_average(self):
        root = Path(__file__).resolve().parent.parent
        df = pd.read_csv(root / "data" / "raw" / "transactions.csv")
        fraud_risk = df[df['is_fraud'] == 1]['behavioral_risk_score'].mean()
        legit_risk = df[df['is_fraud'] == 0]['behavioral_risk_score'].mean()
        assert fraud_risk > legit_risk, "Fraud should have higher avg risk score"
