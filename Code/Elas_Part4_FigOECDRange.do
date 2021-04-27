/*
Figures for OECD comparison
*/

use "./Work/OECD_STAN4_9509_elasticity.dta", clear
append using "./Work/OECD_STAN4_0515_elasticity.dta"
//append using "./Work/USA_0515_elasticity.dta"

sort cou year assump

drop if inrange(elas_labor,-1,.02) // eliminate meaningless calculations 
drop if inrange(elas_labor,.99,2)

drop if series==9509 //& inrange(year,2005,2009) // eliminate overlap, use later series

reshape wide elas_labor elas_capital, i(year cou) j(assump) string


bysort cou: egen cou_count = count(elas_capitaldepr_self)
summ cou_count
keep if cou_count==r(max)
capture drop cou_count
bysort cou: egen cou_count = count(elas_capitalnoprofit_self)
summ cou_count
keep if cou_count==r(max)

bysort year: egen depr_med = median(elas_capitaldepr_self) if cou ~= "USA"
bysort year: egen noprofit_med = median(elas_capitalnoprofit_self) if cou~="USA"

sort cou year

egen cou_id = group(cou)

label define names 1 "AUT" 2 "BEL" 3 "CZE" 4 "DEU" 5 "DNK" 6 "EST" 7 "FIN" ///
	8 "FRA" 9 "GBR" 10 "HUN" 11 "ITA" 12 "JPN" 13 "KOR" 14 "LTU" 15 "LVA" ///
	16 "NLD" 17 "NOR" 18 "POL" 19 "PRT" 20 "SVK" 21 "USA"
label values cou_id names

summ elas_capitaldepr_self if cou=="USA", det
gen usa_depr_med = r(p50)
summ elas_capitalnoprofit_self if cou=="USA", det
gen usa_noprof_med = r(p50)

twoway scatter cou_id elas_capitaldepr_self, msymbol(oh) mcolor(black) ///
	|| scatter cou_id elas_capitalnoprofit_self, msymbol(x) mcolor(black) ///
	|| line cou_id usa_depr_med, lcolor(black) lpattern(dash) ///
	|| line cou_id usa_noprof_med, lcolor(black) lpattern(dash) ///
	xlabel(0(.1)1, format(%9.1f)) ylabel(1(1)21, nogrid angle(0) valuelabel labsize(small)) ///
	xtitle("Capital elasticity") ytitle("") ///
	graphregion(color(white)) ///
	legend(ring(0) pos(2) cols(1)  order(1 "Depreciation bound" 2 "No-profit bound" 3 "Median US bounds"))
graph export "./Drafts/fig_cap_oecd_comparison.eps", as(eps) replace fontface("Times New Roman")
