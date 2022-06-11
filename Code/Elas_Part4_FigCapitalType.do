/*
Figures for different types of capital
*/

use "./Work/USA_scenario_annual_results_all.dta", clear

keep if inrange(year,1948,2018)

twoway line elas_st year if scenario==3, lcolor(black) /// lwidth(medthick) ///
	|| scatter elas_eq year if scenario==3, connect(line) msymbol(dh) mcolor(black) lpattern(dash) lcolor(black) ///
	|| line elas_ip year if scenario==3, lcolor(black) lpattern(dash) ///
	ytitle("Capital elasticity") xtitle("Year") ///
	ylabel(0(.05).35, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(1 "Structures" 2 "Equipment" 3 "Intellectual prop."))

graph export "./Drafts/fig_cap_type_comparison.eps", as(eps) replace fontface("Times New Roman")

/*
Figures for individual capital types
*/

use "./Work/USA_scenario_1_annual_results.dta", clear // baseline no-profit results
gen elas_st_noprofit = elas_st // create single capital elasticity
gen elas_eq_noprofit = elas_eq
gen elas_ip_noprofit = elas_ip
keep year elas_st_noprofit elas_eq_noprofit  elas_ip_noprofit // keep for merging

merge 1:1 year using "./Work/USA_scenario_2_annual_results.dta" // merge depr cost results
gen elas_st_deprcost = elas_st // create single capital elasticity
gen elas_eq_deprcost = elas_eq
gen elas_ip_deprcost = elas_ip
keep year elas_st_* elas_eq_* elas_ip_*

merge 1:1 year using "./Work/USA_scenario_3_annual_results.dta" // merge inv cost results
gen elas_st_invcost = elas_st // create single capital elasticity
gen elas_eq_invcost = elas_eq
gen elas_ip_invcost = elas_ip
keep year elas_st* elas_eq* elas_ip*


twoway rarea elas_st_deprcost elas_st_noprofit year, color(gray) fintensity(10) lwidth(0) ///
	|| line elas_st_deprcost year, lcolor(black) /// lwidth(medthick) ///
	|| line elas_st_noprofit year, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter elas_st_invcost year, connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	ytitle("Structures elasticity") xtitle("Year") text(.22 1983 "Structures") ///
	ylabel(0(.05).25, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	xscale(range(1950 2020)) ///
	legend(off)
	//legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "Boundary capital cost assumption:" 3 "No economic profits" 2 "Depreciation only"  - " " "Alternative capital cost assumption:" 4 "Investment cost"))

graph save "./Work/st.gph", replace
graph export "./Drafts/fig_cap_st_comparison.eps", as(eps) replace fontface("Times New Roman")


twoway rarea elas_eq_deprcost elas_eq_noprofit year, color(gray) fintensity(10) lwidth(0) ///
	|| line elas_eq_deprcost year, lcolor(black) /// lwidth(medthick) ///
	|| line elas_eq_noprofit year, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter elas_eq_invcost year, connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	ytitle("Equipment elasticity") xtitle("Year")  text(.2 1983 "Equipment") ///
	ylabel(0(.05).25, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	xscale(range(1950 2020)) ///
	legend(off)
	//legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "Boundary capital cost assumption:" 3 "No economic profits" 2 "Depreciation only"  - " " "Alternative capital cost assumption:" 4 "Investment cost"))

graph save "./Work/eq.gph", replace	
graph export "./Drafts/fig_cap_eq_comparison.eps", as(eps) replace fontface("Times New Roman")


twoway rarea elas_ip_deprcost elas_ip_noprofit year, color(gray) fintensity(10) lwidth(0) ///
	|| line elas_ip_deprcost year, lcolor(black) /// lwidth(medthick) ///
	|| line elas_ip_noprofit year, lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| scatter elas_ip_invcost year, connect(line) msymbol(x) mcolor(black) lcolor(black) ///
	ytitle("IP elasticity") xtitle("Year")  text(.12 1983 "Intellectual property") ///
	ylabel(0(.05).15, nogrid format(%9.2f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	xscale(range(1950 2020)) ///
	legend(cols(3) order(3 "No-profit upper bound" 2 "Depreciation cost lower bound" 4 "Investment cost assumption"))
	//legend(ring(0) pos(2) cols(1) region(lcolor(white)) order(- "Boundary capital cost assumption:" 3 "No economic profits" 2 "Depreciation only"  - " " "Alternative capital cost assumption:" 4 "Investment cost"))	

graph save "./Work/ip.gph", replace
graph export "./Drafts/fig_cap_ip_comparison.eps", as(eps) replace fontface("Times New Roman")

graph combine "./Work/st.gph" "./Work/eq.gph" "./Work/ip.gph", iscale(.6) col(1) graphregion(color(white))
graph export "./Drafts/fig_cap_combined_comparison.eps", as(eps) replace fontface("Times New Roman")
