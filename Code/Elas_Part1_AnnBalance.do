/*
Import Flow of Funds data on value of equities, bonds, paper, 
This data is not specific to industries
Prepare file with year rows, columns of value of balance sheet item, 
*/

// import raw flow of funds data
import excel using "./Data/USA/Section1All_xls.xlsx", ///
	clear sheet("IMAtS5.a-A") cellrange(A8:BJ170)

rename A line
rename B text
rename C code
	
foreach v of varlist D-BJ { // rename all variables from letters to yYYYY
	local year = `v'[1] // get year from first row of data
	rename `v' val`year' // rename variable to yYYYY
}
keep if inlist(code,"FL103169100","FL103162000","FL103163003","FL104123005","FL103181005")

//keep if inlist(code,"136","137","138","139","144") // keep only paper, munis, bonds, loans, equity

drop line text // drop line numbers and descriptive text
gen fund = ""
replace fund = "Paper" if code=="FL103169100" // commercial paper
replace fund = "Munis" if code=="FL103162000" // munis
replace fund = "Bonds" if code=="FL103163003" // corporate bonds
replace fund = "Loans" if code=="FL104123005" // loans
replace fund = "Equity" if code=="FL103181005" // equity
drop code

reshape long val, i(fund) j(year) // reshape to year-Line rows

destring val, replace // convert to numeric values

reshape wide val, i(year) j(fund) string // reshape to year rows with fund columns

// create share variables for funding sources
gen valTotal = valPaper+valMunis+valBonds+valLoans+valEquity
foreach fund in Paper Munis Bonds Loans Equity {
	gen share`fund' = val`fund'/valTotal
}

save "./Work/USA_IMA_balances.dta", replace

// create share information back to 1945 by extrapolating from the 1960s backwards
use "./Work/USA_IMA_balances.dta", clear
drop if !missing(year) // eliminate existing obs, keep variable names
set obs 15 // create 15 empty observations
replace year = _n + 1944 // fill in years 1945 to 1959
save "./Work/USA_IMA_balances_empty.dta", replace
append using "./Work/USA_IMA_balances.dta" // append the actual data 

gen bal_extrapolated = (inrange(year,1945,1959)) // mark these years as being extrapolated

foreach fund in Paper Munis Bonds Loans Equity { // for each of the fund types
	summ share`fund' if inrange(year,1960,1969) // average the share value for the 1960s
	replace share`fund' = r(mean) if bal_extrapolated==1 // extrapolate that mean to missing years
}

keep year share* bal_extrapolated

save "./Work/USA_ann4518_balances.dta", replace
