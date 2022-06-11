/*
Extract Use tables, VA, GO for 1963-1996
Prepare two types of files:
- Use table entries
- long file with year/naics rows and value-added, GO columns
*/

// set up empty dataset to append year/naics rows to append to
clear
save "./Work/USA_naics6396_va.dta", emptyok replace // create empty dataset

forvalues y = 1963/1996 { // for each year
	// save Use matrix
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1963-1996_Summary.xlsx", ///
		clear sheet("`y'") cellrange(C8:BO74)
	foreach v of varlist C-BO { // for all variables
		qui destring `v', force replace
		qui replace `v' = 0 if missing(`v')
	}
	export delimited using "./CSV/USA_U_`y'.csv", replace novarnames

	// save vector of commodity final use Fc
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1963-1996_Summary.xlsx", ///
		clear sheet("`y'") cellrange(CG8:CG74)
	qui destring CG, force replace
	qui replace CG = 0 if missing(CG)
	export delimited using "./CSV/USA_Fc_`y'.csv", replace novarnames

	// save vector of commodity gross output Xc
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1963-1996_Summary.xlsx", ///
		clear sheet("`y'") cellrange(CH8:CH74)
	qui destring CH, force replace
	qui replace CH = 0 if missing(CH)
	export delimited using "./CSV/USA_Xc_`y'.csv", replace novarnames

	// save dataset of indstury value-added, gross output, and labor compensation
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1963-1996_Summary.xlsx", ///
		clear sheet("`y'") cellrange(C76:BO77)
	foreach v of varlist C-BO { // for all variables
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
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1963-1996_Summary.xlsx", ///
		clear sheet("`y'") cellrange(A8:A72) // import the codes for industries
	svmat IND, names(col) // save back the industry data
	rename A naics6396code
	gen codeorder = _n // to ensure order matches use tables
	gen year = `y'
	append using "./Work/USA_naics6396_va.dta" // append
	save "./Work/USA_naics6396_va.dta", replace
	
	
} // end year loop

// export the long dataset with naics/year rows to CSV folder for input later
use "./Work/USA_naics6396_va.dta", clear
export delimited using "./CSV/USA_naics6396_va.csv", replace
