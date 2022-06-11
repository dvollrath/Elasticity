/*
Figures for comparison of Olley-Pakes decomposition
*/

use "./Work/USA_scenario_1_industry_results.dta", clear // start with baseline no-profit results
keep if inrange(year,1948,2018)

gen comp_beta = .
gen comp_r2 = . 
gen comp_diff = (iova-va_ind)/va_ind
gen comp_spearman = .
gen comp_correlation = .

forvalues y = 1948(1)2018 {
	qui reg iova va_ind if year==`y'
	qui replace comp_beta = _b[va_ind] if year==`y'
	qui replace comp_r2 = e(r2) if year==`y'
	qui spearman iova va_ind if year==`y'
	qui replace comp_spearman = r(rho) if year==`y'
	qui correlate iova va_ind if year==`y'
	qui replace comp_correlation = r(rho) if year==`y'
}

collapse (first) comp_*, by(year)
