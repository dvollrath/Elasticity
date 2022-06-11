/*
Extract Use tables, VA, GO for 1947-1962
Prepare two types of files:
- Use table entries
- long file with year/naics rows and value-added, GO columns
*/

// set up empty dataset to append year/naics rows to append to
clear
save "./Work/USA_naics4762_va.dta", emptyok replace // create empty dataset

forvalues y = 1947/1962 { // for each year
	// save Use matrix
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1947-1962_Summary.xlsx", ///
		clear sheet("`y'") cellrange(C8:AW56)
	foreach v of varlist C-AW { // for all variables
		qui destring `v', force replace
		qui replace `v' = 0 if missing(`v')
	}
	export delimited using "./CSV/USA_U_`y'.csv", replace novarnames

	// save vector of commodity final use Fc
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1947-1962_Summary.xlsx", ///
		clear sheet("`y'") cellrange(BL8:BL56)
	qui destring BL, force replace
	qui replace BL = 0 if missing(BL)
	export delimited using "./CSV/USA_Fc_`y'.csv", replace novarnames

	// save vector of commodity gross output Xc
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1947-1962_Summary.xlsx", ///
		clear sheet("`y'") cellrange(BM8:BM56)
	qui destring BM, force replace
	qui replace BM = 0 if missing(BM)
	export delimited using "./CSV/USA_Xc_`y'.csv", replace novarnames

	// save dataset of indstury value-added, gross output, and labor compensation
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1947-1962_Summary.xlsx", ///
		clear sheet("`y'") cellrange(C58:AW59)
	foreach v of varlist C-AW { // for all variables
		qui destring `v', force replace
		qui replace `v' = 0 if missing(`v')
	}
	xpose, clear // transpose the data into columns
	rename v1 iova
	rename v2 iogo
	keep iova iogo
	mkmat iova iogo, matrix(IND) // save numerical values of these to matrix

	// save vector of industry gross output Xi
	keep iogo
	export delimited using "./CSV/USA_Xi_`y'.csv", replace novarnames

	// attach industry codes to the industry information
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1947-1962_Summary.xlsx", ///
		clear sheet("`y'") cellrange(A8:A54) // import the codes for industries
	svmat IND, names(col) // save back the industry data
	rename A naics4762code // naics code identifier
	gen codeorder = _n // to ensure order matches use tables
	gen year = `y'
	append using "./Work/USA_naics4762_va.dta" // append
	save "./Work/USA_naics4762_va.dta", replace
	
	
} // end year loop

// export the long dataset with naics/year rows to CSV folder for input later
use "./Work/USA_naics4762_va.dta", clear
export delimited using "./CSV/USA_naics4762_va.csv", replace
