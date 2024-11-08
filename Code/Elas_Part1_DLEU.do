/*
Import data on cost shares and production function coefficients from De Loecker Eeckout Unger
*/

/* 
This is a dumb script, on purpose. The necessary coefficients frmo DLEU were prepared from their replication package 
available at https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/5GH8XO

That code depends on restricted data from Compustat. I obtained that data extract through WRDS according to DLEU instructions 
and used the DLEU replication code to recover their estimates of coefficients. That output was saved.

All this does is pull in those replicated coefficients, which are *not* restricted and saves for further use in the CSV folder.
			
*/

import delimited using "./Data/USA/USA_DLEU_theta.csv", clear

/*
Variables:
year
ind2d - 2-digit NAICS code
sale_d - nominal sales for industry
cogs_d - nominal cost of goods sold for industry
xsga_d - nominal cost of sales, general, admin industry
kexp - capital stock for industry
theta_wi1_ct - non-capital elasticity
theta_wi1_kt - capital elasticity 
theta_wi2_ct - non-capital elasticity
theta_wi2_xt - xgsa elasticity
theta_wi2_kt - capital elasticity 
ratio_dleu_pf1_cap_noncap  - ratio of capital to non-capital elasticity (DLEU prod fct 1 estimate)
ratio_dleu_pf2_cap_noncap - ratio of capital to non-capital elasticity (DLEU prod fct 2 estimate)
ratio_dleu_cs_cap_noncap - ratio of capital to non-capital cost shares (DLEU cost share approach)
ratio_dleu_ps_profits_go - ratio of profits to sales (DLEU profit share approach 2) (sale_D - cogs_D - xsga_D - kexp)/sale_D
*/
export delimited using "./CSV/USA_DLEU_theta.csv", replace

