/*
Extract Use tables, VA, GO for 1998-2018
Prepare two types of files:
- Use table entries
- long file with year/naics rows and value-added, GO columns
*/

// set up empty dataset to append year/naics rows to append to
clear
save "./Work/USA_naics9718_va.dta", emptyok replace // create empty dataset

forvalues y = 1997/2018 { // for each year
	// save Use matrix
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1997-2018_Summary.xlsx", ///
		clear sheet("`y'") cellrange(C8:BU80)
	foreach v of varlist C-BU { // for all variables
		qui destring `v', force replace
		qui replace `v' = 0 if missing(`v')
	}
	export delimited using "./CSV/USA_U_`y'.csv", replace novarnames

	// save vector of commodity final use Fc
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1997-2018_Summary.xlsx", ///
		clear sheet("`y'") cellrange(CU8:CU80)
	qui destring CU, force replace
	qui replace CU = 0 if missing(CU)
	export delimited using "./CSV/USA_Fc_`y'.csv", replace novarnames

	// save vector of commodity gross output Xc
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1997-2018_Summary.xlsx", ///
		clear sheet("`y'") cellrange(CV8:CV80)
	qui destring CV, force replace
	qui replace CV = 0 if missing(CV)
	export delimited using "./CSV/USA_Xc_`y'.csv", replace novarnames

	// save dataset of indstury value-added, gross output, and labor compensation
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1997-2018_Summary.xlsx", ///
		clear sheet("`y'") cellrange(C84:BU90)
	foreach v of varlist C-BU { // for all variables
		qui destring `v', force replace
		qui replace `v' = 0 if missing(`v')
	}
	xpose, clear // transpose the data into columns
	rename v1 iocomp // compensation data
	rename v2 iotxpi // taxes on production and imports
	rename v6 iova // value-added
	rename v7 iogo // gross output
	keep iocomp iova iogo iocomp iotxpi
	mkmat iocomp iotxpi iova iogo, matrix(IND) // save numerical values of these to matrix

	// save vector of industry gross output Xi
	keep iogo
	export delimited using "./CSV/USA_Xi_`y'.csv", replace novarnames

	// attach industry codes to the industry information
	import excel using "./Data/USA/IOUse_Before_Redefinitions_PRO_1997-2018_Summary.xlsx", ///
		clear sheet("`y'") cellrange(A8:A78) // import the codes for industries
	svmat IND, names(col) // save back the industry data
	rename A naics9718code
	gen codeorder = _n // to ensure order matches use tables
	gen year = `y'
	append using "./Work/USA_naics9718_va.dta" // append
	save "./Work/USA_naics9718_va.dta", replace
	
	
} // end year loop

// export the long dataset with naics/year rows to CSV folder for input later
use "./Work/USA_naics9718_va.dta", clear
export delimited using "./CSV/USA_naics9718_va.csv", replace
