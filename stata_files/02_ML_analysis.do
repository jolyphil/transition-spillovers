********************************************************************************
* Project: Transition Spillovers
* Task:    Perform the multilevel analysis
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

version 15 
// Version 14 also works, but labels in tables are not displayed properly.
capture log close
capture log using "${logfiles}02_ML_analysis.smcl", replace
set more off

ssc install estout
ssc install coefplot

set scheme minimal

* ______________________________________________________________________________
* Load merged dataset

use "${data}master.dta", clear

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Recode binary variables ("has not done" = 0, "has done" = 1)

recode demonstration (1 = 0) (2 = 1)
recode petition (1 = 0) (2 = 1)
recode boycott (1 = 0) (2 = 1)

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Dummy for Eastern Germany

gen eastde = (country == "DEE")

* ______________________________________________________________________________
* Set survey characteristics

gen one = 1
svyset country, weight(one) || countrywave, weight(one) || _n, weight(dweight)

* ______________________________________________________________________________
* Multilevel models

* Individual-level controls, incorporated in all models
local iv_l1 "i.female agerel i.edu i.unemp i.union i.native i.city i.class5"
local i = 0

foreach dv of varlist demonstration petition boycott {
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Models 1, 4, and 7
	
	local iv "`iv_l1' i.newdem##c.earlyprotest"
	svy, subpop(gen1989): melogit `dv' `iv' || country: || countrywave: 
	est store M_a_`dv'
	local M_a_`dv'_N_sub = e(N_sub) // Number of obs, subpopulation
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Models 2, 5, and 8
	
	local iv "`iv_l1' i.newdem##c.earlyprotest i.eastde"
	svy, subpop(gen1989): melogit `dv' `iv' || country: || countrywave: 
	est store M_b_`dv'
	local M_b_`dv'_N_sub = e(N_sub)
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Models 3, 6, and 9
	
	local iv "`iv_l1' c.earlyprotest##i.newdem i.eastde year lgdp_mean lgdp_diff"
	svy, subpop(gen1989): melogit `dv' `iv' || country: || countrywave: 
	est store M_c_`dv'
	local M_c_`dv'_N_sub = e(N_sub)
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Export RTF Table
	
	local i = `i' + 3 // Last model
	local tabnum = `i' / 3 + 1 // Table number
	local filename "tab`tabnum'_MLM_`dv'.rtf"
	
	do "${programs}export_tab_3MLM_rtf.do" ///
		"M_a_`dv'" ///
		"M_b_`dv'" ///
		"M_c_`dv'" ///
		`M_a_`dv'_N_sub' /// Save number of obs, subpopulation
		`M_b_`dv'_N_sub' ///
		`M_c_`dv'_N_sub' ///
		`i' ///
		"`filename'"
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Export TeX Table
	
	local filename "tab`tabnum'_MLM_`dv'.tex"
	do "${programs}export_tab_3MLM_tex.do" ///
		"M_a_`dv'" /// Save models
		"M_b_`dv'" ///
		"M_c_`dv'" ///
		`M_a_`dv'_N_sub' /// Save subpop. no. obs
		`M_b_`dv'_N_sub' ///
		`M_c_`dv'_N_sub' ///
		`i' /// Save model numbers
		"`filename'"
}

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Adjusted prediction

egen tag_c = tag(country)
gen bar = "|" // Small bars used to display distribution of cases
gen ypos = -0.0175 // Vertical position of the bars

foreach dv of varlist demonstration petition boycott {
* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Restore final models 3, 6, and 9
est restore M_c_`dv'

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Generate adjusted predictions for each protest activity separately 
margins newdem, at(earlyprotest=(0(0.1)0.6)) subpop(gen1989) vce(unconditional)

if "`dv'" == "demonstration" {
	local legend "col(1) off"
	local title "Attended a lawful demonstration, last 12 months"
} 	
if "`dv'" == "petition" {
	local legend "col(1) off"
	local title "Signed a petition, last 12 months"
} 
if "`dv'" == "boycott" {
	local legend "col(1) ring(0) pos(3) xoffset(60)"
	local title "Boycotted certain products, last 12 months"
} 
* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Generate plots for each protest activity

#delimit ;
marginsplot, 
	plot1opts(mcolor("166 206 227") lcolor("166 206 227"))
	plot2opts(mcolor("31 120 180") lcolor("31 120 180"))
	addplot( 
		scatter ypos earlyprotest if tag_c == 1 & newdem==1, 
			msymbol(i) mlabpos(0) mlabel(bar) mlabcolor("166 206 227") || 
		scatter ypos earlyprotest if tag_c == 1 & newdem==2, 
			msymbol(i) mlabpos(0) mlabel(bar) mlabcolor("31 120 180") 
			legend(order(3 "Old democracies" 4 "New democracies"))
		) 
	title("`title'")
	xtitle("Early exposure to protest")
	ytitle("Predicted probabilities")
	legend(`legend')
	
	saving("${figures_gph}mfx_`dv'.gph", replace);
	graph export "${figures_pdf}mfx_`dv'.pdf", replace;
#delimit cr
}
* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Generate Figure 4:
*     Predicted probabilities of having taken part in a protest activity in the
*     12 months preceding the survey, in new and old democracies, as a function 
*     as a function of the protest level measured during the second wave of the 
*     EVS(based on Models 3, 6, and 9)

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Combine plots

gr combine ///
	"${figures_gph}mfx_demonstration.gph" ///
	"${figures_gph}mfx_petition.gph" ///
	"${figures_gph}mfx_boycott.gph", ///
	col(2) row(2) xcommon ycommon ///
	saving("${figures_gph}fig4_pred_prob.gph", replace)
graph export "${figures_eps}fig4_pred_prob.eps", replace
graph export "${figures_pdf}fig4_pred_prob.pdf", replace
graph export "${figures_png}fig4_pred_prob.png", replace  ///
			width(2750) height(2000)

* ______________________________________________________________________________
* Close

log close
exit
