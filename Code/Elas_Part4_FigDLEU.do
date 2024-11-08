/*
Figures for baseline results
*/

use "./Work/USA_scenario_5_annual_results.dta", clear // baseline no-profit results
gen elas_cap_noprofit = 1 - elas_comp // create single capital elasticity
keep year elas_cap_noprofit // keep for merging

merge 1:1 year using "./Work/USA_scenario_6_annual_results.dta" // merge depr cost results
gen elas_cap_deprcost = 1 - elas_comp // create single capital elasticity
keep year elas_cap*

merge 1:1 year using "./Work/USA_scenario_7_annual_results.dta" // merge depr cost results
gen elas_cap_invcost = 1 - elas_comp // create single capital elasticity
keep year elas_cap*

merge 1:1 year using "./Work/USA_scenario_37_annual_results.dta" // merge inv cost results
gen elas_cap_pf1 = 1 - elas_comp // create single capital elasticity
keep year elas_cap*

merge 1:1 year using "./Work/USA_scenario_38_annual_results.dta" // merge user cost results
gen elas_cap_pf2 = 1 - elas_comp // create single capital elasticity
keep year elas_cap*

merge 1:1 year using "./Work/USA_scenario_39_annual_results.dta" // merge user cost results
gen elas_cap_cs = 1 - elas_comp // create single capital elasticity
keep year elas_cap*

merge 1:1 year using "./Work/USA_scenario_40_annual_results.dta" // merge user cost results
gen elas_cap_ps = 1 - elas_comp // create single capital elasticity
keep year elas_cap*


gen alpha = .33 // for plotting standard alpha = 1/3
sort year
keep if inrange(year,1948,2018) // 1947 has odd results

twoway rarea elas_cap_deprcost elas_cap_noprofit year, color(gray) fintensity(10) lwidth(0) ///
	|| line elas_cap_deprcost year, lcolor(black) /// lwidth(medthick) ///
	|| line elas_cap_noprofit year, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter elas_cap_invcost year, connect(line) msymbol(oh) mcolor(black) lcolor(black) ///
	|| scatter elas_cap_cs year, connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	|| scatter elas_cap_pf2 year, connect(line) msymbol(d) mcolor(gray) lcolor(gray) ///
	|| line alpha year, lcolor(black) lpattern(dot) /// lwidth(medthick) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	xscale(range(1950 2020)) ///
	text(.33 2020 "1/3") ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "Capital cost assumption:" 3 "No economic profits" 2 "Depreciation only"  4 "Investment cost" - " " "Compustat based estimates using:" 5 "Cost shares" 6 "Production function"))
graph export "./Drafts/fig_cap_dleu_comparison.eps", as(eps) replace fontface("Times New Roman")
