/*
Figures for comparison of results holding constant Leontief weights
*/

use "./Work/USA_scenario_bound_results_all.dta", clear

keep if inrange(year,1948,2018)

gen elas_cap = elas_st + elas_eq + elas_ip

twoway line elas_cap year if scenario==1, lcolor(black) /// no profit 
	|| line elas_cap year if scenario==2, lcolor(black) lpattern(dash) /// depreciation
	|| line elas_cap year if scenario==992, lcolor(gray) lpattern(dash) /// depr cost with NP weights
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018, nogrid) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "Baseline elasticity estimate:" 1 "No-profit" 2 "Depreciation costs" - " " - "Counterfactual:" 3 "Depreciation cost shares w/ no-profit Leontief weights"))
graph export "./Drafts/fig_cap_bounds_comparison.eps", as(eps) replace fontface("Times New Roman")

