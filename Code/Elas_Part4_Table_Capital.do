/*
Create table of results for capital types, by assumption
*/

// Create file to hold table rows
capture file close f_result
file open f_result using "./Drafts/tab_capital_summary.txt", write replace

// Use file of results of elasticity calculations
use "./Work/USA_scenario_sample_epsilon.dta", clear

keep if inrange(year,1948,2018)

// Create meaningful names for scenarios
gen title = ""
replace title = "No-profit (by stock)" if scenario=="noprofit"
replace title = "No-profit (by invest)" if scenario=="noprofinv"
replace title = "Investment cost" if scenario=="invcost"
replace title = "User cost" if scenario=="usercost"
replace title = "Depreciation cost" if scenario=="deprcost"

// Program to write common information to output file, given a scenario/sample
capture program drop file_calc
program file_calc
	local text = title[1]
	
	summ cost_cap, det
	local mean_cap = r(mean)
	local med_cap = r(p50)
	local min_cap = r(min)
	local max_cap = r(max)
	
	reg cost_cap year
	local reg_slope = _b[year]
	local reg_se = _se[year]
	local reg_fit = _b[year]*70
	local reg_rsquare = e(r2)
	
	file write f_result "`text' &" %9.3f (`mean_cap') "&" %9.3f (`med_cap') ///
		"&" %9.3f (`min_cap') "&" %9.3f (`max_cap') "&" %9.3f (`reg_fit')  "&"  %9.4f (`reg_slope') ///
			"&" %9.3f (`reg_rsquare') "\\" _n
end

// Structures
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{8}{l}{Panel A: Structures} \\" _n
local samp = "all"

foreach s in noprofit noprofinv invcost usercost deprcost {
	preserve
		keep if sample=="all" & scenario=="`s'" & prop=="split" & ip=="ip" // limit dataset
		replace cost_cap = cost_st // use structures cost for program
		file_calc // call program to make calculations and write to file
	restore
}

// Equipment
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{8}{l}{Panel B: Equipment} \\" _n
local samp = "all"

foreach s in noprofit noprofinv invcost usercost deprcost {
	preserve
		keep if sample=="all" & scenario=="`s'" & prop=="split" & ip=="ip" // limit dataset
		replace cost_cap = cost_eq // use structures cost for program
		file_calc // call program to make calculations and write to file
	restore
}

// Intellectual property
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{8}{l}{Panel C: Intellectual property} \\" _n
local samp = "all"

foreach s in noprofit noprofinv invcost usercost deprcost {
	preserve
		keep if sample=="all" & scenario=="`s'" & prop=="split" & ip=="ip" // limit dataset
		replace cost_cap = cost_ip // use structures cost for program
		file_calc // call program to make calculations and write to file
	restore
}


capture file close f_result
