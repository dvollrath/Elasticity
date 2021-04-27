/*
Calculate ratios of Comp/VA for NAICS industries 63-86 to match I/O tables
*/

// create working copy of sic72-naics mapping for matching
insheet using "./CSV/USA_sic72_naics_map.csv", clear names comma
save "./Work/USA_sic72_naics_map.dta", replace

// pull in sic72/year observations on VA, compensation, etc..
insheet using "./CSV/USA_sic4787_va.csv", clear names comma
save "./Work/USA_sic4787_va.dta", replace

joinby sic72text using "./Work/USA_sic72_naics_map.dta" // merge sic-to-naics matches
	// this matches on the *text* of the sics, because unreliable to use created sic codes
	// note that the sictext and naics text won't necessarily be the same (but should make sense)
	// there will be some non-matches for sic categories (e.g. gross domestic product) not in map
	// there will be matched rows without naics info (e.g. Housing) b/c they do not map to naics
drop if naics6396code=="" // drop if matched, but no mapping to naics

// only keep years matching the I/O table
keep if inrange(year,1963,1986)

// this leaves sic-year rows with naics mappings
// naics mappings are not unique, two sic's may map to a single naics (collapse the data)
// two naics may map to a single sic (matching took care of that)

collapse (sum) indcomp indgo indgos indproinc indtxpi indva indftpt indfte ///
	(first) naics6396text, by(naics6396code year) 
move naics6396text naics6396code  // clean-up

// create the ratios
gen ratio_comp_va = indcomp/indva // compensation share of VA
gen ratio_proinc_va = indproinc/indva // proprietor income share of VA
gen ratio_gos_va = indgos/indva // gross oper surplus to VA, for checking
gen ratio_fte_va = indfte/indva
gen ratio_ftpt_va = indftpt/indva
gen ratio_txpi_va = indtxpi/indva // taxes on production

label variable ratio_comp_va "Ratio compensation to VA"
label variable ratio_proinc_va "Ratio proprietors income to VA"
label variable ratio_gos_va "Ratio gross oper surplus to VA"
label variable ratio_fte_va "Ratio FTE workers to VA"
label variable ratio_ftpt_va "Ratio FTPT workers to VA"
label variable ratio_txpi_va "Ratio production taxes to VA"

drop ind* // remove the totals, keep only the ratios

save "./Work/USA_naics6386_comp_ratios.dta", replace 
