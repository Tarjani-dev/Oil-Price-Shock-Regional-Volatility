-- ============================================================
-- 02_cohort_summary.sql
-- Purpose: Charge-off rate for oil-producing states vs. other
-- states, for the final shock-period cohort (2014-2015, 36-month,
-- resolved loans only).
-- ============================================================

-- Overall split: oil-producing vs. other states
SELECT
    CASE
        WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK') THEN 'Oil-producing'
        ELSE 'Other'
    END AS region_cohort,
    COUNT(*) AS total_terminal_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_loans,
    ROUND(
        SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2
    ) AS charge_off_rate_pct
FROM loan_data_clean
WHERE EXTRACT(YEAR FROM issue_d::DATE) IN (2014, 2015)
  AND TRIM(term) = '36 months'
  AND loan_status IN ('Fully Paid', 'Charged Off')
GROUP BY 1
ORDER BY 1;

-- Loan volume and charge-off rate per individual oil-producing state
SELECT
    addr_state AS oil_producing_state,
    COUNT(*) AS total_matured_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_loans,
    ROUND(
        SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2
    ) AS charge_off_rate_pct
FROM loan_data_clean
WHERE EXTRACT(YEAR FROM issue_d::DATE) IN (2014, 2015)
  AND TRIM(term) = '36 months'
  AND addr_state IN ('TX','ND','OK','NM','LA','WY','AK')
  AND loan_status IN ('Fully Paid', 'Charged Off')
GROUP BY addr_state
ORDER BY total_matured_loans DESC;

-- Oil-producing states excluding Texas (checks whether the pooled
-- rate is being shaped mainly by TX's large volume)
SELECT
    'Oil-producing (excluding TX)' AS geographic_cohort,
    COUNT(*) AS total_matured_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_loans,
    ROUND(
        SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2
    ) AS charge_off_rate_pct
FROM loan_data_clean
WHERE EXTRACT(YEAR FROM issue_d::DATE) IN (2014, 2015)
  AND TRIM(term) = '36 months'
  AND addr_state IN ('ND','OK','NM','LA','WY','AK')  -- TX excluded
  AND loan_status IN ('Fully Paid', 'Charged Off');
