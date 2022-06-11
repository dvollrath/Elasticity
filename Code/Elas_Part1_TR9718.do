/*
Extract TR tables, for 1997-2018
Prepare one types of files:
- TR table entries using given naics codes
*/

forvalues y = 1997/2018 { // for each year

	import excel using "./Data/USA/IxI_TR_1997-2020_PRO_SUM.xlsx", ///
		clear sheet("`y'") cellrange(C8:BU78)
	
	foreach v of varlist C-BU { // for all IO variables
		qui destring `v', force replace
		qui replace `v' = 0 if missing(`v')
	}

	export delimited using "./CSV/USA_R_`y'.csv", replace novarnames

} // end forvalues
