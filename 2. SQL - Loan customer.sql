SELECT *
FROM dbo.loan_customers

/* 1. Portfolio Overview Statistics*/
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(*) AS total_loans,
    CONCAT(CAST(SUM(CAST(loan_amount AS BIGINT)) / 1000000000.0 AS DECIMAL(10,2)), ' Billion VND') AS total_disbursed,
    CONCAT(ROUND(AVG(interest_rate), 2), '%') AS avg_interest_rate,
    AVG(dpd_days) AS avg_dpd,
    SUM(CASE WHEN npl_flag = 1 THEN 1 ELSE 0 END) AS npl_count,
	CONCAT(CAST(ROUND(SUM(CASE WHEN npl_flag = 1 THEN loan_amount ELSE 0 END)*100.0 / SUM(CAST(loan_amount AS BIGINT)),2) AS DECIMAL(10,2)),'%') AS portfolio_npl_ratio
FROM dbo.loan_customers

/*2. Customer and Loan Segment*/
drop table if exists loan_summary

SELECT
    *,
    -- Age group
    CASE 
        WHEN age BETWEEN 20 AND 29 THEN 'Age 20-29'
        WHEN age BETWEEN 30 AND 39 THEN 'Age 30-39'
        WHEN age BETWEEN 40 AND 49 THEN 'Age 40-49'
        ELSE 'Age 50-60'
    END AS age_group,

    -- Income group (M VND)
    CASE
        WHEN income < 10000000 THEN '<10M'
        WHEN income BETWEEN 10000000 AND 20000000 THEN '10-20M'
        ELSE '20-30M'
    END AS income_group,

    -- CIC group
    CASE
        WHEN dpd_days <10 THEN 1
        WHEN dpd_days BETWEEN 10 AND 30 THEN 2
        WHEN dpd_days BETWEEN 31 AND 90 THEN 3
        WHEN dpd_days BETWEEN 91 AND 180 THEN 4
        ELSE 5
    END AS cic_group

INTO loan_summary
FROM dbo.loan_customers

SELECT *
FROM loan_summary

/* 3.CIC group portion*/
SELECT 
    cic_group,
    COUNT(cic_group) AS total_customers,
    CONCAT(CAST(ROUND(COUNT(cic_group)*100.0 / 1000,2) AS DECIMAL(10,2)), '%') AS portion
FROM loan_summary
GROUP BY cic_group
ORDER BY cic_group

/* 4.Top 10 Customers with Overdue Loans*/
SELECT TOP 10
    customer_id, 
    gender, 
	income,
    province,
    employment_type,
    loan_amount,
    dpd_days
FROM loan_summary
WHERE status = 'Overdue'
ORDER BY dpd_days DESC

/* 5.NPL Ratio by Province*/
SELECT 
    province,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN npl_flag = 1 THEN 1 ELSE 0 END) AS npl_count,
    CONCAT(CAST(ROUND(SUM(CASE WHEN npl_flag = 1 THEN loan_amount ELSE 0 END)*100.0 / SUM(CAST(loan_amount AS BIGINT)),2) AS DECIMAL(10,2)),'%') AS npl_ratio
FROM dbo.loan_customers
GROUP BY province
ORDER BY npl_ratio DESC


/* 6. NPL Ratio by Customer Age Group*/
SELECT age_group, 
	   COUNT(age_group) AS total_customers,
       CONCAT(CAST(ROUND(SUM(CASE WHEN npl_flag = 1 THEN loan_amount ELSE 0 END)*100.0 / SUM(CAST(loan_amount AS BIGINT)),2) AS DECIMAL(10,2)),'%') AS npl_ratio
FROM loan_summary
GROUP BY age_group
ORDER BY age_group



/*7.NPL Ratio by Employment type*/
SELECT 
    employment_type,
    COUNT(*) AS total_loans,
    CONCAT(CAST(AVG(interest_rate) AS DECIMAL(10,2)),'%') AS avg_interest,
    CONCAT(CAST(ROUND(SUM(CASE WHEN npl_flag = 1 THEN loan_amount ELSE 0 END)*100.0 / SUM(CAST(loan_amount AS BIGINT)),2) AS DECIMAL(10,2)),'%') AS npl_ratio
FROM loan_summary
GROUP BY employment_type
ORDER BY npl_ratio DESC

/* 8.NPL Ratio by loan tenor */
SELECT 
    loan_tenor_month,
    COUNT(*) AS total_loans,
    CONCAT(CAST(AVG(interest_rate) AS DECIMAL(10,2)),'%') AS avg_interest,
    CONCAT(CAST(ROUND(SUM(CASE WHEN npl_flag = 1 THEN loan_amount ELSE 0 END)*100.0 / SUM(CAST(loan_amount AS BIGINT)),2) AS DECIMAL(10,2)),'%') AS npl_ratio
FROM loan_summary
GROUP BY loan_tenor_month
ORDER BY npl_ratio DESC


/* 9.NPL Ratio by gendor */
SELECT 
    gender,
    COUNT(*) AS total_loans,
    CONCAT(CAST(AVG(interest_rate) AS DECIMAL(10,2)),'%') AS avg_interest,
    CONCAT(CAST(ROUND(SUM(CASE WHEN npl_flag = 1 THEN loan_amount ELSE 0 END)*100.0 / SUM(CAST(loan_amount AS BIGINT)),2) AS DECIMAL(10,2)),'%') AS npl_ratio
FROM loan_summary
GROUP BY gender
ORDER BY npl_ratio DESC

/* 10.NPL Ratio by income group */
SELECT 
    income_group,
    COUNT(*) AS total_loans,
    CONCAT(CAST(AVG(interest_rate) AS DECIMAL(10,2)),'%') AS avg_interest,
    CONCAT(CAST(ROUND(SUM(CASE WHEN npl_flag = 1 THEN loan_amount ELSE 0 END)*100.0 / SUM(CAST(loan_amount AS BIGINT)),2) AS DECIMAL(10,2)),'%') AS npl_ratio
FROM loan_summary
GROUP BY income_group
ORDER BY npl_ratio DESC

