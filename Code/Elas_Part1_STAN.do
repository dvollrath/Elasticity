/*
Pull in STAN database on OECD industries
Save as CSV files for use in matching/mergin
*/

import delimited using "./Data/OECD/STAN_2020Ed_ISIC4/DATA.txt", delimiter("|") clear varnames(1)

export delimited using "./CSV/OECD_STAN4_7018_all.csv", replace


import delimited using "./Data/OECD/STAN_2008Ed_ISIC3/DATA.txt", delimiter("|") clear varnames(1)

export delimited using "./CSV/OECD_STAN3_7005_all.csv", replace
