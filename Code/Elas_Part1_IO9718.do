/*
Extract I/O tables, VA, GO for 1998-2018
Prepare two types of files:
- I/O table entries using given naics codes
- long file with year/naics rows and value-added, GO columns
*/

// set up empty dataset to append year/naics rows to append to
clear
save "./Work/USA_naics9718_va.dta", emptyok replace // create empty dataset

forvalues y = 1997/2018 { // for each year
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1997-2018_Summary.xlsx", ///
		clear sheet("`y'") cellrange(A6:BU90)
	
	drop B // drop text column
	
	foreach v of varlist C-BU { // for all variables
		local iocode = `v'[1] // get the naics code from the first row
		rename `v' io`iocode' // rename using the naics code
		destring io`iocode', force replace
		replace io`iocode' = 0 if missing(io`iocode')
	}
	rename A code
	replace code = "T008" if _n==_N // the last row is gross output (T008)
	replace code = "T006" if _n==_N-1 // the second to last row is value added (T006)
	drop if code=="" // lose all rows without codes
	drop if code=="IOCode"

	preserve // save the actual IO table entries
		drop if inlist(code,"Used","Other","T005","T006","T008") // drop misc and summary rows
		drop if inlist(code,"V001","V002","V003") // drop compensation, gos, taxes
		export delimited using "./CSV/USA_io_`y'.csv", replace
	restore

	keep if inlist(code,"T006","T008","V001","V002","V003") // keep VA,GO,Comp,taxes,GOS
	// because of the funky nature of the codes, have to be creative in transposing/reshaping
	mkmat io*, matrix(Temp) // save data into matrix
	mat Transpose = Temp' // transpose
	clear // empty the dataset
	svmat Transpose // save back the tranposed matrix
	rename Transpose1 ioCOMP // give real names
	rename Transpose2 ioTXPI // give real names
	rename Transpose3 ioGOS
	rename Transpose4 ioVA
	rename Transpose5 ioGO
	
	// create variable with iocodes and create year variable
	local rownames : rowfullnames Transpose // get rownames, which are the naics codes
	local c : word count `rownames' // count how many codes there are
	gen iolong="" // set up variables
	gen naics9718code=""
	forvalues i = 1/`c' { // for each row
		qui replace iolong = "`:word `i' of `rownames''" in `i' // save the matrix rowname to variable
		local codelength = strlen(iolong[`i']) // get string length of the save code
		qui replace naics9718code = substr(iolong,3,`codelength') in `i' // clip the "io" from front of code
	}
	drop iolong // lose this working variable
	gen year = `y' // set the year
	
	// save and append with existing long dataseries
	append using "./Work/USA_naics9718_va.dta"
	save "./Work/USA_naics9718_va.dta", replace
	
} // end year loop

// export the long dataset with naics/year rows to CSV folder for input later
use "./Work/USA_naics9718_va.dta", clear
export delimited using "./CSV/USA_naics9718_va.csv", replace
