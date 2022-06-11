/*
Table of summary stats of cost and value-added shares for Gov and Housing only
*/


// Create file to hold table rows
capture file close f_result
file open f_result using "./Drafts/tab_cost_hsgov.txt", write replace

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

// Housing only
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{8}{l}{Panel A: Housing} \\" _n

foreach s in 1 3 4 2 {
	use "./Work/USA_scenario_`s'_industry_results.dta", clear
	keep if inrange(year,1948,2018)
	gen title=""
	replace title = "No-profit" if ctrl_capital=="noprofit"
	replace title = "Investment cost" if ctrl_capital=="invcost"
	replace title = "User cost" if ctrl_capital=="usercost"
	replace title = "Depreciation cost" if ctrl_capital=="deprcost"
	keep if inlist(code,"HS","ORE","531") // only housing
	collapse (first) title (sum) cost_* iova, by(scenario year)
	gen vashare_cap = (cost_st + cost_ip + cost_eq)/iova
	gen fcshare_cap = (cost_st + cost_ip + cost_eq)/(cost_st + cost_ip + cost_eq + cost_comp)
	file_calc // call program to make calculations and write to file
}

// Gov only
file write f_result "\\" _n // make space for next section of table
file write f_result "\multicolumn{8}{l}{Panel B: Government} \\" _n

foreach s in 1 3 4 2 {
	use "./Work/USA_scenario_`s'_industry_results.dta", clear
	keep if inrange(year,1948,2018)
	gen title = ""
	replace title = "No-profit" if ctrl_capital=="noprofit"
	replace title = "Investment cost" if ctrl_capital=="invcost"
	replace title = "User cost" if ctrl_capital=="usercost"
	replace title = "Depreciation cost" if ctrl_capital=="deprcost"
	keep if inlist(code,"GFE","GFG","GFGD","GFGN","GSLE","GSLG") // only government
	collapse (first) title (sum) cost_* iova, by(scenario year)
	gen vashare_cap = (cost_st + cost_ip + cost_eq)/iova
	gen fcshare_cap = (cost_st + cost_ip + cost_eq)/(cost_st + cost_ip + cost_eq + cost_comp)
	file_calc // call program to make calculations and write to file		
}


capture file close f_result
