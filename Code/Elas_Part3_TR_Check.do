/*
Calculate factor elasticities in different scenario/sample combinations
*/

/*
Set up runs of the estimation based on different assumptions
 Each run is controlled by a local macro with the following structure
	  local run<X> = "<sample> <capital cost> <prop income> <ip>"
 - <X> is a unique number to denote a run, has to be consecutive
 - <sample> is one of: all nogov nohs nogovhs 
 - <capital cost> is one of: noprofit deprcost invcost usercost noprofinv noprofuser userfor3 userback3
 - <prop income> is one of: split alllab allcap
 - <ip> is one of: ip noip
*/
local run1 = "all noprofit split ip ignore"
local run2 = "all deprcost split ip ignore"
local run3 = "all invcost split ip ignore"
local run4 = "all usercost split ip ignore"

// Create working files to hold estimates of elasticities
clear
save "./Work/USA_scenario_tr_epsilon.dta", emptyok replace
clear
save "./Work/USA_scenario_tr_industry.dta", emptyok replace

// Run script to ensure programs are loaded
do "./Code/Elas_Part3_Programs.do"

// Loop through runs and do calculations
local i = 1 // iterator for run numbers
while "`run`i''" != "" { // keep looping while run locals exist
	tokenize `run`i'' // split the local holding the options into pieces
	di "Sample `1'"
	di "Scenario `2'"
	di "Proprietors income `3'"
	di "Intell prop `4'"
	di "Treat used/other `5'"
			
	// Create sample and costs using passed parameters
	use "./Work/USA_scenario_baseline.dta", clear // start with baseline data
	
	sample_`1' // call program to select sample
	labor_`3' // call program to set labor costs
	intel_`4' // call program to include/exclude IP
	used_`5' // call program to deal with used/other industries
	capital_`2' // call program to set capital costs
			
	keep if inrange(year,1997,2018) // limit to range of TR tables
	
	qui gen scenario = "`2'" // record parameters as variables for output file
	qui gen sample = "`1'"
	qui gen prop = "`3'"
	qui gen ip = "`4'"
	qui gen used = "`5'"
	qui keep series scenario sample prop ip used code year iova iogo iofu cost* // keep only what is necessary for calcs
	qui save "./Work/USA_scenario_calculate.dta", replace // save working file for calculation
	
	calc_share // call program to calculate VA and factor cost shares of different inputs
			
	calc_tr // call program to go year-by-year and do calculation
		// This produces "./Work/USA_scenario_sample_industry.dta"
			
	clear
	svmat Epsilon, names(col) // save stored elasticities to memory
	qui drop if year==0 // eliminates initial row
	
	qui gen scenario = "`2'" // record parameters as variables for output file
	qui gen sample = "`1'"
	qui gen prop = "`3'"
	qui gen ip = "`4'"
	qui gen used = "`5'"
	
	qui append using "./Work/USA_scenario_tr_epsilon.dta"
	qui save "./Work/USA_scenario_tr_epsilon.dta", replace

	local i = `i' + 1 // increment
} // end while loop

// Save off working results files to permanent storage, if desired
use "./Work/USA_scenario_tr_industry.dta", clear
save "./Work/USA_scenario_tr_industry.dta", replace

use "./Work/USA_scenario_tr_epsilon.dta", clear
save "./Work/USA_scenario_tr_epsilon.dta", replace
