/*
Figures for comparison of cost share and elasticity
*/

use "./Work/USA_scenario_annual_results_all.dta", clear

keep if inrange(year,1948,2018)

gen elas_cap = elas_st + elas_eq + elas_ip
gen fcshare_cap = fcshare_st + fcshare_eq + fcshare_ip

scatter elas_cap fcshare_cap if scenario==2, msymbol(dh) mcolor("gs8%50") ///
	|| scatter elas_cap fcshare_cap if scenario==3, msymbol(sh) mcolor("gs8%50") ///
	|| scatter elas_cap fcshare_cap if scenario==4, msymbol(th) mcolor("gs8%50") ///
	|| lfit fcshare_cap fcshare_cap if scenario==4, lpattern(dash) lcolor(black) ///
	ytitle("Estimated aggregate capital elasticity") xtitle("Aggregate capital costs/aggregate factor costs") ///
	ylabel(0.1(.05).45,nogrid format(%9.2f) angle(0)) ///
	xlabel(0.1(.05).45,format(%9.2f)) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(4) region(lcolor(white)) cols(1) order(- "Capital cost assumption:" 1 "Depreciation costs" 2 "Investment costs" 3 "User costs" 4 "45-degree line"))
graph export "./Drafts/fig_cap_total_comparison.eps", as(eps) replace fontface("Times New Roman")

// Summary statistics on differences
gen diff = elas_cap-fcshare_cap // difference in cost share and elasticity
gen diffsq = diff^2 // squared difference
bysort scenario: egen sum_diffsq = sum(diffsq) // summ difference across scenario
gen rmse = (sum_diffsq/71)^(.5) // RMSE for the scenario

summ diff if scenario==2
summ diff if scenario==3
summ diff if scenario==4

summ rmse if scenario==2
summ rmse if scenario==3
summ rmse if scenario==4
