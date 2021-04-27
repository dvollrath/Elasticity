/*
Go through each OECD I/O file - match to STAN industry data
Given STAN data and I/O data - calculate elasticity under different assumptions
*/

capture file close f_result
file open f_result using "./Work/OECD_STAN4_0515_elasticity.csv", write replace
file write f_result "cou, year, assump, elas_labor, elas_capital, va, emp" _n

local fileList : dir "./CSV" files "OECD_???????_io_2018Ed.csv" // get list of all IO tables

//local fileList = "OECD_FRA2005_io_2018Ed.csv"

local stan = 0
local nostan = 0

mat Epsilon = J(1,4,0)

foreach file of local fileList { // for each of the IO files
	di "`file'"
	local country = substr("`file'",6,3) // get country code from IO file name
	local year = substr("`file'",9,4) // get year from IO file name

	use "./Work/OECD_STAN4_0515_all.dta", clear // load up STAN database
	keep if cou=="`country'"
	keep if year==`year'
	count
	save "./Work/OECD_STAN4_match.dta", replace // save that limited file
	
	if r(N)==0 { // there are no observations from STAN on that country/year
		di "No STAN data for `file'"
		local nostan = `nostan' + 1
	}
	else { // there is a STAN match for that country/year
		local stan = `stan' + 1
		
		foreach assump in depr invest noprofit depr_self invest_self noprofit_self { // for each of three types of assumptions about RK
			di "`assump'"
			insheet using "./CSV/`file'", names clear // open IO file itself
			
			merge 1:1 dcode using "./Work/OECD_STAN4_match.dta",  assert(match master) // merge STAN to the IO data
			sort sortorder // ensures IO rows matches column after merge
			
			qui gen cost_comp = (comp_`assump'/va)*dvalu // get compensation cost scaled to IO VA term
			qui gen cost_RK = (RK_`assump'/va)*dvalu // get RK cost scaled to IO VA term
			
			qui summ emp // total employment
			local emp = r(sum)
			qui summ dvalu // total VA from IO table
			local va = r(sum)
			qui replace dvalu = dvalu/r(sum) // shares of total VA
			qui replace dvalu = 0 if missing(dvalu) // fill in 0s if missing

			egen total_costs = rowtotal(cost*) // get total costs including intermediates
			foreach v of varlist cost* { // for each element of costs
				qui replace `v' = `v'/total_costs // get as share of total costs
				qui replace `v' = 0 if missing(`v') // need to fill in with 0s to override missing from division by zero
			}
			
			local num_intermediates = _N // number of industries in IO table
			
			mkmat cost*, matrix(IO) rownames(dcode) // build matrix with all cost columns
			mat zeros = J(colsof(IO)-rowsof(IO),colsof(IO),0) // create zero rows for all included factors
			mat IO = IO\zeros // add zero rows to bottom of IO for included factors
			local names: colnames IO // get names from columns (includes factors)
			mat rownames IO = `names'
			
			mkmat dvalu, matrix(VA) rownames(dcode) // make VA vector
			mat zeros = J(rowsof(IO)-rowsof(VA),1,0) // make additional rows for VA vector
			mat VA = VA\zeros // add rows
			mat rownames VA = `names'
			
			mat Ident = I(rowsof(IO)) // identity matrix
			mat Leon = inv(Ident - IO) // Leontief inverse
			mat elasticity = VA'*Leon // calculate elasticities

			file write f_result "`country', `year', `assump'," (el(elasticity,1,`num_intermediates'+1)) "," (el(elasticity,1,`num_intermediates'+2)) "," (`va') "," (`emp') _n		
						
		} // end foreach assumption
	} // end else
} // end loop through files

di "STAN exists: " (`stan')
di "No STAN exists: " (`nostan')

capture file close f_result
insheet using "./Work/OECD_STAN4_0515_elasticity.csv", clear
gen series = 0515
save "./Work/OECD_STAN4_0515_elasticity.dta", replace
