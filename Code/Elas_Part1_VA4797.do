/*
Import BEA compensation data
Prepare BEA code/year rows with columns for compensation and value added
*/

/////////////////////////////////////////////////////////////////
// data for 1947-1987 ("72") data and 1987-1997 data ("87") 
/////////////////////////////////////////////////////////////////

// Code is identical in structure for the two sets of data, so loop
foreach input in "72" "87" { // these codes are used in BEA spreadsheet
	// value added by industry
	import excel using "./Data/USA/GDPbyInd_VA_SIC.xls", ///
		clear sheet("`input'SIC_VA, GO, II")

	replace A = "series" if _n==1 // prime this for renaming all columns
	replace B = "text" if _n==1 // prime this for renaming all columns
	foreach v of varlist _all { // rename all year columns from letters to dataYYYY
		local year = `v'[1]
		rename `v' ind`year' // rename variable to dataYYYY
	}
	rename indseries series // rename to more legible name
	rename indtext sic`input'text // rename to more legible name
	
	keep if inlist(series,"VA","GO") // keep only value-added, gross output, and int inputs
	save "./Work/USA_BEA_va_raw`input'.dta", replace
	
	// Components of value-added by industry
	import excel using "./Data/USA/GDPbyInd_VA_SIC.xls", ///
		clear sheet("`input'SIC_Components of VA")

	replace A = "series" if _n==1 // prime this for renaming all columns
	replace B = "text" if _n==1 // prime this for renaming all columns
	foreach v of varlist _all { // rename all year columns from letters to dataYYYY
		local year = `v'[1]
		rename `v' ind`year' // rename variable to dataYYYY
	}
	rename indseries series // rename to more legible name
	rename indtext sic`input'text // rename to more legible name
	
	keep if inlist(series,"COMP","GOS","TXPI","PROINC") // 
		// keep only compensation, gross oper surplus, tax on prod/import, 
		// proprietors income
		
	save "./Work/USA_BEA_comp_raw`input'.dta", replace
	append using "./Work/USA_BEA_va_raw`input'.dta"
	save "./Work/USA_BEA_all_raw`input'.dta", replace

	// Raw labor by industry
	import excel using "./Data/USA/GDPbyInd_VA_SIC.xls", ///
		clear sheet("`input'SIC_Employment")

	replace A = "series" if _n==1 // prime this for renaming all columns
	replace B = "text" if _n==1 // prime this for renaming all columns
	foreach v of varlist _all { // rename all year columns from letters to dataYYYY
		local year = `v'[1]
		rename `v' ind`year' // rename variable to dataYYYY
	}
	rename indseries series // rename to more legible name
	rename indtext sic`input'text // rename to more legible name
	
	keep if inlist(series,"FTPT","FTE") // 
		// keep only full/part and FTE

	save "./Work/USA_BEA_employ_raw`input'.dta", replace
	append using "./Work/USA_BEA_all_raw`input'.dta"
	save "./Work/USA_BEA_all_raw`input'.dta", replace

	// Kludge up a unique identifier for each sic row based on the text
	// This relies on idea that same text for each industry is used across sheets and series
	// One particular problem is "general government" and "government enterprises", which are dupes
	//   appearing once for Federal and once for State
	// Fix this by relying on ordering of rows coming from spreadsheets, which are consistent
	// Don't screw with the spaces!!!
	replace sic`input'text = "Federal general government" if sic`input'text[_n-1]=="      Federal"
	replace sic`input'text = "Federal government enterprises" if sic`input'text[_n-2]=="      Federal"
	replace sic`input'text = "State and local general government" if sic`input'text[_n-1]=="      State and local"
	replace sic`input'text = "State and local government enterprises" if sic`input'text[_n-2]=="      State and local"

	egen sic = group(sic`input'text) // a kludge, which relies on idea that text used to desc. is unique

	move sic sic`input'text
	preserve // hold data so we can come back to whole thing
		collapse (first) sic`input'text, by(sic) // grab just the text and sic to save for reference
		save "./Work/USA_BEA_sic_text`input'.dta", replace
	restore // bring back the whole dataset

	drop sic`input'text // remove this and work only with the kludge sic codes now

	reshape long ind, i(series sic) j(year) // put in series/sic/year rows
	compress series // clean up the definition so it is str6, displays better
	destring ind, replace force // all "na" are set to missing

	reshape wide ind, i(sic year) j(series) string // put in sic/year rows, series are variables

	merge m:1 sic using  "./Work/USA_BEA_sic_text`input'.dta" // for clarity in final file
	move sic`input'text year
	drop _merge // should be perfect

	save "./Work/USA_BEA_all_data`input'.dta", replace
} // end foreach loop

use "./Work/USA_BEA_all_data72.dta", clear
export delimited "./CSV/USA_sic4787_va.csv", replace

use "./Work/USA_BEA_all_data87.dta", clear
export delimited "./CSV/USA_sic8797_va.csv", replace
