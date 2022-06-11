/*
Numbers for depreciation cost breakdown
*/


use "./Work/USA_scenario_2_industry_results.dta", clear // use that scenario file
qui ds cost* // describe all variables called "cost*" - these are factor costs
local nfactors: word count `r(varlist)' // count how many factors there are
mat Results = J(1,1+3*`nfactors',0) // initialize vector to hold results
		// columns for year, 3 columns for each factor included (elasticity, VA share, cost share)
local scenario=scenario[1] // capture scenario number


qui summ year // find min and max years
local ymin = r(min)
local ymax = r(max) 
di "-Years:" _continue
forvalues y = `ymin'(1)`ymax' { // for each year in the scenario passed
	di "-" _continue
	preserve
		qui keep if year==`y' // limit data to given year
		sort codeorder // ensure industries in correct order
		mkmat cost*, matrix(Costs) // matrix of factor costs
		mkmat iova, matrix(Yi) // vector of value-added by industry
		mat CostVA = inv(diag(Yi))*Costs // factor costs/VA ratios
	
		// import use, make, gross output, and final use matrices/vectors for given year
		qui insheet using "./CSV/USA_V_`y'.csv", clear
		mkmat *, matrix(V) // make matrix
		qui insheet using "./CSV/USA_U_`y'.csv", clear
		mkmat *, matrix(U) // use matrix
		qui insheet using "./CSV/USA_Fc_`y'.csv", clear
		mkmat *, matrix(Fc) // final use of commodities
		qui insheet using "./CSV/USA_Xc_`y'.csv", clear
		mkmat *, matrix(Xc) // gross output of commodities
		qui insheet using "./CSV/USA_Xi_`y'.csv", clear
		mkmat *, matrix(Xi) // gross output of industries
	
		// create summation vectors
		mat eJ = J(rowsof(Xi),1,1)
	
	// Regular calculation
		// Create intermediate transaction matrix Z consistent with Use and Make tables
		mat Z = V*inv(diag(Xc))*U // absolute spending on industry inputs to produce Xc in commodity gross output
		mat R = inv(I(rowsof(Z)) - Z*inv(diag(Xi))) // total requirements matrix for gross output

		// Create vector of final use of *industries* and final use shares
		mat Fi = inv(R)*Xi
		mat f = Fi*inv(eJ'*Fi)
		
		// Create vector of value-added and total costs by industry consistent with Z
		mat Y = Xi - Z'*eJ // VA by industry consistent with industry gross output and Z
		mat C = CostVA'*diag(Y) // factor costs for each industry = cost/VA ratio x VA
		mat T = eJ'*Z + J(1,rowsof(C),1)*C // total costs are intermediate trxn plus factor costs
		mat Q = inv(I(rowsof(Z)) - Z*inv(diag(T))) // total *cost* requirement table (note T instead of Xi)

		// Calculate factor elasticities and VA shares
		mat L = C*inv(diag(T))*Q // Leontief inverse for costs = cost/total costs x requirement matrix
		mat E = L*f // factor elasticities are Leontief inverse x final use shares
		mat SVA = C*inv(diag(J(1,rowsof(C),1)*C))*f
		mat SFC = C*eJ*inv(J(1,rowsof(C),1)*C*eJ) // share of costs
		mat mu = diag(Xi)*inv(diag(T))*J(rowsof(Xi),1,1) // generate vector of gross output markup over costs
				
	// Calculate alternative elasticity assuming no intermediates
		mat Xi = Yi // with no intermediates, gross output has to equal VA
		mat Z = J(rowsof(Xi),rowsof(Xi),0) // absolute spending on industry inputs to produce Xc in commodity gross output
		mat R = inv(I(rowsof(Z)) - Z*inv(diag(Xi))) // total requirements matrix for gross output

		// Create vector of final use of *industries* and final use shares
		mat Fi = inv(R)*Xi
		mat f = Fi*inv(eJ'*Fi)
		
		// Create vector of value-added and total costs by industry consistent with Z
		mat Y = Xi - Z'*eJ // VA by industry consistent with industry gross output and Z
		mat C = CostVA'*diag(Y) // factor costs for each industry = cost/VA ratio x VA
		mat T = eJ'*Z + J(1,rowsof(C),1)*C // total costs are intermediate trxn plus factor costs
		mat Q = inv(I(rowsof(Z)) - Z*inv(diag(T))) // total *cost* requirement table (note T instead of Xi)

		// Calculate factor elasticities and VA shares
		mat L = C*inv(diag(T))*Q // Leontief inverse for costs = cost/total costs x requirement matrix
		mat ALT = L*f // factor elasticities are Leontief inverse x final use shares

		local Enames = "" // initialize locals to hold names of results
		local ALTnames = ""
		local SFCnames = ""
		local factors: rownames E // get the existing names from E, will be in form "cost_****"
		foreach n of local factors  {
			local v = substr("`n'",6,.) // grab everything after "cost_" from E rowname
			local Enames = "`Enames'" + " elas_" +  "`v'" // build local of names
			local ALTnames = "`ALTnames'" + " alt_" +  "`v'" // build local of names
			local SFCnames = "`SFCnames'" + " fcshare_" +  "`v'" // build local of  names
		}
		mat year = [`y'] // create vector for year
		mat colnames year = "year"
		mat rownames E = `Enames'
		mat rownames SFC = `SFCnames'
		mat rownames ALT = `ALTnames'
		mat Return = year,E',ALT',SFC' // create full results row vector	
	restore

	mat Results = Results \ Return // append Return vector to Results vector	
}

	local names: colnames Return // get column names from Return vector
	mat colnames Results = `names' // apply those names to full Results vector
	
	// Save off annual results for scenario
	mat Results = Results[2...,1...] // remove 0 row from Results from initializing
	qui keep scenario ctrl_* // keep only the identifier information
	qui keep if _n <= rowsof(Results) // keep enough rows to match Results matrix
	qui svmat Results, names(col) // loads results into memory
	gen fcshare_cap = fcshare_st + fcshare_eq + fcshare_ip
	gen alt_cap = alt_st + alt_eq + alt_ip
	gen elas_cap = elas_st + elas_eq + elas_ip
