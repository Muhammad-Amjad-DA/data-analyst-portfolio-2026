"""
Project 2: Customer Churn Analysis
Cleaning, merging, groupby EDA, visualization, and basic statistics with pandas.

Run: python churn_analysis.py
Expects data/customers.csv and data/customer_regions.csv in ../data relative to this file.
"""

import pandas as pd
import matplotlib.pyplot as plt

try:
    from scipy import stats
    SCIPY_AVAILABLE = True
except ImportError:
    SCIPY_AVAILABLE = False


def load_data():
    customers = pd.read_csv("../data/customers.csv")
    regions = pd.read_csv("../data/customer_regions.csv")
    return customers, regions


def data_quality_checks(df):
    print("Missing values per column:")
    print(df.isna().sum())

    dupes = df[df.duplicated(subset="customer_id", keep=False)]
    print(f"\nDuplicate customer_id rows: {len(dupes)}")

    bad_range = df[(df["tenure_months"] <= 0) | (df["monthly_charges"] <= 0)]
    print(f"Rows with non-positive tenure or charges: {len(bad_range)}")


def clean_data(df):
    df = df.copy()
    df["churned_flag"] = df["churned"].map({"Yes": 1, "No": 0}).astype(bool)
    df["contract_type"] = df["contract_type"].astype("category")
    df["payment_method"] = df["payment_method"].astype("category")
    return df


def merge_regions(customers, regions):
    merged = pd.merge(customers, regions, on="customer_id", how="left")
    missing_region = merged[merged["region"].isna()]
    print(f"Customers with no matching region after merge: {len(missing_region)}")
    return merged


def churn_rate_by_group(df, group_col):
    result = df.groupby(group_col)["churned_flag"].agg(["mean", "count"])
    result = result.rename(columns={"mean": "churn_rate", "count": "customers"})
    result["churn_rate"] = (result["churn_rate"] * 100).round(1)
    return result.sort_values("churn_rate", ascending=False)


def support_ticket_buckets(df):
    df = df.copy()
    df["ticket_bucket"] = pd.cut(
        df["support_tickets"],
        bins=[-1, 0, 1, 2, 10],
        labels=["0", "1", "2", "3+"],
    )
    return churn_rate_by_group(df, "ticket_bucket")


def churn_vs_retained_stats(df):
    summary = df.groupby("churned")[["tenure_months", "support_tickets"]].agg(["mean", "median"])
    print("\nTenure and support tickets, churned vs retained:")
    print(summary.round(1))

    if SCIPY_AVAILABLE:
        churned_tickets = df.loc[df["churned"] == "Yes", "support_tickets"]
        retained_tickets = df.loc[df["churned"] == "No", "support_tickets"]
        t_stat, p_value = stats.ttest_ind(churned_tickets, retained_tickets, equal_var=False)
        print(f"\nWelch's t-test on support_tickets (churned vs retained): t={t_stat:.2f}, p={p_value:.4f}")
        if p_value < 0.05:
            print("Result: statistically significant difference at the 5% level.")
        else:
            print("Result: not statistically significant at the 5% level (small sample size).")
    else:
        print("\nscipy not installed - skipping the t-test. Run: pip install scipy")


def plot_churn_by_contract(df, out_path="../screenshots/churn_by_contract.png"):
    rates = churn_rate_by_group(df, "contract_type")
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.bar(rates.index.astype(str), rates["churn_rate"], color="#c0392b")
    ax.set_ylabel("Churn Rate (%)")
    ax.set_title("Churn Rate by Contract Type")
    for i, v in enumerate(rates["churn_rate"]):
        ax.text(i, v + 1, f"{v}%", ha="center")
    fig.tight_layout()
    fig.savefig(out_path)
    print(f"Saved chart to {out_path}")


def plot_tenure_boxplot(df, out_path="../screenshots/tenure_by_churn_boxplot.png"):
    fig, ax = plt.subplots(figsize=(6, 4))
    data = [
        df.loc[df["churned"] == "No", "tenure_months"],
        df.loc[df["churned"] == "Yes", "tenure_months"],
    ]
    ax.boxplot(data, labels=["Retained", "Churned"])
    ax.set_ylabel("Tenure (months)")
    ax.set_title("Tenure Distribution: Retained vs Churned")
    fig.tight_layout()
    fig.savefig(out_path)
    print(f"Saved chart to {out_path}")


def main():
    customers, regions = load_data()

    print("=== Data Quality Checks ===")
    data_quality_checks(customers)

    customers = clean_data(customers)
    merged = merge_regions(customers, regions)

    print("\n=== Churn Rate by Contract Type ===")
    print(churn_rate_by_group(merged, "contract_type"))

    print("\n=== Churn Rate by Region ===")
    print(churn_rate_by_group(merged, "region"))

    print("\n=== Churn Rate by Support Ticket Bucket ===")
    print(support_ticket_buckets(merged))

    print("\n=== Churned vs Retained: Descriptive Stats ===")
    churn_vs_retained_stats(merged)

    plot_churn_by_contract(merged)
    plot_tenure_boxplot(merged)


if __name__ == "__main__":
    main()
