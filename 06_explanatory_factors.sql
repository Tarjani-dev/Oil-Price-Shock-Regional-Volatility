-- ============================================================
-- 06_explanatory_factors.sql
-- Purpose: Test whether DTI, interest rate, income verification,
-- or employment tenure help explain the pre-shock -> shock-period
-- swing in oil-producing vs. other states. For each factor, compute
-- its average for each region/period, then the "excess change" =
-- (oil-producing change) - (other states change). A value near
-- zero suggests the factor moved in step with the rest of the
-- country and is unlikely to be the driver on its own.
-- ============================================================

-- Template: average DTI by region and period
WITH cohort AS (
    SELECT
        CASE
            WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2012, 2013) THEN 'Pre-shock'
            WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2014, 2015) THEN 'Shock-period'
        END AS period,
        CASE
            WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK') THEN 'Oil-producing'
            ELSE 'Other'
        END AS region_cohort,
        dti,
        int_rate,
        verification_status,
        emp_length  -- proxy for employment tenure at origination
    FROM loan_data_clean
    WHERE TRIM(term) = '36 months'
      AND loan_status IN ('Fully Paid', 'Charged Off')
      AND EXTRACT(YEAR FROM issue_d::DATE) IN (2012, 2013, 2014, 2015)
)

-- 1. Average DTI by region and period
SELECT period, region_cohort, ROUND(AVG(dti), 2) AS avg_dti
FROM cohort
GROUP BY period, region_cohort
ORDER BY period, region_cohort;

-- 2. Average interest rate by region and period
-- SELECT period, region_cohort, ROUND(AVG(int_rate), 2) AS avg_int_rate
-- FROM cohort
-- GROUP BY period, region_cohort
-- ORDER BY period, region_cohort;

-- 3. Income verification mix by region and period
-- SELECT period, region_cohort, verification_status, COUNT(*) AS loans,
--        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY period, region_cohort), 1) AS pct_of_group
-- FROM cohort
-- GROUP BY period, region_cohort, verification_status
-- ORDER BY period, region_cohort, verification_status;

-- 4. Employment tenure (emp_length as proxy) by region, period, and grade
-- SELECT period, region_cohort, grade, ROUND(AVG(emp_length), 2) AS avg_emp_length
-- FROM cohort
-- GROUP BY period, region_cohort, grade
-- ORDER BY grade, period, region_cohort;

-- After running each block, compute the "excess change":
--   excess_change = (oil_producing_shock - oil_producing_pre_shock)
--                  - (other_shock - other_pre_shock)
--
-- Prior analysis found DTI, interest rate, and verification status
-- all showed excess change close to zero (no clear difference from
-- the national trend), while employment tenure showed a more
-- consistent, grade-wide gap — making it the leading (not confirmed)
-- explanatory factor.
