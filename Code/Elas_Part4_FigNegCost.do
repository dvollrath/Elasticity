/*
Figure comparing results allowing and excluding negative costs
*/

use  "./Work/USA_scenario_annual_results_all.dta", clear // baseline no-profit results
gen elas_cap = 1 - elas_comp // create single capital elasticity
sort year
keep if inrange(year,1948,2018) // 1947 has odd results

// Proprietors income
twoway line elas_cap year if scenario==1, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| line elas_cap year if scenario==29, lcolor(gray) lpattern(dash) /// lwidth(medthick) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(10) cols(1) region(lcolor(white)) order( - "No-profit bound:" 2 "Negative costs not allowed" 1 "Negative costs allowed (baseline)"))
graph export "./Drafts/fig_cap_neg_comparison.eps", as(eps) replace fontface("Times New Roman")
