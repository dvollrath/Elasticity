/*
Calculate components of TFP decomposition
*/

/*
Create counter-factual series of elasticities for comparison
*/
use "./Work/USA_scenario_annual_results_all.dta", clear

/*
Create TFP series for selected scenarios
*/

clear
save "./Work/USA_tfp_scenario.dta", emptyok replace // create dataset to hold results

foreach s in 5 6 7 8 37 38 39 40 { // for each baseline scenario
	use "./Work/USA_scenario_annual_results_all.dta", clear
	gen elas_cap = 1 - elas_comp // generate single elasticity for capital
	//keep if inrange(year,1955,2018) // clean-up
	keep if scenario==`s' // keep only estimates for 
		// that scenario, with no gov/housing (priv biz sector), and using split prop income
	
	capture drop _merge
	merge 1:1 year using "./Work/mfp_historical.dta" // merge with BLS MFP data
	drop if _merge==2 // years with BLS MFP data, but no elasticity estimates
	
	// generate dtfp estimates using my elasticities, util and not-util adjusted
	gen dtfp_util_elas =  dY - dutil - elas_cap*dk - elas_comp*dhours - elas_comp*dLQ
	gen dtfp_elas =  dY - elas_cap*dk - elas_comp*dhours - elas_comp*dLQ
	
	// for each of the four different tfp growth rate series, calculate a level
	// level has 1948==100
	gen ln_dtfp = ln(1 + dtfp/100) // log of 1 plus growth rate
	gen ln_dtfp_util = ln(1 + dtfp_util/100) // log of 1 plus growth rate
	gen ln_dtfp_elas = ln(1 + dtfp_elas/100) // log of 1 plus growth rate
	gen ln_dtfp_util_elas = ln(1 + dtfp_util_elas/100) // log of 1 plus growth rate
	
	gen cum_dtfp_util_elas = sum(ln_dtfp_util_elas)
	gen cum_dtfp_elas = sum(ln_dtfp_elas)
	gen cum_dtfp = sum(ln_dtfp)
	gen cum_dtfp_util = sum(ln_dtfp_util)
	
	gen level_util_elas = exp(ln(100) + cum_dtfp_util_elas)
	gen level_util = exp(ln(100) + cum_dtfp_util)
	gen level = exp(ln(100) + cum_dtfp)
	gen level_elas = exp(ln(100) + cum_dtfp_elas)
	
	keep year scenario ctrl_* dtfp* level*
	
	append using "./Work/USA_tfp_scenario.dta"
	save "./Work/USA_tfp_scenario.dta", replace
}
