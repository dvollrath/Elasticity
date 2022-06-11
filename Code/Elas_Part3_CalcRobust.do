/*
Calculate Elasticities USING BEA TOTAL REQUIREMENTS TABLE
- Script takes a given set of industry factor costs for a year and calculates elasticity
- Assumes that a dataset of industry-level data is present

- Takes the BEA Total Requirements Matrix as a given, rather than finding from Use and Make

*/
capture matrix drop V U Fc Xc Xi E SVA SVC Return Include Costs Yi

// Retrieve year from existing data
	qui summ year, det
	if r(min) != r(max) {
		di "ERROR: Multiple years passed"
	}
	else {
		local y = r(min)
	}

// Create matrices of which industries to include and factor costs
	mkmat include, matrix(Include) // vector of 0/1 indicating included industries
	qui drop if include==0 // drop rows for excluded industries
	mkmat cost*, matrix(Costs) // matrix of factor costs
	mkmat iova, matrix(Yi) // vector of value-added by industry
	mat CostVA = inv(diag(Yi))*Costs // factor costs/VA ratios
	
// import use, make, gross output, and final use matrices/vectors for given year
	qui insheet using "./CSV/USA_R_`y'.csv", clear
	mkmat *, matrix(R) // total requirements matrix
	qui insheet using "./CSV/USA_Xi_`y'.csv", clear
	mkmat *, matrix(Xi) // gross output of industries

// Remove rows/columns from matrices/vectors for excluded industries
// Relies on BEA regularity that commodities are ordered as industries, then adding used/other
// This is a bit of a kludge, but works given that BEA regularity
foreach m in R { // for each matrix
	qui clear
	qui svmat `m' // save matrix to memory
	qui svmat Include, names(col) // save Include vector as well
	qui drop if include==0 // drop industry/commodities that are excluded
	qui drop include 
	qui xpose, clear // transpose the data from the matrix
	qui svmat Include, names(col) // save the Include vector again
	qui drop if include==0 // drop industry/commodities that are excluded
	qui drop include
	qui xpose, clear // transpose modified data *back* to original shape
	mkmat *, matrix(`m') // save data back to original matrix name
}
foreach v in Xi { // for each vector
	qui clear
	qui svmat `v' // save vector to memory
	qui svmat Include, names(col) // save Include vector as well
	qui drop if include==0 // drop industry/commodities that are excluded
	qui drop include
	mkmat *, matrix(`v') // save data back to original vector

}
	
// create summation vectors
	mat eJ = J(rowsof(Xi),1,1)
	
// Create matrix of transactions based on total requirements and gross output
	mat Z = (I(rowsof(R)) - inv(R))*diag(Xi)
	
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
	mat SVA = C*eJ*inv(eJ'*Fi) // share of value-added (sum of VA = sum of final use)
	mat SFC = C*eJ*inv(J(1,rowsof(C),1)*C*eJ) // share of costs
	mat N = Q*f // industry elasticities are cost requirements x final use shares
	
// Name and set return vector of results
	local Enames = "" // initialize locals to hold names of results
	local SVAnames = ""
	local SFCnames = ""
	local Lnames = ""
	local factors: rownames E // get the existing names from E, will be in form "cost_****"
	foreach n of local factors  {
		local v = substr("`n'",6,.) // grab everything after "cost_" from E rowname
		local Enames = "`Enames'" + " elas_" +  "`v'" // build local of names
		local SVAnames = "`SVAnames'" + " vashare_" +  "`v'" // build local of names
		local SFCnames = "`SFCnames'" + " fcshare_" +  "`v'" // build local of  names
		local Lnames = "`Lnames'" + " l_" + "`v'" // build local of names
	}
	mat rownames E = `Enames'
	mat rownames SVA = `SVAnames'
	mat rownames SFC = `SFCnames'
	mat rownames L = `Lnames'
	mat colnames N = "elas_ind"
	mat colnames f = "fushare_ind"
	mat colnames Fi = "fu_ind"
	mat colnames Y = "va_ind"
	mat year = [`y'] // create vector for year
	mat colnames year = "year"
	mat Return = year,E',SVA',SFC' // create full results row vector
	mat Industry = f, L', N, Fi, Y // create matrix of industry results
	
