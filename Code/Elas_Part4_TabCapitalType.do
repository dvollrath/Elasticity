/*
Create table of results for capital types, by assumption
*/

// Create file to hold table rows
capture file close f_result
file open f_result using "./Drafts/tab_capital_summary.txt", write replace

// Use file of results of elasticity calculations
use "./Work/USA_scenario_annual_results_all.dta", clear

keep if inrange(year,1948,2018)

// Create meaningful names for scenarios
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

// Structures
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{7}{l}{Panel A: Structures} \\" _n
local samp = "all"

foreach s in 1 3 4 2 {
	preserve
		keep if scenario==`s' // limit dataset
		capture drop elas_cap
		gen elas_cap = elas_st // use structures for program
		file_calc // call program to make calculations and write to file
	restore
}

// Equipment
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{7}{l}{Panel B: Equipment} \\" _n
local samp = "all"

foreach s in 1 3 4 2 {
	preserve
		keep if scenario==`s' // limit dataset
		capture drop elas_cap
		gen elas_cap = elas_eq // use equipment for program
		file_calc // call program to make calculations and write to file
	restore
}

// Intellectual property
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{7}{l}{Panel C: Intellectual property} \\" _n
local samp = "all"

foreach s in 1 3 4 2 {
	preserve
		keep if scenario==`s' // limit dataset
		capture drop elas_cap
		gen elas_cap = elas_ip // use IP for program
		file_calc // call program to make calculations and write to file
	restore
}


capture file close f_result
