/*
Merge all annual result files into one master file of results
*/

// Get list of all scenario files located in the Work folder
local fileList : dir "./Work" files "USA_scenario_*_annual_results.dta" // get file names

clear
qui rm "./Work/USA_scenario_annual_results_all.dta"
qui save "./Work/USA_scenario_annual_results_all.dta", emptyok replace
	
foreach file of local fileList { // for each scenario file
	di "`file'"
	qui append using "./Work/`file'"
}
qui save "./Work/USA_scenario_annual_results_all.dta", replace
