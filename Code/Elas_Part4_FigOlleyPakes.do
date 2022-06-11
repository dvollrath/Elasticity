/*
Figures for comparison of Olley-Pakes decomposition
*/

use "./Work/USA_scenario_1_industry_results.dta", clear // start with baseline no-profit results
append using "./Work/USA_scenario_2_industry_results.dta" // append baseline depr cost results
keep if inrange(year,1948,2018)

gen Lcap = l_st + l_eq + l_ip // sum Leontief entries for all capital types

bysort year scenario: egen fushare_mean = mean(fushare_ind) // mean final-use share across industry, by scenario
bysort year scenario: egen Lcap_mean = mean(Lcap) // mean Leontief entry across industry, by scenario

gen covar_term = (fushare_ind - fushare_mean)*(Lcap - Lcap_mean) // calculate covariance term for an industry
bysort year scenario: egen covariance = total(covar_term) // sum covariance terms

gen mult_term = fushare_ind*Lcap // individual industry FU shares times Leontief entries
bysort year scenario: egen elas_cap = total(mult_term) // sum those FUxLeontief terms, this recreates elasticity

// Plot bounds with Lmean
twoway line elas_cap year if ctrl_capital=="deprcost", lcolor(black) /// lwidth(medthick) ///
	|| line elas_cap year if ctrl_capital=="noprofit", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| line Lcap_mean year if ctrl_capital=="deprcost", lcolor(gs12) /// lwidth(medthick) ///
	|| line Lcap_mean year if ctrl_capital=="noprofit", lcolor(gs12) lpattern(dash) /// lwidth(medthick) ///
	ytitle("Elasticity or mean industry-level elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(10) cols(2) region(lcolor(white)) order( - "No-profit bound:" - "Depreciation cost bound:" 2 "Aggregate elasticity" 1 "Aggregate elasticity" 4 "Mean industry-level elasticity" 3 "Mean industry-level elasticity" ))
graph export "./Drafts/fig_cap_op_comparison.eps", as(eps) replace fontface("Times New Roman")

