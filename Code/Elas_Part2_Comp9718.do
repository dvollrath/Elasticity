/*
Calculate ratios of Comp/VA for NAICS industries 97-18 to match I/O tables
*/

// create working copy of labor data to naics mapping
insheet using "./CSV/USA_bea_labor_map.csv", clear names comma
save "./Work/USA_bea_labor_map.dta", replace

// create working copy of naics 97-18 value-added and comp data
insheet using "./CSV/USA_naics9718_va.csv", clear names comma
save "./Work/USA_naics9718_va.dta", replace

merge m:1 naics9718code using "./Work/USA_bea_labor_map.dta"
drop _merge // will be perfect
merge 1:1 year laborline using "./Work/USA_BEA_comp9718.dta" // will have no matches for Used or Other
drop if naics9718code=="" 

// Fill in for housing industry
replace fte = 0 if naics9718code=="HS"
replace ftpt = 0 if naics9718code=="HS"
replace ratio_proinc_comp = 0 if naics9718code=="HS"

// create the ratios
gen ratio_comp_va = iocomp/iova // compensation share of VA
gen ratio_proinc_va = ratio_proinc_comp*ratio_comp_va // prop inc as share of VA
gen ratio_fte_va = fte/iova
gen ratio_ftpt_va = ftpt/iova
gen ratio_txpi_va = iotxpi/iova // taxes on production

label variable ratio_comp_va "Ratio compensation to VA"
label variable ratio_proinc_va "Ratio proprietors income to VA"
label variable ratio_fte_va "Ratio FTE workers to VA"
label variable ratio_ftpt_va "Ratio FTPT workers to VA"
label variable ratio_txpi_va "Ratio production taxes to VA"

drop ratio_proinc_comp

keep naics9718code year naics9718text ratio*

save "./Work/USA_naics9718_comp_ratios.dta", replace 
