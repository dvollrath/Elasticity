/*
Import BEA labor data for 1997-2018
Import BEA proprietors income and overall compensation data for 1997-2018
Prepare BEA code/year rows with columns for labor used
*/

// Proprietors income
import excel using "./Data/USA/Section6All_xls.xlsx", ///
	clear sheet("T61200D-A") cellrange(A8:X36)

replace B = "text" if _n==1 // prime this for renaming all columns
replace C = "code" if _n==1 // prime this for renaming
foreach v of varlist _all { // rename all year columns from letters to dataYYYY
	local year = `v'[1]
	rename `v' pro`year' // rename variable to dataYYYY
}
drop if proLine=="Line" // drops first row with header information

reshape long pro, i(procode) j(year) // put in naics/year rows
destring pro, replace force //

save "./Work/USA_BEA_labor_propinc.dta", replace
export delimited "./CSV/USA_BEA_propinc9818.csv", replace

// Compensation data
import excel using "./Data/USA/Section6All_xls.xlsx", ///
	clear sheet("T60200D-A") cellrange(A8:X107)

replace B = "text" if _n==1 // prime this for renaming all columns
replace C = "code" if _n==1 // prime this for renaming
foreach v of varlist _all { // rename all year columns from letters to dataYYYY
	local year = `v'[1]
	rename `v' comp`year' // rename variable to dataYYYY
}
drop if compLine=="Line" // drops first row with header information
rename compLine laborLine // for matching

reshape long comp, i(compcode) j(year) // put in naics/year rows
destring comp, replace force //

save "./Work/USA_BEA_labor_comp.dta", replace

// FTE
import excel using "./Data/USA/Section6All_xls.xlsx", ///
	clear sheet("T60500D-A") cellrange(A8:X105)

replace B = "text" if _n==1 // prime this for renaming all columns
replace C = "code" if _n==1 // prime this for renaming
foreach v of varlist _all { // rename all year columns from letters to dataYYYY
	local year = `v'[1]
	rename `v' labor`year' // rename variable to dataYYYY
}
drop if laborLine=="Line" // drops first row with header information

reshape long labor, i(laborcode) j(year) // put in naics/year rows
destring labor, replace force //
rename labor fte

save "./Work/USA_BEA_labor_fte.dta", replace


// Full and part-time employees
import excel using "./Data/USA/Section6All_xls.xlsx", ///
	clear sheet("T60400D-A") cellrange(A8:X105)

replace B = "text" if _n==1 // prime this for renaming all columns
replace C = "code" if _n==1 // prime this for renaming
foreach v of varlist _all { // rename all year columns from letters to dataYYYY
	local year = `v'[1]
	rename `v' labor`year' // rename variable to dataYYYY
}
drop if laborLine=="Line" // drops first row with header information

reshape long labor, i(laborcode) j(year) // put in naics/year rows
destring labor, replace force //
rename labor ftpt

save "./Work/USA_BEA_labor_ftpt.dta", replace

// merge FTE and FTPT together
merge 1:1 year laborLine using "./Work/USA_BEA_labor_fte.dta"
drop _merge
merge 1:1 year laborLine using "./Work/USA_BEA_labor_comp.dta"
drop _merge // some failures on rest of world



export delimited "./CSV/USA_BEA_labor9818.csv", replace

