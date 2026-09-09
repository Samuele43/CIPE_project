* Set project root (user must modify only this line)
global ROOT "/Users/samuele/Desktop/CIPE_Project"



****************************************************
* Labour Force data Netherlands
* Author: Samuele Magatti
* Data source: Statistics Netherlands (CBS) statline archive
* Table:  Labor force: 1800-2013 (12-hour threshold) by sex
* Years: 1951–1985
* Variable: Gross labor partecipation 
* Downloaded: March 2026
****************************************************

cd "$ROOT"
import delimited "data_raw/nl_employment_1960_1983.csv", clear

* reaname variables

rename periods year
rename grosslabourparticipation lab_for
rename personalcharacteristics pers_char

* drop and reshape the dataset

drop pers_char

destring year, replace

encode sex, gen(sex_id)

drop sex
reshape wide lab_for, i(year) j(sex_id)

describe

rename lab_for1 lab_for_male_ne
rename lab_for2 lab_for_total_ne
rename lab_for3 lab_for_female_ne

destring lab_for_total_ne, replace dpcomma
destring lab_for_male_ne, replace dpcomma
destring lab_for_female_ne, replace dpcomma

label variable lab_for_total_ne  "Netherlands Labour Force Participation Rate - Total"
label variable  lab_for_male_ne  "Netherlands Labour Force Participation Rate - Men"
label variable  lab_for_female_ne "Netherlands Labour Force Participation Rate - Women"
label variable year "Year"

order year lab_for_total_ne lab_for_male_ne lab_for_female_ne

sort year

* save the new dataset

save "data_clean/nl_lfpr_clean_main.dta", replace

browse

* plotting the data

twoway ///
(line  lab_for_total_ne year, lwidth(medthick)) ///
, ///
title("Labour Force Participation Rate - Netherlands") ///
ytitle("Percent") ///
xtitle("Year") ///
xline(1967 1973 1979, lpattern(dash)) ///
text(55 1967 "WAO introduced", place(e)) ///
text(55 1973 "First Oil Crisis", place(e)) ///
text(55 1979 "Second Oil Crisis", place(e)) ///
legend(off)
graph export "output/nl_lfpr_total.pdf", replace


twoway ///
(line   lab_for_male_ne year, lwidth(medthick)) ///
, ///
title("Male Labour Force Participation Rate - Netherlands") ///
ytitle("Percent") ///
xtitle("Year") ///
xline(1967 1973 1979, lpattern(dash)) ///
text(70 1967 "WAO introduced", place(e)) ///
text(70 1973 "First Oil Crisis", place(e)) ///
text(70 1979 "Second Oil Crisis", place(e)) ///
legend(off)
graph export "output/nl_lfpr_male.pdf", replace


twoway ///
(line  lab_for_female_ne year, lwidth(medthick)) ///
, ///
title("Female Labour Force Participation Rate - Netherlands") ///
ytitle("Percent") ///
xtitle("Year") ///
xline(1967 1973 1979, lpattern(dash)) ///
text(31 1967 "WAO introduced", place(e)) ///
text(31 1973 "First Oil Crisis", place(e)) ///
text(31 1979 "Second Oil Crisis", place(e)) ///
legend(off)
graph export "output/nl_lfpr_female.pdf", replace


* keep the useful part for the confrontation 

use "data_clean/nl_lfpr_clean_main.dta", clear
keep if year >= 1960


****************************************************
* Labour Force Rate – Denmark
* Author: Samuele Magatti
* Data source: Federal Reserve Bank of St. Louis (FRED)
* Tables: Labour Force Total 
*   Total Population 
*   Working-age population share (% ages 15-64)
* Years: 1960–1985
* Downloaded: March 2026
****************************************************



**** IMPORT TOTAL LABOR FORCE


import delimited "data_raw/dk_tot_lf_LFACTTTTDKA647N.csv", clear

* create year variables

gen year = year(date(observation_date,"YMD"))
drop observation_date

*rename variables
rename lfacttttdka647n dk_tot_lf

* interpola missing
ipolate dk_tot_lf year, gen(dk_tot_lf_i)
drop dk_tot_lf
rename dk_tot_lf_i dk_tot_lf

save "data_clean/dk_lf_tot_clean.dta", replace




***** IMPORT MALE LABOR FORCE

 import delimited "data_raw/dk_male_lf_LFACTTMADKA647N .csv", clear

* create year variables

gen year = year(date(observation_date,"YMD"))
drop observation_date

*rename variables
rename lfacttmadka647n dk_male_lf

* interpola missing
ipolate dk_male_lf year, gen(dk_male_lf_i)
drop dk_male_lf
rename dk_male_lf_i dk_male_lf

save "data_clean/dk_lf_male_clean.dta", replace



**** IMPORT FEMALE LABOR FORCE

import delimited "data_raw/dk_female_lf_LFACTTFEDKA647N.csv", clear

* create year variables

gen year = year(date(observation_date,"YMD"))
drop observation_date

*rename variables
rename lfacttfedka647n dk_female_lf

* interpola missing
ipolate dk_female_lf year, gen(dk_female_lf_i)
drop dk_female_lf
rename dk_female_lf_i dk_female_lf

save "data_clean/dk_lf_female_clean.dta", replace




**** IMPORT WORKING AGE POPULATION PERCENTAGE
 
import delimited "data_raw/dk_wap_per_SPPOP1564TOZSDNK.csv", clear


* create year variables

gen year = year(date(observation_date,"YMD"))
drop observation_date

*rename variables
rename sppop1564tozsdnk dk_wap_per

save "data_clean/dk_wap_per_clean.dta", replace




**** IMPORT TOTAL POPULATION 

import delimited "data_raw/dk_pop_tot_POPTOTDKA647NWDB.csv", clear

* create year variables

gen year = year(date(observation_date,"YMD"))
drop observation_date

* rename variables

rename poptotdka647nwdb dk_pop

save "data_clean/dk_pop_clean.dta", replace

************************
*  MERGE THE DATASETS
***********************+

use "data_clean/dk_lf_tot_clean.dta", clear

merge 1:1 year using "data_clean/dk_lf_male_clean.dta"
drop _merge

merge 1:1 year using "data_clean/dk_lf_female_clean.dta"
drop _merge

merge 1:1 year using "data_clean/dk_wap_per_clean.dta"
drop _merge

merge 1:1 year using "data_clean/dk_pop_clean.dta"
drop _merge

browse

* build the rate ( i divided the total population by 2 for male and female rates, in the following computation it is written *200 because it is mathematically the same thing)

gen dk_wap = dk_pop * (dk_wap_per/100)
gen lfpr_total_dk = (dk_tot_lf / dk_wap) * 100
gen lfpr_male_dk = (dk_male_lf / dk_wap) * 200
gen lfpr_female_dk = (dk_female_lf / dk_wap) * 200
keep year lfpr_total_dk lfpr_male_dk lfpr_female_dk
sort year

browse
save "data_clean/dk_lfpr_clean_main.dta", replace

*final merge

use "data_clean/nl_lfpr_clean_main.dta", clear

merge 1:1 year using "data_clean/dk_lfpr_clean_main.dta"
drop _merge
keep if year >= 1960


*rename variables 
rename lab_for_total_ne lf_tot_NE
rename lab_for_male_ne lf_m_NE
rename lab_for_female_ne lf_F_NE
rename lfpr_total_dk lf_tot_DK
rename lfpr_male_dk lf_M_DK
rename lfpr_female_dk lf_F_DK
browse

**** PLOTS

* total

twoway ///
(line lf_tot_NE year, lwidth(medthick)) ///
(line lf_tot_DK year, lwidth(medthick) lpattern(dash)) ///
, ///
title("Labour Force Participation Rate - Total") ///
subtitle("Netherlands vs Denmark") ///
ytitle("Percent") ///
xtitle("Year") ///
legend(label(1 "Netherlands") label(2 "Denmark")) ///
xline(1967 1973 1979, lpattern(dot)) ///
text(55 1967 "WAO introduced", place(e)) ///
text(55 1973 "First Oil Crisis", place(e)) ///
text(55 1979 "Second Oil Crisis", place(e))

graph export "output/lfpr_total_NL_DK.pdf", replace



*male

twoway ///
(line lf_m_NE year, lwidth(medthick)) ///
(line lf_M_DK year, lwidth(medthick) lpattern(dash)) ///
, ///
title("Labour Force Participation Rate - Male") ///
subtitle("Netherlands vs Denmark") ///
ytitle("Percent") ///
xtitle("Year") ///
legend(label(1 "Netherlands") label(2 "Denmark")) ///
xline(1967 1973 1979, lpattern(dot)) ///
text(74 1967 "WAO introduced", place(e)) ///
text(74 1973 "First Oil Crisis", place(e)) ///
text(74 1979 "Second Oil Crisis", place(e))

graph export "output/lfpr_male_NL_DK.pdf", replace



*female

twoway ///
(line lf_F_NE year, lwidth(medthick)) ///
(line lf_F_DK year, lwidth(medthick) lpattern(dash)) ///
, ///
title("Labour Force Participation Rate - Female") ///
subtitle("Netherlands vs Denmark") ///
ytitle("Percent") ///
xtitle("Year") ///
legend(label(1 "Netherlands") label(2 "Denmark")) ///
xline(1967 1973 1979, lpattern(dot)) ///
text(30 1967 "WAO introduced", place(e)) ///
text(30 1973 "First Oil Crisis", place(e)) ///
text(30 1979 "Second Oil Crisis", place(e))

graph export "output/lfpr_female_NL_DK.pdf", replace



