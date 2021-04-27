/*
Import BEA inflation data by capital type
This data is not specific to industries
Prepare file with year rows, columns of inflation in diff capital types
*/

freduse A009RV1A225NBEA Y033RV1A225NBEA Y001RV1A225NBEA A011RV1A225NBEA, clear

gen year = year(daten)
rename A009RV1A225NBEA infST00 // non-res structures
rename Y033RV1A225NBEA infEQ00 // equipment
rename Y001RV1A225NBEA infIP00 // IP
rename A011RV1A225NBEA infRES // res structures

replace infST00 = infST00/100 // put in decimal form
replace infEQ00 = infEQ00/100
replace infIP00 = infIP00/100
replace infRES = infRES/100

drop date daten

save "./Work/USA_ann3019_kinflation.dta", replace

