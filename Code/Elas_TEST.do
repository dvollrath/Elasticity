////////////////////////////////////////////////////////////////////////
// Test script for aggregate elasticity calculations
////////////////////////////////////////////////////////////////////////

/*
The location of the master folder is the only thing you should need to 
edit in order to replicate the results. You should have downloaded the
"Code" and "Data" folders as part of the replication package, 
and put them under this master folder. 

Also under the master folder need to be three empty folders: "Work", "CSV", and "Drafts".
The code will check that these exist and make them if necessary. 
"Work" holds temporary DTA files produced.
"CSV" holds cleaned data. 
"Drafts" holds figures and tables produced.
*/
cd ~/dropbox/project/elasticity/

////////////////////////////////////////////////////////////////////////
// Option for graph fonts
////////////////////////////////////////////////////////////////////////
graph set window fontface "Times New Roman"

////////////////////////////////////////////////////////////////////////
// Check for and ensure directories are in place
////////////////////////////////////////////////////////////////////////
capture mkdir "./CSV" // try to create CSV folder in case it doesn't exist
if _rc==0 {
	di "Created missing CSV folder"
}
capture mkdir "./Work" // try to create Work folder in case it doesn't exist
if _rc==0 {
	di "Created missing Work folder"
}
capture mkdir "./Drafts" // try to create Drafts folder in case it doesn't exist
if _rc==0 {
	di "Created missing Drafts folder"
}

////////////////////////////////////////////////////////////////////////
// This test script is solely for evaluating the logic in Part 3
// It presumes that Parts 1 and 2 have been run already and produced
// the "./USA_scenario_baseline.dta" file
////////////////////////////////////////////////////////////////////////

// Swap in limited test scenario file for main scenario file
import delimited "./Data/USA/scenarios.csv", clear
export delimited "./Data/USA/bkup_scenarios.csv", replace

import delimited "./Data/USA/test_scenarios.csv", clear
export delimited "./Data/USA/scenarios.csv", replace

// Swap in saved working dataset for the one produced by main script
use "./Data/USA/test_USA_scenario_baseline.dta", clear
save "./Work/USA_scenario_baseline.dta", replace

// Delete existing working files of scenarios
local fileList : dir "./Work" files "USA_scenario_*_data.dta"

foreach file of local fileList {
    rm "./Work/`file'"
}


////////////////////////////////////////////////////////////////////////
// Part 3 - pulls in merged naics/year file from Part 2
//        - call script to load programs used in elasticity calcs
//        - run script that calculates elasticities in different scenarios/samples
//        - run script that calculates markups in different scenarios/samples
//
//
////////////////////////////////////////////////////////////////////////

do "./Code/Elas_Part3_Scenarios.do" // creates data file of costs for each scenario in control file

do "./Code/Elas_Part3_MainLoop.do" // evaluate each scenario file, calculate elasticities

// Produces two files of interest
// "./Work/USA_scenario_3_annual_results.dta"
// "./Work/USA_scenario_3_industry_results.dta"

// Clean up
import delimited "./Data/USA/bkup_scenarios.csv", clear
export delimited "./Data/USA/scenarios.csv", replace

// Open for examination
use "./Work/USA_scenario_3_annual_results.dta", clear

