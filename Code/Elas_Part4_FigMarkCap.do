/*
Figures for comparing capital cost shares to implied markup of industry and to intermediate share
*/

use "./Work/USA_scenario_1_industry_results.dta", clear // start with baseline no-profit results
append using "./Work/USA_scenario_2_industry_results.dta" // append baseline depr cost results
append using "./Work/USA_scenario_3_industry_results.dta" // append baseline inv cost results
append using "./Work/USA_scenario_4_industry_results.dta" // append baseline user cost results
keep if inrange(year,1948,2018)

gen share_cap = (cost_st + cost_eq + cost_ip)/(cost_st + cost_eq + cost_ip+cost_comp) // cap cost share
gen fu_share = fu_ind/go_ind // final use share of gross output
gen int_share = 1 - fu_share // intermediate use share of gross output

binscatter share_cap markup if scenario==2, msymbol(oh) n(100) absorb(year) reportreg ///
	ytitle("Industry capital costs / factor costs") xtitle("Industry gross output markup") ///
	lcolor(black) mcolor(black) ///
	ylabel(, nogrid format(%9.1f) angle(0)) ///
	xlabel(.5(.5)3) 
graph export "./Drafts/fig_cap_share_markup_ind.eps", as(eps) replace fontface("Times New Roman")

binscatter share_cap int_share if scenario==2, msymbol(oh) n(100) absorb(year) reportreg ///
	ytitle("Industry capital costs / factor costs") xtitle("Industry intermediate use share") ///
	lcolor(black) mcolor(black) ///
	ylabel(, nogrid format(%9.1f) angle(0)) ///
	xlabel(0(.25)1.5) 
graph export "./Drafts/fig_cap_share_intshare_ind.eps", as(eps) replace fontface("Times New Roman")

