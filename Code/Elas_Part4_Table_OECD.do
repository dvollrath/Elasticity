/*
Table for comparison of labor shares across OECD
*/


use "./Work/OECD_STAN4_9509_elasticity.dta", clear
append using "./Work/OECD_STAN4_0515_elasticity.dta"

sort cou year assump

drop if inrange(elas_labor,-1,.02) // eliminate meaningless calculations 
drop if inrange(elas_labor,.99,2)

drop if series==9509 // only use the 2005-15 estimates

reshape wide elas_labor elas_capital, i(year cou) j(assump) string

bysort cou: egen cou_count = count(elas_capitaldepr_self)
summ cou_count
keep if cou_count==r(max)
capture drop cou_count
bysort cou: egen cou_count = count(elas_capitalnoprofit_self)
summ cou_count
keep if cou_count==r(max)

sort cou year

capture file close f_result
file open f_result using "./Drafts/tab_oecd_summary2.txt", write replace

gen name = ""
replace name = "Austria" if cou=="AUT"
replace name = "Belgium" if cou=="BEL"
replace name = "Czech Republic" if cou=="CZE"
replace name = "Germany" if cou=="DEU"
replace name = "Denmark" if cou=="DNK"
replace name = "Estonia" if cou=="EST"
replace name = "Finland" if cou=="FIN"
replace name = "France" if cou=="FRA"
replace name = "United Kingdom" if cou=="GBR"
replace name = "Hungary" if cou=="HUN"
replace name = "Italy" if cou=="ITA"
replace name = "Japan" if cou=="JPN"
replace name = "South Korea" if cou=="KOR"
replace name = "Lithuania" if cou=="LTU"
replace name = "Latvia" if cou=="LVA"
replace name = "Netherlands" if cou=="NLD"
replace name = "Norway" if cou=="NOR"
replace name = "Portugal" if cou=="PRT"
replace name = "Slovakia" if cou=="SVK"
replace name = "United States (OECD)" if cou=="USA"

levelsof name, local(countries)

foreach n of local countries {

	foreach i in capitaldepr_self capitalnoprofit_self capitalinvest_self {
		summ elas_`i' if name == "`n'"
		local `i' = r(mean)
		summ elas_`i' if name == "`n'" & year==2005
		local first = r(mean)
		summ elas_`i' if name == "`n'" & year==2015
		local last = r(mean)
		local diff_`i' = `last' - `first'
	}
	
	file write f_result "`n' &" %9.3f (`capitaldepr_self') "&" %9.3f (`capitalinvest_self') ///
		"&" %9.3f (`capitalnoprofit_self') "&" %9.3f (`diff_capitaldepr_self') "&" ///
		%9.3f (`diff_capitalinvest_self') "&" %9.3f (`diff_capitalnoprofit_self') "\\" _n 
	
}

file write f_result "\\" _n

foreach i in capitaldepr_self capitalnoprofit_self capitalinvest_self {
	summ elas_`i', det
	local `i'_mean = r(mean)
	local `i'_med = r(p50)
	summ elas_`i' if year==2005, det
	local first_mean = r(mean)
	local first_med = r(p50)
	summ elas_`i' if year==2015, det
	local last_mean = r(mean)
	local last_med = r(p50)
	local diff_mean_`i' = `last_mean' - `first_mean'
	local diff_med_`i' = `last_med' - `first_med'
}

file write f_result "OECD mean &" %9.3f (`capitaldepr_self_mean') "&" %9.3f (`capitalinvest_self_mean') ///
		"&" %9.3f (`capitalnoprofit_self_mean') "&" %9.3f (`diff_mean_capitaldepr_self') "&" ///
		%9.3f (`diff_mean_capitalinvest_self') "&" %9.3f (`diff_mean_capitalnoprofit_self') "\\" _n 
file write f_result "OECD median &" %9.3f (`capitaldepr_self_med') "&" %9.3f (`capitalinvest_self_med') ///
		"&" %9.3f (`capitalnoprofit_self_med') "&" %9.3f (`diff_med_capitaldepr_self') "&" ///
		%9.3f (`diff_med_capitalinvest_self') "&" %9.3f (`diff_med_capitalnoprofit_self') "\\" _n 

file write f_result "\\" _n

use "./Work/USA_scenario_sample_epsilon.dta", clear

foreach i in deprcost noprofit invcost {
		summ cost_cap if scenario=="`i'" & sample=="all" & prop=="split" & ip=="ip" & inrange(year,2005,2015)
		local `i' = r(mean)
		summ cost_cap if scenario=="`i'" & sample=="all" & prop=="split" & ip=="ip" & year==2005
		local first = r(mean)
		summ cost_cap if scenario=="`i'" & sample=="all" & prop=="split" & ip=="ip" & year==2015
		local last = r(mean)
		local diff_`i' = `last' - `first'
}

file write f_result "United States (BEA) &" %9.3f (`deprcost') "&" %9.3f (`invcost') ///
		"&" %9.3f (`noprofit') "&" %9.3f (`diff_deprcost') "&" ///
		%9.3f (`diff_invcost') "&" %9.3f (`diff_noprofit') "\\" _n 

capture file close f_result

