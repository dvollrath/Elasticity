/*
Create table of results comparing estimates w/ and w/o imports, by assumption
*/

// Create file to hold table rows
capture file close f_result1
file open f_result1 using "./Drafts/tab_import_summary1.txt", write replace
capture file close f_result2
file open f_result2 using "./Drafts/tab_import_summary2.txt", write replace

	use "./Work/USA_scenario_import_results_all.dta", clear
	keep if inrange(year,1997,2018)

	gen tr_cap = elas_st + elas_eq + elas_ip

	keep tr_cap year scenario
	save "./Work/USA_tr_table_trdata.dta", replace
	
	use "./Work/USA_scenario_annual_results_all.dta", clear
	keep if inrange(year,1997,2018)
	capture drop elas_cap
	gen elas_cap = elas_st + elas_eq + elas_ip

	merge 1:1 year scenario using "./Work/USA_tr_table_trdata.dta"
	keep if _merge==3
	
	gen diff = tr_cap - elas_cap
	
forvalues y = 1997(1)2018 {
	foreach i in 1 2 3 4 {
		summ tr_cap if year==`y' & scenario==`i'
		local tr_`i' = r(mean)
		summ elas_cap if year==`y' & scenario==`i'
		local elas_`i' = r(mean)
		summ tr_cap if scenario==`i'
		local tr_mean_`i' = r(mean)
		summ elas_cap if scenario==`i'
		local elas_mean_`i' = r(mean)
		summ diff if scenario==`i'
		local diff_mean_`i' = r(mean)
	}
	
	file write f_result1 (`y') " & " %9.4f (`tr_1') " & " %9.4f (`elas_1') " & "  %9.4f (`tr_1'-`elas_1') " & " %9.4f (`tr_2') " & " %9.4f (`elas_2') " & " %9.4f (`tr_2'-`elas_2') "\\" _n
	file write f_result2 (`y') " & " %9.4f (`tr_3') " & " %9.4f (`elas_3') " & "  %9.4f (`tr_3'-`elas_3') " & " %9.4f (`tr_4') " & " %9.4f (`elas_4') " & " %9.4f (`tr_4'-`elas_4') "\\" _n
	
}
file write f_result1 "\\" _n
file write f_result1 "Mean & " %9.4f (`tr_mean_1') " & " %9.4f (`elas_mean_1') " & " %9.4f (`diff_mean_1') " & " %9.4f (`tr_mean_2') " & " %9.4f (`elas_mean_2') " & " %9.4f (`diff_mean_2') "\\" _n
file write f_result2 "\\" _n
file write f_result2 "Mean & " %9.4f (`tr_mean_3') " & " %9.4f (`elas_mean_3') " & " %9.4f (`diff_mean_3') " & " %9.4f (`tr_mean_4') " & " %9.4f (`elas_mean_4') " & " %9.4f (`diff_mean_4') "\\" _n


capture file close f_result1
capture file close f_result2
