/*
Create table of results for housing and government, by assumption
*/

// Create file to hold table rows
capture file close f_result
file open f_result using "./Drafts/tab_cost_hsgov.txt", write replace

// Program to write common information to output file, given a scenario/sample
capture program drop file_calc
program file_calc
	local text = title[1]
	
	summ va_cap, det
	local mean_cap = r(mean)
	local med_cap = r(p50)
	local min_cap = r(min)
	local max_cap = r(max)
	
	summ factor_cap, det
	local mean_factor = r(mean)
	local med_factor = r(p50)
	local min_factor = r(min)
	local max_factor = r(max)

	file write f_result "`text' &" %9.3f (`mean_cap') "&" %9.3f (`med_cap') ///
		"&" %9.3f (`min_cap') "&" %9.3f (`max_cap') ///
		"&" %9.3f (`mean_factor')  "&"  %9.3f (`med_factor') ///
		"&" %9.3f (`min_factor') "&" %9.3f (`max_factor') "\\" _n
end

// Split by sector
use "./Work/USA_scenario_sample_industry.dta", clear

keep if inrange(year,1948,2018)

gen cost_cap = cost_st + cost_eq + cost_ip
gen cap_total = cost_cap*iogo
gen comp_total = cost_comp*iogo

gen group = 0
replace group = 1 if inlist(code,"HS","ORE","531")
replace group = 2 if inlist(code,"GFE","GFG","GFGD","GFGN")
replace group = 2 if inlist(code,"GSLE","GSLG")
collapse (sum) cap_total comp_total iova, by(scenario sample prop group year)

gen va_cap = cap_total/iova
gen va_comp = comp_total/iova
gen factor_cap = cap_total/(cap_total+comp_total)

// Create meaningful names for scenarios
gen title = ""
replace title = "No-profit" if scenario=="noprofit"
replace title = "Investment cost" if scenario=="invcost"
replace title = "User cost" if scenario=="usercost"
replace title = "Depreciation cost" if scenario=="deprcost"


// Housing
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{8}{l}{Panel A: Owner-occupied housing only} \\" _n
local group = 1

foreach s in noprofit invcost usercost deprcost {
	preserve
		keep if sample=="all" & scenario=="`s'" & prop=="split" & group==`group' // limit dataset
		file_calc // call program to make calculations and write to file
	restore
}

// Government
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{8}{l}{Panel B: Government only} \\" _n
local group = 2

foreach s in noprofit invcost usercost deprcost {
	preserve
		keep if sample=="all" & scenario=="`s'" & prop=="split" & group==`group' // limit dataset
		file_calc // call program to make calculations and write to file
	restore
}
// Private business sector
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{8}{l}{Panel C: Excluding owner-occupried housing and government} \\" _n
local group = 0

foreach s in noprofit invcost usercost deprcost {
	preserve
		keep if sample=="all" & scenario=="`s'" & prop=="split" & group==`group' // limit dataset
		file_calc // call program to make calculations and write to file
	restore
}
capture file close f_result
