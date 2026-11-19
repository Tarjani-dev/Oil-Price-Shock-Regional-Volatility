-- ============================================================
-- 01_filters_funnel.sql
-- Purpose: Walk through each filtering step from raw data to the
-- final resolved cohort, tracking loan_status counts at each stage.
-- ============================================================

-- Step 0: Unfiltered — baseline status distribution
SELECT loan_status, COUNT(*) AS count
FROM loan_data_raw
GROUP BY 1
ORDER BY 2 DESC;

-- Step 1: Date filter — loans issued in 2014 or 2015 (shock window)
-- Also removes the 33 blank/null records, which have no issue_d.
SELECT loan_status, COUNT(*) AS count
FROM loan_data_raw
WHERE EXTRACT(YEAR FROM issue_d::DATE) IN (2014, 2015)
GROUP BY 1
ORDER BY 2 DESC;

-- Step 2: Date filter for the pre-shock comparison window (2012-2013)
SELECT loan_status, COUNT(*) AS count
FROM loan_data_raw
WHERE EXTRACT(YEAR FROM issue_d::DATE) IN (2012, 2013)
GROUP BY 1
ORDER BY 2 DESC;

-- Step 3: Date + term filter — 36-month loans only
-- TRIM() handles the leading-space formatting issue in the term column.
SELECT loan_status, COUNT(*) AS count
FROM loan_data_raw
WHERE EXTRACT(YEAR FROM issue_d::DATE) IN (2014, 2015)
  AND TRIM(term) = '36 months'
GROUP BY 1
ORDER BY 2 DESC;

-- Step 4: Final cohort — date + term + terminal status only
-- (Fully Paid or Charged Off). This is the denominator used
-- throughout the analysis.
SELECT loan_status, COUNT(*) AS count
FROM loan_data_raw
WHERE EXTRACT(YEAR FROM issue_d::DATE) IN (2014, 2015)
  AND TRIM(term) = '36 months'
  AND loan_status IN ('Fully Paid', 'Charged Off')
GROUP BY 1
ORDER BY 2 DESC;

-- Data-quality check: rows with missing status, state, or issue date
SELECT
    COALESCE(loan_status, '(SQL NULL)') AS loan_status,
    COUNT(*) AS rows_total,
    COUNT(*) FILTER (WHERE addr_state IS NULL) AS missing_state,
    COUNT(*) FILTER (WHERE issue_d IS NULL) AS missing_issue_date
FROM loan_data_raw
WHERE loan_status IS NULL
   OR loan_status = 'Null'
   OR addr_state IS NULL
   OR issue_d IS NULL
GROUP BY loan_status;

-- Maturity check: confirms the dataset extraction date gave every
-- loan in the window enough time to reach a terminal status.
SELECT
    MAX(issue_d::DATE) AS latest_loan_issued,
    MAX(last_pymnt_d::DATE) AS latest_payment_recorded
FROM loan_data_clean;

-- Unresolved loans remaining in the window, by issue month
-- (used to confirm they are too few / too concentrated to change
-- the headline result).
SELECT
    DATE_TRUNC('month', issue_d::DATE) AS issue_month,
    COUNT(*) AS unresolved_loans
FROM loan_data_clean
WHERE TRIM(term) = '36 months'
  AND issue_d::DATE BETWEEN DATE '2014-01-01' AND DATE '2015-12-31'
  AND loan_status NOT IN ('Fully Paid', 'Charged Off')
GROUP BY 1
ORDER BY 1;
