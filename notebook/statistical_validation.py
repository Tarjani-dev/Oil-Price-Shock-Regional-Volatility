"""
statistical_validation.py

Validates the headline charge-off rate gap between oil-producing and
other states (shock period, 2014-2015) using a two-proportion z-test
and a 95% confidence interval on the difference.

Inputs are the total loan count and charged-off count for each group,
from the overall oil-producing vs. other states cohort split.
"""

import math
from scipy.stats import norm

# --- Inputs: pulled directly from the SQL query output ---
oil_total = 50972
oil_charged_off = 7581
other_total = 394624
other_charged_off = 56866

# --- Step 1: Compute the two proportions ---
p_oil = oil_charged_off / oil_total
p_other = other_charged_off / other_total

abs_diff = p_oil - p_other
rel_diff = abs_diff / p_other * 100

print(f"Oil-producing rate:   {p_oil * 100:.2f}%  (n = {oil_total:,}, charged off = {oil_charged_off:,})")
print(f"Other states rate:    {p_other * 100:.2f}%  (n = {other_total:,}, charged off = {other_charged_off:,})")
print(f"Absolute difference:  {abs_diff * 100:.2f} percentage points")
print(f"Relative difference:  {rel_diff:.2f}%")
print()

# --- Step 2: 95% confidence interval on the difference (unpooled SE) ---
se_diff = math.sqrt(
    (p_oil * (1 - p_oil) / oil_total) +
    (p_other * (1 - p_other) / other_total)
)
z_crit = 1.96  # 95% confidence
ci_lower = (abs_diff - z_crit * se_diff) * 100
ci_upper = (abs_diff + z_crit * se_diff) * 100

print(f"95% confidence interval on the difference: {ci_lower:.2f} to {ci_upper:.2f} percentage points")
print()

# --- Step 3: Two-proportion z-test (pooled SE, for the test statistic) ---
p_pooled = (oil_charged_off + other_charged_off) / (oil_total + other_total)
se_pooled = math.sqrt(
    p_pooled * (1 - p_pooled) * (1 / oil_total + 1 / other_total)
)
z_stat = abs_diff / se_pooled
p_value = 2 * (1 - norm.cdf(abs(z_stat)))  # two-tailed

print(f"Pooled proportion:     {p_pooled * 100:.3f}%")
print(f"z-statistic:           {z_stat:.2f}")
print(f"p-value (two-tailed):  {p_value:.4f}")

if p_value < 0.05:
    print("Result: statistically significant at the 95% confidence level.")
else:
    print("Result: not statistically significant at the 95% confidence level.")
