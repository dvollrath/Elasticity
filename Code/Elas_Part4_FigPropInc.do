/*
Figure for different assumptions on proprietors income
*/

use  "./Work/USA_scenario_annual_results_all.dta", clear // baseline no-profit results
gen elas_cap = 1 - elas_comp // create single capital elasticity
sort year
keep if inrange(year,1948,2018) // 1947 has odd results

// Proprietors income
twoway line elas_cap year if scenario==1, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| line elas_cap year if scenario==21, lcolor(gray) lpattern(dash) /// lwidth(medthick) ///
	|| scatter elas_cap year if scenario==25, connect(line) msymbol(oh) mcolor(gray) lcolor(gray) /// lwidth(medthick) ///
	|| line elas_cap year if scenario==2, lcolor(black) /// lwidth(medthick) ///
	|| line elas_cap year if scenario==22, lcolor(gray)   /// lwidth(medthick) ///	
	|| scatter elas_cap year if scenario==26, connect(line) msymbol(x) mcolor(gray) lcolor(gray) /// lwidth(medthick) ///	
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(10) cols(2) region(lcolor(white)) order( - "No-profit bound:" - "Depreciation cost bound:" 1 "Prop. income split" 4 "Prop. income split" 2 "Prop. income = labor cost" 5 "Prop. income = labor cost" 3 "Prop. income = capital cost" 6 "Prop. income = capital cost" ))
graph export "./Drafts/fig_cap_prop_comparison.eps", as(eps) replace fontface("Times New Roman")
