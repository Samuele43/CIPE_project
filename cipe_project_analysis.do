* the following analysis will use the dataset built in cipe_project_clean_main.do 

* NOTE: To avoid execution errors, please run each section ( separated by * rows) individually. This prevents memory or macro conflicts in stata 

* Set project root (user must modify only this line)
global ROOT "/Users/samuele/Desktop/CIPE_Project"
cd "$ROOT"


* create the proper ds for did 

* Netherlands

use "data_clean/nl_lfpr_clean_main.dta", clear
keep if year >= 1960
gen country = "NL"
gen lf_tot = lab_for_total_ne
gen lf_m   = lab_for_male_ne
gen lf_f   = lab_for_female_ne
keep year country lf_tot lf_m lf_f
save "data_clean/nl_temp.dta", replace
browse

* Denmark

use "data_clean/dk_lfpr_clean_main.dta", clear
gen country = "DK"
gen lf_tot = lfpr_total_dk
gen lf_m   = lfpr_male_dk
gen lf_f   = lfpr_female_dk
keep year country lf_tot lf_m lf_f


* final ds


append using "data_clean/nl_temp.dta"

sort  year

save "data_clean/final_data.dta", replace




**** DID ANALYSIS

encode country, gen(country_id)
xtset country_id year

gen treated = (country == "NL")
gen post73 = (year >= 1973)
gen post67 = year >= 1967

gen treat_post67 = treated * post67
gen treat_post73 = treated * post73

preserve
keep year country_id lf_m lf_f treated post73 post67

browse


* interrupted time series

gen t = year - 1960



* avoid multicollinearity

gen t67 = max(0, year - 1967)
gen t73 = max(0, year - 1973)

* interaction terms (change in slope)

reg lf_m t t67 t73, robust





* parallel trend assumption test

reg lf_tot c.year##treated if year < 1967
reg lf_f c.year##treated if year < 1967
reg lf_m c.year##treated if year < 1967




* placebo test

gen post_fake = (year >= 1965)
gen did_fake = treated*post_fake

reg lf_tot treated##post_fake i.year
reg lf_m treated##post_fake i.year
reg lf_f treated##post_fake i.year

*first did

reg lf_tot treated##post67 treated##post73 i.year, robust

reg lf_f treated##post67 treated##post73 i.year, robust
reg lf_m treated##post67 treated##post73 i.year, robust



*  we allow trends to diverge

gen t = year

reg lf_m treated##post67 treated##post73 i.year c.t#treated, robust

reg lf_f treated##post67 treated##post73 i.year c.t#treated, robust

reg lf_tot treated##post67 treated##post73 i.year c.t#treated, robust



* DDD 

* test assumptions



gen diff_mf = lf_m - lf_f

display "== Parallel Trends Test Difference M-F =="
reg diff_mf c.year##treated if year < 1967



* final reshape




reshape long lf_, i(year country_id) j(sex) string
rename lf_ lf
gen female = (sex=="f")



* final ddd




xtreg lf ///
    treated##post67##female ///
    treated##post73##female ///
    , fe robust



* EVENT STUDY

* policy year

gen rel_year = year - 1967

* dummies


forvalues i = -10/10 {
    local j = `i'
    if `i' < 0 local j = abs(`i')  
    if `i' < 0 {
        gen rel_neg`j' = (rel_year == `i') & treated
    }
    else if `i' != -1 {
        gen rel_`i' = (rel_year == `i') & treated
    }
}





* male event study



xtreg lf rel_neg10 rel_neg9 rel_neg8 rel_neg7 rel_neg6 rel_neg5 rel_neg4 rel_neg3 rel_neg2 ///
      rel_0 rel_1 rel_2 rel_3 rel_4 rel_5 rel_6 rel_7 rel_8 rel_9 rel_10 ///
      if sex=="m", fe robust

matrix b_m = e(b)





* female event study

xtreg lf rel_neg10 rel_neg9 rel_neg8 rel_neg7 rel_neg6 rel_neg5 rel_neg4 rel_neg3 rel_neg2 ///
      rel_0 rel_1 rel_2 rel_3 rel_4 rel_5 rel_6 rel_7 rel_8 rel_9 rel_10 ///
      if sex=="f", fe robust

matrix b_f = e(b)



*final graph  ( install before the pakage)

ssc install coefplot, replace

* 

coefplot (matrix(b_m), label("Male")) ///
         (matrix(b_f), label("Female")), vertical yline(0) ///
         title("Event Study: Wao Effect by Sex") ///
         xlabel(-10(2)10) ylabel(, angle(horizontal)) ///
         legend(position(6))
graph export "output/event_study67cutoff.pdf", replace


