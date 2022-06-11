/*
Calculate correlation of BEA reported VA and my imputed VA
*/

use "./Work/USA_scenario_1_industry_results.dta", clear // use baseline scenario
keep if inrange(year,1948,2018)

gen comp_beta = .
gen comp_r2 = . 
gen comp_diff = (iova-va_ind)/va_ind
gen comp_spearman = .
gen comp_correlation = .

forvalues y = 1948(1)2018 { // for each year
	qui reg iova va_ind if year==`y' // regress BEA VA (iova) on my VA (va_ind)
	qui replace comp_beta = _b[va_ind] if year==`y' // save coefficient
	qui replace comp_r2 = e(r2) if year==`y' // save R-squared
	qui spearman iova va_ind if year==`y' // spearman rank correlation
	qui replace comp_spearman = r(rho) if year==`y' // save spearman
	qui correlate iova va_ind if year==`y' // correlation
	qui replace comp_correlation = r(rho) if year==`y' // save correlation
}

collapse (first) comp_*, by(year)

summ comp_* // report summary stats for use in Appendix
