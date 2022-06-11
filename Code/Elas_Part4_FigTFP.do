/*
Figures for TFP level
*/

use "./Work/USA_tfp_scenario.dta", clear

// BLS, no utilization adjustment

twoway line level_elas year if capital=="noprofit", lcolor(black) lpattern(dash) ///
	|| line level_elas year if capital=="deprcost", lcolor(black) ///
	|| scatter level_elas year if capital=="invcost", connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	|| scatter level_elas year if capital=="usercost", connect(line) msymbol(p) mcolor(black) lcolor(gray) lpattern(dash_dot) ///
	ytitle("TFP level (1947==100)") xtitle("Year") ///
	ylabel(100(50)350, nogrid format(%9.0f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(10) cols(1) region(lcolor(white)) order(- "Bounds:" 1 "No-profit/BLS baseline" 2 "Depreciation cost" - " " "Alternatives:" 3 "Investment cost" 4 "User cost"))
graph export "./Drafts/fig_tfp_comparison.eps", as(eps) replace fontface("Times New Roman")
