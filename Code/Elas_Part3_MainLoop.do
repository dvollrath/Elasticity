/*
Main Loop to process scenarios and calculate elasticities
*/

// Get list of all scenario files located in the Work folder
local fileList : dir "./Work" files "USA_scenario_*_data.dta" // get file names
local nfiles: word count `fileList'

local i = 1
foreach file of local fileList { // for each scenario file
	di _newline "Processing file `i' of `nfiles'"
	di "-Scenario: `file'"
	use "./Work/`file'", clear // use that scenario file
	qui ds cost* // describe all variables called "cost*" - these are factor costs
	local nfactors: word count `r(varlist)' // count how many factors there are
	mat Results = J(1,1+3*`nfactors',0) // initialize vector to hold results
		// columns for year, 3 columns for each factor included (elasticity, VA share, cost share)
	local scenario=scenario[1] // capture scenario number
	
	// Main loop
	qui summ year // find min and max years
	local ymin = r(min)
	local ymax = r(max) 
	di "-Years:" _continue
	forvalues y = `ymin'(1)`ymax' { // for each year in the scenario passed
		di "-" _continue
		
		// Perform calculations for given year
		preserve
			qui keep if year==`y' // limit data to given year
			sort codeorder // ensure industries in correct order
			qui do "./New/Elas_Part3_Calculate.do" // Call script to calculate elasticities
		restore
		
		// Save off industry results for given year
		preserve
			qui keep if year==`y' // limit date to given year
			sort codeorder // ensure industries in correct order
			qui drop if include==0 // drop industries not included to match returned results
			qui svmat Industry, names(col)
			qui save "./Work/USA_scenario_temp_industry_`y'.dta", replace
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
	qui save "./Work/USA_scenario_`scenario'_annual_results.dta", replace // save individual results file
	
	// Loop through industry-level files to save single file of all industry-level results
	qui clear
	qui save "./Work/USA_scenario_`scenario'_industry_results.dta", emptyok replace
	forvalues y = `ymin'(1)`ymax' { // for each year in the scenario passed
		qui append using "./Work/USA_scenario_temp_industry_`y'.dta"
		qui rm "./Work/USA_scenario_temp_industry_`y'.dta"
	}
	qui save "./Work/USA_scenario_`scenario'_industry_results.dta", replace
	local i = `i' + 1
}
	
		
		
	
