/*
Figures for comparison of cost share and elasticity
*/

use "./Work/USA_scenario_sample_epsilon.dta", clear

keep if inrange(year,1948,2018)

gen factor_cap = factor_st + factor_eq + factor_ip

scatter cost_cap factor_cap if scenario=="deprcost" & sample=="all" & prop=="split" & ip=="ip", msymbol(dh) mcolor("gs8%50") ///
	|| scatter cost_cap factor_cap if scenario=="invcost" & sample=="all" & prop=="split" & ip=="ip", msymbol(sh) mcolor("gs8%50") ///
	|| scatter cost_cap factor_cap if scenario=="usercost" & sample=="all" & prop=="split" & ip=="ip", msymbol(th) mcolor("gs8%50") ///
	|| lfit factor_cap factor_cap if scenario=="usercost" & sample=="all" & prop=="split" & ip=="ip", lpattern(dash) lcolor(black) ///
	ytitle("Estimated aggregate capital elasticity") xtitle("Aggregate capital costs/aggregate factor costs") ///
	ylabel(0.1(.05).45,nogrid format(%9.2f) angle(0)) ///
	xlabel(0.1(.05).45,format(%9.2f)) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(4) region(lcolor(white)) cols(1) order(- "Capital cost assumption:" 1 "Depreciation costs" 2 "Investment costs" 3 "User costs" 4 "45-degree line"))
graph export "./Drafts/fig_cap_total_comparison.eps", as(eps) replace fontface("Times New Roman")

gen diff = cost_cap-factor_cap
summ diff if scenario=="deprcost" & sample=="all" & prop=="split" & ip=="ip"
summ diff if scenario=="invcost" & sample=="all" & prop=="split" & ip=="ip"
summ diff if scenario=="usercost" & sample=="all" & prop=="split" & ip=="ip"
