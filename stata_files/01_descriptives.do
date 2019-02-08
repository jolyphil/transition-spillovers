********************************************************************************
* Project: Transition Spillovers
* Task:    Generate and export descriptive figures
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

* version 15
capture log close
capture log using "${logfiles}01_descriptives.smcl", replace
set more off

set scheme minimal
ssc install sencode

* ______________________________________________________________________________
* Load and collapse data at the country level

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Load merged dataset

use "${data}master.dta", clear

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Recode binary variables ("has not done" = 0, "has done" = 1)

recode demonstration (1 = 0) (2 = 1)
recode petition (1 = 0) (2 = 1)
recode boycott (1 = 0) (2 = 1)

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Collapse data

sort country
collapse ///
	(mean) demonstration petition boycott ///
	(first) earlyprotest newdem ///
	[pweight=dweight], by(country)

* ______________________________________________________________________________
* Generate Figure 1: 
*     Protest experience of the 1989 generation as measured during the second 
*     wave of the European Values Study conducted between 1990 and 1993

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Sort countries according to demo EVS

gsort earlyprotest
sencode country, gen(countryrank)

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Generate graph

summ earlyprotest if newdem == 2
local mean_newdem = round(r(mean), 0.01)
local sd_newdem = round(r(sd), 0.01)

summ earlyprotest if newdem == 1
local mean_olddem = round(r(mean), 0.01)
local sd_olddem = round(r(sd), 0.01)

twoway ///
	(bar earlyprotest countryrank if newdem==2, ///
		sort horizontal fcolor("31 120 180") ///
		lwidth(none) lcolor(%0) barwidth(0.8)) ///
	(bar earlyprotest countryrank if newdem==1, ///
		sort horizontal fcolor("166 206 227") ///
		lwidth(none) lcolor(%0) barwidth(0.8)), ///
	xlabel(0(0.1)0.6) ///
	ylabel(1(1)25, valuelabel nogrid) ///
	xtitle("Proportion having taken part in a demonstration") ///
	ytitle("") ///
	legend(position(3) ///
		order(1 "New democracies" "(mean = `mean_newdem'; sd = `sd_newdem')" ///
			  2 "Old democracies" "(mean = `mean_olddem'; sd = `sd_olddem')")) ///
	saving("${figures_gph}fig1_protest_1990_93.gph", replace)
	graph export "${figures_eps}fig1_protest_1990_93.eps", replace
	graph export "${figures_pdf}fig1_protest_1990_93.pdf", replace
	graph export "${figures_png}fig1_protest_1990_93.png", replace ///
			width(2750) height(2000)

* ______________________________________________________________________________
* Generate Figure 3: 
*     Annual participation in demonstrations, petitions, and boycotts 
*     (2002-2017) as a function of early exposure to protest (1990-1993), 
*     aggregated by country

foreach var of varlist demonstration petition boycott {

	reg `var' earlyprotest if newdem == 1
	gen yhat_olddem = _b[_cons] + _b[earlyprotest]*earlyprotest if newdem == 1
	
	reg `var' earlyprotest if newdem == 2
	gen yhat_newdem = _b[_cons] + _b[earlyprotest]*earlyprotest  if newdem == 2
	
	
	if "`var'" == "demonstration" {
		local legend "col(1) off"
		local title "Attended a lawful demonstration, last 12 months"
	} 	
	if "`var'" == "petition" {
		local legend "col(1) off"
		local title "Signed a petition, last 12 months"
	} 
	if "`var'" == "boycott" {
		local legend "col(1) ring(0) pos(3) xoffset(60) order(1 `"Old democracies"' 2 `"New democracies"' 3 `"Linear prediction, old democracies"' 4 `"Linear prediction, new democracies"')"
		local title "Boycotted certain products, last 12 months"
	} 
	
	twoway ///
		(scatter `var' earlyprotest if newdem==1, ///
			mcolor("166 206 227") /*mlabel(country)*/) ///
		(scatter `var' earlyprotest if newdem == 2, ///
			mcolor("31 120 180") /*mlabel(country)*/) ///
		(line yhat_olddem earlyprotest, ///
			lcolor("166 206 227")) ///
		(line yhat_newdem earlyprotest, ///
			lcolor("31 120 180")), ///
		xlabel(0(0.2)0.6) ///
		xtitle("Early exposure to protest") ///
		ytitle("Proportion") ///
		title("`title'") ///
		legend(`legend') ///
		saving("${figures_gph}earlyprotest_`var'.gph", replace)

	drop yhat_olddem yhat_newdem
		
}
gr combine ///
	"${figures_gph}earlyprotest_demonstration.gph" ///
	"${figures_gph}earlyprotest_petition.gph" ///
	"${figures_gph}earlyprotest_boycott.gph", ///
	col(2) row(2) xcommon ycommon ///
	saving("${figures_gph}fig3_bivar.gph", replace)
graph export "${figures_eps}fig3_bivar.eps", replace
graph export "${figures_pdf}fig3_bivar.pdf", replace
graph export "${figures_png}fig3_bivar.png", replace ///
			width(2750) height(2000)

* ______________________________________________________________________________
* Close

log close
exit
