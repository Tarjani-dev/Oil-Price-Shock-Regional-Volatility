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


-- Gap = oil-producing rate minus other-states rate for that quarter,
-- found by comparing the two region_cohort rows above for the same
-- issue_quarter (this query returns them as separate rows, not as
-- a single gap column). 
-- Positive values mean oil-producing states
-- charged off at a higher rate in that quarter.

-- Finding: the gap is negative or near zero through 2012-13 and
-- early-mid 2014, briefly touches +0.01 in Q3 2013 (a one-off, not
-- a trend), then turns consistently positive starting Q3 2014
-- (+0.48) and stays positive through the rest of the window,
-- reaching +1.81 by Q4 2015 -- lining up closely with the mid-2014
-- oil price decline.
