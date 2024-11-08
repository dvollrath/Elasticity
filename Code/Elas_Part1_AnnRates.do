/*
Import FRED data on return to various financial instruments
This data is not specific to industries
Prepare file with year rows, columns of return on instruments
*/

freduse MPRIME GS10 AAA BAA CP A053RC1Q027SBEA WCP3M DCPN3M FEDFUNDS M13043USM156NNBR MORTGAGE30US, clear
rename MPRIME ratePrime // H.15
rename GS10 rateTbond10year // H.15
rename AAA rateCorpAAA 
rename BAA rateCorpBaa
rename WCP3M ratePaper3month
rename DCPN3M ratePaper3monthAAnon
rename FEDFUNDS rateFedFunds
rename CP profitsAfterTax
rename A053RC1Q027SBEA profitsBeforeTax
rename M13043USM156NNBR rateMuni
rename MORTGAGE30US rateMortgage

gen agg_corp_tax_rate = 1-profitsAfterTax/profitsBeforeTax // calculate aggregate effective corporate tax rate

// all rates are taken as first observable rate from a given year
gen year = year(daten)
collapse (firstnm) rate* (mean) agg_corp_tax_rate, by(year)

save "./Work/USA_FRED1920_rates.dta", replace

// pull in S&P 500 dividend yield for equity premium
insheet using "./Data/USA/MULTPL-SP500_DIV_YIELD_MONTH.csv", names clear
// this file is a mess with dates
keep if _n<1000 // only use the first 1000 observations, which corresponds to about 1935-2020
gen year = substr(date,-2,2) // grab the 2-digit year
destring year, replace // destring this
replace year = 2000 + year if year<30 // kludge the century
replace year = 1900 + year if year>30 & year<100 // kludge the century
rename value rateSPyield 
replace rateSPyield = rateSPyield/100
collapse (firstnm) rateSPyield, by(year) // get to first value from year

save "./Work/USA_SP_yield.dta", replace

// pull in NBER historical mortgage series
import delimited using "./Data/USA/m13045.txt", delimiter(" ", collapse) clear
rename v1 year
rename v2 month
rename v3 nberMortgage
keep if month==12 // arbitrarily use the end of year rate
drop v4 month // spaces
save "./Work/USA_nbermort_rates.dta", replace

// pull in NBER historical mortgage series
import delimited using "./Data/USA/m13058.txt", delimiter(" ", collapse) clear
rename v1 year
rename v2 month
rename v3 nberFederal
keep if month==1 // arbitrarily use the beginning of year rate
drop v4 month // spaces
save "./Work/USA_nberfederal_rates.dta", replace

use "./Work/USA_FRED1920_rates.dta", clear 
merge 1:1 year using "./Work/USA_SP_yield.dta" // merge with existing rate data
drop _merge
merge 1:1 year using "./Work/USA_nbermort_rates.dta"
drop _merge
merge 1:1 year using "./Work/USA_nberfederal_rates.dta"

replace rateMortgage = nberMortgage if missing(rateMortgage)
replace rateTbond10year = nberFederal if missing(rateTbond10year)

drop nber*

save "./Work/USA_ann1920_rates.dta", replace
