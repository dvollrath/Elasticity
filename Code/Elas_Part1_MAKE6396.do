/*
Extract Make Table
*/


forvalues y = 1963/1996 { // for each year
	// save Make matrix
	import excel using "./Data/USA/IOMake_Before_Redefinitions_1963-1996_Summary.xlsx", ///
		clear sheet("`y'") cellrange(C8:BQ72)
	foreach v of varlist C-BQ { // for all variables
		qui destring `v', force replace
		qui replace `v' = 0 if missing(`v')
	}
	export delimited using "./CSV/USA_V_`y'.csv", replace novarnames


} // end year loop
