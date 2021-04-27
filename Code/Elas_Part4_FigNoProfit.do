/*
Figures for baseline results
*/

use "./Work/USA_scenario_sample_epsilon.dta", clear

keep if inrange(year,1948,2018)

//replace cost_cap = share_st + share_eq + share_ip if scenario=="noprofit"
gen factor_cap = factor_st + factor_eq + factor_ip
gen noprof_cost_cap = noprof_cost_st + noprof_cost_eq + noprof_cost_ip

// Baseline capital elasticity series
twoway line noprof_cost_cap year ///
	if scenario=="noprofit" & sample=="all" & ip=="ip" & prop=="split" ///
	, lcolor(black) lpattern(dash) ///
	|| line factor_cap year ///
	if scenario=="noprofit" & sample=="all" & ip=="ip" & prop=="split", ///
	lcolor(black) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "No-profit elasticity calculated:" 1 "Matrix method" 2 "Cost share method" ))
graph export "./Drafts/fig_cap_noprofit_comparison.eps", as(eps) replace fontface("Times New Roman")

