/*
Set up scenarios to calculate elasticities for
*/

// The scenarios are controlled by the "scenarios.csv" text file
// That file sets flags on what to include/exclude, and how to calculate various costs
capture file close scenario
file open scenario using "./Data/USA/scenarios.csv", read text // control file for scenarios
file read scenario line // reads header line
local control = subinstr("`line'",","," ",.) // sub spaces for commas
local ncontrol: word count `control' // count number of control fields

file read scenario line // read first scenario

while r(eof)==0 { // while there are lines in the scenario file
	local fcontrols = subinstr("`line'",","," ",.) // save scenario control options with spaces
	local scenario = word("`fcontrols'",1) // save 1st control as scenario ID number

	forvalues i = 2(1)`ncontrol' { // cycle through remaining controls, assign locals
		local name = word("`control'",`i') // name of control (housing, gov, capital, etc..)
		local value = word("`fcontrols'",`i') // value of control (Yes, No, noprofit, etc.)
		local `name' = "`value'" // build a local with name, that holds value
	}
	
	// start with baseline data
	use "./Work/USA_scenario_baseline.dta", clear
	qui gen include = 1 // default to all industries being included

	/////////////////////////////////////////////////////////////////
	// Series of IF statements to evaluate controls variables
	// and modify data according to those
	/////////////////////////////////////////////////////////////////
	di "Creating scenario `id'"
	
	/////////////////////////////////////////////////////////////////
	// Housing
	if inlist("`housing'","Yes","yes") {
		di "--Housing included"
	}
	else {
		di "--Housing excluded"
		qui replace include=0 if inlist(code,"HS","ORE","531")
	}

	/////////////////////////////////////////////////////////////////
	// Government
	if inlist("`gov'","Yes","yes") {
		di "--Government included"
	}
	else {
		di "--Government excluded"
		qui replace include=0 if inlist(code,"GFE","GFG","GFGD","GFGN") // federal industries
		qui replace include=0 if inlist(code,"GSLE","GSLG") // state and local
	}

	/////////////////////////////////////////////////////////////////	
	// Farming
	if inlist("`farm'","Yes","yes") {
		di "--Farming included"
	}
	else {
		di "--Farms excluded"
		qui replace include=0 if inlist(code,"111CA","113FF")
	}

	/////////////////////////////////////////////////////////////////
	// Proprietors income
	// Creates the "cost_comp" variable for labor costs
	// Note - this has to come prior to capital costs
	if inlist("`proprietor'","alllab","labor") { // assign all to labor
		di "--All proprietors income to labor"
		qui capture drop cost_comp
		qui gen cost_comp = ratio_comp_va*iova + ratio_proinc_va*iova
		qui replace cost_comp = cost_comp/(1-ratio_txpi_va)
		qui replace cost_comp = 0 if missing(cost_comp)
	}
	else if inlist("`proprietor'","allcap","capital") { // assign all to capital
		di "--All proprietors income to capital"
		qui capture drop cost_comp
		qui gen cost_comp = ratio_comp_va*iova
		qui replace cost_comp = cost_comp/(1-ratio_txpi_va)
		qui replace cost_comp = 0 if missing(cost_comp)
	}
	else { // default case is to split
		di "--Proprietors income split per Gomme/Rupert"
		qui capture drop cost_comp
		qui gen cost_comp = ratio_comp_va*iova /// compensation plus proportion of prop income
			+ ratio_proinc_va*iova*(ratio_comp_va/(1-ratio_proinc_va))
		qui replace cost_comp = cost_comp/(1-ratio_txpi_va) // scale up total comp to account for share of production tax
		qui replace cost_comp = 0 if missing(cost_comp)	
	}

	/////////////////////////////////////////////////////////////////
	// Intellectual property
	// Note - this has to come prior to capital costs
	// Note - this has to come after the proprietors income calculation
	if inlist("`ip'","Yes","yes") {
		di "--IP included"
	}
	else {
		di "--IP excluded"
		qui capture drop inv_ip
		qui gen inv_ip = ratio_invip_va*iova // get amount of investment in IP
		qui replace iova = iova - inv_ip // remove IP investment from value-added
		qui drop inv_ip
		
		qui replace ratio_stockip00_va= 0 // no ip capital
		qui replace ratio_invip_va = 0 // no ip investment
		qui replace deprateip00 = 0 // no ip depreciation
	}
	
	/////////////////////////////////////////////////////////////////
	// Capital costs
	if inlist("`capital'","noprofit") { // no profit assumption
		di "--Capital costs assume no profits"
		foreach j in st eq ip { // for each type of capital
			qui capture drop K_`j'
			qui capture drop inv_`j'
			qui gen K_`j' = ratio_stock`j'00_va*iova // stock is K/VA ratio times VA
			qui gen inv_`j' = ratio_inv`j'_va*iova // investment is I/VA ratio times VA
		}
		foreach j in st eq ip { // for each type of capital
			qui capture drop cost_`j'
			qui gen cost_`j' = (iova - cost_comp)*inv_`j'/(inv_st + inv_eq + inv_ip) // cost of cap, allocate by investment
			qui replace cost_`j' = (iova - cost_comp)*K_`j'/(K_st + K_eq + K_ip) if missing(cost_`j') // use K to allocate if I isn't present
			//qui replace cost_`j' = 0 if missing(cost_`j') // or I/O calcs won't work
		}
	}
	else if inlist("`capital'","deprcost") { // depreciation costs
		di "--Capital costs using only depreciation"
		foreach j in st eq ip { // for each type of capital
			qui capture drop cost_`j'
			qui gen cost_`j' = ratio_stock`j'00_va*iova*deprate`j' // use just depreciation costs
			qui replace cost_`j' = 0 if missing(cost_`j') // or I/O calcs won't work
		}
	}
	else if inlist("`capital'","usercost") { // user costs
		di "--Capital costs using user cost formula"
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
	}
	else if inlist("`capital'","invcost") { // investment cost
		di "--Capital costs using investment spending"
		foreach j in st eq ip { // for each type of capital
			qui capture drop cost_`j'
			qui gen cost_`j' = ratio_inv`j'_va*iova // use just investment costs
			qui replace cost_`j' = 0 if missing(cost_`j') // or I/O calcs won't work
		}
	} 
	else {
		di "--No legitimate capial cost assumption made"
	}

	/////////////////////////////////////////////////////////////////
	// Treatment of government capital costs
	if inlist("`costgov'","Private","private") {
		di "--Government treated like private industry"
	}
	else {
		di "--Government capital costs are depreciation-only (as per BEA)"
		foreach j in st eq ip {
			qui replace cost_`j' = ratio_stock`j'00_va*iova*deprate`j' if inlist(code,"GFE","GFG","GFGD","GFGN") // federal
			qui replace cost_`j' = ratio_stock`j'00_va*iova*deprate`j' if inlist(code,"GSLE","GSLG") // state/local
		}
	}
	
	/////////////////////////////////////////////////////////////////
	// Negatives for factor costs
	if inlist("`negative'","Yes","yes") {
		di "--Negative factor costs allowed"
	}
	else {
		di "--Negative factor costs not allowed"
		foreach j of varlist cost_* {
			qui replace `j' = 0 if `j'<0 & `j'~=. // no negative costs
		}
	}
	
	/////////////////////////////////////////////////////////////////
	// Set variables to save in the scenario file
	/////////////////////////////////////////////////////////////////
	qui keep year code codeorder include series iova cost* // only data variables necessary for scenario
	qui gen scenario=`scenario' // save variables describing scenario terms
	
	forvalues i = 2(1)`ncontrol' { // cycle through remaining controls, assign locals
		local name = word("`control'",`i') // name of control (housing, gov, capital, etc..)
		local value = word("`fcontrols'",`i') // value of control (Yes, No, noprofit, etc.)
		qui gen ctrl_`name' = "`value'" // create variable with that control
	}

	sort year codeorder // ensure order matching the IO tables
	capture rm "./Work/USA_scenario_`scenario'_data.dta" // delete any existing version
	save "./Work/USA_scenario_`scenario'_data.dta", replace // save scenario file using ID number
	
	file read scenario line // read next scenario
}
capture file close scenario
