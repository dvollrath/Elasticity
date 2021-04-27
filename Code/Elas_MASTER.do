////////////////////////////////////////////////////////////////////////
// Master script for aggregate elasticity calculations
////////////////////////////////////////////////////////////////////////

/*
The location of the master folder is the only thing you should need to 
edit in order to replicate the results. You should have downloaded the
"Code" and "Data" folders, and put them under this master folder. Also 
under the master folder need to be three empty folders: "Work", "CSV", and "Drafts".
"Work" holds temporary DTA files produced. "CSV" holds cleaned data. "Drafts" holds
figures and tables produced.
*/
cd ~/dropbox/project/elasticity/
graph set window fontface "Times New Roman"

////////////////////////////////////////////////////////////////////////
// There are four parts to the code. Each part feeds files to the next, but
// each part works independently given that the prior part has run. For example,
// once Part 1 and Part 2 have been run, you can execute Part 3 over and over again
// without having to run Part 1 and Part 2 as well. 
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
// Part 1 - scrapes data from spreadsheets and web
//        - produces organized CSV files for use in analysis
//        - this is data input and cleaning, no meaningful calculations
//        - exceptions are several extrapolations for depreciation allowances
////////////////////////////////////////////////////////////////////////
// industry-level data
do "./Code/Elas_Part1_IO4762.do" // I/O data, naics codes differ by years
do "./Code/Elas_Part1_IO6396.do" // same
do "./Code/Elas_Part1_IO9718.do" // same
do "./Code/Elas_Part1_Cap4718.do" // Capital stock and depr rate data
do "./Code/Elas_Part1_Gov4718.do" // Gov capital and depr rate data
do "./Code/Elas_Part1_VA4797.do" // Compensation/VA data 
do "./Code/Elas_Part1_Emp9818.do" // FTE, FTPT, and prop income by industry for 98-18

// annual data
do "./Code/Elas_Part1_AnnInfl.do" // get inflation data by capital type
do "./Code/Elas_Part1_AnnAllow.do" // get depr allowance by capital type
do "./Code/Elas_Part1_AnnBalance.do" // get balance sheet items
do "./Code/Elas_Part1_AnnRates.do" // get rate of return data for balance sheet items
do "./Code/Elas_Part1_AnnMerge.do" // merge all annual data to one file
do "./Code/Elas_Part1_Compustat.do" // get Edmonds et al markups for comparison

// BLS TFP
do "./Code/Elas_Part1_MFP.do" // import data from Fernald 

// sic-naics-bea crosswalks
do "./Code/Elas_Part1_Maps.do" // create CSVs of these maps

// OECD data scraping
do "./Code/Elas_Part1_STAN.do"
do "./Code/Elas_Part1_OECDIO.do"

////////////////////////////////////////////////////////////////////////
// Part 2 - pulls in CSV files from Part 1
//        - matches different industry codes
//		  - calculates ratios of compensation, K, I, and others to VA
//        - produces 1) file at naics/year level with ratios of costs to VA, level of VA
//                   2) file at year level with rate of return information
////////////////////////////////////////////////////////////////////////

// generate propietors income ratios for 9718
do "./Code/Elas_Part2_Emp9718.do"

// match sic industry to naics industry - create Comp/va ratios
do "./Code/Elas_Part2_Comp4762.do" 
do "./Code/Elas_Part2_Comp6386.do"
do "./Code/Elas_Part2_Comp8796.do"
do "./Code/Elas_Part2_Comp9718.do"

// combine private and gov K data, then match bea level K data to naics industries
do "./Code/Elas_Part2_K4718.do" 
do "./Code/Elas_Part2_CapRatios.do" 

// merge Comp/va and K/va ratios to naics/year level
do "./Code/Elas_Part2_Merge.do"

// create nominal return data for use in calculating R
do "./Code/Elas_Part2_Nominal.do"

// merge naics/year comp/va, K/va data with nominal return data
do "./Code/Elas_Part2_MergeNominal.do"

// OECD merging of sources
do "./Code/Elas_Part2_STAN_ratios.do"

////////////////////////////////////////////////////////////////////////
// Part 3 - pulls in merged naics/year file from Part 2
//        - call script to load programs used in elasticity calcs
//        - run script that calculates elasticities in different scenarios/samples
//        - run script that calculates markups in different scenarios/samples
//
////////////////////////////////////////////////////////////////////////
do "./Code/Elas_Part3_Programs.do" // loads programs
	// this script is where new assumptions or samples get entered
	
do "./Code/Elas_Part3_Scenarios.do" // calculates elasticities for various assumptions

do "./Code/Elas_Part3_TFP_Calc.do" // does TFP growth calculations using prior results

// OECD calculation
do "./Code/Elas_Part3_OECD_0515_Elas.do"
do "./Code/Elas_Part3_OECD_9509_Elas.do"

////////////////////////////////////////////////////////////////////////
// Part 4 - reporting and figures
//        - pulls in results files from different scenarios
////////////////////////////////////////////////////////////////////////

// these are mainly for main paper
do "./Code/Elas_Part4_FigComparison.do" // main script for main figures comparing assumptions
do "./Code/Elas_Part4_FigDecomp.do" // Olley-Pakes decomp of elasticity figure 
do "./Code/Elas_Part4_FigCosts.do" // comparison of cost ratios and elasticities
do "./Code/Elas_Part4_FigTFP.do" // comparison of TFP under different assumptions

// these are for appendix
do "./Code/Elas_Part4_FigCapital.do" // different types of capital
do "./Code/Elas_Part4_FigMarkup.do" // markups under different assumptions
do "./Code/Elas_Part4_FigNoProfit.do" // compare calculation methods for no-profit assumption

// these are for main paper
do "./Code/Elas_Part4_Table_Scenario.do" // main table of summary stats
do "./Code/Elas_Part4_Table_Costs.do" // summary table of cost ratios
do "./Code/Elas_Part4_Table_TFP.do" // table of TFP growth by decade

// appendix tables
do "./Code/Elas_Part4_Table_Capital.do" // summary table by capital type
do "./Code/Elas_Part4_Table_Housing.do" // summary table for housing/gov
do "./Code/Elas_Part4_Table_Match.do" // table of matches from NAICS to BEA

// OECD results
do "./Code/Elas_Part4_FigOECDRange.do"  // main figure for OECD results
do "./Code/Elas_Part4_Table_OECD.do"  // main table of OECD results
