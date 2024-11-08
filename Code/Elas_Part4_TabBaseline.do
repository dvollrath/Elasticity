/*
Table of summary stats of elasticities with different assumptions
*/

// Create file to hold table rows
capture file close f_result
file open f_result using "./Drafts/tab_scenario_summary.txt", write replace

use "./Work/USA_scenario_annual_results_all.dta", clear // start with file of all annual results
keep if inrange(year,1948,2018)
gen elas_cap = elas_st + elas_eq + elas_ip // generate single measure of capital elasticity

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
	
	summ elas_cap, det
	local mean_cap = r(mean)
	local med_cap = r(p50)
	local min_cap = r(min)
	local max_cap = r(max)
	
	summ elas_cap if inrange(year,1948,2000)
	local year_prior = r(mean)
	summ elas_cap if inrange(year,2000,2018)
	local year_post = r(mean)
		
	file write f_result "`text' &" %9.3f (`mean_cap') "&" %9.3f (`med_cap') ///
		"&" %9.3f (`min_cap') "&" %9.3f (`max_cap') "&" %9.3f (`year_prior')  "&"  %9.3f (`year_post') ///
		 "\\" _n
end


// Main results
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{7}{l}{Panel A: Baseline} \\" _n

foreach s in 1 3 4 2 {
	preserve
		keep if scenario==`s' // limit dataset
		file_calc // call program to make calculations and write to file
	restore
}

// Private business sector
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{7}{l}{Panel B: Private business sector} \\" _n

foreach s in 5 7 8 6 {
	preserve
		keep if scenario==`s' // limit dataset
		file_calc // call program to make calculations and write to file
	restore
}

// Excluding IP
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{7}{l}{Panel C: De-capitalizing intellectual property} \\" _n

foreach s in 9 11 12 10 {
	preserve
		keep if scenario==`s' // limit dataset
		file_calc // call program to make calculations and write to file
	restore
}

// Excluding housing, gov, and IP
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{7}{l}{Panel D: Private business sector and decapitalizing IP} \\" _n

foreach s in 13 15 16 14 {
	preserve
		keep if scenario==`s' // limit dataset
		file_calc // call program to make calculations and write to file
	restore
}

capture file close f_result
