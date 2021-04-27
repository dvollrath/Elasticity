/*
Merge naics/year rows of comp/va and K/va data
Creates file of va, comp/va, K/va ratios for use in scenarios
*/

// create empty version of merged file to append to
capture rm "./Work/USA_naics4718_merged.dta"
clear
save "./Work/USA_naics4718_merged.dta", replace emptyok

foreach series in "4762" "6386" "8796" "9718" { // four distinct series based on matching
	use "./Work/USA_naics`series'_comp_ratios.dta", clear // use the compensation ratios
	foreach v of varlist naics*code { // kludge to get the naics code used to match
		local match = substr("`v'",6,4) // pull the year series from this
	}
	
	// pull in map for naics code matching
	insheet using "./CSV/USA_naics`match'_va.csv", clear names comma
	save "./Work/USA_naics`match'_va.dta", replace
	
	merge 1:1 year naics`match'code using "./Work/USA_naics`series'_comp_ratios.dta"
	keep if _merge==3
	drop _merge
	
	merge 1:1 year naics`match'code using "./Work/USA_naics`match'_K_ratios.dta"
	keep if _merge==3
	drop _merge

	gen series = "`series'" // store which data series produced the observation
	label variable series "SIC-NAICS matching used"
	rename naics`match'code code // rename for merge with I/O table
	move series code // clean-up

	label variable iova "Industry value-added"
	label variable iogo "Industry gross output"

	keep year series code iova iogo bearate ratio* deprate* pchange* // just what is necessary for scenarios
	append using "./Work/USA_naics4718_merged.dta"
	save "./Work/USA_naics4718_merged.dta", replace
	
} // end foreach

save "./Work/USA_naics4718_merged.dta", replace
