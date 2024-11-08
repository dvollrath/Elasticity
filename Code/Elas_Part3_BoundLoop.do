/*
Loop to decompose difference in no-profit and depreciation cost estimates
*/

use "./Work/USA_scenario_1_data.dta", clear // use that scenario file
qui ds cost* // describe all variables called "cost*" - these are factor costs
local nfactors: word count `r(varlist)' // count how many factors there are
mat ResultsNP = J(1,1+`nfactors',0) // initialize vector to hold results
mat ResultsD = J(1,1+`nfactors',0) // initialize vector to hold results

forvalues y = 1948(1)2018 { // for each year in the scenario - hard-coded for this robustness check
	di "-" _continue
	
	use "./Work/USA_scenario_1_data.dta", clear // use no-profit scenario

	// Perform calculations for given year
	preserve
		qui keep if year==`y' // limit data to given year
		sort codeorder // ensure industries in correct order
		qui do "./Code/Elas_Part3_Calculate.do" // Call script to calculate elasticities
	restore
	
	mat NPCost = C*inv(diag(T)) // save factor cost shares of total costs for no-profit scenario
	mat NPQ = Q // save total requirement matrix for no-profit scenario
	mat NPf = f // save final use vector for no-profit scenario
	
	use "./Work/USA_scenario_2_data.dta", clear // use depreciation scenario

	// Perform calculations for given year
	preserve
		qui keep if year==`y' // limit data to given year
		sort codeorder // ensure industries in correct order
		qui do "./Code/Elas_Part3_Calculate.do" // Call script to calculate elasticities
	restore
	
	mat DCost = C*inv(diag(T)) // save factor cost shares of total costs for depr scenario
	mat DQ = Q // save total requirement matrix for depr scenario
	mat Df = f // save final use vector for depr scenario
	
	mat NPDE = NPCost*DQ*Df // no-profit capital cost shares with depr cost Leontief
	mat DNPE = DCost*NPQ*NPf // depr capital cost shares with no-profit Leontief
		
	mat year = [`y']
	
	mat ReturnNP = year,NPDE'
	mat ReturnD = year,DNPE'
	
	mat ResultsNP = ResultsNP \ ReturnNP
	mat ResultsD = ResultsD \ ReturnD

}
di _newline // for spacing

// Name columns in Results matrix based on Return vector
mat colnames ResultsNP = year elas_comp elas_st elas_eq elas_ip // apply those names to full Results vector
mat colnames ResultsD = year elas_comp elas_st elas_eq elas_ip // apply those names to full Results vector

// Save off annual results for scenario
mat ResultsNP = ResultsNP[2...,1...] // remove 0 row from Results from initializing
qui keep scenario ctrl_* // keep only the identifier information
qui replace scenario=991 // placeholder
qui replace ctrl_capital="NPwithDmat"
qui keep if _n <= rowsof(ResultsNP) // keep enough rows to match Results matrix
qui svmat ResultsNP, names(col) // loads results into memory
qui save "./Work/USA_scenario_NPwithDmat_bound_results.dta", replace // save individual results file

// Save off annual results for scenario
mat ResultsD = ResultsD[2...,1...] // remove 0 row from Results from initializing
qui keep scenario ctrl_* // keep only the identifier information
qui replace scenario=992 // placeholder
qui replace ctrl_capital="DwithNPmat"
qui keep if _n <= rowsof(ResultsD) // keep enough rows to match Results matrix
qui svmat ResultsD, names(col) // loads results into memory
qui save "./Work/USA_scenario_DwithNPmat_bound_results.dta", replace // save individual results file


// Combine results for decomp figure
clear
qui capture rm "./Work/USA_scenario_bound_results_all.dta"
qui save "./Work/USA_scenario_bound_results_all.dta", emptyok replace
	
qui append using "./Work/USA_scenario_1_annual_results.dta"	
qui append using "./Work/USA_scenario_2_annual_results.dta"	
qui append using "./Work/USA_scenario_NPwithDmat_bound_results.dta"
qui append using "./Work/USA_scenario_DwithNPmat_bound_results.dta"	
	

qui save "./Work/USA_scenario_bound_results_all.dta", replace		

// Use last entries, 2018, to do specific look at relationships		
// These vectors are by industry, not year
// This is all purely for investigation and background, not published results
mat NPcapcost = NPCost[2...,1...]	
mat NPcapcost = NPcapcost'*J(3,1,1)
mat Dcapcost = DCost[2...,1...]	
mat Dcapcost = Dcapcost'*J(3,1,1)

mat NPLeon = NPQ*NPf
mat DLeon = DQ*Df

mat All = NPcapcost,Dcapcost,NPLeon,DLeon
mat colnames All = NPcapcost Dcapcost NPLeon DLeon
clear
svmat All, names(col)

gen diffShare = NPcapcost - Dcapcost
gen diffLeon = NPLeon - DLeon

gen order = _n

egen meanNPcapcost = mean(NPcapcost)
egen meanDcapcost = mean(Dcapcost)
egen meanNPLeon = mean(NPLeon)
egen meanDLeon = mean(DLeon)
gen covNP = (NPcapcost - meanNPcapcost)*(NPLeon - meanNPLeon)
gen covD = (Dcapcost - meanDcapcost)*(DLeon - meanDLeon)
egen sumcovNP = sum(covNP)
egen sumcovD = sum(covD)
