/*
Figures for comparison of cost share and elasticity
*/

use "./Work/USA_scenario_annual_results_all.dta", clear

keep if inrange(year,1948,2018)

gen elas_cap = elas_st + elas_eq + elas_ip
gen fcshare_cap = fcshare_st + fcshare_eq + fcshare_ip
gen vashare_cap = vashare_st + vashare_eq + vashare_ip


twoway line elas_cap year if scenario==1, lcolor(black) /// lwidth(medthick) ///
	|| line elas_cap year if scenario==2, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| line fcshare_cap year if scenario==2, lcolor(gray) lpattern(dash) /// lwidth(medthick) ///
	|| scatter fcshare_cap year if scenario==3, connect(line) msymbol(x) mcolor(gray) lcolor(gray) msize(small) /// lwidth(medthick) ///
	|| scatter elas_cap year if scenario==3, connect(line) msymbol(x) mcolor(black) lcolor(black) msize(small) /// lwidth(medthick) ///
	ytitle("Capital share of costs") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018, nogrid) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "Elasticity estimate:" 1 "No-profit" 2 "Depreciation costs" 5 "Investment cost" - " " - "Aggregate cost share:" 3 "Depreciation costs" 4 "Investment costs"))
graph export "./Drafts/fig_cap_ratio_comparison.eps", as(eps) replace fontface("Times New Roman")

// Summary statistics on differences
gen diff = elas_cap-fcshare_cap // difference in cost share and elasticity
