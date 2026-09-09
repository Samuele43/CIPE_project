
* Set project root (user must modify only this line)
global ROOT "/Users/samuele/Desktop/CIPE_Project"


*see markdown for dataset origin information

*industry workers

cd "$ROOT"
import delimited "data_raw/nl_industry_workers.csv", clear
browse


* plotting the data

twoway ///
(line  employedpersonsx1000 periods, lwidth(medthick)) ///
, ///
title("Employed persons in industry - Netherlands") ///
ytitle("Employed in thousands") ///
xtitle("Year") ///
xline( 1973 1979, lpattern(dash)) ///
text(875 1973 "First Oil Crisis", place(e)) ///
text(875 1979 "Second Oil Crisis", place(e)) ///
legend(off)


graph export "output/nl_industry_workers.pdf", replace

* sikness absence


import delimited "data_raw/nl_sikness_absence _1950_1985.csv", clear
destring healthstatussicknessabsence, replace dpcomma

browse


* plotting the data

twoway ///
(line  healthstatussicknessabsence periods, lwidth(medthick)) ///
, ///
title("Sikness absence - Netherlands") ///
ytitle("Percentage of total woked hours") ///
xtitle("Year") ///
xline( 1967 1973 1979, lpattern(dash)) ///
text(4 1967 "WAO introduction", place(e)) ///
text(4 1973 "First Oil Crisis", place(e)) ///
text(4 1979 "Second Oil Crisis", place(e)) ///
legend(off)


graph export "output/nl_sikness_absence.pdf", replace




