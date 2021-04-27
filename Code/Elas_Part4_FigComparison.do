/*
Figures for baseline results
*/

use "./Work/USA_scenario_sample_epsilon.dta", clear

keep if inrange(year,1948,2018)

//replace cost_cap = share_st + share_eq + share_ip if scenario=="noprofit"
gen factor_cap = factor_st + factor_eq + factor_ip

keep cost* share* factor* year sample prop ip scenario
reshape wide cost* share* factor*, i(year sample prop ip) j(scenario) string
sort sample prop year
gen alpha = .33
gen beta = .67

// Baseline capital elasticity series
twoway rarea cost_capdeprcost cost_capnoprofit year if sample=="all" & prop=="split" & ip=="ip", color(gray) fintensity(10) lwidth(0) ///
	|| line cost_capdeprcost year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) /// lwidth(medthick) ///
	|| line cost_capnoprofit year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| line alpha year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dot) /// lwidth(medthick) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	xscale(range(1950 2020)) ///
	text(.33 2020 "1/3") ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "Boundary capital cost assumption:" 3 "No economic profits" 2 "Depreciation only" ))
graph export "./Drafts/fig_cap_base_comparison.eps", as(eps) replace fontface("Times New Roman")


// Alternative capital elasticity series
twoway rarea cost_capdeprcost cost_capnoprofit year if sample=="all" & prop=="split" & ip=="ip", color(gray) fintensity(10) lwidth(0) ///
	|| line cost_capdeprcost year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) /// lwidth(medthick) ///
	|| line cost_capnoprofit year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter cost_capinvcost year if sample=="all" & prop=="split" & ip=="ip", connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	|| scatter cost_capusercost year if sample=="all" & prop=="split" & ip=="ip", connect(line) msymbol(oh) mcolor(black) lcolor(black) ///
	|| line alpha year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dot) /// lwidth(medthick) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	xscale(range(1950 2020)) ///
	text(.33 2020 "1/3") ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "Boundary capital cost assumption:" 3 "No economic profits" 2 "Depreciation only"  - " " "Alternative capital cost assumption:" 4 "Investment cost" 5 "User cost"))
graph export "./Drafts/fig_cap_all_comparison.eps", as(eps) replace fontface("Times New Roman")

// Baseline labor elasticity series
twoway rarea cost_compdeprcost cost_compnoprofit year if sample=="all" & prop=="split" & ip=="ip", color(gray) fintensity(10) lwidth(0) ///
	|| line cost_compdeprcost year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) /// lwidth(medthick) ///
	|| line cost_compnoprofit year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter cost_compinvcost year if sample=="all" & prop=="split" & ip=="ip", connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	|| scatter cost_compusercost year if sample=="all" & prop=="split" & ip=="ip", connect(line) msymbol(p) mcolor(black) lpattern(dash_dot) ///
	ytitle("Labor elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(5) cols(1) region(lcolor(white)) order(- "Bounds:" 2 "Depreciation only" 3 "No profits" - " " "Alternatives:" 4 "Investment cost" 5 "User cost"))
graph export "./Drafts/fig_comp_all_comparison.eps", as(eps) replace fontface("Times New Roman")

// Private business
twoway rarea cost_capdeprcost cost_capnoprofit year if sample=="all" & prop=="split" & ip=="ip", color(gray) fintensity(10) lwidth(0) ///
	|| rarea cost_capdeprcost cost_capnoprofit year if sample=="nogovhs" & prop=="split" & ip=="ip", color(gray) fintensity(40) lwidth(0) ///
	|| line cost_capnoprofit year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| line cost_capdeprcost year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| line cost_capnoprofit year if sample=="nogovhs" & prop=="split" & ip=="ip", lcolor(black)  ///
	|| line cost_capdeprcost year if sample=="nogovhs" & prop=="split" & ip=="ip",  lcolor(black) ///	
	|| line alpha year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dot) /// lwidth(medthick) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	xscale(range(1950 2020)) ///
	text(.33 2020 "1/3") ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "Private business only:" 2 "Range" 5 "Bounds" - " " "GDP (Priv. bus. plus housing and gov.):" 1 "Range" 3 "Bounds"))
graph export "./Drafts/fig_cap_priv_comparison.eps", as(eps) replace fontface("Times New Roman")

// Decapitalize IP
twoway rarea cost_capdeprcost cost_capnoprofit year if sample=="all" & prop=="split" & ip=="ip", color(gray) fintensity(10) lwidth(0) ///
	|| rarea cost_capdeprcost cost_capnoprofit year if sample=="all" & prop=="split" & ip=="noip", color(gray) fintensity(40) lwidth(0) ///
	|| line cost_capnoprofit year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| line cost_capdeprcost year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| line cost_capnoprofit year if sample=="all" & prop=="split" & ip=="noip", lcolor(black)  ///
	|| line cost_capdeprcost year if sample=="all" & prop=="split" & ip=="noip",  lcolor(black) ///	
	|| line alpha year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dot) /// lwidth(medthick) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	xscale(range(1950 2020)) ///
	text(.33 2020 "1/3") ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "De-capitalized IP:" 2 "Range" 5 "Bounds" - " " "Baseline (IP as capital):" 1 "Range" 3 "Bounds"))
graph export "./Drafts/fig_cap_ip_comparison.eps", as(eps) replace fontface("Times New Roman")

// Proprietors income
twoway line cost_capnoprofit year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| line cost_capnoprofit year if sample=="all" & prop=="alllab" & ip=="ip", lcolor(gray) lpattern(dash) /// lwidth(medthick) ///
	|| scatter cost_capnoprofit year if sample=="all" & prop=="allcap" & ip=="ip", connect(line) msymbol(oh) mcolor(gray) lcolor(gray) /// lwidth(medthick) ///
	|| line cost_capdeprcost year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) /// lwidth(medthick) ///
	|| line cost_capdeprcost year if sample=="all" & prop=="alllab" & ip=="ip", lcolor(gray)   /// lwidth(medthick) ///	
	|| scatter cost_capdeprcost year if sample=="all" & prop=="allcap" & ip=="ip", connect(line) msymbol(x) mcolor(gray) lcolor(gray) /// lwidth(medthick) ///	
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(10) cols(2) region(lcolor(white)) order( - "No-profit bound:" - "Depreciation cost bound:" 1 "Prop. income split" 4 "Prop. income split" 2 "Prop. income = labor cost" 5 "Prop. income = labor cost" 3 "Prop. income = capital cost" 6 "Prop. income = capital cost" ))
graph export "./Drafts/fig_cap_prop_comparison.eps", as(eps) replace fontface("Times New Roman")


// Expected inflation
twoway line cost_capusercost year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) /// lwidth(medthick) ///
	|| scatter cost_capuserfor3 year if sample=="all" & prop=="split" & ip=="ip" & year<2015, connect(line) msymbol(x) mcolor(gray) lcolor(gray) /// lwidth(medthick) ///
	|| scatter cost_capuserback3 year if sample=="all" & prop=="split" & ip=="ip" & year>1951, connect(line) msymbol(oh) mcolor(gray) lcolor(gray) /// lwidth(medthick) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(10) cols(1) region(lcolor(white)) order( - "User cost of capital:" 1 "Expected inflation = current inflation" 2 "Expected inflation = 3-year forward avg." 3 "Expected inflation = 3-year backward avg."))
graph export "./Drafts/fig_cap_user_comparison.eps", as(eps) replace fontface("Times New Roman")


// Cap elasticity with series breaks
twoway line cost_capdeprcost year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) /// lwidth(medthick) ///
	|| line cost_capnoprofit year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter cost_capinvcost year if sample=="all" & prop=="split" & ip=="ip", connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	|| scatter cost_capusercost year if sample=="all" & prop=="split" & ip=="ip", connect(line) msymbol(oh) mcolor(black) lcolor(black) ///
	|| line alpha year if sample=="all" & prop=="split" & ip=="ip", lcolor(black) lpattern(dot) /// lwidth(medthick) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	xscale(range(1950 2020)) ///
	text(.02 1955 "1948-1962") ///
	text(.02 1975 "1963-1986") ///
	text(.02 1991.5 "1987-1996") ///
	text(.02 2008 "1997-2018") ///
	xline(1962.5, lpattern(dot) lcolor(black)) ///
	xline(1986.5, lpattern(dot) lcolor(black)) ///
	xline(1996.5, lpattern(dot) lcolor(black)) ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "Boundary capital cost assumption:" 3 "No economic profits" 2 "Depreciation only"  - " " "Alternative capital cost assumption:" 4 "Investment cost" 5 "User cost"))
graph export "./Drafts/fig_cap_break_comparison.eps", as(eps) replace fontface("Times New Roman")
