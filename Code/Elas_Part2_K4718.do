/*
Bring together government and private capital series
Produce file of beacode/year rows, with K by capital series as columns
*/

// get working copy of bea/naics map to get information on which rates to apply
insheet using "./CSV/USA_bea_return_map.csv", clear names
save "./Work/USA_bea_return_map.dta", replace

// get working copy of government capital data
insheet using "./CSV/USA_bea4718_gov.csv", clear names
save "./Work/USA_bea4718_gov.dta", replace

// get working copy of capital data
insheet using "./CSV/USA_bea4718_capital.csv", clear names
save "./Work/USA_bea4718_capital.dta", replace

append using "./Work/USA_bea4718_gov.dta"

merge m:1 beacode using "./Work/USA_bea_return_map.dta" // map
keep if _merge==3

keep year beacode bearate stock* dep* inv* pchange*
save "./Work/USA_bea4718_Kstock.dta", replace

