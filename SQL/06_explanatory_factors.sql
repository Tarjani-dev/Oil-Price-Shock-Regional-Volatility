-- ============================================================
-- 06_explanatory_factors.sql
-- Tests whether DTI, interest rate, income verification, or
-- employment tenure help explain the pre-shock -> shock-period
-- swing in oil-producing vs. other states.
-- ============================================================


-- 1. Average DTI, interest rate, verification by period + grade
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


-- 2. Average DTI, interest rate, verification by period + grade
--    (oil-producing states)
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


-- 3. Employment tenure (emp_length as proxy) by period, region, and grade
SELECT 
    CASE WHEN EXTRACT(YEAR FROM issue_d::DATE) IN (2012,2013) THEN 'Pre-shock' ELSE 'Shock-period' END AS period,
    CASE WHEN addr_state IN ('TX','ND','OK','NM','LA','WY','AK') THEN 'Oil-producing' ELSE 'Other' END AS region_cohort,
    grade,
    COUNT(*) AS total_loans,
    ROUND(AVG(
        CASE 
            WHEN emp_length = '< 1 year' THEN 0
            WHEN emp_length = '10+ years' THEN 10
            ELSE CAST(REGEXP_REPLACE(emp_length, '[^0-9]', '', 'g') AS INTEGER)
        END
    ), 2) AS avg_emp_length_years,
    ROUND(SUM(CASE WHEN emp_length IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_missing_emp_length
FROM loan_data_clean
WHERE TRIM(term) = '36 months'
  AND loan_status IN ('Fully Paid', 'Charged Off')
  AND (issue_d::DATE BETWEEN '2012-01-01' AND '2013-12-31'
       OR issue_d::DATE BETWEEN '2014-01-01' AND '2015-12-31')
GROUP BY 1, 2, 3
ORDER BY 3, 2, 1;


-- 4. Average DTI and interest rate by region and period (collapsed
--    across grade)
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
