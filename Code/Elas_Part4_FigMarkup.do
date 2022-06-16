/*
Figures for comparison of implied markups
*/


insheet using "./CSV/USA_compustat_markup.csv", names clear
gen scenario=999 // dummy number for appending
save "./Work/USA_compustat_markup.dta", replace

use "./Work/USA_scenario_1_industry_results.dta", clear // start with baseline no-profit results
append using "./Work/USA_scenario_2_industry_results.dta" // append baseline depr cost results
append using "./Work/USA_scenario_3_industry_results.dta" // append baseline inv cost results
keep if inrange(year,1948,2018)

gen cost_total = go_ind/markup // factor plus int costs

gen markupva = va_ind/(cost_comp + cost_st + cost_eq + cost_ip) // industry-level VA markup
bysort scenario year: egen va_total = sum(va_ind) // get total VA in year
gen va_share = va_ind/va_total // get share of VA in year
gen markup_term = (1/markupva)*va_share // markup term for geometric average
collapse (sum) markup_term cost_total go_ind va_ind, by(scenario year) // collapse to scenario/year, summing the markup terms
gen markupva = (1/markup_term) // aggregate VA markup is 1/sum of geometric terms
gen markupgo = go_ind/cost_total // aggregate GO markup is total gross output over gross costs
gen vago = va_ind/go_ind // Value-added to gross output ratio
gen profitvashare = (markupgo-1)*cost_total/va_ind // profits as share of value-added
gen profitgoshare = 1 - 1/markupgo // profits as share of gross output

append using "./Work/USA_compustat_markup.dta"

twoway line markupgo year if scenario==2, lcolor(black) /// lwidth(medthick) ///
	|| line markupgo year if scenario==1, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter markupgo year if scenario==3, connect(line) msymbol(x) mcolor(black) lcolor(black)  ///
	ytitle("Aggregate gross output markup") xtitle("Year") ///
	ylabel(.9(.05)1.3, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(1 "Depreciation cost" 2 "No-profit" 3 "Investment cost"))
graph export "./Drafts/fig_cap_markupgo_comparison.eps", as(eps) replace fontface("Times New Roman")


twoway line markupva year if scenario==2, lcolor(black) /// lwidth(medthick) ///
	|| line markupva year if scenario==1, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter markupva year if scenario==3, connect(line) msymbol(x) mcolor(black) lcolor(black)  ///
	ytitle("Aggregate value-added markup") xtitle("Year") ///
	ylabel(.9(.05)1.5, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(1 "Depreciation cost" 2 "No-profit" 3 "Investment cost"))
graph export "./Drafts/fig_cap_markupva_comparison.eps", as(eps) replace fontface("Times New Roman")

twoway line profitvashare year if scenario==2, lcolor(black) /// lwidth(medthick) ///
	|| line profitvashare year if scenario==1, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter profitvashare year if scenario==3, connect(line) msymbol(x) mcolor(black) lcolor(black)  ///
	ytitle("Profits as share of value-added") xtitle("Year") ///
	ylabel(0(.05).35, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(1 "Depreciation cost" 2 "No-profit" 3 "Investment cost"))
graph export "./Drafts/fig_cap_profitsva_comparison.eps", as(eps) replace fontface("Times New Roman")

