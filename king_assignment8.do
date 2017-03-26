capture log close
log using "king_assignment8.log", replace

set more off

/*Teacher Mobility and Racial Congruence*/
/*Robert King*/
/*March 26, 2017*/

/*Set Directory*/
global in "/fs0/TNCRED_Projects/TNCRED_Projects_Mobility/Mobility I/Data"
use "/fs0/TNCRED_Projects/TNCRED_Projects_Mobility/Data/mobility_tchlvl_analysisfile.dta", clear

global workdir `c(pwd)'

/*Note missing data in the dataset*/
mdesc

/*Create a dataset with the information I want using preserve and restore*/
preserve

keep year deident_tchnum districtno sch_id tch_yrsexp tch_salaryamt tch_ethnicity ///
	tch_female tch_age sch_type sch_ulocal sch_status sch_high_poverty sch_high_minority ///
	tch_edlevel_BA tch_edlevel_MA tch_edlevel_PHD ///
	left_school2 left_d_wis2 left_district2 left_s_wid2 left_s_wis2 left_state2
	
/*Change teacher ethnicity from categorical to numerical*/
encode tch_ethnicity, generate (ntch_ethnicity)

drop tch_ethnicity

mdesc

* Set local for variables to drop missing observations from
local dropmisvar year deident_tchnum districtno sch_id tch_yrsexp tch_salaryamt ///
	ntch_ethnicity tch_female tch_age sch_ulocal sch_status ///
	sch_high_poverty sch_high_minority

* Drop missing data in local
foreach var of local dropmisvar {
	drop if `var'==.
	}
	
mdesc

save "mobility_king", replace

restore

use mobility_king

/*Create a variable for racial congruence*/
gen tch_minority=1 if ntch_ethnicity==1|2|3|4|5|6
replace tch_minority=0 if ntch_ethnicity==7

drop if year > 2014

/*1. Using your own dataset, run a regression using a continuous variable as your 
dependent variable and several regressors. Report the results of at least two model 
specifications in a nice table.*/

local control_1 i.tch_female tch_age i.tch_minority
local control_2 i.tch_female tch_age i.tch_minority i.sch_ulocal i.sch_high_poverty i.sch_high_minority

eststo model_1: reg tch_salaryamt `control_1'
eststo model_2: reg tch_salaryamt `control_2'

/*2. Test for collinearity in the model. Describe the results of your test and 
say what you have decided to do as a result.*/

estimates restore model_1
estat vif
eststo model_1_col, title("Model 1: Collinearity")

estimates restore model_2
estat vif
eststo model_2_col, title("Model 2: Collinearity")

/*3. Test for heteroskedacity in the model. Describe the results of your test 
and say what you have decided to do as a result.*/

estimates restore model_1
estat hettest, iid
estat hettest `control_1', iid

eststo model_1_robust: reg tch_salaryamt `control_1', robust

estimates restore model_2
estat hettest, iid
estat hettest `control_2', iid

eststo model_2_robust: reg tch_salaryamt `control_2', robust 
exit
/*5. Check on the functional form of your model using graphical approaches. 
Include some of these graphics in your paper.*/

graph twoway scatter tch_salaryamt tch_age, msize(tiny)|| lowess tch_salaryamt tch_age, name(lowess_plot)
graph export lowess.pdf, replace

graph twoway scatter tch_salaryamt tch_age, msize(tiny)|| lowess tch_salaryamt tch_age ///
	||lfit tch_salaryamt tch_age, name(lfit_plot)
graph export lfit.pdf, replace

log close
exit
