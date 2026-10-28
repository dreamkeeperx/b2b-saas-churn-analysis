# B2B SaaS Churn Analysis

Which customers leave, why, and who should the customer success team call first? Exploratory analysis, a rule-based risk score and a prioritized retention list on a B2B SaaS dataset (Python + SQL).

🇷🇺 [Русская версия](README.ru.md)

## Overview

A SaaS company loses about 2% of its clients, but not all losses cost the same. This project answers three questions:

1. Which client segments churn most often, and how much revenue (MRR) does it cost?
2. Which signals are linked to churn: payment status, feature adoption, seat utilization, support tickets?
3. Which active clients should be contacted first, based on risk and MRR?

The risk score is built from simple, explainable rules (no machine learning), and it is validated against actual churn.

## Key Results

**1. Ten percent of clients bring three quarters of the revenue.** The Enterprise segment is 9.9% of clients and 75.4% of MRR, so one lost Enterprise account costs as much as dozens of Mass accounts. Logo churn is 1.8% (916 of 50,000 clients), while MRR churn is lower, 1.2% ($396,040 of about $33.3M monthly MRR), because churned clients are smaller on average.

![Share of clients vs share of MRR](images/mrr_segments.png)

**2. Payment problems, low product usage and many tickets go together with churn.**

- Failed payment: 14.5% churn vs 1.1% for clients with an active payment status.
- Feature adoption: 5.1% churn in the lowest fifth of clients vs 0.2% in the highest fifth.
- Seat utilization: 5.0% churn in the lowest fifth vs 0.2% in the highest fifth.
- Support tickets: 6.6% churn at 6-8 tickets in 30 days vs 0.3% at 0-2 tickets.

![Churn rate by key drivers](images/churn_drivers.png)

**3. A simple risk score separates clients well.** The score is the number of risk flags (0-4). Churn rate grows with every flag, and clients with all four flags churn at 44.7%, about 24 times the average.

![Churn rate by risk score](images/churn_by_risk_score.png)

| Risk level | Flags | Clients | Share of clients | Churned | Share of churned | Churn rate | vs average |
|---|---|---:|---:|---:|---:|---:|---:|
| Low | 0 | 30,404 | 60.8% | 109 | 11.9% | 0.4% | 0.2x |
| Medium | 1-2 | 14,624 | 29.2% | 381 | 41.6% | 2.6% | 1.4x |
| High | 3-4 | 4,972 | 9.9% | 426 | 46.5% | 8.6% | 4.7x |

The High group is 10% of clients but almost half of all churned clients.

![Share of clients vs share of churned clients by risk level](images/risk_levels.png)

**4. A priority list for the customer success team.** For every active client, expected loss = churn rate of the client's risk-score group x MRR. The ranking uses the risk score, not only the risk level: a client with four flags and $1,713 MRR ranks above a client with three flags and $8,491 MRR.

| Client | Segment | MRR | Risk score | Expected loss | Reasons | Recommended action |
|---|---|---:|---:|---:|---|---|
| CUST-39138 | Enterprise | $7,799 | 4 | $3,489 | Failed payment; Low feature adoption; Low seat utilization; Many support tickets | Contact the client to resolve the failed payment |
| CUST-44183 | Enterprise | $6,871 | 4 | $3,074 | same four flags | same action |
| CUST-22228 | Enterprise | $6,363 | 4 | $2,847 | same four flags | same action |

All top-20 clients are Enterprise. For lower-priced segments (Mass, Economy, Business) there is a separate list of the 5 riskiest clients per segment, meant for automated retention scenarios instead of personal calls. Full lists: [`data/priority_list_top20.csv`](data/priority_list_top20.csv) and [`data/priority_list_auto_segments.csv`](data/priority_list_auto_segments.csv).

## Dataset

[B2B SaaS Churn Dataset](https://www.kaggle.com/datasets/mpsynthetics/b2b-saas-churn-dataset) from Kaggle: 50,000 clients, 18 columns (company profile, plan, billing cycle, MRR, signup and last activity dates, payment status, seats used and allowed, support tickets in the last 30 days, feature adoption rate, churn risk score, churn flag).

**Data notes**

- The dataset is synthetic, so the patterns reflect how the data was generated, not real customer behavior.
- `days_since_last_active` separates the groups perfectly: churned clients have 30 or more days, active clients have 13 or fewer. In other words, it defines churn, so it is not used as a risk flag. The built-in `Churn_Risk_Score` is also not used: it is a ready-made score of unknown origin.
- `tenure_days` is measured from signup to the latest activity date in the data (the same date for all clients), so it does not depend on whether a client churned.
- MRR segments follow the price list: Mass $49-79, Economy $99-129, Business $249-299, Premium $399-499 (plus 79 accounts at $1,500-1,598) and Enterprise from $1,602 up to $8,499 (individual prices).

## Methodology

1. **Cleaning and audit** - types, missing values, duplicates, unique IDs, dates, percentages stored as text.
2. **Feature engineering** - seat utilization, days since last activity, tenure, tickets per seat, MRR per seat, MRR segment.
3. **KPIs and segments** - logo churn, MRR churn, churn rate by plan, billing cycle, payment status, industry, country, account manager, company size, MRR segment.
4. **SQL analysis** - queries on the cleaned data ([`sql/churn_queries.sql`](sql/churn_queries.sql)).
5. **Risk score** - four binary flags, the score is their sum:

   | Flag | Rule |
   |---|---|
   | Failed payment | `payment_status = Failed` |
   | Low feature adoption | at or below the 20th percentile (about 52%) |
   | Low seat utilization | at or below the 20th percentile (about 46%) |
   | Many support tickets | 5 or more tickets in 30 days |

   Risk levels: Low = 0 flags, Medium = 1-2, High = 3-4. The score is checked on actual churn: the rate grows with every flag.
6. **Priority list** - expected loss per active client, reasons (which flags are on) and a recommended action.

## Tech Stack

Python · pandas · NumPy · Matplotlib · Seaborn · SQL · Jupyter Notebook · kagglehub

## Project Structure

```
b2b-saas-churn-analysis/
├── notebooks/
│   ├── 01_cleaning_eda.ipynb                 # cleaning, features, KPIs, EDA
│   └── 02_risk_score_and_priority_list.ipynb # risk score, risk levels, priority lists
├── sql/
│   └── churn_queries.sql
├── data/
│   ├── priority_list_top20.csv
│   └── priority_list_auto_segments.csv
├── images/
├── requirements.txt
└── README.md
```

`data/clean_data.csv` is created by the first notebook and is not stored in the repository.

## How to Run

```bash
git clone https://github.com/dreamkeeperx/b2b-saas-churn-analysis.git
cd b2b-saas-churn-analysis
pip install -r requirements.txt
jupyter notebook notebooks/
```

Run `01_cleaning_eda.ipynb` first: it downloads the dataset with `kagglehub` and creates `data/clean_data.csv`. Then run `02_risk_score_and_priority_list.ipynb`.

## Limitations and Next Steps

- The data is synthetic, so the results show the method rather than real business findings.
- Flag thresholds and risk levels are chosen and checked on the same data (in-sample). A stricter check: choose thresholds on one half of the clients and validate on the other half.
- The risk score is a rule-based ranking, not a forecast. Expected loss has no time horizon, and the effect of the recommended actions is not measured.
- The churn rate of score 4 is based on 190 clients, so it is less stable than the other groups.
- Possible next steps: a Power BI dashboard with the overview, segments and the risk list; a cohort analysis by signup date.
