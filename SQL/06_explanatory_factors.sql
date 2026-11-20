-- ============================================================
-- 06_explanatory_factors.sql
-- Tests whether DTI, interest rate, income verification, or
-- employment tenure help explain the pre-shock -> shock-period
-- swing in oil-producing vs. other states.
-- ============================================================


-- 1. Average DTI and interest rate by region and period (collapsed
--    across grade) -- quick top-line check before the grade-level
--    detail below
SELECT 
    CASE WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2012,2013) 
         THEN 'Pre-shock' ELSE 'Shock-period' END AS period,
    CASE WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK') 
         THEN 'Oil-producing' ELSE 'Other' END AS region_cohort,
    COUNT(*) AS total_loans,
    ROUND(AVG(dti), 2) AS avg_dti,
    ROUND(AVG(int_rate), 2) AS avg_int_rate
FROM loan_data_clean
WHERE TRIM(term) = '36 months'
  AND loan_status IN ('Fully Paid', 'Charged Off')
  AND (issue_d::DATE BETWEEN '2012-01-01' AND '2013-12-31'
       OR issue_d::DATE BETWEEN '2014-01-01' AND '2015-12-31')
GROUP BY 1, 2
ORDER BY 1, 2;

-- Finding: at the aggregate level, DTI rose for both groups
-- (oil-producing +1.34 pts, other states +1.43 pts) and interest
-- rates fell for both (oil-producing -1.44 pts, other states
-- -1.43 pts). The excess change is close to zero for both metrics
-- (-0.09 and -0.01), confirming the same conclusion found at the
-- grade level below: neither factor moved differently in
-- oil-producing states.


-- 2. Average DTI, interest rate, verification by period + grade
--    (other states)
SELECT 
    CASE WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2012,2013) 
         THEN 'Pre-shock' ELSE 'Shock-period' END AS period,
    grade,
    COUNT(*) AS total_loans,
    ROUND(AVG(dti), 2) AS avg_dti,
    ROUND(AVG(int_rate), 2) AS avg_int_rate,
    ROUND(SUM(CASE WHEN verification_status = 'Not Verified' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_not_verified
FROM loan_data_clean
WHERE TRIM(term) = '36 months'
  AND loan_status IN ('Fully Paid', 'Charged Off')
  AND addr_state NOT IN ('TX','ND','OK','NM','LA','WY','AK')
  AND (issue_d::DATE BETWEEN '2012-01-01' AND '2013-12-31'
       OR issue_d::DATE BETWEEN '2014-01-01' AND '2015-12-31')
GROUP BY 1, 2
ORDER BY 2, 1;


-- 3. Average DTI, interest rate, verification by period + grade
--    (oil-producing states) -- compare row-by-row against query 2
--    above to get the excess change per grade
SELECT 
    CASE WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2012,2013) 
         THEN 'Pre-shock' ELSE 'Shock-period' END AS period,
    grade,
    COUNT(*) AS total_loans,
    ROUND(AVG(dti), 2) AS avg_dti,
    ROUND(AVG(int_rate), 2) AS avg_int_rate,
    ROUND(SUM(CASE WHEN verification_status = 'Not Verified' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_not_verified
FROM loan_data_clean
WHERE TRIM(term) = '36 months'
  AND loan_status IN ('Fully Paid', 'Charged Off')
  AND addr_state IN ('TX','ND','OK','NM','LA','WY','AK')
  AND (issue_d::DATE BETWEEN '2012-01-01' AND '2013-12-31'
       OR issue_d::DATE BETWEEN '2014-01-01' AND '2015-12-31')
GROUP BY 1, 2
ORDER BY 2, 1;

-- Finding: for both oil-producing and other states, DTI rose and
-- interest rates fell across every grade A-G from pre-shock to
-- shock-period. The excess change (oil-producing's change minus
-- other states' change) stays close to zero in grades A-E for all
-- three metrics -- DTI excess ranges -0.11 to +0.20, interest rate
-- excess -0.11 to +0.02, verification excess -0.72 to +2.69 --
-- meaning none of these three factors moved differently in
-- oil-producing states through grade E.
--
-- Grade F shows a larger DTI excess (-2.05) and verification excess
-- (+6.74), but n=62/331 loans is too small to trust on its own --
-- treated as a secondary, lower-confidence observation. Grade G's
-- excess values are even larger but come from just 3 pre-shock
-- oil-producing loans, so they are not a usable finding at all.


-- 4. Employment tenure (emp_length as proxy) by period, region, and
--    grade. Joins to loan_data since emp_length is not in
--    loan_data_clean.
SELECT
    CASE WHEN EXTRACT(YEAR FROM lc.issue_d::DATE) IN (2012,2013) THEN 'Pre-shock' ELSE 'Shock-period' END AS period,
    CASE WHEN lc.addr_state IN ('TX','ND','OK','NM','LA','WY','AK') THEN 'Oil-producing' ELSE 'Other' END AS region_cohort,
    lc.grade,
    COUNT(*) AS total_loans,
    ROUND(AVG(
        CASE WHEN raw.emp_length = '< 1 year' THEN 0
             WHEN raw.emp_length = '10+ years' THEN 10
             ELSE CAST(REGEXP_REPLACE(raw.emp_length, '[^0-9]', '', 'g') AS INTEGER)
        END
    ), 2) AS avg_emp_length_years,
    ROUND(SUM(CASE WHEN raw.emp_length IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_missing_emp_length
FROM loan_data_clean lc
JOIN loan_data raw ON lc.id = raw.id
WHERE TRIM(lc.term) = '36 months'
  AND lc.loan_status IN ('Fully Paid', 'Charged Off')
  AND (lc.issue_d::DATE BETWEEN '2012-01-01' AND '2013-12-31'
       OR lc.issue_d::DATE BETWEEN '2014-01-01' AND '2015-12-31')
GROUP BY 1, 2, 3
ORDER BY 3, 2, 1;

-- Finding: this is the one factor with a consistent, grade-wide
-- excess -- oil-producing borrowers' average tenure fell more than
-- other states' in every grade, and the gap widens for riskier
-- grades (A: -0.09 yrs to F: -0.88 yrs). Unlike DTI, interest rate,
-- and verification (all near zero), this pattern does not wash out
-- -- making it the leading explanatory lead, though it is measured
-- at loan origination, not proof that specific borrowers who
-- charged off lost their jobs mid-loan.
--
-- Secondary note: missing emp_length data also rose more in other
-- states than oil-producing states in every grade (e.g. grade D:
-- +3.64 vs. +1.91), a smaller, less consistent signal worth noting
-- but not treated as a separate finding.


-- 5. Income verification mix by region and period
SELECT 
    CASE WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2012,2013) 
         THEN 'Pre-shock' ELSE 'Shock-period' END AS period,
    CASE WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK') 
         THEN 'Oil-producing' ELSE 'Other' END AS region_cohort,
    verification_status,
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

-- Finding: the verification status mix shifted almost identically
-- in both groups -- "Source Verified" share nearly doubled (Oil:
-- 21.92% to 40.71%, Other: 21.37% to 40.35%) while "Verified" and
-- "Not Verified" both declined, in both groups, by similar amounts.
-- Excess change across all three categories stays small (+1.47,
-- -0.19, -1.28), confirming verification practices moved in
-- lockstep nationally rather than as a region-specific pattern.
