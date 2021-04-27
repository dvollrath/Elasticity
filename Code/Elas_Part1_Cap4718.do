/*
Import BEA depreciation data by industry and by capital type
Prepare BEA industry/year rows with columns for capital type depreciation rates
*/

capture rm "./Work/USA_bea4718_capital.dta"
clear
save "./Work/USA_bea4718_capital.dta", replace emptyok

foreach s in FAAt301E-A FAAt301I-A FAAt301S-A /// current-cost
	FAAt304E-A FAAt304I-A FAAt304S-A /// depreciation
	FAAt302E-A FAAt302I-A FAAt302S-A /// quantity index
	FAAt303E-A FAAt303I-A FAAt303S-A /// historical cost
	FAAt307E-A FAAt307I-A FAAt307S-A /// investment
	{ // for each of these sheets
	
	// import from excel file of bea fixed asset tables
	import excel using "./Data/USA/Section3All_xls.xlsx", ///
		clear sheet("`s'") cellrange(A8:BW86)

	drop A B // drop line and text associated with industry
	foreach v of varlist _all { // rename all variables from letters to yYYYY
		local year = `v'[1] // get year from first row of data
		rename `v' y`year' // rename variable to yYYYY
	}
	rename y id // the bea id given to each series
	drop if id=="" // drop first line which has year data
	gen beacode = upper(substr(id,4,4)) // pull the bea industry code from given identifier
	gen capcode = substr(id,1,2)+substr(id,9,4) // pull the series (cap, dep) and cap type (eq, st, ip, es)
	move beacode id // move to front
	move capcode id //move to front
	drop id // no longer necessary
	
	reshape long y, i(beacode) j(year) // put in beacode/year rows
	
	append using "./Work/USA_bea4718_capital.dta" // add existing cap data to this series
	save "./Work/USA_bea4718_capital.dta", replace // save
}

destring y, replace force // destring the actual data
replace y = 1000*y // put into millions, not billions

// put in beacode/year rows with columns for diff cap types
reshape wide y, i(beacode year) j(capcode) string

egen beaid = group(beacode) // organize panel
xtset beaid year

// some simple renaming basic price change calculations
foreach k in eq00 ip00 st00 {
	gen stock`k' = yk1`k' // renaming
	gen dep`k' = ym1`k' // renaming
	gen inv`k' = yi3`k' // renaming
	gen pchange`k' = ln(yk3`k'/ykc`k') - ln(L.yk3`k'/L.ykc`k')
	gen pchange`k'curr = ln(yk1`k'/ykc`k') - ln(L.yk1`k'/L.ykc`k')
}

keep beacode year stock* dep* inv* pchange*

save "./Work/USA_bea_capital.dta", replace // save
export delimited using "./CSV/USA_bea4718_capital.csv", replace

