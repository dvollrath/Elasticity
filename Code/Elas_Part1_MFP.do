/*
Import BLS and Fernald MFP series for comparison
*/

// BLS
insheet using "./Data/USA/BLS_mfp_historical.csv", clear
save "./Work/BLS_mfp_historical.dta", replace

// Fernald
import excel using "./Data/USA/quarterly_tfp.xlsx", ///
		clear sheet("annual") cellrange(A1:V74) firstrow
		
rename date year // to make consistent
drop if year==1947 // no data

save "./Work/Fernald_mfp_historical.dta", replace

// Merge to final dataset
merge 1:1 year using "./Work/BLS_mfp_historical.dta"
capture drop _merge
save "./Work/mfp_historical.dta", replace // to be used in sensitivity analysis

