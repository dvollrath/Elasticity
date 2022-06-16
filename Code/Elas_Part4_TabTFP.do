/*
Table of TFP growth results by decade
*/

use "./Work/USA_tfp_scenario.dta", clear

// Create file to hold table rows
capture file close f_result
file open f_result using "./Drafts/tab_tfp_scenario.txt", write replace

// Program to write common information to output file, given a scenario/sample
capture program drop file_calc
program file_calc
	sort year
	
	local max = _N
	
	summ level_elas if _n==1, det // first year
	local init_level = r(mean)
	summ level_elas if _n==`max', det // last year
	local last_level = r(mean)
	summ year if _n==1
	local init_year = r(mean)
	summ year if _n==`max'
	local last_year = r(mean)
	
	local rate = 100*(ln(`last_level')-ln(`init_level'))/(`max'-1)
	
	file write f_result "&" %9.2f (`rate')
end

forvalues y = 1950(10)2010 {
	local end = `y'+9
	summ year if inrange(year,`y',`end')
	local end = r(max)
	file write f_result %4.0f (`y') "-" %4.0f (`end')
	foreach s in 5 8 7 6 {
		preserve
			keep if scenario==`s' // limit dataset
			keep if inrange(year,`y',`end')
			file_calc // call program to make calculations and write to file
		restore
	}
	file write f_result "\\" _n
}

local y = 1948
local end = 2018

file write f_result "\\" _n
file write f_result %4.0f (`y') "-" %4.0f (`end')
foreach s in 5 8 7 6 {
	preserve
		keep if scenario==`s' // limit dataset
		keep if inrange(year,`y',`end')
		file_calc // call program to make calculations and write to file
	restore
}
file write f_result "\\" _n


capture file close f_result
