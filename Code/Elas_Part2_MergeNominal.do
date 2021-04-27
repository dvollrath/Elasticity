/*
Create raw files for scenarios
Naics/year files
- One with just the basic assumed nominal return data
- One with the full information on nominal returns to allow for alternative assumptions
*/

//////////////////////////////////////////////////////////////////
// merge annual return data to create working file
//////////////////////////////////////////////////////////////////
use "./Work/USA_naics4718_merged.dta", clear

merge m:1 bearate year using "./Work/USA_annual_Rcalc.dta"
keep if _merge==3 // failures will be years with Rcalc data but not in 1947-2018 window
drop _merge

save "./Work/USA_scenario_baseline.dta", replace

//////////////////////////////////////////////////////////////////
// merge full annual return data to create working file
//////////////////////////////////////////////////////////////////
use "./Work/USA_naics4718_merged.dta", clear

merge m:1 bearate year using "./Work/USA_annual_Rcalc_full.dta"
keep if _merge==3 // failures will be years with Rcalc data but not in 1947-2018 window
drop _merge

save "./Work/USA_scenario_baseline_full.dta", replace
