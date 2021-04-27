/*
Calculate proprietor income/compensation ratio for naics industries 98-18
*/

// create working copy of labor data to naics mapping
insheet using "./CSV/USA_bea_labor_map.csv", clear names comma
save "./Work/USA_bea_labor_map.dta", replace

// create working copy of 98-18 employment data
insheet using "./CSV/USA_BEA_propinc9818.csv", clear names comma
save "./Work/USA_BEA_propinc9818.dta", replace

// create working copy of compensation data 98-18
insheet using "./CSV/USA_BEA_labor9818.csv", clear names comma
save "./Work/USA_BEA_labor9818.dta", replace

merge m:1 laborline using "./Work/USA_bea_labor_map.dta"
// merge fails on HS, and on high-level aggregates from master with no mapping
drop if missing(naics9718code)
drop if naics9718code=="HS" // no prop inc data for housing
drop _merge

// merge the proprietors income data to the compensation data
merge m:1 year proline using "./Work/USA_BEA_propinc9818.dta"
drop if _merge==2 // prop income aggregates we don't care about
replace pro=0 if _merge==1 // no prop income information for govt, farms

bysort year proline: egen comp_sum = sum(comp) // get total comp for a given proline/year
gen ratio_proinc_comp = pro/comp_sum // get ratio of prop inc to comp for each industry

rename comp comp_check // this will be used to validate merge with other comp data

gen copies = 1 // variable to drive replication for 1997 data
replace copies = 2 if year==1998 // going to duplicate 1998 and use for 1997
expand copies, generate(newcopy)
replace year = 1997 if newcopy==1 // change year, keep other info the same

keep year laborline comptext comp_check ratio_proinc_comp fte ftpt // 
sort year laborline
save "./Work/USA_BEA_comp9718.dta", replace // save for merging with other comp data

