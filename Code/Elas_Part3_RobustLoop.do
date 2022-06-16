/*
Robust Loop to calculate elasticities using BEA Total Requirements Table
*/


foreach i in 1 2 3 4 { // for each scenario file
	di "Scenario `i'"
	use "./Work/USA_scenario_`i'_data.dta", clear // use that scenario file
	qui ds cost* // describe all variables called "cost*" - these are factor costs
	local nfactors: word count `r(varlist)' // count how many factors there are
	mat Results = J(1,1+3*`nfactors',0) // initialize vector to hold results
		// columns for year, 3 columns for each factor included (elasticity, VA share, cost share)
	local scenario=scenario[1] // capture scenario number
	
	// Main loop
	di "-Years:" _continue
	forvalues y = 1997(1)2018 { // for each year for which the TR table exists
		di "-" _continue
		
		// Perform calculations for given year
		preserve
			qui keep if year==`y' // limit data to given year
			sort codeorder // ensure industries in correct order
			qui do "./Code/Elas_Part3_CalcRobust.do" // Call script to calculate elasticities
		restore
				
		// program returns vector "Return" of results
		mat Results = Results \ Return // append Return vector to Results vector	
	}
	di _newline // for spacing

	// Name columns in Results matrix based on Return vector
	local names: colnames Return // get column names from Return vector
	mat colnames Results = `names' // apply those names to full Results vector
	
	// Save off annual results for scenario
	mat Results = Results[2...,1...] // remove 0 row from Results from initializing
	qui keep scenario ctrl_* // keep only the identifier information
	qui keep if _n <= rowsof(Results) // keep enough rows to match Results matrix
	qui svmat Results, names(col) // loads results into memory
	qui save "./Work/USA_scenario_`scenario'_robust_results.dta", replace // save individual results file
}
	
clear
qui capture rm "./Work/USA_scenario_robust_results_all.dta"
qui save "./Work/USA_scenario_robust_results_all.dta", emptyok replace
	
foreach i in 1 2 3 4 { // for each scenario file
	di "File `i'"
	qui append using "./Work/USA_scenario_`i'_robust_results.dta"
}
qui save "./Work/USA_scenario_robust_results_all.dta", replace		
		
	
