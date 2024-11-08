/*
Create table of annual results, by assumption
*/


foreach s in 1 2 3 4 38 39 {
	use "./Work/USA_scenario_`s'_annual_results.dta", clear
	keep if inrange(year,1948,2018)

	local name = ctrl_capital[1]
	capture file close f_result
	file open f_result using "./Drafts/tab_elas_`name'_annual.txt", write replace

	sort year
	
	local max = _N/2+1
	forvalues y = 1(1)`max' {
		file write f_result (year[`y']) " & " %9.4f (elas_comp[`y']) " & " %9.4f (elas_st[`y']) " & " %9.4f (elas_eq[`y']) " & " %9.4f (elas_ip[`y']) ///
		" & "  (year[`y'+`max']) " & " %9.4f (elas_comp[`y'+`max']) " & " %9.4f (elas_st[`y'+`max']) " & "  %9.4f (elas_eq[`y'+`max']) " & "  %9.4f (elas_ip[`y'+`max']) "\\" _n
	}

	capture file close f_result
}
