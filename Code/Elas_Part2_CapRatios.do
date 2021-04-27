/*
Match naics industries to capital stock data
Calculate RK/VA, and RK/GOS for each industry
*/

// get working copy of bea-naics map
insheet using "./CSV/USA_bea_naics_map.csv", clear names
save "./Work/USA_bea_naics_map.dta", replace

foreach series in "4762" "6396" "9718" { // for three separate naics I/O sources

	// get naics data on va
	insheet using "./CSV/USA_naics`series'_va.csv", clear names
	save "./Work/USA_naics`series'_va.dta", replace

	// join with bea-naics map data
	joinby naics`series' using "./Work/USA_bea_naics_map.dta"

	// join with bea capital K data
	merge m:1 year beacode using "./Work/USA_bea4718_Kstock.dta" // same beacode/year rows for some naics
	keep if _merge==3 // these are years with bea K data, but no VA data - okay
		
	// sum up the RK data for naics codes with multiple beacode/year rows
	collapse (sum) stock* dep* inv* (mean) pchange* (first) io* naics`series'text beacode bearate, by(year naics`series'code)

	bysort year beacode: egen beava = sum(iova) // sum of VA for a given bea code
	gen naics_K_share = iova/beava // naics industry share of VA for a bea code

	foreach v in st eq ip { // for each different possible K 
		gen ratio_stock`v'00_va = naics_K_share*stock`v'00/iova // K/VA ratio
		label variable ratio_stock`v'00_va "Ratio of K`v' to VA"
		gen ratio_inv`v'_va = naics_K_share*inv`v'/iova // I/VA ratio
		label variable ratio_inv`v'_va "Ratio of I`v' to VA"
		gen deprate`v'00 = dep`v'00/stock`v'00 // depreciation rate
		label variable deprate`v'00 "Depreciation rate of `v'"
		label variable pchange`v'00 "Inflation of `v' historical"
		label variable pchange`v'00curr "Inflation of `v' current"
	}

	label variable bearate "Type of rate to apply"
	
	keep year naics`series'code naics`series'text bearate deprate* pchange* ratio*
	
	save "./Work/USA_naics`series'_K_ratios.dta", replace
}
