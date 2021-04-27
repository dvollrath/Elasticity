/*
Figures for markups
*/

insheet using "./CSV/USA_compustat_markup.csv", names clear
gen scenario="computstat"
gen sample="compustat"
gen prop="computstat"
gen ip="computstat"
rename markup_emx_cost markup // rename to match from my calculations
drop markup_emx_sales // not valid calculation
save "./Work/USA_compustat_markup.dta", replace

use "./Work/USA_scenario_sample_industry.dta", clear
gen markup = (1/markupva)*iovashare // geometric average of markupva, using va shares
collapse (sum) markup, by(scenario sample prop ip year) // sum terms for year/scenario/etc.
replace markup = (1/markup) // complete geometric average for year/scenario/etc..

append using "./Work/USA_compustat_markup.dta"

twoway line markup year if sample=="nogovhs" & prop=="split" & ip=="ip" & scenario=="deprcost", lcolor(black) /// lwidth(medthick) ///
	|| line markup year if sample=="nogovhs" & prop=="split" & ip=="ip" & scenario=="noprofit", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter markup year if sample=="nogovhs" & prop=="split" & ip=="ip" & scenario=="invcost", connect(line) msymbol(x) mcolor(black) lcolor(black)  ///
	|| scatter markup year if sample=="compustat", connect(line) msymbol(oh) mcolor(black) lcolor(black)  ///	
	ytitle("Aggregate value-added markup") xtitle("Year") ///
	ylabel(.9(.1)1.5, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- 1 "Depreciation cost" 2 "No-profit" 3 "Investment cost" 4 "Compustat cost-based markup"))
graph export "./Drafts/fig_cap_markup_comparison.eps", as(eps) replace fontface("Times New Roman")
