/*
Figures for TFP level
*/

use "./Work/USA_tfp_scenario.dta", clear

xtset scenario year
gen ma_dtfp_elas = (F2.dtfp_elas + F1.dtfp_elas + dtfp_elas + L1.dtfp_elas + L2.dtfp_elas)/5

capture drop dtfpCycle dtfpTrend
tsfilter hp dtfpCycle = dtfp_elas, trend(dtfpTrend) smooth(40) // HP filter the dtfp series. smoothing of 40 is by trial and error

twoway line ma_dtfp_elas year if scenario==5 & inrange(year,1951,2015), lpattern(dash) lcolor(gs13) ///
	|| line ma_dtfp_elas year if scenario==6 & inrange(year,1951,2015), lpattern(solid) lcolor(gs13) ///
	|| line ma_dtfp_elas year if scenario==38 & inrange(year,1958,2013), lpattern(shortdash) lcolor(gs13) ///
	|| line dtfpTrend year if scenario==5 & inrange(year,1951,2015), lpattern(dash) lcolor(black) ///
	|| line dtfpTrend year if scenario==6 & inrange(year,1951,2015), lpattern(solid) lcolor(black) ///
	|| scatter dtfpTrend year if scenario==38 & inrange(year,1958,2013), msymbol(dh) mcolor(black) msize(small) connect(line) lcolor(black) ///
	xlabel(1950(5)2015) ylabel(-.5(0.5)3.5, format(%4.1f)) ///
	graphregion(color(white)) ///
	legend(ring(0) position(7) cols(1) order(- "Capital cost assumption:" 4 "No-profit/BLS baseline" 5 "Depreciation cost" 6 "Compustat based prod. fct.")) ///
	text(-.1 2005 "5-year centered moving averages in gray" "HP-filtered trend in black", size(small)) ///
	xtitle("Year") ytitle("Growth rate of TFP (percent)")
graph export "./Drafts/fig_tfp_comparison.eps", as(eps) replace fontface("Times New Roman")

summ level_elas if scenario==5 & year==2018
summ level_elas if scenario==6 & year==2018
summ dtfp_elas if scenario==38

	
summ dtfpTrend if scenario==5 & year==1990
local pre = r(mean)
summ dtfpTrend if scenario==5 & year==2000
local max = r(mean)
summ dtfpTrend if scenario==5 & year==2010
local post = r(mean)
local rise = `max' - `pre'
local fall = `post' - `max'
di "No-profit rise: `rise'"
di "No-profit fall: `fall'"

summ dtfpTrend if scenario==6 & year==1990
local pre = r(mean)
summ dtfpTrend if scenario==6 & year==2000
local max = r(mean)
summ dtfpTrend if scenario==6 & year==2010
local post = r(mean)
local rise = `max' - `pre'
local fall = `post' - `max'
di "Depreciation rise: `rise'"
di "Depreciation fall: `fall'"


summ dtfpTrend if scenario==38 & year==1990
local pre = r(mean)
summ dtfpTrend if scenario==38 & year==2000
local max = r(mean)
summ dtfpTrend if scenario==38 & year==2010
local post = r(mean)
local rise = `max' - `pre'
local fall = `post' - `max'
di "Compustat rise: `rise'"
di "Compustat fall: `fall'"

// Side-figure for blog post
twoway line ma_dtfp_elas year if scenario==5 & inrange(year,1951,2015), lpattern(dash) lcolor(gs13) ///
	|| line dtfpTrend year if scenario==5 & inrange(year,1951,2015), lcolor(black) ///
	xlabel(1950(5)2015) ylabel(-.5(0.5)3.5, format(%4.1f)) ///
	legend(off) ///
	text(-.1 2005 "5-year centered moving averages in gray" "HP-filtered trend in black", size(small)) ///
	xtitle("Year") ytitle("Growth rate of TFP (percent)") ///
	xline(1963) xline(1980) xline(2000) ///
	text(3 1968 "First boomers" "hit age eighteen", size(small)) ///
	text(3 1985 "First boomers" "hit age thirty-five", size(small)) ///
	text(3 2005 "First boomers" "hit age fifty-five", size(small))
graph export "./Drafts/fig_tfp_simple.png", as(png) replace
