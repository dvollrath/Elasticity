/*
Summary stats of elasticities for different purposes
*/

use "./Work/USA_scenario_annual_results_all.dta", clear // start with file of all annual results
keep if inrange(year,1948,2018)
gen elas_cap = elas_st + elas_eq + elas_ip // generate single measure of capital elasticity

summ elas_cap if scenario==1 & inrange(year,1948,1995) // upper bound
summ elas_cap if scenario==2 & inrange(year,1948,1995) // lower bound

capture file close f_result
file open f_result using "./Drafts/tab_summ_elasticities.tex", write replace

summ elas_cap if scenario==2 & inrange(year,1948,1995) // upper bound
file write f_result "{\newcommand{\baseearlydepr}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==1 & inrange(year,1948,1995) // upper bound
file write f_result "{\newcommand{\baseearlynoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==2 & inrange(year,1996,2018) // lower bound
file write f_result "{\newcommand{\baselatedepr}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==1 & inrange(year,1996,2018) // upper bound
file write f_result "{\newcommand{\baselatenoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==14 // no IP, gov, housing
file write f_result "{\newcommand{\excldepr}{" %3.2f (r(mean)) "}" _n
file write f_result "{\newcommand{\exclmaxdepr}{" %3.2f (r(max)) "}" _n

summ elas_cap if scenario==13 // no IP, gov, housing
file write f_result "{\newcommand{\exclnoprofit}{" %3.2f (r(mean)) "}" _n
file write f_result "{\newcommand{\exclmaxnoprofit}{" %3.2f (r(max)) "}" _n

summ elas_cap if scenario==3 // investment average
file write f_result "{\newcommand{\baseinv}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==10 & inrange(year,1948,1995) // no IP
file write f_result "{\newcommand{\noipearlydepr}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==9 & inrange(year,1948,1995) // no IP
file write f_result "{\newcommand{\noipearlynoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==10 & inrange(year,1996,2018) // no IP
file write f_result "{\newcommand{\noiplatedepr}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==9 & inrange(year,1996,2018) // no IP
file write f_result "{\newcommand{\noiplatenoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==6 & inrange(year,1948,1995) // no IP
file write f_result "{\newcommand{\nohsearlydepr}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==5 & inrange(year,1948,1995) // no IP
file write f_result "{\newcommand{\nohsearlynoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==6 & inrange(year,1996,2018) // no IP
file write f_result "{\newcommand{\nohslatedepr}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==5 & inrange(year,1996,2018) // no IP
file write f_result "{\newcommand{\nohslatenoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_st if scenario==2 // upper bound
file write f_result "{\newcommand{\basestdepr}{" %3.2f (r(mean)) "}" _n

summ elas_st if scenario==1 // upper bound
file write f_result "{\newcommand{\basetnoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_eq if scenario==2 // upper bound
file write f_result "{\newcommand{\baseeqdepr}{" %3.2f (r(mean)) "}" _n

summ elas_eq if scenario==1 // upper bound
file write f_result "{\newcommand{\baseeqnoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_ip if scenario==2 // upper bound
file write f_result "{\newcommand{\baseipdepr}{" %3.2f (r(mean)) "}" _n

summ elas_ip if scenario==1 // upper bound
file write f_result "{\newcommand{\baseipnoprofit}{" %3.2f (r(mean)) "}" _n


summ elas_ip if scenario==2 & inrange(year,1948,1960) // upper bound
file write f_result "{\newcommand{\baseipearlydepr}{" %3.2f (r(mean)) "}" _n

summ elas_ip if scenario==1 & inrange(year,1948,1960) // upper bound
file write f_result "{\newcommand{\baseipearlynoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_ip if scenario==2 & inrange(year,2000,2018) // upper bound
file write f_result "{\newcommand{\baseiplatedepr}{" %3.2f (r(mean)) "}" _n

summ elas_ip if scenario==1 & inrange(year,2000,2018) // upper bound
file write f_result "{\newcommand{\baseiplatenoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==1 & year==1948 // upper bound
file write f_result "{\newcommand{\basefirstnoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==1 & year==2018 // upper bound
file write f_result "{\newcommand{\baselastnoprofit}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==2 & year==1948 // upper bound
local basefirstdepr = r(mean)
file write f_result "{\newcommand{\basefirstdepr}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==2 & year==2018 // upper bound
local baselastdepr = r(mean)
file write f_result "{\newcommand{\baselastdepr}{" %3.2f (r(mean)) "}" _n

file write f_result "{\newcommand{\basediffdepr}{" %3.2f (`baselastdepr'-`basefirstdepr') "}" _n

summ elas_cap if scenario==3 & year==1948 // upper bound
file write f_result "{\newcommand{\basefirstinv}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==3 & year==2018 // upper bound
file write f_result "{\newcommand{\baselastinv}{" %3.2f (r(mean)) "}" _n

summ elas_cap if scenario==1  // upper bound
file write f_result "{\newcommand{\basemednoprofit}{" %4.3f (r(p50)) "}" _n

summ elas_cap if scenario==2  // upper bound
file write f_result "{\newcommand{\basemeddepr}{" %4.3f (r(p50)) "}" _n

summ elas_cap if scenario==1 
file write f_result "{\newcommand{\basemeannoprofit}{" %4.3f (r(mean)) "}" _n
file write f_result "{\newcommand{\baseminnoprofit}{" %4.3f (r(min)) "}" _n
file write f_result "{\newcommand{\basemaxnoprofit}{" %4.3f (r(max)) "}" _n

summ elas_cap if scenario==13


file close f_result


