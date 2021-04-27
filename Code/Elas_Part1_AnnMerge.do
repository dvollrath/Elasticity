/*
Merge balance and rate of return data to form basis for calculations of R
*/

use "./Work/USA_ann1920_rates.dta", clear  // start with returns data

capture drop _merge

merge 1:1 year using "./Work/USA_ann3019_kinflation.dta" // merge k inflation

drop _merge

merge 1:1 year using "./Work/USA_ann4518_balances.dta" // merge financial balances

drop _merge

merge 1:1 year using "./Work/USA_ann4519_kallowance.dta" // merge depr allowances

drop _merge

save "./Work/USA_annual_Rcalc.dta", replace // save working file
export delimited "./CSV/USA_annual_Rcalc.csv", replace






