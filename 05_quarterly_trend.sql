-- ============================================================
-- 05_quarterly_trend.sql
-- Purpose: Track the oil-producing vs. other states charge-off
-- gap by the quarter each loan was issued (not the quarter it
-- resolved), to see when/whether the gap shifts direction.
-- ============================================================

WITH cohort AS (
    SELECT
        DATE_TRUNC('quarter', issue_d::DATE) AS issue_quarter,
        CASE
            WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK') THEN 'Oil-producing'
            ELSE 'Other'
        END AS region_cohort,
        loan_status
    FROM loan_data_clean
    WHERE TRIM(term) = '36 months'
      AND loan_status IN ('Fully Paid', 'Charged Off')
      AND issue_d::DATE BETWEEN DATE '2012-01-01' AND DATE '2015-12-31'
),
quarterly_rates AS (
    SELECT
        issue_quarter,
        region_cohort,
        COUNT(*) AS total_loans,
        ROUND(
            SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0
            / COUNT(*), 2
        ) AS charge_off_rate_pct
    FROM cohort
    GROUP BY issue_quarter, region_cohort
)
SELECT
    issue_quarter,
    MAX(CASE WHEN region_cohort = 'Oil-producing' THEN charge_off_rate_pct END) AS oil_producing_rate,
    MAX(CASE WHEN region_cohort = 'Other' THEN charge_off_rate_pct END) AS other_rate,
    ROUND(
        MAX(CASE WHEN region_cohort = 'Oil-producing' THEN charge_off_rate_pct END)
        - MAX(CASE WHEN region_cohort = 'Other' THEN charge_off_rate_pct END)
    , 2) AS gap_pct
FROM quarterly_rates
GROUP BY issue_quarter
ORDER BY issue_quarter;

-- Gap = oil-producing rate minus other-states rate for that quarter.
-- Positive values mean oil-producing states charged off at a higher
-- rate in that quarter. Watch for the shift around Q3 2014, close to
-- when the oil price decline began.
