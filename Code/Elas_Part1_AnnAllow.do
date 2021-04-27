/*
Import BEA depreciation allowance data
This data is not specific to industries
Prepare file with year rows, columns of inflation in diff capital types
*/

// import just raw data - will apply labels in this code
import excel using "./Data/USA/capital_allowances.xlsx", ///
	clear sheet("Sheet2") cellrange(B2:AP4)
	
xpose, clear // transpose to be year by capital type

rename v1 allowST00 // to match codes from depreciation - structures
rename v2 allowEQ00 // equipment
rename v3 allowIP00 // intellectual property

gen year = _n+1978 // data runs from 1979 forward

// extrapolate to missing years from existing data
gen allow_extrapolated = 0
replace allow_extrapolated = 1 if inrange(year,2013,2017)
replace allowST00 = 0.35 if inrange(year,2013,2017)
replace allowIP00 = 0.63 if inrange(year,2013,2017)
replace allowEQ00 = 0.877 if inrange(year,2013,2017)  

save "./Work/USA_cap_allowance.dta", replace

// extrapolate to prior years from existing data
use "./Work/USA_cap_allowance.dta", clear
drop if !missing(year) // eliminate existing obs, keep variable names
set obs 34 // add 33 rows for missing data

replace year = _n + 1944 // set year
replace allow_extrapolated = 1 // set to extrapolated

save "./Work/USA_cap_allowance_empty.dta", replace
append using "./Work/USA_cap_allowance.dta"

replace allowST00 = .561 if inrange(year,1945,1978) // take 1979 value backwards
replace allowEQ00 = .98 if inrange(year,1945,1978) // take 1979 value backwards
replace allowIP00 = 0 if inrange(year,1945,1978) // set to zero given lack of information
replace allowIP00 = 0 if inrange(year,1979,1998) // set to zero given lack of information

save "./Work/USA_ann4519_kallowance.dta", replace
