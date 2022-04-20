/*
Extract TR tables, for 1997-2020
Prepare one types of files:
- TR table entries using given naics codes
*/

forvalues y = 1997/2020 { // for each year

	import excel using "./Data/USA/IxI_TR_1997-2020_PRO_SUM.xlsx", ///
		clear sheet("`y'") cellrange(A6:BU78)
	
	drop B // drop text column
	
	foreach v of varlist C-BU { // for all IO variables
		local iocode = `v'[1] // get the naics code from the first row
		rename `v' io`iocode' // rename using the naics code
		destring io`iocode', force replace // replaces ... from Excel
		replace io`iocode' = 0 if missing(io`iocode')
	}
	rename A code
	drop if code=="Code"
	drop if code==""

	export delimited using "./CSV/USA_tr_`y'.csv", replace

} // end forvalues
