/*
Figures for comparison of implied markups
*/

use "./Work/USA_scenario_1_industry_results.dta", clear // start with baseline no-profit results
append using "./Work/USA_scenario_2_industry_results.dta" // append baseline depr cost results
append using "./Work/USA_scenario_40_industry_results.dta" // append baseline inv cost results
append using "./Work/USA_scenario_39_industry_results.dta" // append baseline inv cost results
append using "./Work/USA_scenario_38_industry_results.dta" // append baseline inv cost results
append using "./Work/USA_scenario_37_industry_results.dta" // append baseline inv cost results
append using "./Work/USA_scenario_5_industry_results.dta" // append baseline inv cost results
append using "./Work/USA_scenario_6_industry_results.dta" // append baseline inv cost results
append using "./Work/USA_scenario_7_industry_results.dta" // append baseline inv cost results

keep if inrange(year,1948,2018)

gen cost_total = go_ind/markup // factor plus int costs
gen cost_factor = cost_comp + cost_st + cost_eq + cost_ip // factor cost only

gen markupva = va_ind/cost_factor // industry-level VA markup
bysort scenario year: egen va_total = sum(va_ind) // get total VA in year
gen va_share = va_ind/va_total // get share of VA in year
gen markup_term = (1/markupva)*va_share // markup term for geometric average
collapse (sum) markup_term cost_total cost_factor go_ind va_ind iova, by(scenario year) // collapse to scenario/year, summing the markup terms
gen markupva = iova/cost_factor //(1/markup_term) // aggregate VA markup is 1/sum of geometric terms
gen markupgo = go_ind/cost_total // aggregate GO markup is total gross output over gross costs
gen vago = va_ind/go_ind // Value-added to gross output ratio

twoway line markupgo year if scenario==6, lcolor(black) /// lwidth(medthick) ///
	|| line markupgo year if scenario==5, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter markupgo year if scenario==7, connect(line) msymbol(oh) mcolor(black) lcolor(black) ///
	|| scatter markupgo year if scenario==39, connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	|| scatter markupgo year if scenario==38, connect(line) msymbol(d) mcolor(gray) lcolor(gray)  ///
	ytitle("Aggregate gross output markup") xtitle("Year") ///
	ylabel(.9(.05)1.3, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(12) cols(2) region(lcolor(white)) order(- "Capital cost assumption:" - "Compustat based estimates:" 2 "No-profits" 4 "Cost shares"1 "Depreciation costs" 5 "Production function" 3 "Investment cost" ))
graph export "./Drafts/fig_cap_markupgo_comparison_dleu.eps", as(eps) replace fontface("Times New Roman")


twoway line markupva year if scenario==6, lcolor(black) /// lwidth(medthick) ///
	|| line markupva year if scenario==5, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter markupva year if scenario==7, connect(line) msymbol(oh) mcolor(black) lcolor(black) ///
	|| scatter markupva year if scenario==39, connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	|| scatter markupva year if scenario==40, connect(line) msymbol(d) mcolor(gray) lcolor(gray)  ///
	ytitle("Aggregate value-added markup") xtitle("Year") ///
	ylabel(.9(.05)1.45, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(12) cols(2) region(lcolor(white)) order(- "Capital cost assumption:" - "Compustat based estimates:" 2 "No-profits" 4 "Cost shares"1 "Depreciation costs" 5 "Production function" 3 "Investment cost" ))
graph export "./Drafts/fig_cap_markupva_comparison_dleu.eps", as(eps) replace fontface("Times New Roman")
