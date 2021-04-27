/*
Figures for different types of capital
*/

use "./Work/USA_scenario_sample_epsilon.dta", clear

keep if inrange(year,1948,2018)

sort sample prop year

twoway line cost_st year if scenario=="deprcost" & sample=="all" & prop=="split" & ip=="ip", lcolor(black) /// lwidth(medthick) ///
	|| scatter cost_eq year if scenario=="deprcost" & sample=="all" & prop=="split" & ip=="ip", connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	|| line cost_ip year if scenario=="deprcost" & sample=="all" & prop=="split" & ip=="ip", lcolor(gray) ///
	|| line cost_st year if scenario=="noprofinv" & sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter cost_eq year if scenario=="noprofinv" & sample=="all" & prop=="split" & ip=="ip", connect(line) msymbol(dh) mcolor(black) lpattern(dash) lcolor(black) ///
	|| line cost_ip year if scenario=="noprofinv" & sample=="all" & prop=="split" & ip=="ip", lcolor(gray) lpattern(dash) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.05).4, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(12) cols(2) region(lcolor(white)) order(- "Depreciation bound:" - "No-profit bound:" 1 "Structures" 4 "Structures" 2 "Equipment" 5 "Equipment" 3 "Intellectual prop." 6 "Intellectual prop."))

graph export "./Drafts/fig_cap_type_comparison.eps", as(eps) replace fontface("Times New Roman")

