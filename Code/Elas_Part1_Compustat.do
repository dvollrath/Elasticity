/*
Import Compustat-based markups from Edmonds et al for comparison later
*/

// import just raw data - will apply labels in this code
import excel using "./Data/USA/sales_and_cost_weighted_markups.xlsx", ///
	clear sheet("Sheet1") cellrange(A4:E68)
	
drop B D // empty
rename A year
rename C markup_emx_sales
rename E markup_emx_cost

export delimited using "./CSV/USA_compustat_markup.csv", replace
