/*
Figure showing series breaks for data sources
*/

use  "./Work/USA_scenario_annual_results_all.dta", clear // baseline no-profit results
gen elas_cap = 1 - elas_comp // create single capital elasticity
sort year
keep if inrange(year,1948,2018) // 1947 has odd results


twoway line elas_cap year if scenario==2, lcolor(black) /// lwidth(medthick) ///
	|| line elas_cap year if scenario==1, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter elas_cap year if scenario==3, connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	|| scatter elas_cap year if scenario==4, connect(line) msymbol(oh) mcolor(black) lcolor(black) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	xscale(range(1950 2020)) ///
	text(.02 1955 "1948-1962") ///
	text(.02 1975 "1963-1986") ///
	text(.02 1991.5 "1987-1996") ///
	text(.02 2008 "1997-2018") ///
	xline(1962.5, lpattern(dot) lcolor(black)) ///
	xline(1986.5, lpattern(dot) lcolor(black)) ///
	xline(1996.5, lpattern(dot) lcolor(black)) ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "Boundary capital cost assumption:" 2 "No economic profits" 1 "Depreciation only"  - " " "Alternative capital cost assumption:" 3 "Investment cost" 4 "User cost"))
graph export "./Drafts/fig_cap_break_comparison.eps", as(eps) replace fontface("Times New Roman")

xtset scenario year
gen elas_cap_diff = elas_cap - L.elas_cap

summ elas_cap_diff if scenario==1 & year==1997
summ elas_cap_diff if scenario==2 & year==1997
summ elas_cap_diff if scenario==3 & year==1997
summ elas_cap_diff if scenario==4 & year==1997
