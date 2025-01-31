////////////////////////////////////////////////////////////////////////
// Master script for aggregate elasticity calculations
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

capture confirm file "./Data/USA/scenarios.csv" // confirm control file exists, by proxy confirms the Data folder exists
if _rc!=0 {
	di "Confirm that data folder exists."
	di "Stata returned code: " _rc
}

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
// industry/year data
do "./Code/Elas_Part1_USE4762.do" // Use tables and industry VA, GO, commod FU
do "./Code/Elas_Part1_USE6396.do" // same
do "./Code/Elas_Part1_USE9718.do" // same

do "./Code/Elas_Part1_MAKE4762.do" // Make tables
do "./Code/Elas_Part1_MAKE6396.do" // same
do "./Code/Elas_Part1_MAKE9718.do" // same

do "./Code/Elas_Part1_IMPORT9718.do" // Imported intermediate tables
do "./Code/Elas_Part1_TR9718.do" // requirement tables after adjustment

do "./Code/Elas_Part1_Cap4718.do" // Capital stock and depr rate data
do "./Code/Elas_Part1_Gov4718.do" // Gov capital and depr rate data
do "./Code/Elas_Part1_VA4797.do" // Compensation/VA data 
do "./Code/Elas_Part1_Emp9818.do" // FTE, FTPT, and prop income by industry for 98-18

// yearly data - these five scripts must be run in order
do "./Code/Elas_Part1_AnnInfl.do" // get inflation data by capital type
do "./Code/Elas_Part1_AnnAllow.do" // get depr allowance by capital type
do "./Code/Elas_Part1_AnnBalance.do" // get balance sheet items
do "./Code/Elas_Part1_AnnRates.do" // get rate of return data for balance sheet items
do "./Code/Elas_Part1_AnnMerge.do" // merge all annual data to one file

// DeLoecker, Eeckhout, Unger Compustat data
do "./Code/Elas_Part1_DLEU.do" // run their replication scripts and get firm-based production elasticities and cost shares

// BLS TFP
do "./Code/Elas_Part1_MFP.do" // import data from Fernald 

// sic-naics-bea crosswalks
do "./Code/Elas_Part1_Maps.do" // create CSVs of these maps

////////////////////////////////////////////////////////////////////////
// Part 2 - pulls in CSV files from Part 1
//        - matches different industry codes
//		  - calculates ratios of compensation, K, I, and others to VA
//        - produces 1) file at naics/year level with ratios of costs to VA, level of VA
//                   2) file at year level with rate of return information
//
// PART 2 MUST BE RUN IN THE ORDER SHOWN
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

// calculate nominal return data for use in calculating R
do "./Code/Elas_Part2_Nominal.do"

// merge naics/year comp/va, K/va data with nominal return data
do "./Code/Elas_Part2_MergeNominal.do"

// - produces file "./Work/USA_scenario_baseline.dta" that is used for scenarios in Part 3

////////////////////////////////////////////////////////////////////////
// Part 3 - pulls in merged naics/year file from Part 2
//        - call script to load programs used in elasticity calcs
//        - run script that calculates elasticities in different scenarios/samples
//        - run script that calculates markups in different scenarios/samples
//
// MUST BE RUN IN ORDER SHOWN
////////////////////////////////////////////////////////////////////////
do "./Code/Elas_Part3_Scenarios.do" // creates data file of costs for each scenario in control file

do "./Code/Elas_Part3_MainLoop.do" // evaluate each scenario file, calculate elasticities
do "./Code/Elas_Part3_MergeResults.do" // merge results files from each individual scenario

do "./Code/Elas_Part3_RobustLoop.do" // evaluate main scenarios using BEA total requirement table
do "./Code/Elas_Part3_ImportLoop.do" // evaluate main scenarios excluding imported intermediates
do "./Code/Elas_Part3_BoundLoop.do" // evaluate main scenarios holding Leontief weights constant

do "./Code/Elas_Part3_TFP_Calc.do" // calculate alternative TFP estimates using elasticities

////////////////////////////////////////////////////////////////////////
// Part 4 - reporting and figures
//        - pulls in results files from different scenarios
// 
// CAN BE RUN IN ANY ORDER
////////////////////////////////////////////////////////////////////////

// these are for main paper
do "./Code/Elas_Part4_FigBaseline.do" // Figures 1 and 2. main script for main figures comparing assumptions
do "./Code/Elas_Part4_FigRatios.do" // Figure 3. comparison of cost ratios and elasticities
do "./Code/Elas_Part4_FigPrivBus.do" // Figure 4. private business only
do "./Code/Elas_Part4_FigCapitalType.do" // Figure 5. elasticities for diff capital types
do "./Code/Elas_Part4_FigNoIP.do" // Figure 6. de-capitalized IP
do "./Code/Elas_Part4_FigDLEU.do" // Figure 7. using Compustat estimates
do "./Code/Elas_Part4_FigMarkupDLEU.do" // Figures 8 and A.5. markups under different assumptions
do "./Code/Elas_Part4_FigTFP.do" // Figure 9. comparison of TFP under different assumptions

// these are for main paper
do "./Code/Elas_Part4_TabBaseline.do" // Table 2. main table of summary stats
do "./Code/Elas_Part4_TabCapitalType.do" // Table 3. summ table for diff cap types
do "./Code/Elas_Part4_TabTFP.do" // Table 4. table of TFP growth by decade

// these are for appendix
do "./Code/Elas_Part4_FigPropInc.do" // Figure A.1. diff prop income treatments
do "./Code/Elas_Part4_FigMarkCap.do" // Figures A.2 and A.3. comparing markups to capital cost shares
do "./Code/Elas_Part4_FigBounds.do" // Figure A.4 comparing results holding Leontief weights constant
do "./Code/Elas_Part4_FigOlleyPakes.do" // Figure A.6. Olley-Pakes decomp of elasticity figure 
do "./Code/Elas_Part4_FigBreaks.do" // Figure A.7. show baseline with series breaks noted
do "./Code/Elas_Part4_FigGovCapital.do" // Figure A.8. comparing assumptions on govt user costs
do "./Code/Elas_Part4_FigNegCost.do" // Figure A.9. excluding negative costs

// these are for appendix
do "./Code/Elas_Part4_TabMatch.do" // Tables A.2 through A.7 table of matches from NAICS to BEA
do "./Code/Elas_Part4_TabRobust.do" // Tables A.8 and A.9 comparing to BEA total requirements table results
do "./Code/Elas_Part4_TabImport.do" // Tables A.10 and A.11 comparing to results excluding imports
do "./Code/Elas_Part4_TabCosts.do" // Table A.12 summary table of cost ratios
do "./Code/Elas_Part4_TabHouseGov.do" // Table A.13 cost ratios for Gov and housing
do "./Code/Elas_Part4_TabAnnual.do" // Tables A.14 through A.17 annual estimates for baseline

// numeric results for paper
do "./Code/Elas_Part4_NumBasics.do" // writes basic summary stats to Tex tags for paper
do "./Code/Elas_Part4_NumVA.do" // summary stats on correlation of Value-added between BEA and my calc

