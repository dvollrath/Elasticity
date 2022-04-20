/*
Programs to do sample selection and capital assumptions
*/


/////////////////////////////////////////////////////////
// Treatment of Used/Other industries from Use table
/////////////////////////////////////////////////////////

// Treat used/other as factors of production
capture program drop used_asfactor
program used_asfactor
	qui capture drop cost_used cost_other
	qui gen cost_used = ioused
	qui gen cost_other = ioother
end

// Ignore used/other entirely
capture program drop used_ignore
program used_ignore
	qui capture drop cost_used cost_other
	qui capture drop ioused ioother
end

/////////////////////////////////////////////////////////
// Proprietors income assumptions
/////////////////////////////////////////////////////////

// Labor costs with split proprietors income
capture program drop labor_split
program labor_split
	qui capture drop cost_comp
	qui gen cost_comp = ratio_comp_va*iova /// compensation plus proportion of prop income
		+ ratio_proinc_va*iova*(ratio_comp_va/(1-ratio_proinc_va))
	qui replace cost_comp = cost_comp/(1-ratio_txpi_va) // scale up total comp to account for share of production tax
		//+ ratio_proinc_va*iova*(ratio_comp_va/(1-ratio_proinc_va-ratio_txpi_va)) // set comp costs
	
end

// Labor costs with all proprietors income to labor
capture program drop labor_alllab
program labor_alllab
	qui capture drop cost_comp
	qui gen cost_comp = ratio_comp_va*iova + ratio_proinc_va*iova
	qui replace cost_comp = cost_comp/(1-ratio_txpi_va)
end

// Labor costs with all proprietors income to capital
capture program drop labor_allcap
program labor_allcap
	qui capture drop cost_comp
	qui gen cost_comp = ratio_comp_va*iova
	qui replace cost_comp = cost_comp/(1-ratio_txpi_va)
end

/////////////////////////////////////////////////////////
// Capital cost assumptions
/////////////////////////////////////////////////////////

// Investment costs
capture program drop capital_invcost
program capital_invcost
	quietly {
	capture drop cost_st
	gen cost_st = ratio_invst_va*iova // set capital costs
	capture drop cost_eq
	gen cost_eq = ratio_inveq_va*iova
	capture drop cost_ip
	gen cost_ip = ratio_invip_va*iova
	}
end

// Depreciation costs
capture program drop capital_deprcost
program capital_deprcost
	foreach j in st eq ip { // for each type of capital
		qui capture drop cost_`j'
		qui gen cost_`j' = ratio_stock`j'00_va*iova*deprate`j' // use just depreciation costs
		qui replace cost_`j' = 0 if missing(cost_`j') // or I/O calcs won't work
	}
end

// User costs
capture program drop capital_usercost
program capital_usercost
	foreach j in st eq ip { // for each type of capital
		qui capture drop einflation`j'
		qui gen einflation`j' = inf`j'00 // use economy-wide inflation rate as baseline
		qui replace einflation`j' = pchange`j'00curr if !missing(pchange`j'00curr) 
			// override with naics/year specific inflation rate if available
		
		qui capture drop K_`j'
		qui gen K_`j' = ratio_stock`j'00_va*iova // stock is K/VA ratio times VA
		qui capture drop R_`j'
		qui gen R_`j' = (nominal - einflation`j' + deprate`j'00)*tax_`j' // user cost of capital
		qui capture drop cost_`j'
		qui gen cost_`j' = R_`j'*K_`j' // total cost of capital
		
		qui replace cost_`j' = 0 if missing(cost_`j') // or I/O calcs won't work
		qui replace cost_`j' = 0 if cost_`j'<0 & !missing(cost_`j') // eliminate negative costs
	}
end

// User costs - forward-looking 3 year average inflation
capture program drop capital_userfor3
program capital_userfor3
	qui egen code_num = group(code) // organize as panel
	xtset code_num year
	
	foreach j in st eq ip { // for each type of capital
		qui capture drop einflation`j'
		qui gen einflation`j' = ((1+inf`j'00)*(1+F.inf`j'00)*(1+F2.inf`j'00))^(1/3) - 1 
			// use economy-wide inflation rate as baseline
		qui replace einflation`j' = ((1+pchange`j'00curr)*(1+F.pchange`j'00curr)*(1+F2.pchange`j'00curr))^(1/3) - 1 ///
			if !missing(pchange`j'00curr) 
			// override with naics specific inflation rate if available	
		
		qui capture drop K_`j'
		qui gen K_`j' = ratio_stock`j'00_va*iova // stock is K/VA ratio times VA
		qui capture drop R_`j'
		qui gen R_`j' = (nominal - einflation`j' + deprate`j'00)*tax_`j' // user cost of capital
		qui capture drop cost_`j'
		qui gen cost_`j' = R_`j'*K_`j' // total cost of capital
		
		qui replace cost_`j' = 0 if missing(cost_`j') // or I/O calcs won't work
		qui replace cost_`j' = 0 if cost_`j'<0 & !missing(cost_`j') // eliminate negative costs
	}
	qui drop code_num
end

// User costs - backward-looking 3 year average inflation
capture program drop capital_userback3
program capital_userback3
	qui egen code_num = group(code) // organize as panel
	xtset code_num year
	
	foreach j in st eq ip { // for each type of capital
		qui capture drop einflation`j'
		qui gen einflation`j' = ((1+inf`j'00)*(1+L.inf`j'00)*(1+L2.inf`j'00))^(1/3) - 1 
			// use economy-wide inflation rate as baseline
		qui replace einflation`j' = ((1+pchange`j'00curr)*(1+L.pchange`j'00curr)*(1+L2.pchange`j'00curr))^(1/3) - 1 ///
			if !missing(pchange`j'00curr) 
			// override with naics specific inflation rate if available	
		
		qui capture drop K_`j'
		qui gen K_`j' = ratio_stock`j'00_va*iova // stock is K/VA ratio times VA
		qui capture drop R_`j'
		qui gen R_`j' = (nominal - einflation`j' + deprate`j'00)*tax_`j' // user cost of capital
		qui capture drop cost_`j'
		qui gen cost_`j' = R_`j'*K_`j' // total cost of capital
		
		qui replace cost_`j' = 0 if missing(cost_`j') // or I/O calcs won't work
		qui replace cost_`j' = 0 if cost_`j'<0 & !missing(cost_`j') // eliminate negative costs
	}
	qui drop code_num
end

// No profits - naive weights
capture program drop capital_noprofit
program capital_noprofit
	foreach j in st eq ip { // for each type of capital
		qui capture drop K_`j'
		qui gen K_`j' = ratio_stock`j'00_va*iova // stock is K/VA ratio times VA
	}
	
	qui egen cost_noncapital = rowtotal(cost_*) // all costs not from capital (labor, other, used)
	
	// capital costs are not obvious, set according to size of capital stock			  
	qui capture drop cost_st
	qui gen cost_st = (iova - cost_noncapital)*K_st/(K_st + K_eq + K_ip)
	qui capture drop cost_eq
	qui gen cost_eq = (iova - cost_noncapital)*K_eq/(K_st + K_eq + K_ip)
	qui capture drop cost_ip
	qui gen cost_ip = (iova - cost_noncapital)*K_ip/(K_st + K_eq + K_ip)

	qui capture drop cost_noncapital
end


// No profits - user cost weights
capture program drop capital_noprofuser
program capital_noprofuser
	foreach j in st eq ip { // for each type of capital
		qui capture drop einflation`j'
		qui gen einflation`j' = inf`j'00 // use economy-wide inflation rate as baseline
		qui replace einflation`j' = pchange`j'00curr if !missing(pchange`j'00curr) 
			// override with naics/year specific inflation rate if available
		
		qui capture drop K_`j'
		qui gen K_`j' = ratio_stock`j'00_va*iova // stock is K/VA ratio times VA
		qui capture drop R_`j'
		qui gen R_`j' = (nominal - einflation`j' + deprate`j'00)*tax_`j' // user cost of capital
		qui capture drop cost_`j'
		qui gen cost_`j' = R_`j'*K_`j' // total cost of capital
		
		qui replace cost_`j' = 0 if missing(cost_`j') // or I/O calcs won't work
		qui replace cost_`j' = 0 if cost_`j'<0 & !missing(cost_`j') // eliminate negative costs
	}

	qui egen cost_noncapital = rowtotal(cost_*) // all costs not from capital (labor, other, used)
	
	// Use no-profit assumption for total capital costs, but weight according to user cost			  
	qui replace cost_st = (iova - cost_noncapital)*cost_st/(cost_st + cost_eq + cost_ip)
	qui replace cost_eq = (iova - cost_noncapital)*cost_eq/(cost_st + cost_eq + cost_ip)
	qui replace cost_ip = (iova - cost_noncapital)*cost_ip/(cost_st + cost_eq + cost_ip)

	foreach j in st eq ip { 
		qui replace cost_`j' = 0 if missing(cost_`j') // or I/O calcs won't work
		qui replace cost_`j' = 0 if cost_`j'<0 & !missing(cost_`j') // eliminate negative costs
	}
	
	qui capture drop cost_noncapital
end

// No profits - investment cost weights
capture program drop capital_noprofinv
program capital_noprofinv
	quietly {
	capture drop cost_st
	gen cost_st = ratio_invst_va*iova // set capital costs
	capture drop cost_eq
	gen cost_eq = ratio_inveq_va*iova
	capture drop cost_ip
	gen cost_ip = ratio_invip_va*iova
	}

	qui egen cost_noncapital = rowtotal(cost_*) // all costs not from capital (labor, other, used)
	
	// Use no-profit assumption for total capital costs, but weight according to inv cost			  
	qui replace cost_st = (iova - cost_noncapital)*cost_st/(cost_st + cost_eq + cost_ip)
	qui replace cost_eq = (iova - cost_noncapital)*cost_eq/(cost_st + cost_eq + cost_ip)
	qui replace cost_ip = (iova - cost_noncapital)*cost_ip/(cost_st + cost_eq + cost_ip)

	qui replace cost_st = 0 if missing(cost_st)
	qui replace cost_eq = 0 if missing(cost_eq)
	qui replace cost_ip = 0 if missing(cost_ip)
	qui replace cost_st = 0 if cost_st<0 & !missing(cost_st)
	qui replace cost_eq = 0 if cost_eq<0 & !missing(cost_eq)
	qui replace cost_ip = 0 if cost_ip<0 & !missing(cost_ip)
	
	qui capture drop cost_noncapital
end

/////////////////////////////////////////////////////////
// Sample selection assumptions
/////////////////////////////////////////////////////////

// All industries
capture program drop sample_all
program sample_all
	di "All industries included"
end

// No housing
capture program drop sample_nohs
program sample_nohs
	qui drop if inlist(code,"HS","ORE","531") // housing
end

// No government
capture program drop sample_nogov
program sample_nogov
	qui drop if inlist(code,"GFE","GFG","GFGD","GFGN") // federal industries
	qui drop if inlist(code,"GSLE","GSLG") // state and local
end

// No government or housing
capture program drop sample_nogovhs
program sample_nogovhs
	qui drop if inlist(code,"HS","ORE","531") // housing
	qui drop if inlist(code,"GFE","GFG","GFGD","GFGN") // federal industries
	qui drop if inlist(code,"GSLE","GSLG") // state and local
end

// No government or housing or farming
capture program drop sample_nonfarm
program sample_nonfarm
	qui drop if inlist(code,"HS","ORE","531") // housing
	qui drop if inlist(code,"GFE","GFG","GFGD","GFGN") // federal industries
	qui drop if inlist(code,"GSLE","GSLG") // state and local
	qui drop if inlist(code,"111CA","113FF") // farming, fishery, forestry
end


// No IP
capture program drop intel_noip
program intel_noip
	qui capture drop inv_ip
	qui gen inv_ip = ratio_invip_va*iova // get amount of investment in IP
	qui replace iova = iova - inv_ip // remove IP investment from value-added
	qui replace iogo = iogo - inv_ip // remove IP investment from gross output
	qui drop inv_ip
	
	qui replace ratio_stockip00_va= 0 // no ip capital
	qui replace ratio_invip_va = 0 // no ip investment
	qui replace deprateip00 = 0 // no ip depreciation
end

// Yes IP
capture program drop intel_ip
program intel_ip
	di "No changes to data"
end

// No IP and No Housing
capture program drop sample_noiphs
program sample_noiphs
	qui drop if inlist(code,"HS","ORE","531") // housing
	qui capture drop inv_ip
	qui gen inv_ip = ratio_invip_va*iova // get amount of investment in IP
	qui replace iova = iova - inv_ip // remove IP investment from value-added
	qui replace iogo = iogo - inv_ip // remove IP investment from gross output
	qui drop inv_ip
	
	qui replace ratio_stockip00_va= 0 // no ip capital
	qui replace ratio_invip_va = 0 // no ip investment
	qui replace deprateip00 = 0 // no ip depreciation
end


// No IP and no housing or government
capture program drop sample_noipgovhs
program sample_noipgovhs
	qui drop if inlist(code,"HS","ORE","531") // housing
	qui drop if inlist(code,"GFE","GFG","GFGD","GFGN") // federal industries
	qui drop if inlist(code,"GSLE","GSLG") // state and local
	qui capture drop inv_ipsu
	qui gen inv_ip = ratio_invip_va*iova // get amount of investment in IP
	qui replace iova = iova - inv_ip // remove IP investment from value-added
	qui replace iogo = iogo - inv_ip // remove IP investment from gross output
	qui drop inv_ip
	
	qui replace ratio_stockip00_va= 0 // no ip capital
	qui replace ratio_invip_va = 0 // no ip investment
	qui replace deprateip00 = 0 // no ip depreciation
end

/////////////////////////////////////////////////////////
// Calculation programs
/////////////////////////////////////////////////////////

// Merge Cost and IO data
capture program drop calc_merge
program calc_merge
	qui use "./Work/USA_io.dta", clear // assumes working IO file was crated
	mkmat io*, matrix(TEMP) rownames(code) // make a matrix of all columns of I/O matrix
	qui drop io* // drop the original columns
	mat cost = TEMP' // transpose because IO comes in wrong layout
	
	qui svmat cost, names(matcol) // save back columns with cost data
	qui gen sortorder = _n // to ensure rows in order after the merge 

	qui merge 1:1 code using "./Work/USA_costs.dta" // match up cost data with I/O table
	
	levelsof code if _merge==1, local(nomatch)  // I/O industries without matching cost data
		// there will be non-matches if the scenario omits some industries (e.g. Housing, Gov)
	foreach n of local nomatch {
		qui drop if code=="`n'" // drop the rows that did not match
		qui drop cost`n' // drop the I/O columns from those non-match industries
	}
	qui drop _merge
	qui sort sortorder // put back in correct order
	qui drop sortorder // no longer needed
	qui move iova code // clean-up
end

// Calculate cost shares and elasticities
capture program drop calc_epsilon
program calc_epsilon
	// get cost shares
	qui egen total_costs = rowtotal(cost*) // get total costs including intermediates
	foreach v of varlist cost* { // for each element of costs
		qui replace `v' = `v'/total_costs // get as share of total costs
	}
	qui gen markupgo = iogo/total_costs
	//qui drop total_costs // no longer necessary
	
	// get value-added shares
	qui summ iova // get total va
	qui gen iovashare = iova/r(sum) // get va as share of total va

	// get final use shares
	qui summ iofu // get total va
	qui gen iofushare = iofu/r(sum) // get fu as share of total fu

	// Create cost matrix, va matrix, and use to calculate elasticities
	mkmat cost*, matrix(IO) rownames(code) // make IO matrix
	mat zeros = J(colsof(IO)-rowsof(IO),colsof(IO),0) // create zero rows for all included factors
	mat IO = IO\zeros // add zero rows to bottom of IO for included factors
	local names: colnames IO // get names from columns (includes factors)
	mat rownames IO = `names'
	
	mkmat iovashare, matrix(VA) rownames(code) // make VA vector
	mat zeros = J(rowsof(IO)-rowsof(VA),1,0) // make additional rows for VA vector
	mat VA = VA\zeros // add rows
	mat rownames VA = `names'

	mkmat iofushare, matrix(FU) rownames(code) // make VA vector
	mat zeros = J(rowsof(IO)-rowsof(FU),1,0) // make additional rows for VA vector
	mat FU = FU\zeros // add rows
	mat rownames FU = `names'
		
	mat Ident = I(rowsof(IO)) // identity matrix
		
	mat Leon = inv(Ident - IO) // Leontief inverse
	mat elasticity = FU'*Leon // calculate elasticities
	
	local num_intermediates = _N // save the number of intermediate industries
	mat factors = elasticity[1,`num_intermediates'+1...] // save off factor elasticities
	mat industries = elasticity[1,1..`num_intermediates'] // save off industry elasticities
	mat indtran = industries' // transpose to column
	
	svmat indtran, name(epsilon) // save industry elasticity as variable epsilon
	rename epsilon1 epsilon
	
	mat L = Leon[1...,`num_intermediates'+1...] // save columns of Leontief for factors
	svmat L, names(matcol) // add Leontief terms as variables in dataset
end

// Calculate value-added shares
capture program drop calc_share
program calc_share
	qui collapse (sum) iova cost* (first) series, by(year) // get simple totals for costs and VA
	
	qui egen factor_costs = rowtotal(cost*) 
	
	qui ds cost_* // get all cost variables
	foreach v of varlist `r(varlist)' {
		local text = substr("`v'",6,.) // get name of factor
		qui gen share_`text' = `v'/iova // calculate share of value-added
		qui gen factor_`text' = `v'/factor_costs // calculate share of factor costs
	}
	qui drop factor_costs
	mkmat share* , matrix(Shares) // save matrix of revenue shares
	mkmat factor* , matrix(Factors) // save matrix of factor cost shares
end

// Main loop to work through years of calculations
capture program drop calc_loop
program calc_loop
	// Set up for year-by-year calculation of elasticities
	qui summ year // get years spanned in this scenario
	local from = r(min)
	local to = r(max)

	qui ds cost* // show all variables with the "cost" prefix - these are factors of production
	local nfactors: word count `r(varlist)' // save number of factors in local
	mat Epsilon = J(1,`nfactors'+2,0) // create matrix with space for year, series, elas for factors
	mat colnames Epsilon = year series `r(varlist)' // name cols with appropriate headers
	
	// Loop through years
	forvalues y = `from'(1)`to' { // for years in scenario
		qui use "./Work/USA_scenario_calculate.dta", clear // assumes this was created
		qui keep if year==`y' // process one year at a time
		local series = series[1] // store the series identifier as a number for year y
		
		qui egen factor_costs = rowtotal(cost*) // gets total
		qui gen markupva = iova/factor_costs // VA markup
		capture drop factor_costs
		
		qui save "./Work/USA_costs.dta", replace // temporary file of costs for year y - used in merge
		
		insheet using "./CSV/USA_io_`y'.csv", names clear // get I/O table for year y
		qui save "./Work/USA_io.dta", replace // save in working file for merge
		
		calc_merge // call program to merge industry cost data with io table
		calc_epsilon // call program to calculate elasticities
		
		mat header = [`y',`series'] // create header information to save
		mat yearEpsilon = header,factors // combine header with `factors' matrix from calc_merge
		mat Epsilon = Epsilon\yearEpsilon // combine current year results with overall results
		
		qui keep sample scenario series prop code used ip year iova io*share iogo markupgo markupva epsilon ///
			cost_* Lcost* total_costs
		qui append using "./Work/USA_scenario_sample_industry.dta"
		qui save "./Work/USA_scenario_sample_industry.dta", replace
	} // end for each year
end


// Save off the results of year-by-year calculation
capture program drop calc_save
program calc_save
	clear
	svmat Epsilon, names(col) // save stored elasticities to memory
	qui drop if year==0 // eliminates initial row
	svmat Shares, names(col) // save stored VA shares to memory
	svmat Factors, names(col) // save stored factor cost shares to memory

	qui gen cost_cap = 1 - cost_comp // combination capital elasticity

end


// Adjust elasticity in noprofit scenarios to match share data
capture program drop calc_noprofit
program calc_noprofit
	foreach v in comp st eq ip { // override with analytical elas in no-profit case - avoids computation errors from inverse
		qui gen noprof_cost_`v' = cost_`v' if inlist(scenario,"noprofit","noprofuser","noprofinv")
		qui replace cost_`v' = share_`v' if inlist(scenario,"noprofit","noprofuser","noprofinv")
	}
	qui drop cost_cap // recalculate overall capital elasticity
	qui gen cost_cap = 1 - cost_comp // combination capital elasticity

end
// Calculate input totals
capture program drop calc_inputs
program calc_inputs
	preserve 
		foreach j in st eq ip { 
			qui capture drop K_`j'
			qui gen input_`j' = ratio_stock`j'00_va*iova // stock is K/VA ratio times VA	
		}
		qui gen input_comp = ratio_fte_va*iova // get labor input from FTE/VA ratio times VA
		
		collapse (sum) input* (first) series, by(year) // get total cap stocks and labor comp (used to measure labor input)

		mkmat input*, matrix(Inputs) // save matrix of revenue shares, labor costs, and capital stocks
	restore
end

// TR loop to work through years of calculations
capture program drop calc_tr
program calc_tr
	// Set up for year-by-year calculation of elasticities
	qui summ year // get years spanned in this scenario
	local from = r(min)
	local to = r(max)

	qui ds cost* // show all variables with the "cost" prefix - these are factors of production
	local nfactors: word count `r(varlist)' // save number of factors in local
	mat Epsilon = J(1,`nfactors'+`nfactors'+2,0) // create matrix with space for year, series, elas for factors, VA shares for factors
	local names = "" // initialize names for results matrix
	di "`names'"
	foreach var of varlist `r(varlist)' {
		local v = substr("`var'",6,.)
		local names = "`names'" + " share_" +  "`v'"
	}
	di "`names'"
	mat colnames Epsilon = year series `r(varlist)' `names' // name cols with appropriate headers
	
	// Loop through years
	forvalues y = `from'(1)`to' { // for years in scenario
		qui use "./Work/USA_scenario_calculate.dta", clear // assumes this was created
		qui keep if year==`y' // process one year at a time
		local series = series[1] // store the series identifier as a number for year y	
		qui save "./Work/USA_costs.dta", replace // temporary file of costs for year y
		
		insheet using "./CSV/USA_tr_`y'.csv", names clear // get TR table for year y
		mkmat io*, matrix(TR) rownames(code) // save TR table as matrix
		qui gen sortorder = _n // to ensure rows in order after the merge 
		qui merge 1:1 code using "./Work/USA_costs.dta" // match up cost data with TR table
		qui sort sortorder
		qui drop sortorder
		mkmat iogo, matrix(X) rownames(code) // save raw final output vector
		mkmat iova, matrix(V) rownames(code) // save raw value-added vector
		mkmat cost*, matrix(Ctran) rownames(code) // save factor cost matrix
		mat C = Ctran' // transpose cost matrix
		mat e = J(rowsof(TR),1,1) // vector of ones
		mat ec = J(rowsof(C),1,1)
		
		mat cva = C*inv(diag(V)) // costs as share of VA from table
		
		// Solve for industry VA consistent with TR and industry GO
		di "Solve for Z"
		mat Z = (I(rowsof(TR)) - inv(TR))*diag(X)
		mat Vcalc = X - Z'*e // value added consistent with gross output and TR
		mat C = cva*diag(Vcalc) // factor costs consistent with TR
		
		di "Solve for T"
		mat T = e'*Z + ec'*C // total costs
		mat TRC = inv(I(colsof(T))-Z*inv(diag(T))) // TR based on *costs*
		
		//mat A = I(rowsof(TR)) - inv(TR) // 
		//mat Vcalc = X - diag(X)*A'*e // VA consistent

		// Solve for industry FU consistent with TR and GO
		di "Solve for F"
		mat F = inv(TR)*X // this is implicitly what final use is given TR - negatives are OKAY - some FU is negative
		mat f = F*inv(e'*F) // calculates shares of final use
		
		// Solve for elasticity given TR, cost shares of gross output, final use shares
		//mat c = C*inv(diag(X)) // costs as share of gross output
		//mat elasticity = c*TR*f // BF calculation

		di "Solve for E"
		mat elasticity = C*inv(diag(T))*TRC*f

		//mat SVA = C*e*inv(e'*V)
		//mat SCOST = C*e*inv(e'*C*e)
		
		// Solve for cost shares of value-added
		mat S = C*e*inv(e'*Vcalc)
						
		mat factors = elasticity' // save off factor elasticities
		mat shares = S' // save of VA shares
		
		mat header = [`y',`series'] // create header information to save
		mat yearEpsilon = header,factors,shares // combine header with `factors' matrix from calc_merge
		mat Epsilon = Epsilon\yearEpsilon // combine current year results with overall results
		
		qui keep sample scenario series prop code used ip year iova iogo 
		qui append using "./Work/USA_scenario_tr_industry.dta"
		qui save "./Work/USA_scenario_tr_industry.dta", replace
	} // end for each year
end

