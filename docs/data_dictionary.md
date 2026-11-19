# Data Dictionary — Lending Club Loan Data

The source dataset ships column definitions across **two separate categories**, reflecting two different stages of Lending Club's own data pipeline:

| Category | What it represents | Naming style |
|---|---|---|
| **BrowseNotesFile** | Fields as they appeared on the investor-facing "browse notes" listing (pre-funding / loan-listing stage) | camelCase, e.g. `addrState`, `annualInc`, `intRate` |
| **LoanStatNew** | Fields as they appear in the historical loan performance file (post-funding / full lifecycle) | snake_case, e.g. `addr_state`, `annual_inc`, `int_rate` |

Both categories describe the **same underlying concepts** — the difference is naming convention and which pipeline stage they came from. This project uses the **`LoanStatNew` (snake_case) column set**, since the accepted-loans history file (`accepted_2007_to_2018Q4.csv`) follows that naming convention throughout.

---

## Key columns used in this project

These are the columns actually referenced in the SQL scripts and analysis, pulled from the full `LoanStatNew` dictionary below.

| Column | Format / type | Description | Role in this project |
|---|---|---|---|
| `addr_state` | Text (2-letter state code) | The state provided by the borrower in the loan application | Used to split loans into oil-producing (TX, ND, OK, NM, LA, WY, AK) vs. other states |
| `issue_d` | Date (month-level, e.g. "Dec-2015") | The month the loan was funded | Used to build the pre-shock (2012–13) and shock-period (2014–15) cohort windows |
| `term` | Text (" 36 months" / " 60 months" — note leading space) | Number of payments on the loan | Filtered to 36-month loans only; required `TRIM()` to handle formatting |
| `loan_status` | Text category (e.g. Fully Paid, Charged Off, Current, Late, etc.) | Current status of the loan | Used as both the filter for "resolved" loans and the outcome variable (charge-off) |
| `grade` | Text (A–G) | LC-assigned loan grade | Used to check whether the charge-off swing holds consistently across risk tiers |
| `dti` | Numeric (percentage/ratio) | Borrower's monthly debt payments ÷ monthly income (excludes mortgage and the requested LC loan) | Tested as a possible explanatory factor — found to move in step with other states |
| `int_rate` | Numeric (percentage) | Interest rate on the loan | Tested as a possible explanatory factor — found to move in step with other states |
| `verification_status` | Text category (Verified / Source Verified / Not Verified) | Whether LC verified the borrower's income | Tested as a possible explanatory factor — no consistent pattern found |
| `emp_length` | Text/ordinal (0–10, where 10 = "10+ years") | Employment length in years at time of application | Used as a proxy for employment tenure at loan origination — the leading explanatory lead found |
| `last_pymnt_d` | Date (month-level) | Last month a payment was received | Used to confirm the data extraction date and that all cohort loans had matured |

> **Format note:** `issue_d` and `last_pymnt_d` arrive as text in formats like `"Dec-2015"` and were standardized to `"2015-12-01"` during cleaning. The `term` column has a leading space in its raw values (`" 36 months"`), handled with `TRIM()` in every query that filters on it.

---

## Full reference: BrowseNotesFile fields

| Field | Description |
|---|---|
| acceptD | The date which the borrower accepted the offer |
| accNowDelinq | The number of accounts on which the borrower is now delinquent |
| accOpenPast24Mths | Number of trades opened in past 24 months |
| addrState | The state provided by the borrower in the loan application |
| all_util | Balance to credit limit on all trades |
| annual_inc_joint | The combined self-reported annual income provided by the co-borrowers during registration |
| annualInc | The self-reported annual income provided by the borrower during registration |
| application_type | Indicates whether the loan is an individual or joint application |
| avg_cur_bal | Average current balance of all accounts |
| bcOpenToBuy | Total open to buy on revolving bankcards |
| bcUtil | Ratio of total current balance to high credit/credit limit for all bankcard accounts |
| chargeoff_within_12_mths | Number of charge-offs within 12 months |
| collections_12_mths_ex_med | Number of collections in 12 months excluding medical collections |
| creditPullD | The date LC pulled credit for this loan |
| delinq2Yrs | Number of 30+ day delinquencies in the past 2 years |
| delinqAmnt | Past-due amount owed on delinquent accounts |
| desc | Loan description provided by the borrower |
| dti | Borrower's monthly debt payments ÷ monthly income, excluding mortgage and the LC loan |
| dti_joint | Same as dti, but for co-borrowers' combined income |
| earliestCrLine | Date the borrower's earliest reported credit line was opened |
| effective_int_rate | Interest rate reduced by LC's estimate of uncollected interest prior to charge-off |
| emp_title | Job title supplied by the borrower |
| empLength | Employment length in years (0–10, 10 = 10+ years) |
| expD | Date the listing will expire |
| expDefaultRate | Expected default rate of the loan |
| ficoRangeHigh / ficoRangeLow | Upper/lower boundary of borrower's FICO at origination |
| fundedAmnt | Total amount committed to the loan at that point in time |
| grade | LC-assigned loan grade |
| homeOwnership | RENT, OWN, MORTGAGE, or OTHER |
| id | Unique LC loan listing ID |
| il_util | Ratio of current balance to high credit on installment accounts |
| ils_exp_d | Whole-loan platform expiration date |
| initialListStatus | W or F |
| inq_fi | Number of personal finance inquiries |
| inq_last_12m | Credit inquiries in past 12 months |
| inqLast6Mths | Inquiries in past 6 months (excl. auto/mortgage) |
| installment | Monthly payment owed if the loan originates |
| intRate | Interest rate on the loan |
| isIncV | Whether income was verified, not verified, or source verified |
| listD | Date the application was listed on the platform |
| loanAmnt | Listed loan amount applied for |
| max_bal_bc | Max current balance on revolving accounts |
| memberId | Unique LC borrower ID |
| mo_sin_old_rev_tl_op / mo_sin_rcnt_rev_tl_op / mo_sin_rcnt_tl | Months since oldest/most recent revolving or other account opened |
| mortAcc | Number of mortgage accounts |
| msa | Metropolitan Statistical Area of the borrower |
| mths_since_last_major_derog | Months since most recent 90-day+ derogatory rating |
| mths_since_oldest_il_open / mths_since_rcnt_il | Months since oldest/most recent installment account opened |
| mthsSinceLastDelinq / mthsSinceLastRecord | Months since last delinquency / public record |
| mthsSinceMostRecentInq | Months since most recent inquiry |
| mthsSinceRecentBc | Months since most recent bankcard opened |
| mthsSinceRecentLoanDelinq / mthsSinceRecentRevolDelinq | Months since most recent personal/revolving delinquency |
| num_accts_ever_120_pd | Accounts ever 120+ days past due |
| num_actv_bc_tl / num_actv_rev_tl | Currently active bankcard/revolving accounts |
| num_bc_sats / num_bc_tl | Satisfactory/total bankcard accounts |
| num_il_tl | Installment accounts |
| num_op_rev_tl / num_rev_accts / num_rev_tl_bal_gt_0 | Open/total revolving accounts, revolving accounts with balance > 0 |
| num_sats | Satisfactory accounts |
| num_tl_120dpd_2m / num_tl_30dpd / num_tl_90g_dpd_24m | Accounts currently or recently past due |
| num_tl_op_past_12m | Accounts opened in past 12 months |
| open_acc_6m / open_il_12m / open_il_24m / open_act_il / open_rv_12m / open_rv_24m | Various open-trade counts by type and recency |
| openAcc | Number of open credit lines |
| pct_tl_nvr_dlq | Percent of trades never delinquent |
| percentBcGt75 | Percent of bankcard accounts > 75% of limit |
| pub_rec_bankruptcies / pubRec | Public record bankruptcies / derogatory records |
| purpose | Borrower's stated reason for the loan |
| reviewStatus / reviewStatusD | Listing review status (APPROVED/NOT_APPROVED) and review date |
| revolBal / revolUtil | Revolving balance / utilization rate |
| serviceFeeRate | Investor service fee rate |
| subGrade | LC-assigned loan subgrade |
| tax_liens | Number of tax liens |
| term | Loan term in months (36 or 60) |
| title | Loan title provided by borrower |
| tot_coll_amt / tot_cur_bal / tot_hi_cred_lim | Total collections owed / current balance / credit limit |
| total_bal_il / total_cu_tl / total_il_high_credit_limit | Installment balance / finance trades / installment credit limit |
| total_rev_hi_lim | Total revolving credit limit |
| totalAcc / totalBalExMort / totalBcLimit | Total credit lines / balance excl. mortgage / bankcard limit |
| url | URL for the LC listing |
| verified_status_joint | Joint income verification status |
| zip_code | First 3 digits of borrower's zip code |
| revol_bal_joint | Co-borrowers' combined revolving balance |
| sec_app_* fields | Secondary applicant's FICO, credit line, inquiries, mortgage accounts, etc. |
| disbursement_method | CASH or DIRECT_PAY |

*Employer Title replaces Employer Name for all loans listed after 9/23/2013.*

---

## Full reference: LoanStatNew fields (used in this project)

This is the historical performance file's naming convention — the one used throughout this project's SQL and analysis.

| Field | Description |
|---|---|
| acc_now_delinq | Accounts on which the borrower is now delinquent |
| acc_open_past_24mths | Trades opened in past 24 months |
| **addr_state** | Borrower's state — **used for region grouping** |
| all_util | Balance to credit limit on all trades |
| annual_inc / annual_inc_joint | Self-reported income (individual / joint) |
| application_type | Individual or joint application |
| avg_cur_bal | Average current balance of all accounts |
| bc_open_to_buy / bc_util | Revolving bankcard open-to-buy / utilization |
| chargeoff_within_12_mths | Charge-offs within 12 months |
| collection_recovery_fee | Post charge-off collection fee |
| collections_12_mths_ex_med | Collections in 12 months excl. medical |
| delinq_2yrs / delinq_amnt | Delinquency count (2 yrs) / past-due amount |
| desc | Borrower's loan description |
| **dti** / dti_joint | Debt-to-income ratio — **tested as explanatory factor** |
| earliest_cr_line | Month earliest credit line opened |
| **emp_length** | Employment length (0–10 yrs) — **used as tenure proxy** |
| emp_title | Borrower's job title |
| fico_range_high / fico_range_low | FICO range at origination |
| funded_amnt / funded_amnt_inv | Amount funded total / by investors |
| **grade** / sub_grade | Loan grade — **used for grade-level breakdown** |
| home_ownership | RENT, OWN, MORTGAGE, OTHER |
| id / member_id | Unique loan / borrower IDs |
| il_util | Installment account utilization |
| initial_list_status | W or F |
| inq_fi / inq_last_12m / inq_last_6mths | Various credit inquiry counts |
| installment | Monthly payment owed |
| **int_rate** | Interest rate — **tested as explanatory factor** |
| **issue_d** | Loan funding month — **used to build cohort windows** |
| last_credit_pull_d | Most recent credit pull month |
| last_fico_range_high / last_fico_range_low | Most recent FICO range |
| last_pymnt_amnt / **last_pymnt_d** | Last payment amount / month — **used for maturity check** |
| loan_amnt | Listed loan amount |
| **loan_status** | Current loan status — **primary outcome variable** |
| max_bal_bc | Max revolving balance |
| mo_sin_old_il_acct / mo_sin_old_rev_tl_op / mo_sin_rcnt_rev_tl_op / mo_sin_rcnt_tl | Account-age / recency metrics |
| mort_acc | Number of mortgage accounts |
| mths_since_last_delinq / mths_since_last_major_derog / mths_since_last_record | Months since last delinquency / derogatory mark / public record |
| mths_since_rcnt_il / mths_since_recent_bc / mths_since_recent_bc_dlq / mths_since_recent_inq / mths_since_recent_revol_delinq | Various recency-of-event metrics |
| next_pymnt_d | Next scheduled payment date |
| num_* fields | Various account-count metrics (active, satisfactory, past-due, opened recently, etc.) |
| open_acc / open_acc_6m / open_il_12m / open_il_24m / open_act_il / open_rv_12m / open_rv_24m | Open credit line counts by type and recency |
| out_prncp / out_prncp_inv | Remaining outstanding principal |
| pct_tl_nvr_dlq | Percent of trades never delinquent |
| percent_bc_gt_75 | Percent of bankcard accounts > 75% of limit |
| policy_code | 1 = publicly available, 2 = new products |
| pub_rec / pub_rec_bankruptcies | Derogatory records / bankruptcies |
| purpose | Stated reason for the loan |
| pymnt_plan | Whether a payment plan is in place |
| recoveries | Post charge-off gross recovery |
| revol_bal / revol_util | Revolving balance / utilization |
| tax_liens | Number of tax liens |
| **term** | Loan term (36 or 60 months) — **cohort filter** |
| title | Loan title |
| tot_coll_amt / tot_cur_bal / tot_hi_cred_lim | Total collections / balance / credit limit |
| total_acc / total_bal_ex_mort / total_bal_il / total_bc_limit / total_cu_tl / total_il_high_credit_limit | Various account totals |
| total_pymnt / total_pymnt_inv | Total payments received (total / by investors) |
| total_rec_int / total_rec_late_fee / total_rec_prncp | Interest / late fees / principal received to date |
| total_rev_hi_lim | Total revolving credit limit |
| url | LC listing URL |
| **verification_status** | Income verification status — **tested as explanatory factor** |
| verified_status_joint | Joint income verification status |
| zip_code | First 3 digits of zip code |
| revol_bal_joint | Co-borrowers' combined revolving balance |
| sec_app_* fields | Secondary applicant's credit/financial details |
| hardship_* fields | Hardship plan details (type, reason, status, dates, amounts) |
| disbursement_method | CASH or DIRECT_PAY |
| debt_settlement_flag / debt_settlement_flag_date | Whether borrower is in a debt settlement plan, and when flagged |
| settlement_status / settlement_date / settlement_amount / settlement_percentage / settlement_term | Settlement plan details |

*Employer Title replaces Employer Name for all loans listed after 9/23/2013.*

---

## Summary

| | BrowseNotesFile | LoanStatNew |
|---|---|---|
| Naming style | camelCase | snake_case |
| Pipeline stage | Pre-funding listing | Post-funding historical performance |
| Used in this project? | No (reference only) | **Yes — primary column set** |

Bolded fields above (`addr_state`, `issue_d`, `term`, `loan_status`, `grade`, `dti`, `int_rate`, `verification_status`, `emp_length`, `last_pymnt_d`) are the ones this project actually filters, aggregates, or tests on.
