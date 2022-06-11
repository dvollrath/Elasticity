/*
Table of summary stats of cost and value-added shares
*/


// Create file to hold table rows
capture file close f_result
file open f_result using "./Drafts/tab_cost_summary.txt", write replace

use "./Work/USA_scenario_annual_results_all.dta", clear // start with file of all annual results
keep if inrange(year,1948,2018)
gen vashare_cap = vashare_st + vashare_eq + vashare_ip // generate single measure of capital VA share
gen fcshare_cap = fcshare_st + fcshare_eq + fcshare_ip // generate single measure of capital factor cost share

// Create meaningful names for scenarios to use in table
gen title = ""
replace title = "No-profit" if ctrl_capital=="noprofit"
replace title = "Investment cost" if ctrl_capital=="invcost"
replace title = "User cost" if ctrl_capital=="usercost"
replace title = "Depreciation cost" if ctrl_capital=="deprcost"

// Program to write common information to output file, given a scenario/sample
capture program drop file_calc
program file_calc
	local text = title[1]
	
	summ vashare_cap, det
	local mean_cap = r(mean)
	local med_cap = r(p50)
	local min_cap = r(min)
	local max_cap = r(max)
	
	summ fcshare_cap, det
	local mean_factor = r(mean)
	local med_factor = r(p50)
	local min_factor = r(min)
	local max_factor = r(max)

	file write f_result "`text' &" %9.3f (`mean_factor')  "&"  %9.3f (`med_factor') ///
		"&" %9.3f (`min_factor') "&" %9.3f (`max_factor') ///
		"&"  %9.3f (`mean_cap') "&" %9.3f (`med_cap') ///
		"&" %9.3f (`min_cap') "&" %9.3f (`max_cap') ///
		"\\" _n
end

// All industries
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{8}{l}{Panel A: All industries} \\" _n

foreach s in 1 3 4 2 {
	preserve
		keep if scenario==`s' // limit dataset
		file_calc // call program to make calculations and write to file
	restore
}

// Private business sector
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{8}{l}{Panel B: Private business sector} \\" _n

foreach s in 5 7 8 6 {
	preserve
		keep if scenario==`s' // limit dataset
		file_calc // call program to make calculations and write to file
	restore
}

capture file close f_result
