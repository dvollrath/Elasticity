/*
Extract Make Table
*/

forvalues y = 1997/2018 { // for each year
	// save Use matrix
	import excel using "./Data/USA/IOMake_Before_Redefinitions_PRO_1997-2020_Summary.xlsx", ///
		clear sheet("`y'") cellrange(C8:BW78)
	foreach v of varlist C-BW { // for all variables
		qui destring `v', force replace
		qui replace `v' = 0 if missing(`v')
	}
	export delimited using "./CSV/USA_V_`y'.csv", replace novarnames


} // end year loop
