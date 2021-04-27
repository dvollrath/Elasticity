/*
Merge annual return data with bearate classes
Creates file bearate/year nominal rates and tax treatment by cap type for calculating R
*/

insheet using "./CSV/USA_annual_Rcalc.csv", names clear

// Create 4 rows for each year, one for each type of funding (private, fed, s/l, housing)
gen copies = 4 // create 4 copies of each year
expand copies
bysort year: gen row = _n // number the 4 rows for each year
gen bearate = ""
label variable bearate "Type of rate to apply"
replace bearate = "private" if row==1
replace bearate = "federal" if row==2
replace bearate = "statelocal" if row==3
replace bearate = "housing" if row==4

// set corp tax rate for non-private
qui replace agg_corp_tax_rate = 0 if inlist(bearate,"federal","statelocal","housing")

// set nominal returns by type of financing
gen intbonds = ratecorpaaa/100
gen intpaper = ratefedfunds/100 // based on correlation of fed funds and comm paper
gen intloans = ratecorpbaa/100  // assumes loan rates are like low quality corp bonds
gen intequity = ratetbond10year/100 + ratespyield // risk-free plus div yield on S&P
gen intfed = ratetbond10year/100 
gen intstlc = ratecorpbaa/100 - .02 // based on correlation of muni rates and corp Baa
gen intmort = ratemortgage/100

// interpolate returns for some early years
replace intequity = ratecorpaaa/100 + .05 if missing(intequity)
replace intpaper = .01 if missing(intpaper)
replace agg_corp_tax_rate = .35 if missing(agg_corp_tax_rate)
replace intmort = rateprime/100 + .01 if missing(intmort) // late 1960s/early 1970s
replace intmort = .0432 if inrange(year,1947,1948) // extends NBER rates backwards
replace intfed = intbonds if missing(intfed) // if missing 10-year bond data, use corporate AAA

// gen cost of capital financing
qui gen nominal = .
label variable nominal "Nominal cost of capital i_jt"
qui replace nominal = /// 
	(sharebonds*intbonds + sharepaper*intpaper + shareloans*intloans)*(1-agg_corp_tax_rate) ///
	+ shareequity*intequity /// weight the  financial alternatives by share of balance sheet
	if bearate=="private" // for private industries
qui replace nominal = intfed if bearate=="federal"
qui replace nominal = intstlc if bearate=="statelocal"
qui replace nominal = intmort if bearate=="housing"

// gen tax treatment
foreach j in st eq ip {
	qui gen tax_`j' = (1-allow`j'00*agg_corp_tax_rate)/(1-agg_corp_tax_rate) 
	label variable tax_`j' "Tax adjustment for `j' (1-ztau/1-tau)"
	label variable inf`j' "Agg. inflation for `j' pi_mt"
}

label variable ratemortgage "30-year mortgage rate"
label variable ratemuni "Municipal bond rate"
label variable ratefedfunds "Fed Funds rate"
label variable ratecorpbaa "Corporate Baa rate"
label variable ratecorpaaa "Corporate AAA rate"
label variable ratetbond10year "10-year T-bond rate"
label variable rateprime "Prime rate"
label variable agg_corp_tax_rate "Effective corp. tax rate"
label variable ratespyield "S&P dividend yield"
label variable sharepaper "Share paper in balances (B_kt)"
label variable sharemunis "Share munis in balances (B_kt)"
label variable sharebonds "Share bonds in balances (B_kt)"
label variable shareloans "Share loans in balances (B_kt)"
label variable shareequity "Share equity in balances (B_kt)"
label variable bal_extrapolated "Were balances extrapolated? 1=Yes"
label variable allowst00 "Depreciate allowance for st"
label variable alloweq00 "Depreciate allowance for eq"
label variable allowip00 "Depreciate allowance for ip"
label variable allow_extrapolated "Were allowances extrapolated? 1=Yes"
label variable intbonds "Assumed nominal rate bonds (i_kt)"
label variable intpaper "Assumed nominal rate paper (i_kt)"
label variable intloans "Assumed nominal rate loans (i_kt)"
label variable intequity "Assumed nominal rate equity (i_kt)"
label variable intfed "Assumed nominal rate federal gov (i_kt)"
label variable intstlc "Assumed nominal rate state/local gov (i_kt)"
label variable intmort "Assumed nominal rate mortgage (i_kt)"
label variable infres "Agg. inflation for residences"

keep if inrange(year,1947,2018)
drop copies row
save "./Work/USA_annual_Rcalc_full.dta", replace // save all information used for rate of return

keep year bearate nominal tax* inf*
save "./Work/USA_annual_Rcalc.dta", replace // save just the assumed nominal rates
