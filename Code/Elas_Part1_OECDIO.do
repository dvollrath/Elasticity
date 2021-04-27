/*
Pull in OECD I/O data by country/year
Save as separate CSV files for processing
*/

local fileList : dir "./Data/OECD/IO_2018Ed_ISIC4" files "???????ttl.csv"

foreach file of local fileList { // for each of the IO files
	insheet using "./Data/OECD/IO_2018Ed_ISIC4/`file'", names clear
	
	rename v1 code // industry code for I/O table
	keep code d* // keep only the dcode and d????? variables that are part of I/O table (drop Inv, Cons, etc..)
	
	// drop summary measures and international adjustments, keep only the I/O entries
	drop if inlist(code,"TXS_INT_FNL","TXS_IMP_FNL","TTL_INT_FNL","OUTPUT")
	
	mkmat d*, matrix(TEMP) rownames(code)
	drop d* // drop the original columns
	mat cost = TEMP' // transpose the matrix
	svmat cost, names(matcol) // save back columns with cost data
	gen sortorder = _n // ensure matrix can be sorted back into order after merge 
	
	drop if code=="VALU" // orphan row without data
	replace code = substr(code,5,.) // remove the TTL_ prefix so can match to STAN
	rename code dcode // rename to match STAN
	rename costVALU dVALU // rename to avoid cost prefix
	
	replace dcode="09" if dcode=="9" // make sure dcode uses same double-digit terminology as STAN
	
	local newname = substr("`file'",1,7)
	export delimited "./CSV/OECD_`newname'_io_2018Ed.csv", replace // save io file to CSV folder
}

/*
Similar process for 2015 edition using ISIC 3
*/

local fileList : dir "./Data/OECD/IO_2015Ed_ISIC3" files "???????ttl.csv"

foreach file of local fileList { // for each of the IO files
	insheet using "./Data/OECD/IO_2015Ed_ISIC3/`file'", names clear
	
	rename v1 id // industry code for I/O table
	drop cons_abr cons_nonres // lose these VA categories
	keep id c* // keep only the dcode and d????? variables that are part of I/O table (drop Inv, Cons, etc..)
	
	// drop summary measures and international adjustments, keep only the I/O entries
	//capture drop hfce npish ggfc gfcf invnt cons_abr cons_nonres expo impo
	drop if inlist(id,"OUTPUT","TXS_INT_FNL","TTL_INT_FNL")
	
	mkmat c*, matrix(TEMP) rownames(id)
	drop c* // drop the original columns
	mat cost = TEMP' // transpose the matrix
	svmat cost, names(matcol) // save back columns with cost data
	gen sortorder = _n // ensure matrix can be sorted back into order after merge 
	
	rename id dcode // to match standard from 2018 edition
	drop if dcode=="VALU" // orphan row without data
	replace dcode = substr(dcode,6,.) // remove the TTL_ prefix so can match to STAN
	rename costVALU dVALU // rename to avoid cost prefix
	
	replace dcode="09" if dcode=="9" // make sure dcode uses same double-digit terminology as STAN
	
	drop if dcode=="95" // drop information for household workeres
	drop costTTL_C95 // drop column for household workers
	
	local newname = substr("`file'",1,7)
	export delimited "./CSV/OECD_`newname'_io_2015Ed.csv", replace // save io file to CSV folder
}
