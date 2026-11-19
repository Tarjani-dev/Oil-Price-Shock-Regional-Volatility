-- ============================================================
-- 03_preshock_vs_shock.sql
-- Purpose: Difference-in-differences comparison — charge-off
-- rate by region cohort, across the pre-shock (2012-2013) and
-- shock-period (2014-2015) windows.
-- ============================================================

SELECT 
    CASE WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2012, 2013) THEN 'Pre-shock'
         ELSE 'Shock-period' END AS period,
    CASE WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK') THEN 'Oil-producing'
         ELSE 'Other' END AS region_cohort,
    COUNT(*) AS total_terminal_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_loans,
    ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS charge_off_rate_pct
FROM loan_data_clean
WHERE TRIM(term) = '36 months'
  AND loan_status IN ('Fully Paid', 'Charged Off')
  AND (
      issue_d::DATE BETWEEN DATE '2012-01-01' AND DATE '2013-12-31'
      OR issue_d::DATE BETWEEN DATE '2014-01-01' AND DATE '2015-12-31'
  )
GROUP BY 1, 2
ORDER BY 1, 2;


-- Gap and swing calculation:
--
--   gap_pre_shock      = oil_producing_pre_shock_rate   - other_pre_shock_rate
--   gap_shock_period   = oil_producing_shock_rate        - other_shock_rate
--   swing               = gap_shock_period - gap_pre_shock
--
-- Values based on analysis:
--   Pre-shock:    Oil-producing 11.51%  vs. Other 12.85%   -> gap -1.34 pts
--   Shock period: Oil-producing 14.87%  vs. Other 14.41%   -> gap +0.46 pts
--   Swing: +1.80 percentage points
