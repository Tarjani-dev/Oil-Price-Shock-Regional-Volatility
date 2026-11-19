-- ============================================================
-- 05_quarterly_trend.sql
-- Purpose: Track the oil-producing vs. other states charge-off
-- gap by the quarter each loan was issued (not the quarter it
-- resolved), to see when/whether the gap shifts direction.
-- ============================================================

SELECT 
    CASE WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK') THEN 'Oil-producing' ELSE 'Other' END AS region_cohort,
    DATE_TRUNC('quarter', issue_d::DATE)::DATE AS issue_quarter,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off,
    ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS charge_off_rate_pct
FROM loan_data_clean
WHERE TRIM(term) = '36 months'
  AND loan_status IN ('Fully Paid', 'Charged Off')
  AND (issue_d::DATE BETWEEN '2012-01-01' AND '2013-12-31'
       OR issue_d::DATE BETWEEN '2014-01-01' AND '2015-12-31')
GROUP BY 1, 2
ORDER BY 2, 1;


-- Gap = oil-producing rate minus other-states rate for that quarter.
-- Positive values mean oil-producing states charged off at a higher
-- rate in that quarter. Watch for the shift around Q3 2014, close to
-- when the oil price decline began.
