/*
Extract Make Table
*/

forvalues y = 1947/1962 { // for each year
	// save Make matrix
	import excel using "./Data/USA/IOMake_Before_Redefinitions_1947-1962_Summary.xlsx", ///
		clear sheet("`y'") cellrange(C8:AY54)
	foreach v of varlist C-AY { // for all variables
		qui destring `v', force replace
		qui replace `v' = 0 if missing(`v')
	}
	export delimited using "./CSV/USA_V_`y'.csv", replace novarnames


} // end year loop
