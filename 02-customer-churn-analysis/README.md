# Project 2: Customer Churn Analysis

**Tools:** Python (pandas, matplotlib/seaborn, scipy) · Tableau (KPI cards, filters, drill-downs)

## Business Problem

A subscription business wants to know which customers are about to leave and why, before they cancel. The Retention team asked for two things: a clear picture of which customer segments churn most, and the specific behavioral signal that predicts churn early enough to act on it. This project cleans raw customer records in Python, merges in a regional lookup file, quantifies churn drivers, and presents the findings in a Tableau dashboard the Retention team can monitor weekly.

## Dataset

data/customers.csv is a 30-customer illustrative sample (customer_id, tenure_months, contract_type, monthly_charges, total_charges, support_tickets, payment_method, churned). data/customer_regions.csv is a second small lookup file (customer_id, region) used to demonstrate merging two datasets in pandas. As with the other projects in this portfolio, the numbers are intentionally small and traceable to specific rows; swap in a larger real churn dataset (for example a 1,000+ row telecom churn export) to scale this up — the cleaning, grouping, merge, and visualization code all work unchanged on a bigger file with the same columns.

## Data Cleaning (Python / pandas)

python/churn_analysis.py starts by loading both CSVs and running standard checks: missing values per column with df.isna().sum(); duplicate customer_id rows with df.duplicated(); data-type fixes (churned mapped to a boolean, contract_type and payment_method cast to category); and a range check confirming tenure_months and monthly_charges are positive. The two files are then joined with pd.merge(customers, regions, on="customer_id", how="left") so every customer record carries a region.

## Analysis (Python highlights)

The script demonstrates groupby aggregation (churn rate by contract_type and by region using groupby(...)["churned"].mean()), a support-ticket bucket analysis (pd.cut into ticket ranges, then churn rate per bucket), and descriptive statistics comparing churned vs. retained customers (mean and median tenure_months and support_tickets per group). It also runs a basic two-sample comparison with scipy.stats.ttest_ind on support_tickets between churned and retained customers to check whether the difference is statistically meaningful, not just a small-sample coincidence. Visualizations include a bar chart of churn rate by contract type and a boxplot of tenure by churn status, both saved to screenshots/.

## Dashboard

The Tableau dashboard is documented in tableau/TABLEAU_DASHBOARD_SPEC.md, covering the data model, KPI cards, filters, and drill-down design. A screenshot goes in screenshots/tableau_dashboard.png once built; see the note at the bottom of this README.

## Key Insights

Finding 1: Overall churn rate in this sample is 40% (12 of 30 customers).

Finding 2: Month-to-month contracts churn at 66.7% (10 of 15 customers) versus 25% for one-year contracts (2 of 8) and 0% for two-year contracts (0 of 7) — contract length is the single strongest churn signal in the data.

Finding 3: Customers who churned logged an average of 4.1 support tickets versus just 0.8 for retained customers — roughly 5x more support contact before leaving.

Finding 4: Churned customers had an average tenure of only 4.9 months at cancellation, compared to 20.2 months average tenure among retained customers, meaning churn risk is heavily concentrated in a customer's first few months.

Finding 5: Two customers on a one-year contract still churned, and both had 4+ support tickets and above-average monthly charges — showing that a high ticket count can override an otherwise "safer" contract type.

## Business Recommendations

Recommendation 1: Trigger a retention outreach automatically once a customer logs their 3rd support ticket within the first 90 days — this sample shows that ticket volume, not just tenure, is the earliest reliable churn signal.

Recommendation 2: Offer a incentivized upgrade from month-to-month to a one-year or two-year plan during onboarding, since contract type alone separates a 66.7% churn segment from a 0% churn segment.

Recommendation 3: Build a simple risk score combining tenure under 6 months, month-to-month contract, and 3+ support tickets, and route anyone hitting all three criteria to a retention specialist before they reach the cancellation stage.

## Files in This Folder

| File | Purpose |
|---|---|
| data/customers.csv | Sample customer-level dataset |
| data/customer_regions.csv | Region lookup file, joined in pandas |
| python/churn_analysis.py | Cleaning, merging, groupby EDA, visualization, basic stats |
| tableau/TABLEAU_DASHBOARD_SPEC.md | Tableau data model, KPI cards, filters, drill-downs |
| screenshots/ | Chart and dashboard screenshots (add after running the script and building Tableau) |

## One Manual Step Left

Run python/churn_analysis.py to regenerate the charts, then follow tableau/TABLEAU_DASHBOARD_SPEC.md in Tableau Public or Desktop and drop both sets of screenshots into screenshots/.
