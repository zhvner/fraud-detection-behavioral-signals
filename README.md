# Detecting Fraudulent Financial Activity Using Behavioral Signals and Machine Learning

> A personal research project on synthetic data generation and fraud detection. Built from scratch using Python, scikit-learn, XGBoost, and Oracle.

---

## Motivation

During my Data Science Engineering internship at Mastercard, I worked on financial fraud detection and anomaly analysis as part of our team's internal hackathon. That experience sparked my curiosity about how behavioral signals. The way people transact, not just what they transact can reveal fraudulent activity.

This project is my independent deep dive into that problem. I designed the entire pipeline from scratch: generating realistic synthetic transaction data, engineering behavioral features, training and comparing ML models, and storing everything in an Oracle-compatible schema. No starter code, no templates, just me exploring how data synthesis and machine learning can tackle fraud detection in fintech.

## What I Built

- **Synthetic data generator from scratch**: 50,000 transactions across 2,000 customers with 5 realistic fraud archetypes (card testing, account takeover, bust-out, identity theft, friendly fraud), built using statistical distributions and behavioral modeling
- **17 engineered behavioral features**: transaction velocity, amount z-scores, geographic mismatches, temporal anomalies, session patterns, and a composite risk score
- **3 ML models compared**: Logistic Regression, Random Forest, and XGBoost with class-balanced training for imbalanced data
- **Oracle database layer**: full DDL schema, analytical queries, and bulk-load scripts
- **End-to-end reproducible pipeline**: one command (`make run-all`) runs everything

## Why Synthetic Data?

Real financial transaction data is sensitive and hard to access. Instead of relying on overused public datasets, I researched how to generate realistic synthetic data that preserves the statistical properties and behavioral patterns of real-world fraud. This involved modeling customer spending profiles with lognormal distributions, simulating fraud patterns based on documented attack vectors, engineering features that capture the *behavioral* difference between legitimate and fraudulent transactions, and maintaining a realistic class imbalance (~3.5% fraud rate).

The data generation logic itself is a core contribution of this project — not just a preprocessing step.

## Repository Structure

```
fraud-detection-project/
│
├── README.md
├── requirements.txt
├── .gitignore
├── Makefile                           ← Run pipeline with make commands
│
├── configs/
│   └── config.yaml                    ← Hyperparameters, paths, constants
│
├── data/
│   ├── raw/                           ← Generated CSVs (immutable)
│   │   ├── customers.csv
│   │   └── transactions.csv
│   ├── processed/                     ← Train/test splits after feature engineering
│   └── external/
│
├── notebooks/                         ← Walkthrough notebooks (numbered)
│   ├── 01_data_generation.ipynb
│   ├── 02_eda.ipynb
│   ├── 03_feature_engineering.ipynb
│   ├── 04_modeling.ipynb
│   └── 05_evaluation.ipynb
│
├── src/                               ← Reusable Python modules
│   ├── data/
│   │   ├── generate_dataset.py        ← Synthetic data generator (core of project)
│   │   └── data_loader.py
│   ├── features/
│   │   ├── behavioral_features.py     ← Velocity, timing, geo features
│   │   └── feature_pipeline.py
│   ├── models/
│   │   ├── train.py
│   │   ├── evaluate.py
│   │   └── predict.py
│   ├── visualization/
│   │   └── plots.py
│   └── utils/
│       └── helpers.py
│
├── sql/                               ← Oracle database layer
│   ├── ddl/create_tables.sql
│   ├── queries/fraud_analysis.sql
│   └── scripts/bulk_load.sql
│
├── tests/
│   ├── test_data_generation.py
│   ├── test_features.py
│   └── test_models.py
│
├── outputs/                           ← Git-ignored: saved models, figures, results
│
└── docs/
    ├── data_dictionary.json
    └── reports/final_report.md
```

## Quick Start

```bash
# Clone and set up
git clone https://github.com/yourusername/fraud-detection-behavioral-signals.git
cd fraud-detection-behavioral-signals

python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Generate the dataset
python src/data/generate_dataset.py

# Run full pipeline
make run-all
```

## Models & Results

| Model               | ROC-AUC | Precision | Recall | F1-Score |
|---------------------|---------|-----------|--------|----------|
| Logistic Regression | —       | —         | —      | —        |
| Random Forest       | —       | —         | —      | —        |
| XGBoost             | —       | —         | —      | —        |

> Results will be filled in after running the full pipeline.

## Key Behavioral Features

| Feature                 | What it captures                                 | Signal |
|-------------------------|--------------------------------------------------|--------|
| `behavioral_risk_score` | Composite score from all behavioral signals       | High   |
| `amount_zscore`         | How unusual is this amount for this customer?     | High   |
| `ip_velocity`           | Transaction frequency from same IP                | High   |
| `failed_auth_count`     | Failed login attempts before transaction          | High   |
| `province_mismatch`     | Transaction location ≠ home location              | Medium |
| `is_night`              | Transactions between 10pm–5am                     | Medium |
| `short_session_flag`    | Session under 15 seconds (bot-like behavior)      | Medium |

## Oracle Integration

The `sql/` directory contains everything needed to deploy to Oracle:
- `ddl/create_tables.sql` — Schema with proper data types, indexes, and foreign keys
- `queries/fraud_analysis.sql` — 8 ready-to-run analytical queries
- `scripts/bulk_load.sql` — External table setup for CSV bulk import

## Future Work

- **Graph analysis** — model transaction networks to detect fraud rings
- **Anomaly detection** — Isolation Forest and Autoencoders for unsupervised detection
- **Real-time scoring** — stream processing for online model serving
- **SHAP explanations** — per-transaction feature contribution for analyst review

## Tech Stack

- **Languages**: Python 3.10+, SQL (Oracle)
- **Libraries**: pandas, scikit-learn, XGBoost, numpy, matplotlib, seaborn, scipy
- **Database**: Oracle
- **Tools**: Jupyter, Git, Make

## License

MIT

---

*Built from scratch as an independent research project, inspired by my fraud detection work at Mastercard.*
