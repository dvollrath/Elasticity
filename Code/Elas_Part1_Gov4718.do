/*
Import BEA depreciation data by industry and by capital type
Prepare BEA industry/year rows with columns for capital type depreciation rates
*/

capture rm "./Work/USA_bea4718_gov.dta"
clear
save "./Work/USA_bea4718_gov.dta", replace emptyok

foreach s in FAAt701-A FAAt703-A FAAt705-A { // for three sheets
	//local s = "FAAt705-A" // for testing
	local col = "CS"
	if "`s'" == "FAAt705-A" {
		local col = "DQ" // need to change range of sheet for investment data
	}
	di "`col'"

	import excel using "./Data/USA/Section7All_xls.xlsx", ///
		clear sheet("`s'") cellrange(A8:`col'99)

	drop A B // drop line and text associated with industry
	foreach v of varlist _all { // rename all variables from letters to yYYYY
		local year = `v'[1] // get year from first row of data
		rename `v' y`year' // rename variable to yYYYY
	}
	rename y id // the bea id given to each series
	drop if id=="" // drop first line which has year data
	gen beacode = substr(id,3,6) // pull the bea industry code from given identifier
	gen capcode = substr(id,1,2)+substr(id,9,4) // pull the series (cap, dep) and cap type (eq, st, ip, es)
	gen captype = substr(id,9,4) // just the cap type
	move beacode id // move to front
	move capcode id //move to front
	drop id // no longer necessary
	
	keep if inlist(beacode,"gdefn1","gndef1","gstlc1","gtotlg","gtotle") // only these will work
	keep if inlist(captype,"eq00","st00","ip00") // keep only these capital series
	drop captype // not necessary any more
	
		// despite having def/non-def capital data, can't break from fed enterprises
	reshape long y, i(beacode capcode) j(year) // put in beacode/year rows
	
	append using "./Work/USA_bea4718_gov.dta" // add existing cap data to this series
	save "./Work/USA_bea4718_gov.dta", replace // save
} // end foreach sheet

destring y, replace force // destring the actual data
replace y = 1000*y // put into millions, not billions

// put in beacode/year rows with columns for diff cap types
reshape wide y, i(beacode year) j(capcode) string

// create an aggregate federal government total and append to existing data
save "./Work/USA_bea_gov.dta", replace // save off full copy
keep if inlist(beacode,"gdefn1","gndef1") // just the two federal categories
collapse (sum) yk1* ym1* yi3*, by(year)
gen beacode = "gfedr1" // add in column for combined federal category
append using "./Work/USA_bea_gov.dta" // add back the saved off copy

// some simple renaming and depr rate calculation
foreach k in eq00 ip00 st00 {
	gen stock`k' = yk1`k' // renaming
	gen dep`k' = ym1`k' // dep rate
	gen inv`k' = yi3`k' // investment
}

keep beacode year stock* dep* inv*
keep if year>=1947 // no need for prior to 1947
replace beacode=upper(beacode) // put in all caps to match other sources

save "./Work/USA_bea_gov.dta", replace
export delimited using "./CSV/USA_bea4718_gov.csv", replace

