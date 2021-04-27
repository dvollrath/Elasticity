/*
Pull in STAN CSV file
Calculate ratios for use in cost shares
- output is an cou/industry/year file with cost shares
*/

insheet using "./CSV/OECD_STAN4_7018_all.csv", clear

keep if inrange(year,2005,2015) // only the years matching the IO database

gen dcode = substr(ind,2,.) // drop the "D" from the industry code to match I/O dcode entries
drop flag // not used

destring value, replace force // data values come in as strings - force non-numerics to missing
rename value v // shorten for reshaping

reshape wide v, i(cou ind year) j(var) string // reshape to country/industry/year

gen va = vVAFC //vVALU // at basic prices, meaning after taxes and subsidies to *production*

gen RK_noprofit = vGOPS // (alt vVALU-vLABR), but includes mixed income in GOPS
gen comp_noprofit = vLABR
gen RK_depr = vCFCC
gen comp_depr = vLABR
gen RK_invest = vGFCF
gen comp_invest = vLABR

gen RK_noprofit_self = vGOPS - vLABR*vSELF/vEMPE
gen comp_noprofit_self = vLABR + vLABR*vSELF/vEMPE // actual labor costs plus imputed value for self-employed
gen RK_depr_self = vCFCC
gen comp_depr_self = vLABR + vLABR*vSELF/vEMPE
gen RK_invest_self = vGFCF
gen comp_invest_self = vLABR + vLABR*vSELF/vEMPE

gen emp = vEMPE

keep cou year dcode va emp comp* RK* // just the cost variables necessary


// collapse several separate STAN codes to match aggregation in IO tables
replace dcode = "17T18" if inlist(dcode,"17","18")
replace dcode = "90T96" if inlist(dcode,"90T93","94T96")
collapse (sum) va emp comp* RK*, by(cou year dcode)

gen mergecode=dcode // generate a new mergecode to use in matching to wider industries
replace mergecode="05T09" if inlist(mergecode,"05T06","07T08","09")
replace mergecode="16T18" if inlist(mergecode,"16","17T18")
replace mergecode="22T23" if inlist(mergecode,"22","23")
replace mergecode="24T25" if inlist(mergecode,"24","25")
replace mergecode="29T30" if inlist(mergecode,"29","30")
replace mergecode="90T99" if inlist(mergecode,"97T98")

save "./Work/OECD_STAN4_0515_premerge.dta", replace // save basic data with new mergecode

// create merging dataset
gen RK_depr_va = RK_depr/va
gen RK_invest_va = RK_invest/va

drop mergecode // drop the mergecode from above
rename dcode mergecode // rename the original dcode to the mergecode
// this will ensure that we match the original data on the RK ratios to the industries identified by the mergecode

keep cou year mergecode RK_depr_va RK_invest_va
save "./Work/OECD_STAN4_0515_ratiomerge.dta", replace

use "./Work/OECD_STAN4_0515_premerge.dta", clear
merge m:1 cou year mergecode using "./Work/OECD_STAN4_0515_ratiomerge.dta"
keep if _merge==3 // non-matches are unnecessary to keep - premerge is master dataset
drop _merge

replace RK_depr = RK_depr_va*va if RK_depr==0 // replace a zero entry for RK_depr with ratioxVA using ratio from larger industry
replace RK_invest = RK_invest_va*va if RK_invest==0 // replace a zero entry for RK_depr with ratioxVA using ratio from larger industry
replace RK_depr_self = RK_depr_va*va if RK_depr_self==0 // replace a zero entry for RK_depr with ratioxVA using ratio from larger industry
replace RK_invest_self = RK_invest_va*va if RK_invest_self==0 // replace a zero entry for RK_depr with ratioxVA using ratio from larger industry

// merge with IO map to shrink this down to just industries that are part of IO table
merge m:1 dcode using "./Data/OECD/IO_2018Ed_ISIC4_Map.dta"
keep if _merge==3 // these are industries from STAN that match to IO industries
keep cou year dcode va emp comp* RK* // just the necessary fields

bysort cou year: egen dcodecount = count(dcode)
keep if dcodecount==36 // there should be exactly 36 industry rows for each country/year

save "./Work/OECD_STAN4_0515_all.dta", replace

////////////////////////////////////////////////////////////////
// For STAN3 and IO ISIC 3 information from 1995-2009
////////////////////////////////////////////////////////////////

insheet using "./CSV/OECD_STAN3_7005_all.csv", clear

keep if inrange(year,1995,2009) // only the years matching the IO database
drop datanote // not used

rename value v // for reshaping

gen first = substr(ind,1,2) // first two digits of industry code
gen last = substr(ind,3,4) // last two digits of industry code

drop if inlist(first,"aa","zz") // aggregate groups we don't care about

gen dcode = first + "T" + last if last~="00" 
replace dcode = first if last=="00"
drop first last

reshape wide v, i(cou ind year) j(var) string // reshape to country/industry/year

gen va = vVAFC //vVALU // at basic prices, meaning after taxes and subsidies to *production*

gen RK_noprofit = vGOPS // (alt vVALU-vLABR), but includes mixed income in GOPS
gen comp_noprofit = vLABR
gen RK_depr = vCFCC
gen comp_depr = vLABR
gen RK_invest = vGFCF
gen comp_invest = vLABR

gen RK_noprofit_self = vGOPS - vLABR*vSELF/vEMPE
gen comp_noprofit_self = vLABR + vLABR*vSELF/vEMPE // actual labor costs plus imputed value for self-employed
gen RK_depr_self = vCFCC
gen comp_depr_self = vLABR + vLABR*vSELF/vEMPE
gen RK_invest_self = vGFCF
gen comp_invest_self = vLABR + vLABR*vSELF/vEMPE

gen emp = vEMPE

keep cou year dcode va emp comp* RK* // just the cost variables necessary

replace dcode = "73T74" if inlist(dcode,"73","74")
collapse (sum) va emp comp* RK*, by(cou year dcode)

gen mergecode=dcode // generate a new mergecode to use in matching to wider industries
replace mergecode="10T41" if inlist(mergecode,"10T14","20","27","28","29","30T33X")
replace mergecode="10T41" if inlist(mergecode,"31","36T37")
replace mergecode="22" if inlist(mergecode,"21T22")
replace mergecode="23T25" if inlist(mergecode,"24","25")

save "./Work/OECD_STAN4_9509_premerge.dta", replace // save basic data with new mergecode

// create merging dataset
gen RK_depr_va = RK_depr/va
gen RK_invest_va = RK_invest/va

drop mergecode // drop the mergecode from above
rename dcode mergecode // rename the original dcode to the mergecode
// this will ensure that we match the original data on the RK ratios to the industries identified by the mergecode

keep cou year mergecode RK_depr_va RK_invest_va
save "./Work/OECD_STAN4_9509_ratiomerge.dta", replace

use "./Work/OECD_STAN4_9509_premerge.dta", clear
merge m:1 cou year mergecode using "./Work/OECD_STAN4_9509_ratiomerge.dta"
keep if _merge==3 // non-matches are unnecessary to keep - premerge is master dataset
drop _merge

replace dcode = "30T33X" if dcode=="30T33" // inconsistency between STAN and IO files

replace RK_depr = RK_depr_va*va if RK_depr==0 // replace a zero entry for RK_depr with ratioxVA using ratio from larger industry
replace RK_invest = RK_invest_va*va if RK_invest==0 // replace a zero entry for RK_depr with ratioxVA using ratio from larger industry
replace RK_depr_self = RK_depr_va*va if RK_depr_self==0 // replace a zero entry for RK_depr with ratioxVA using ratio from larger industry
replace RK_invest_self = RK_invest_va*va if RK_invest_self==0 // replace a zero entry for RK_depr with ratioxVA using ratio from larger industry

// merge with IO map to shrink this down to just industries that are part of IO table
merge m:1 dcode using "./Data/OECD/IO_2015Ed_ISIC3_Map.dta"
keep if _merge==3 // these are industries from STAN that match to IO industries
keep cou year dcode va emp comp* RK* // just the necessary fields

drop if dcode=="95" // drop household worker industry - no IO information

bysort cou year: egen dcodecount = count(dcode)
keep if inrange(dcodecount,33,34) // there should be exactly 33 or 34 industry rows for each country/year

save "./Work/OECD_STAN4_9509_all.dta", replace
