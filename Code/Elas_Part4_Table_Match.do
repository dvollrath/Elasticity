/*
Write table of SIC/NAICS matches for appendix
*/

// 47-62 matching
capture file close f_result1
file open f_result1 using "./Drafts/tab_match_sic72_4762part1.txt", write replace
capture file close f_result2
file open f_result2 using "./Drafts/tab_match_sic72_4762part2.txt", write replace

use "./Work/USA_sic72_naics_map.dta", clear

replace sic72text = substr(sic72text,1,40)
replace naics4762text = substr(naics4762text,1,40)

local max = _N
local count = 1
forvalues i = 1(1)`max' {
	local file = 1
	if `count' > 28 {
		local file = 2
	}
	
	if naics4762code[`i']~="" {
		local count = `count' + 1
		file write f_result`file' (sic72[`i']) "&" (sic72text[`i']) "&" ///
			(naics4762code[`i']) "&" (naics4762text[`i']) "\\" _n
	}
}

capture file close f_result1
capture file close f_result2

// 63-86 matching
capture file close f_result1
file open f_result1 using "./Drafts/tab_match_sic72_6386part1.txt", write replace
capture file close f_result2
file open f_result2 using "./Drafts/tab_match_sic72_6386part2.txt", write replace

use "./Work/USA_sic72_naics_map.dta", clear

replace sic72text = substr(sic72text,1,40)
replace naics6396text = substr(naics6396text,1,40)

local max = _N
local count = 1
forvalues i = 1(1)`max' {
	local file = 1
	if `count' > 34 {
		local file = 2
	}
	
	if naics6396code[`i']~="" {
		local count = `count' + 1
		file write f_result`file' (sic72[`i']) "&" (sic72text[`i']) "&" ///
			(naics6396code[`i']) "&" (naics6396text[`i']) "\\" _n
	}
}

capture file close f_result1
capture file close f_result2


// 87-96 matching
capture file close f_result1
file open f_result1 using "./Drafts/tab_match_sic87_8796part1.txt", write replace
capture file close f_result2
file open f_result2 using "./Drafts/tab_match_sic87_8796part2.txt", write replace

use "./Work/USA_sic87_naics_map.dta", clear

replace sic87text = substr(sic87text,1,40)
replace naics6396text = substr(naics6396text,1,40)

local max = _N
local count = 1
forvalues i = 1(1)`max' {
	local file = 1
	if `count' > 34 {
		local file = 2
	}
	
	if naics6396code[`i']~="" {
		local count = `count' + 1
		file write f_result`file' (sic87code[`i']) "&" (sic87text[`i']) "&" ///
			(naics6396code[`i']) "&" (naics6396text[`i']) "\\" _n
	}
}

capture file close f_result1
capture file close f_result2

