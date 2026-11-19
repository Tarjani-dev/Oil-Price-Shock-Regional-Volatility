-- ============================================================
-- 04_grade_breakdown.sql
-- Purpose: Check whether the pre-shock -> shock-period swing in
-- the oil-producing vs. other states gap holds consistently
-- across credit grades (A-G).
-- ============================================================

WITH cohort AS (
    SELECT
        grade,
        CASE
            WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2012, 2013) THEN 'Pre-shock'
            WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2014, 2015) THEN 'Shock-period'
        END AS period,
        CASE
            WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK') THEN 'Oil-producing'
            ELSE 'Other'
        END AS region_cohort,
        loan_status
    FROM loan_data_clean
    WHERE TRIM(term) = '36 months'
      AND loan_status IN ('Fully Paid', 'Charged Off')
      AND EXTRACT(YEAR FROM issue_d::DATE) IN (2012, 2013, 2014, 2015)
),
rates AS (
    SELECT
        grade,
        period,
        region_cohort,
        COUNT(*) AS total_loans,
        ROUND(
            SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0
            / COUNT(*), 2
        ) AS charge_off_rate_pct
    FROM cohort
    GROUP BY grade, period, region_cohort
)
SELECT *
FROM rates
ORDER BY grade, period, region_cohort;

-- Note: Grade G should be reviewed for sample size before trusting
-- its swing value — a pre-shock oil-producing sample under ~10 loans
-- is generally too small to draw a conclusion from (see grade G,
-- pre-shock n=3 in prior analysis).
--
-- To get the swing per grade, compute (shock gap - pre-shock gap)
-- for each grade from the rates above, where:
--   gap = oil_producing_rate - other_rate
