-- ============================================================
-- 04_grade_breakdown.sql
-- Purpose: Check whether the pre-shock -> shock-period swing in
-- the oil-producing vs. other states gap holds consistently
-- across credit grades (A-G).
-- ============================================================

SELECT
    CASE WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2012,2013)
    THEN 'Pre-shock' ELSE 'Shock-period' END AS period,
    CASE WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK')
    THEN 'Oil-producing' ELSE 'Other' END AS region_cohort,
    grade, COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off,
    ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS charge_off_rate_pct
FROM loan_data_clean
WHERE TRIM(term) = '36 months'
  AND loan_status IN ('Fully Paid', 'Charged Off')
  AND (issue_d::DATE BETWEEN '2012-01-01' AND '2013-12-31' OR issue_d::DATE BETWEEN '2014-01-01' AND '2015-12-31')
GROUP BY 1,2,3 ORDER BY 1,2,3;

-- Note: swing per grade = shock-period gap - pre-shock gap,
-- where gap = oil-producing rate - other-states rate, computed
-- from the rows above.

-- Grade G's swing should not be treated as a real finding — its
-- pre-shock oil-producing sample was only 3 loans, far too small
-- to draw any conclusion from.

-- Finding: a positive swing means oil-producing states' charge-off
-- rate rose relative to other states, from the pre-shock period to
-- the shock period, at that grade -- i.e. oil-producing states got
-- comparatively worse, not just worse in absolute terms.
-- The swing is positive and grows roughly with risk grade
-- (A: +1.32 to F: +4.55), though not strictly linear (E dips below
-- D) -- consistent with the oil-shock effect being stronger for
-- riskier borrowers, but not a perfectly clean trend.

-- Grade mix by region and period, to check whether oil-producing
-- states shifted toward riskier grades (which could explain the
-- swing without any change in risk per grade)
SELECT
    CASE WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2012,2013) THEN 'Pre-shock' ELSE 'Shock-period' END AS period,
    CASE WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK') THEN 'Oil-producing' ELSE 'Other' END AS region_cohort,
    grade,
    COUNT(*) AS total_loans,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY
        CASE WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2012,2013) THEN 'Pre-shock' ELSE 'Shock-period' END,
        CASE WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK') THEN 'Oil-producing' ELSE 'Other' END
    ), 2) AS pct_of_group
FROM loan_data_clean
WHERE TRIM(term) = '36 months'
  AND loan_status IN ('Fully Paid', 'Charged Off')
  AND (issue_d::DATE BETWEEN '2012-01-01' AND '2013-12-31'
       OR issue_d::DATE BETWEEN '2014-01-01' AND '2015-12-31')
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;

-- Finding: the grade mix shifted in both groups from pre-shock to shock-period. 
-- A-grade share rose about 4-5 points and B-grade share fell about 7 points, in both oil-producing and other states. 
-- The shift between the two regions differs by at most about half a point at every grade, 
-- meaning oil-producing states did not originate meaningfully riskier-grade loans than the rest
-- of the country. This rules out a change in loan-grade mix as an explanation for the regional charge-off gap 
-- the deterioration happened within each grade, not from moving into riskier grades.
