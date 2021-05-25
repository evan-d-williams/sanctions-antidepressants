
*================*
* Import Dataset *
*================*

import excel "$Path\\Quarterly_Sanctions_Dataset_SSRI_Prescribing.xlsx", sheet("Sheet1") firstrow

*==========================
* Reshape to longform
*==========================

reshape long ssri cardio antibio ///
		origadv ///
		age015_ age1624_ age2529_ age3034_ age3539_ age4044_ age4549_ age5054_ age5559_ age6064_ age65plus_ ///
		female white ///
		claimant unemp employ inact ///
		gva gdhi ///
		wca ///
		, i(la_code) j(quarter)

*=================*
* Create Variables*
*=================*

* Urban / Rural

gen urban_2011=.
replace urban_2011=1 if rural_2011 < 3
replace urban_2011=2 if rural_2011 == 3
replace urban_2011=3 if rural_2011 > 3

* age

gen age1629_ = age1624_ + age2529_
gen age3049_ = age3034_ + age3539_ + age4044_ + age4549_
gen age5064_ = age5054_ + age5559_ + age6064_

* Reform

gen reform=.
replace reform=0 if quarter < 14
replace reform=1 if quarter >= 14

* Reform interaction

generate origadv_post = reform*origadv

* Timetrend interactions

generate imd_2=0 
replace imd_2=1 if imd_2010==2

generate imd_3=0 
replace imd_3=1 if imd_2010==3

generate imd_4=0 
replace imd_4=1 if imd_2010==4

generate imd_5=0 
replace imd_5=1 if imd_2010==5

generate imd_2b = imd_2*quarter
generate imd_3b = imd_3*quarter
generate imd_4b = imd_4*quarter
generate imd_5b = imd_5*quarter

generate urban_2=0 
replace urban_2=1 if urban_2011==2

generate urban_3=0 
replace urban_3=1 if urban_2011==3

generate urban_2b = urban_2*quarter
generate urban_3b = urban_3*quarter

*================================*
* Specify time period and sample *
*================================*

* time period

keep if quarter < 23
keep if quarter > 4

* drop small local authorities

drop if la_code == 61 // City of London
drop if la_code == 138 // Isles of Scilly

* deal with Universal Credit rollout
// Substantive results unchanged if these LA quarters are retained

drop if la_code == 271 & quarter >= 16 // Tameside
drop if la_code == 312 & quarter >= 17 // Wigan
drop if la_code == 195 & quarter >= 17 // Oldham
drop if la_code == 295 & quarter >= 17 // Warrington
drop if la_code == 116 & quarter >= 18 // Hammersmith & Fulham
drop if la_code == 217 & quarter >= 18 // Rugby
drop if la_code == 120 & quarter >= 19 // Harrogate
drop if la_code == 16 & quarter >= 19 // Bath
drop if la_code == 287 & quarter >= 21 // Trafford
drop if la_code == 227 & quarter >= 21 // Sefton
drop if la_code == 24 & quarter >= 21 // Bolton
drop if la_code == 316 & quarter >= 21 // Wirral
drop if la_code == 202 & quarter >= 21 // Preston
drop if la_code == 246 & quarter >= 21 // South Ribble
drop if la_code == 41 & quarter >= 21 // Bury
drop if la_code == 223 & quarter >= 21 // Salford
drop if la_code == 146 & quarter >= 21 // Knowsley
drop if la_code == 256 & quarter >= 21 // St. Helens
drop if la_code == 55 & quarter >= 21 // Cheshire West and Chester
drop if la_code == 54 & quarter >= 21 // Cheshire East 
drop if la_code == 160 & quarter >= 22 // Manchester
drop if la_code == 212 & quarter >= 22 // Rochdale
drop if la_code == 21 & quarter >= 22 // Blackburn with Darwen
drop if la_code == 114 & quarter >= 22 // Halton
drop if la_code == 260 & quarter >= 22 // Stockport
drop if la_code == 40 & quarter >= 22 // Burnley
drop if la_code == 135 & quarter >= 22 // Hyndburn
drop if la_code == 197 & quarter >= 22 // Pendle
drop if la_code == 214 & quarter >= 22 // Rossendale
drop if la_code == 306 & quarter >= 22 // West Lancashire
drop if la_code == 155 & quarter >= 22 // Liverpool

* Deal with zero values in ssri and sanctions

replace ssri=. if ssri==0
replace origadv=. if origadv==0

*========================*
* Descriptive Statistics *
*========================*

* Table A1

summarize ssri origadv cardio claimant unemp inact employ wca gva gdhi age015_ age1629_ age3049_ age5064_ age65plus_ female white antibio
tabulate imd_2010
tabulate urban_2011

* Figure 1

pwcorr ssri origadv, sig

regress ssri origadv
local r2: display %4.3f e(r2)
twoway scatter ssri origadv, jitter(10) msymbol(oh) mcolor(gs9) ///
				|| lfit ssri origadv, lwidth(medthick) lcolor(black) ///
				xtitle("Sanctions per" "100,000 population", height(10)) ///
				xlabel(, format(%9.0fc)) ///
				ytitle("SSRI Items per" "100,000 population", height(10)) ///
				ylabel(, format(%9.0fc)) ///
				legend(off) ///
				graphregion(color(white)) ///
				caption("R{superscript:2} = `r2'", ring(0) position(2) height(10))

*======================*
* Fixed Effects Models *
*======================*

xtset la_code quarter

* Multicollinearity check

corr origadv claimant
corr origadv unemp

* Initial models (Table A2)
// Two versions of models - xtreg / xtscc

xtreg ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio, fe
xtreg ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xtreg ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio i.imd_2010 i.urban_2011, re

xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio, fe
xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio i.imd_2010 i.urban_2011, re

* FE/RE comparison - Hausman test

xtreg ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
estimates store fixed
xtreg ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio i.imd_2010 i.urban_2011, re
estimates store random
hausman fixed random
hausman fixed random, sigmamore

* Pre and Post Reform (Table 1)

xtreg ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
xtreg ssri origadv c.origadv#reform unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
lincom origadv + 1.reform#c.origadv

xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xtscc ssri origadv c.origadv#reform unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
lincom origadv + 1.reform#c.origadv

* GVA / GDHI check

xtreg ssri origadv unemp inact wca gdhi i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xtreg ssri origadv c.origadv#reform unemp inact wca gdhi i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
lincom origadv + 1.reform#c.origadv

xtscc ssri origadv unemp inact wca gdhi i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xtscc ssri origadv c.origadv#reform unemp inact wca gdhi i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
lincom origadv + 1.reform#c.origadv

*===================================
* Visualise the regression estimates
*===================================

/*
ssc install coefplot
ssc install lincomest
*/

// Version 1

gen origadvb=origadv
gen origadvc=origadv
gen reformb=reform

quietly xtreg ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio quarter c.quarter#i.imd_2010 c.quarter#i.urban_2011, fe robust
estimates store full
quietly xtreg ssri origadvb c.origadvb#reform unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio quarter c.quarter#i.imd_2010 c.quarter#i.urban_2011, fe robust
estimates store before
quietly xtreg ssri origadvc c.origadvc#reformb unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio quarter c.quarter#i.imd_2010 c.quarter#i.urban_2011, fe robust
lincomest origadvc + 1.reformb#c.origadvc
estimates store after
coefplot(full, label(Full) offset(.0)) (before, label(Before)) (after, label(After)), ///
		keep(origadv origadvb (1)) ///
		yline(0) vertical legend(off) graphregion(color(white)) levels(95) ///
		ytitle("Increase in SSRI Prescribing Items" "per 100,000 population", height(10)) ///
		coeflabels(origadv = "Full Time Period" ///
		origadvb = "Pre-Welfare Reform Act 2012" ///
		(1) = "Post-Welfare Reform Act 2012", ///
		wrap(20) labgap(3))

// Version 2
		
quietly xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
estimates store full
quietly xtscc ssri origadvb origadv_post unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
estimates store before
quietly xtscc ssri origadvc origadv_post unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
lincomest origadvc + origadv_post
estimates store after
coefplot(full, label(Full) offset(.0)) (before, label(Before)) (after, label(After)), ///
		keep(origadv origadvb (1)) ///
		yline(0) vertical legend(off) graphregion(color(white)) levels(95) ///
		ytitle("Increase in SSRI Prescribing Items" "per 100,000 population", height(10)) ///
		coeflabels(origadv = "Full Time Period" ///
		origadvb = "Pre-Welfare Reform Act 2012" ///
		(1) = "Post-Welfare Reform Act 2012", ///
		wrap(20) labgap(3))
		
*====================*
* Falsification Test *
*====================*

// Version 1

xtreg cardio origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
xtreg cardio origadv c.origadv#reform unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
lincom origadv + 1.reform#c.origadv

quietly xtreg cardio origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
estimates store full
quietly xtreg cardio origadvb c.origadvb#reform unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
estimates store before
quietly xtreg cardio origadvc c.origadvc#reformb unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
lincomest origadvc + 1.reformb#c.origadvc
estimates store after
coefplot(full, label(Full) offset(.0)) (before, label(Before)) (after, label(After)), ///
		keep(origadv origadvb (1)) ///
		yline(0) vertical legend(off) graphregion(color(white)) levels(95) ///
		ytitle("Increase in Cardiovascular Prescribing Items" "per 100,000 population", height(10)) ///
		coeflabels(origadv = "Full Time Period" ///
		origadvb = "Pre-Welfare Reform Act 2012" ///
		(1) = "Post-Welfare Reform Act 2012", ///
		wrap(20) labgap(3))
		
// Version 2

xtscc cardio origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
xtscc cardio origadv c.origadv#reform unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
lincom origadv + 1.reform#c.origadv

quietly xtscc cardio origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
estimates store full
quietly xtscc cardio origadvb origadv_post unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
estimates store before
quietly xtscc cardio origadvc origadv_post unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
lincomest origadvc + origadv_post
estimates store after
coefplot(full, label(Full) offset(.0)) (before, label(Before)) (after, label(After)), ///
		keep(origadv origadvb (1)) ///
		yline(0) vertical legend(off) graphregion(color(white)) levels(95) ///
		ytitle("Increase in Cardiovascular Prescribing Items" "per 100,000 population", height(10)) ///
		coeflabels(origadv = "Full Time Period" ///
		origadvb = "Pre-Welfare Reform Act 2012" ///
		(1) = "Post-Welfare Reform Act 2012", ///
		wrap(20) labgap(3))

*========================*
* Granger Causality Test *
*========================*

xtgcause ssri origadv, l(4)
xtgcause origadv ssri, l(4)

xtgcause ssri origadv, l(aic)
xtgcause origadv ssri, l(aic)

xtgcause ssri origadv, l(bic)
xtgcause origadv ssri, l(bic)

xtgcause ssri origadv, l(hqic)
xtgcause origadv ssri, l(hqic)

*===================================*
* Appendix / Regression Diagnostics *
*===================================*

* a) Normality of Dependent Variable

hist ssri, norm
pnorm ssri

sktest ssri
swilk ssri
sfrancia ssri

* b) Normality of Residuals

// Version 1

xtreg ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
predict res1, e

histogram res1,	normal frequency fcolor(gs10) lcolor(gs12) ///
				xtitle("Residuals", height(6)) xlabel(, format(%9.0fc)) ///
				ytitle("Frequency", height(6))	ylabel(, format(%9.0fc)) ///
				graphregion(color(white))

// Version 2

xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
predict res2, residuals

histogram res2,	normal frequency fcolor(gs10) lcolor(gs12) ///
				xtitle("Residuals", height(6)) xlabel(, format(%9.0fc)) ///
				ytitle("Frequency", height(6))	ylabel(, format(%9.0fc)) ///
				graphregion(color(white))
				
pnorm res
qnorm res
kdensity res, normal

sktest res
swilk res
sfrancia res

* c) Cross-sectional dependence / contemporaneous correlation

preserve
replace unemp=0 if unemp==.
xtreg ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe robust
xtcsd, pesaran abs
restore

* d) Homoscedasticity

xtreg ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
xttest3

xtreg ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
predict res, e 
predict yhat1, xb

summarize res 

twoway scatter 	res yhat1, ///
				ytitle("Residuals", height(6)) ylabel(, format(%9.0fc)) ///
				xtitle("Predicted Values", height(6)) xlabel(, format(%9.0fc)) ///
				msize(medium) yline(0) graphregion(color(white)) ///
				jitter(10) msymbol(oh) mcolor(gs9)

* e) Serial correlation
// Lagrange Multiplier test

xtserial ssri origadv unemp inact wca gva age1629_ age3049_ age5064_ age65plus_ female white antibio

* f) Unit root / stationarity

pescadf ssri, lags(0) 
pescadf ssri, lags(0) trend

pescadf origadv, lags(0)
pescadf origadv, lags(0) trend

* g) Outliers / Leverage / Influence

// Residuals +/- 2S.D. from mean

xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
predict res2, residual
summarize res2, detail // +/- 2SD = [XXXX, YYYY]
gen res_1 = .
replace res_1 = 1 if res2 > XXXX  & res2 < YYYY
xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b if res_1 == 1, fe

// Extreme observations > 99th percentile

summarize ssri, detail // 1% = XXXX, 99% = YYYY
gen ssri_new =.
replace ssri_new = 1 if  ssri > XXXX & ssri < YYYY
xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b if ssri_new == 1, fe

summarize origadv, detail // 1% = XXXX, 99% = YYYY
gen origadv_new =.
replace origadv_new = 1 if  origadv > XXXX & origadv < YYYY
xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b if origadv_new == 1, fe

* Coastal towns check

preserve
xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
drop if la_code == 22 // Blackpool
drop if la_code == 284 // Torbay
drop if la_code == 124 // Hastings
drop if la_code == 110 // Great Yarmouth
drop if la_code == 280 // Thanet
xtscc ssri origadv unemp inact wca gva i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, fe
restore

* h) Multicollinearity

pwcorr ssri origadv claimant unemp inact wca gva age015_ age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b, sig

// Tolerance and VIF scores.

regress ssri origadv claimant i.la_code i.quarter age1629_ age3049_ age5064_ age65plus_ female white antibio imd_2b imd_3b imd_4b imd_5b urban_2b urban_3b
estat vif
collin origadv claimant age1629_ age3049_ age5064_ age65plus_ female white antibio
