"""
Project 3: SaaS Signup Funnel & A/B Test Analysis
Two-proportion z-test for A/B significance on the pricing-page experiment.

Run: python ab_test_analysis.py
Expects data/funnel_events.csv in ../data relative to this file.
"""

import numpy as np
import pandas as pd
from scipy import stats


def load_data():
    return pd.read_csv("../data/funnel_events.csv")


def funnel_summary(df):
    summary = df.groupby("variant").agg(
        visited=("user_id", "count"),
        signed_up=("signed_up", "sum"),
        activated=("activated", "sum"),
        subscribed=("subscribed", "sum"),
    )
    summary["subscribe_rate"] = (summary["subscribed"] / summary["visited"] * 100).round(1)
    return summary


def two_proportion_ztest(success_a, n_a, success_b, n_b):
    p_a = success_a / n_a
    p_b = success_b / n_b
    p_pool = (success_a + success_b) / (n_a + n_b)
    se = np.sqrt(p_pool * (1 - p_pool) * (1 / n_a + 1 / n_b))
    z = (p_b - p_a) / se
    p_value = 2 * (1 - stats.norm.cdf(abs(z)))
    return p_a, p_b, z, p_value


def leakiest_funnel_step(df):
    visited = len(df)
    signed_up = df["signed_up"].sum()
    activated = df["activated"].sum()
    subscribed = df["subscribed"].sum()

    steps = pd.DataFrame({
        "step": ["Visited->SignedUp", "SignedUp->Activated", "Activated->Subscribed"],
        "entered": [visited, signed_up, activated],
        "completed": [signed_up, activated, subscribed],
    })
    steps["dropped"] = steps["entered"] - steps["completed"]
    steps["drop_off_pct"] = (steps["dropped"] / steps["entered"] * 100).round(1)
    return steps.sort_values("drop_off_pct", ascending=False)


def main():
    df = load_data()

    print("=== Funnel Summary by Variant ===")
    summary = funnel_summary(df)
    print(summary)

    print("\n=== Leakiest Funnel Step (Overall) ===")
    print(leakiest_funnel_step(df))

    a = summary.loc["A"]
    b = summary.loc["B"]

    p_a, p_b, z, p_value = two_proportion_ztest(
        a["subscribed"], a["visited"], b["subscribed"], b["visited"]
    )

    print("\n=== Two-Proportion Z-Test: Subscribe Rate, Variant A vs B ===")
    print(f"Variant A subscribe rate: {p_a:.1%} ({int(a['subscribed'])} of {int(a['visited'])})")
    print(f"Variant B subscribe rate: {p_b:.1%} ({int(b['subscribed'])} of {int(b['visited'])})")
    print(f"z = {z:.2f}, p-value = {p_value:.3f}")

    if p_value < 0.05:
        print("Result: statistically significant at the 5% level - Variant B's lift is real.")
    else:
        print("Result: NOT statistically significant at the 5% level.")
        print("Directionally positive for B (+10 points), but n=20 per group is too small to be confident.")
        print("Recommendation: keep the test running until reaching the pre-registered sample size before rolling out.")


if __name__ == "__main__":
    main()
