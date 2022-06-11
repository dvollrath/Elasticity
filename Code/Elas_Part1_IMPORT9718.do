/*
Extract Make Table
*/

forvalues y = 1997/2018 { // for each year
	// save import matrix
	import excel using "./Data/USA/ImportMatrices_Before_Redefinitions_SUM_1997-2020.xlsx", ///
		clear sheet("`y'") cellrange(C8:BU80)
	foreach v of varlist C-BU { // for all variables
		qui destring `v', force replace
		qui replace `v' = 0 if missing(`v')
	}
	export delimited using "./CSV/USA_P_`y'.csv", replace novarnames


} // end year loop
