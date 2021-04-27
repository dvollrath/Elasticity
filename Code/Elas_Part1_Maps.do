/*
Create CSV files for sic-to-naics maps
*/

import excel using "./Data/USA/USA_sic72_naics_map.xlsx", ///
	clear sheet("USA_sic72_naics_map") firstrow
export delimited "./CSV/USA_sic72_naics_map.csv", replace

import excel using "./Data/USA/USA_sic87_naics_map.xlsx", ///
	clear sheet("USA_sic87_naics_map") firstrow
export delimited "./CSV/USA_sic87_naics_map.csv", replace

import excel using "./Data/USA/USA_bea_naics_map.xlsx", ///
	clear sheet("bea_naics_map") firstrow
export delimited "./CSV/USA_bea_naics_map.csv", replace

import excel using "./Data/USA/USA_bea_naics_map.xlsx", ///
	clear sheet("bea_return_map") firstrow
export delimited "./CSV/USA_bea_return_map.csv", replace

import excel using "./Data/USA/USA_bea_naics_map.xlsx", ///
	clear sheet("bea_labor_map") firstrow
export delimited "./CSV/USA_bea_labor_map.csv", replace

import excel using "./Data/USA/USA_bea_naics_map.xlsx", ///
	clear sheet("naics_collapse") firstrow
export delimited "./CSV/USA_naics_collapse_map.csv", replace
