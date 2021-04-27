/*
Figures for comparison of Olley-Pakes decomposition
*/

use "./Work/USA_scenario_sample_industry.dta", clear

keep if inrange(year,1948,2018)

gen Lcap = Lcost_st+Lcost_eq+Lcost_ip // Leontief entry for capital as a whole

bysort year scenario sample prop ip: egen iovashare_mean = mean(iovashare)
bysort year scenario sample prop ip: egen Lcap_mean = mean(Lcap)
bysort year scenario sample prop ip: egen Lcomp_mean = mean(Lcost_comp)
gen covar_term = (iovashare - iovashare_mean)*(Lcap - Lcap_mean)
gen covar_comp_term = (iovashare - iovashare_mean)*(Lcost_comp - Lcomp_mean)
bysort year scenario sample prop ip: egen covariance = total(covar_term)
bysort year scenario sample prop ip: egen covar_comp = total(covar_comp_term)

gen mult_term = iovashare*Lcap
gen comp_term = iovashare*Lcost_comp
bysort year scenario sample prop ip: egen elasticity_cap = total(mult_term)
bysort year scenario sample prop ip: egen elasticity_comp = total(comp_term)

// Plot bounds with Lmean
twoway line elasticity_cap year if sample=="all" & prop=="split" & scenario=="deprcost" & ip=="ip", lcolor(black) /// lwidth(medthick) ///
	|| line elasticity_cap year if sample=="all" & prop=="split" & scenario=="noprofit" & ip=="ip", lcolor(black) lpattern(dash) /// lwidth(medthick) ///
	|| line Lcap_mean year if sample=="all" & prop=="split" & scenario=="deprcost" & ip=="ip", lcolor(gray) /// lwidth(medthick) ///
	|| line Lcap_mean year if sample=="all" & prop=="split" & scenario=="noprofit" & ip=="ip", lcolor(gray) lpattern(dash) /// lwidth(medthick) ///
	ytitle("Elasticity or mean industry-level elasticity") xtitle("Year") ///
	ylabel(0(.1)1, nogrid format(%9.1f) angle(0)) ///
	xlabel(1950(10)2010 2018) ///
	graphregion(color(white)) ///
	legend(ring(0) pos(10) cols(2) region(lcolor(white)) order( - "No-profit bound:" - "Depreciation cost bound:" 2 "Aggregate elasticity" 1 "Aggregate elasticity" 4 "Mean industry-level elasticity" 3 "Mean industry-level elasticity" ))
graph export "./Drafts/fig_cap_op_comparison.eps", as(eps) replace fontface("Times New Roman")

