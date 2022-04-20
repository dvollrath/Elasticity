/*
Extract I/O tables, VA, GO for 1947-1962
Prepare two types of files:
- I/O table entries using given naics codes
- long file with year/naics rows and value-added, GO columns
*/

// set up empty dataset to append year/naics rows to
clear
save "./Work/USA_naics6396_va.dta", emptyok replace // create empty dataset

forvalues y = 1963/1996 { // for each year
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1963-1996_Summary.xlsx", ///
		clear sheet("`y'") cellrange(A7:CG77)
	
	drop B // drop text column
	drop BP-CF // drop detailed columns on final use (BL is actual final use column)
	destring CG, force replace // force final use to numeric (replaces ... from Excel)

	foreach v of varlist C-BO { // for all variables
		local iocode = `v'[1] // get the naics code from the first row
		rename `v' io`iocode' // rename using the naics code
		destring io`iocode', force replace
		replace io`iocode' = 0 if missing(io`iocode')
	}
	rename A code
	drop if code=="Code"
	
	preserve
		drop if inlist(code,"Used","Other","T005","T006","T008") // drop misc and summary rows
		mkmat CG, matrix(FINAL) // save final use into own vector
		drop CG // remove BL so that it isn't saved into I/O entries
		export delimited using "./CSV/USA_io_`y'.csv", replace
	restore

	drop CG // get rid of final use as no VA or GO values for this column
	keep if inlist(code,"Used","Other","T006","T008") // keep Used, Other, VA, and GO
	// because of the funky nature of the codes, have to be creative in transposing/reshaping
	mkmat io*, matrix(Temp) // save data into matrix
	mat Transpose = Temp' // transpose
	clear // empty the dataset
	svmat Transpose // save back the tranposed matrix
	rename Transpose1 ioUsed // give real names
	rename Transpose2 ioOther // give real names
	rename Transpose3 ioVA // give real names
	rename Transpose4 ioGO // give real names
	svmat FINAL // save back final use
	rename FINAL1 ioFU // give real names
	
	// create variable with iocodes and create year variable
	local rownames : rowfullnames Transpose // get rownames, which are the naics codes
	local c : word count `rownames' // count how many codes there are
	gen iolong="" // set up variables
	gen iocode=""
	forvalues i = 1/`c' { // for each row
		qui replace iolong = "`:word `i' of `rownames''" in `i' // save the matrix rowname to variable
		local codelength = strlen(iolong[`i']) // get string length of the save code
		qui replace iocode = substr(iolong,3,`codelength') in `i' // clip the "io" from front of code
	}
	drop iolong // lose this working variable
	gen year = `y' // set the year
	
	// save and append with existing long dataseries
	append using "./Work/USA_naics6396_va.dta"
	save "./Work/USA_naics6396_va.dta", replace
}

// export the long dataset with naics/year rows to CSV folder for input later
use "./Work/USA_naics6396_va.dta", clear
rename iocode naics6396code // for matching later on
export delimited using "./CSV/USA_naics6396_va.csv", replace
