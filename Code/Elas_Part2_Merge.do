/*
Merge naics/year rows of comp/va and K/va data
Creates file of va, comp/va, K/va ratios for use in scenarios
*/

// create empty version of merged file to append to
capture rm "./Work/USA_naics4718_merged.dta"
clear
save "./Work/USA_naics4718_merged.dta", replace emptyok

foreach series in "4762" "6386" "8796" "9718" { // four distinct series based on matching
//local series "6386"
	use "./Work/USA_naics`series'_comp_ratios.dta", clear // use the compensation ratios
	foreach v of varlist naics*code { // kludge to get the naics code used to match
		local match = substr("`v'",6,4) // pull the year series from this
	}
	
	// pull in map for naics code matching
	insheet using "./CSV/USA_naics`match'_va.csv", clear names comma
	save "./Work/USA_naics`match'_va.dta", replace
	
	merge 1:1 year naics`match'code using "./Work/USA_naics`series'_comp_ratios.dta" // merge labor cost ratios
	keep if _merge==3
	drop _merge
	
	merge 1:1 year naics`match'code using "./Work/USA_naics`match'_K_ratios.dta" // merge capital ratios
	keep if _merge==3
	drop _merge
	
	gen series = "`series'" // store which data series produced the observation
	label variable series "SIC-NAICS matching used"
	rename naics`match'code code // rename for merge with I/O table
	move series code // clean-up

	label variable iova "Industry value-added"
	label variable iogo "Industry gross output"

	keep year series code codeorder iova iogo bearate ratio* deprate* pchange* // just what is necessary for scenarios
	append using "./Work/USA_naics4718_merged.dta"
	save "./Work/USA_naics4718_merged.dta", replace
	
} // end foreach

save "./Work/USA_naics4718_merged.dta", replace // complete file of all naics/year information

// pull in prod fct estimated coefficients from DLEU at 2-digit level
insheet using "./CSV/USA_DLEU_theta.csv", clear names comma // create working file of DLEU coefficient estimates
save "./Work/USA_DLEU_theta.dta", replace

use "./Work/USA_naics4718_merged.dta", clear // use existing naics/year file
gen ind2d = substr(code,1,2) // get first two chars of NAICS code
destring ind2d, replace force // destring and set any alphabetic NAICS chars to missing (housing, gov, etc.)

merge m:1 year ind2d using "./Work/USA_DLEU_theta.dta" // match many-to-one
	// using 2 digits, many naics/year observations will have same 2-digit code, that's okay
	// implicitly assuming that the industry elasticities are the same in all sub-industries of the 2-digit industry
	// lots of non-matches: naics/year observations without a DLEU estimate available (no firms or no data from that year)
	// several non-matches: DLEU has observation for industries 45 and 99, which don't have matching BEA industries in my data
drop _merge

save "./Work/USA_naics4718_merged.dta", replace // complete file of all naics/year information
