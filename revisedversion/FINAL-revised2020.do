cd "C:\Users\ngoca\Dropbox\Pubs_since_2018\2018-Intra-Asian-FDI\Economic-Modelling\2nd submission"
capture log close
set matsize 10000
use DATA, clear
//log using All-Tables, text  replace
global withfe sumgdp gdpdifsq  gdpter tradecost_s  tradecost_h  terdif tradeter investcost_h  dist gdpdif bit contig comlang_ethno comcol y* idh* ids*
global nofe   sumgdp gdpdifsq  gdpter tradecost_s  tradecost_h  terdif tradeter investcost_h  dist gdpdif bit contig comlang_ethno comcol y* 

*================================== TABLE 4: MODEL SELECTION TESTS ===========================================================
*********************RESET********************************
*OLS
eststo clear
use DATA, clear
reg stock0 $withfe, vce(cluster dist)
eststo POLSfe
qui predict fit, xb
rvfplot //not i.i.d
qui predict resid, residuals
qnorm resid //=> not normal
qui gen fit2 = fit^2
qui reg stock0 $withfe fit2, vce(cluster dist)
test fit2=0 // p-value =0.0000, not pass reset
qui drop fit* 
*TOBIT
version 14: tobit stock0 $withfe, ll(0) vce(cluster dist) nolog
eststo TOBITfe
tobcm //p-value =0.0000 > not normal
qui predict fit, xb
qui gen fit2 = fit^2
version 14: qui tobit stock0 $withfe fit2, ll(0) vce(cluster dist) nolog
test fit2=0 // p-value =0.0000, not pass reset
qui drop fit* 
*PPML
ppml stock0 $withfe, cluster(dist) 
eststo PPMLfe
margins, dydx(*) post
eststo PPMLme
qui ppml stock0 $withfe, cluster(dist)
qui predict fit, xb
qui gen fit2 = fit^2
qui ppml stock0 $withfe fit2,  cluster(dist) 
test fit2 =0 // P-value = 0.819 => model is correctly specified
qui drop fit*
*LH
capture drop fit*
churdle exponential stock0 $withfe , select($withfe) ll(0) vce(cluster dist) nolog
eststo LHfe
margins, dydx(*) post
eststo LHme
qui churdle exponential stock0 $withfe , select($withfe) ll(0) vce(cluster dist) nolog
qui predict fit, xb
qui gen fit2 = fit^2
qui churdle exponential stock0 $withfe fit2, select($withfe fit2) ll(0) vce(cluster dist) nolog
test fit2 = 0 // p-value = 0.4116 => model is correctly specified
qui drop fit*


*Heckit- ET2T
heckman lstock $withfe , difficult robust sel(dinvest = $withfe ) nolog //LH is better than HEckit based on the LR test
eststo Heckit

qui heckman lstock $withfe , difficult robust sel(dinvest = $withfe ) 
qui predict fit, xb
qui gen fit2 = fit^2
qui heckman lstock $withfe fit2, difficult robust sel(dinvest =  $withfe fit2) 

test fit2 = 0 // p-value = 0.047
qui drop fit*

*=====================================HPC===========================================================

qui tobit stock0 $withfe, ll(0) vce(cluster dist)
qui predict double fitT

qui ppml stock0 $withfe, cluster(dist)
qui predict double fitP

qui reg stock0 $withfe, vce(cluster dist)
qui predict double fitO

qui churdle exponential stock0 $withfe , select($withfe) ll(0) vce(cluster dist)
qui predict double fitL

qui heckman lstock $withfe , difficult robust sel(dinvest = $withfe ) rhoforce  nolog 
qui predict double fito, xb
qui predict double xg, xbsel
qui gen double fitH=exp(fito+0.5*e(sigma)^2+log(normal(xg+ e(rho)*e(sigma))))

*OLS versus ET2T
hpc stock0 $withfe  , a(fitH) b(fitO) cluster(dist) // pA = 0.473 , pB = 0.000

*Tobit versus ET2T
hpc stock0 $withfe  , a(fitH) b(fitT) cluster(dist) // pA= 0.261, pB = 0.004

*PPML versus ET2T
hpc stock0 $withfe  , a(fitH) b(fitP) cluster(dist) // pA = 0.192, pB = 0.787

*OLS versus LH
hpc stock0  $withfe , a(fitL) b(fitO) cluster(dist) // pA= 0.479, pB = 0.000

*Tobit versus LH
hpc stock0  $withfe , a(fitL) b(fitT) cluster(dist) // pA = 0.285, pB = 0.003
 
*PPML versus LH
hpc stock0  $withfe , a(fitL) b(fitP) cluster(dist) // pA = 0.189, pB = 0.762


esttab using All-Tables.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N r2 ar2 pr2 aic bic ll_0 ll chi2) ///
se(3) b(3) nodepvars drop ( y* *id*) noomitted title(Table 6: Results with Country Fixed Effects) compress append style(tab)


*=============================TABLE 5 -NO COUNTRY FEs================================================
eststo clear
use DATA, clear
reg stock0 $nofe, vce(cluster dist)
eststo POLSfe

tobit stock0 $nofe, ll(0) vce(cluster dist) nolog
eststo TOBITnofe

ppml stock0 $nofe, cluster(dist)
eststo PPMLnofe

churdle exponential stock0 $nofe , select($nofe) ll(0) vce(cluster dist) nolog
eststo LHnofe

heckman lstock $nofe , difficult robust sel(dinvest = sumgdp gdpdifsq  gdpter tradecost_s  tradecost_h  terdif tradeter investcost_h  dist gdpdif contig comlang_ethno comcol y* ) nolog
eststo Heckitnofe

esttab using All-Tables.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N r2 ar2 pr2 aic bic ll_0 ll chi2) ///
se(3) b(3) nodepvars drop ( y* ) noomitted title(Table 5: Results without Country Fixed Effects) compress append


*===============Table A2: Results for pairs with at least one year of positive FDI=============================== 
use DATA, clear
drop if z==0
*(1)Pooled OLS
eststo clear
reg stock0  $withfe , vce(cluster dist)
eststo OLS
*(2)Tobit
tobit stock0 $withfe, ll(0)  vce(cluster dist) nolog
eststo Tobit
*(3)PPML
ppml stock0 $withfe, cluster(dist) 
eststo PPML 
*(4)LH
churdle exponential stock0 $withfe , select($withfe) ll(0) vce(cluster dist) nolog
eststo LH

esttab using All-Tables.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N r2 ar2 pr2 aic bic ll_0 ll chi2) ///
se(3) b(3) nodepvars drop (  y* *id*) noomitted title(Table 7: Results for Pairs with at Least One Year of Positive FDI) compress append

*===========Table A3: Results based on Braconier et al. (2005) specification======================
use DATA, clear
qui gen usk_ipo_h = total_ipo_h - sk_ipo_h
qui gen usk_ipo_s = total_ipo_s - sk_ipo_s
qui gen Ss = sk_ipo_s/(sk_ipo_h + sk_ipo_s)
qui gen Us = usk_ipo_s/(usk_ipo_h + usk_ipo_s)
qui gen size = sqrt(Ss^2 + Us^2)
qui gen sizesq = size*size
qui gen skill = Ss/Us
qui gen sizesk = size*skill
qui gen skilltrade = skill^2*tradecost_h
global withfe sumgdp sizesq  sizesk tradecost_s  tradecost_h  skill skilltrade investcost_h  dist size bit contig comlang_ethno comcol y* idh* ids*
*(1)OLS
eststo clear
reg stock0  $withfe , vce(cluster dist)
eststo OLS
*(2)Tobit
tobit stock0 $withfe, ll(0) vce(cluster dist) nolog
eststo Tobit
*(3)PPML
ppml stock0 $withfe, cluster(dist) 
eststo PPML
*(4)LH
churdle exponential stock0 $withfe , select($withfe) ll(0) vce(cluster dist) nolog 
eststo LH

esttab using All-Tables.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N r2 ar2 pr2 aic bic ll_0 ll chi2) ///
se(3) b(3) nodepvars drop (  y* *id*) noomitted title(Table 9: Results based on Braconier et al. (2005) Specification) compress append


*===============Table A4: Results based on Davies (2008)’ specification============================== 
* TERDIF <0
use DATA, clear
global withfe sumgdp gdpdifsq  gdpter tradecost_s  tradecost_h  terdif terdifsq tradeter investcost_h  dist gdpdif bit contig comlang_ethno comcol y* idh* ids*
drop if terdif >0
*(1)OLS
eststo clear
reg stock0  $withfe , vce(cluster dist)
eststo OLS
*(2)Tobit
tobit stock0 $withfe, ll(0)  vce(cluster dist) nolog
eststo Tobit
*(3)PPML
ppml stock0 $withfe, cluster(dist) 
eststo PPML
*(4)LH
churdle exponential stock0 $withfe , select($withfe) ll(0) vce(cluster dist) nolog
eststo LH

esttab using All-Tables.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N r2 ar2 pr2 aic bic ll_0 ll chi2) ///
se(3) b(3) nodepvars drop (  y* *id*) noomitted title(Table 8a: Results based on Davies (2008)’ Specification, negative FDI) compress append

* TERDIF >0
use DATA, clear
drop if terdif <0
*(1)OLS
eststo clear
reg stock0  $withfe , vce(cluster dist)
eststo OLS
*(2)Tobit
tobit stock0 $withfe, ll(0)  vce(cluster dist)
eststo Tobit
*(3)PPML
ppml stock0 $withfe, cluster(dist)
eststo PPML
*(4)LH
churdle exponential stock0 $withfe , select($withfe) ll(0) vce(cluster dist) nolog
eststo LH


esttab using All-Tables.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N r2 ar2 pr2 aic bic ll_0 ll chi2) ///
se(3) b(3) nodepvars drop ( y* *id*) noomitted title(Table 8b: Results based on Davies (2008)’ Specification, positive FDI) compress append




*===========Table A5: Results based on Bergstrand and Egger 2013 specification======================


// *Gross fixed capital formation
// import delimited "$mainpath\Journal\NewData\API_NE.GDI.FTOT.CD_DS2_en_csv_v2_53419.csv", varnames(1) clear
// browse
// replace indicatorcode = "fixedcapital"
// egen id = group(countrycode )
//
// reshape long y, i(id indicatorcode) j(time)
// reshape wide y, i(id time) j(indicatorcode, string)
// rename y* *
// label var fixedcapital "Gross fixed capital formation (current US$)"
// rename ïcountryname  CountryName
// format %16s CountryName
// drop id
// gen host = countrycode
// gen source = countrycode
// duplicates drop
//
// save fixedcapital, replace

// use DATA, clear
// merge m:1 host time using fixedcapital.dta, keepusing(fixedcapital)
// drop if _merge == 2
// rename fixedcapital fixedcapital_h
// drop _merge
// merge m:1 source time using fixedcapital.dta, keepusing(fixedcapital)
// drop if _merge == 2
// rename fixedcapital fixedcapital_s
// drop _merge
//
//
//
// des rgdpus* stock*
// gen lsumgdp1 = ln(rgdpus_h + rgdpus_s)
// gen similarity = rgdpus_h*rgdpus_s/(rgdpus_h + rgdpus_s)^2
// gen lsimilarity = ln(similarity)
// drop lgdp*
// gen lgdp_h = ln(rgdpus_h)
// gen lgdp_s = ln(rgdpus_s)
//
// qui gen usk_ipo_h = total_ipo_h - sk_ipo_h
// qui gen usk_ipo_s = total_ipo_s - sk_ipo_s
// qui gen Ss = sk_ipo_s/(sk_ipo_h + sk_ipo_s)
// gen Ss2 = Ss^2
// gen Ss3 = Ss^3
// gen Ss4 = Ss^4
//
// qui gen Us = usk_ipo_s/(usk_ipo_h + usk_ipo_s)
//
//
// qui gen Ks = fixedcapital_s/(fixedcapital_s + fixedcapital_h)
// gen Ks2 = Ks^2
// gen Ks3 = Ks^3
// gen Ks4 = Ks^4
// gen SsKs = Ss*Ks
// gen SsUs = Ss*Us
// gen KsUs = Ks*Us
//
// sum  tradecost_h tradecost_s
// gen ltradecost_h = ln(tradecost_h)
// gen ltradecost_s = ln(tradecost_s)
// gen linvestcost_h = ln(investcost_h)
// save DATA, replace

use DATA, clear
global nofe1 lsumgdp lsimilarity ldist bit contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss  Ks Us y*
global nofe2 lsumgdp lsimilarity ldist bit contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss Ss2 Ss3 Ss4  Ks Ks2 Ks3 Ks4 Us SsKs SsUs KsUs y*

global withfe1 lsumgdp lsimilarity ldist bit contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss  Ks Us y* idh* ids*
global withfe2 lsumgdp lsimilarity ldist bit contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss Ss2 Ss3 Ss4  Ks Ks2 Ks3 Ks4 Us SsKs SsUs KsUs y* idh* ids*

*PPML
sum $nofe1
eststo clear

ppml stock0 $nofe1, cluster(dist) 
eststo NOFE1

ppml stock0 $nofe2, cluster(dist) 
eststo NOFE2
ppml stock0 $withfe1, cluster(dist) 
eststo WITHFE1
ppml stock0 $withfe2, cluster(dist) 
eststo WITHFE2


esttab using Gravity2019.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N  ll_0 ll ) ///
se(3) b(3) nodepvars drop (  y* *id*) noomitted nogaps title(Table A5: Results based on Bersgtrand and Egger 2013 Specification) compress replace

*A5 without BIT and ln(Similarity)

use DATA, clear
global nofe1 lsumgdp  ldist contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss  Ks Us y*
global nofe2 lsumgdp ldist contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss Ss2 Ss3 Ss4  Ks Ks2 Ks3 Ks4 Us SsKs SsUs KsUs y*

global withfe1 lsumgdp  ldist contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss  Ks Us y* idh* ids*
global withfe2 lsumgdp ldist contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss Ss2 Ss3 Ss4  Ks Ks2 Ks3 Ks4 Us SsKs SsUs KsUs y* idh* ids*

*PPML
sum $nofe1
eststo clear

ppml stock0 $nofe1, cluster(dist) 
eststo NOFE1

ppml stock0 $nofe2, cluster(dist) 
eststo NOFE2
ppml stock0 $withfe1, cluster(dist) 
eststo WITHFE1
ppml stock0 $withfe2, cluster(dist) 
eststo WITHFE2

esttab using Gravity2019.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N r2 ar2 pr2 aic bic ll_0 ll chi2) ///
se(3) b(3) nodepvars drop (  y* *id*) noomitted nogaps title(Results without BIT and Similarity) compress replace

*================= Table A6: Gravity specificaiton========================
use DATA, clear
eststo clear
global nofe lgdp_s lgdp_h ldist bit contig comlang_ethno comcol y*
global withfe lgdp_s lgdp_h ldist bit contig comlang_ethno comcol  y* idh* ids*

*PPML


ppml stock0 $nofe, cluster(dist) 
eststo NOFE1

ppml stock0 $withfe, cluster(dist) 
eststo WITHFE1

churdle exponential stock0 $nofe , select($nofe) ll(0) vce(cluster dist) nolog
eststo LHnofe1
churdle exponential stock0 $withfe , select($withfe) ll(0) vce(cluster dist) nolog
eststo LHfe

esttab using Gravity2019.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N r2 ar2 pr2 aic bic ll_0 ll chi2) ///
se(3) b(3) nodepvars drop (  y* *id*) noomitted nogaps title(Table A6: Gravity Specification) compress append

* Some additional tests for the gravity specification
*1.Reset
qui ppml stock0 $withfe, cluster(dist)
qui predict fit, xb
qui gen fit2 = fit^2
qui ppml stock0 $withfe fit2,  cluster(dist) 
test fit2 =0 // P-value = 0.2635 => model is correctly specified
qui drop fit*

qui churdle exponential stock0 $withfe , select($withfe) ll(0) vce(cluster dist) nolog
qui predict fit, xb
qui gen fit2 = fit^2
qui churdle exponential stock0 $withfe fit2, select($withfe fit2) ll(0) vce(cluster dist) nolog
test fit2 = 0 // p-value = 0.5931 => model is correctly specified
qui drop fit*
*2. HPC

qui ppml stock0 $withfe, cluster(dist)
qui predict double fitP

qui churdle exponential stock0 $withfe , select($withfe) ll(0) vce(cluster dist)
qui predict double fitL
 
*PPML versus LH
hpc stock0  $withfe , a(fitL) b(fitP) cluster(dist) // pA = 0.201, pB = 0.998





*=========================== 1ST REVISION REQUESTS- Economic Modelling================================================================================

*==================== Different capital variable
use DATA, clear
rename host countrycode
rename time year
merge m:1 countrycode year using pwt91.dta, keepusing(cn)
drop if _merge == 2
rename cn capital_h
drop _merge
renam countrycode host
rename source countrycode
merge m:1 countrycode year using pwt91.dta, keepusing(cn)
drop if _merge == 2
rename cn capital_s
drop _merge

qui gen nKs = capital_s/(capital_s + capital_h)
gen nKs2 = nKs^2
gen nKs3 = nKs^3
gen nKs4 = nKs^4
gen nSsKs = Ss*nKs
gen nSsUs = Ss*Us
gen nKsUs = nKs*Us
rename year time
rename countrycode source
save DATA_revised, replace

use DATA_revised, clear
global nofe1 lsumgdp lsimilarity ldist bit contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss  nKs Us y*
global nofe2 lsumgdp lsimilarity ldist bit contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss Ss2 Ss3 Ss4  nKs nKs2 nKs3 nKs4 Us nSsKs nSsUs nKsUs y*

global withfe1 lsumgdp lsimilarity ldist bit contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss  nKs Us y* idh* ids*
global withfe2 lsumgdp lsimilarity ldist bit contig comlang_ethno comcol linvestcost_h ltradecost_h ltradecost_s Ss Ss2 Ss3 Ss4  nKs nKs2 nKs3 nKs4 Us nSsKs nSsUs nKsUs y* idh* ids*

*PPML
sum $nofe1
eststo clear

ppml stock0 $nofe1, cluster(dist) 
eststo NOFE1

ppml stock0 $nofe2, cluster(dist) 
eststo NOFE2
ppml stock0 $withfe1, cluster(dist) 
eststo WITHFE1
ppml stock0 $withfe2, cluster(dist) 
eststo WITHFE2


esttab using Results_2ndsubmission.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N  ll_0 ll ) ///
se(3) b(3) nodepvars drop (  y* *id*) noomitted nogaps title(Table A5: Results based on Bersgtrand and Egger 2013 Specification and new capital variable) compress replace


*======================== Results with flows
use STEP5-AllFDI-panel-UNTACD2, clear
egen idp = group(host source)
browse

*** Creating FLOW variable with the highest number of observations

gen y = 1 if !missing(unif)
bysort idp: egen countif = total(y)
drop y
gen y = 1 if !missing(unof)
bysort idp: egen countof = total(y)
drop y

gen flow = unif
replace flow = unof if countif < countof 
drop countof countif

gen y = 1 if !missing(unis)
bysort idp: egen countis = total(y)
drop y
gen y = 1 if !missing(unos)
bysort idp: egen countos = total(y)
drop y

gen stock_original = unis
replace stock_original = unos if countis < countos
drop countos countis
la var flow "FDI flows, million $, UNTACD"

codebook unif unof flow, compact
save FDI, replace


use DATA_revised, clear
merge 1:1 time source host using FDI, keepusing(flow)
drop if _merge ==2
drop _merge
inspect flow 
replace flow =. if flow <0

gen y =1 if missing(flow)
bysort id_p: egen x = total(y)
replace flow = 0 if x ==12
drop x y


global withfe sumgdp gdpdifsq  gdpter tradecost_s  tradecost_h  terdif tradeter investcost_h  dist gdpdif bit contig comlang_ethno comcol y* idh* ids*
global nofe   sumgdp gdpdifsq  gdpter tradecost_s  tradecost_h  terdif tradeter investcost_h  dist gdpdif bit contig comlang_ethno comcol y* 

*OLS

eststo clear
reg flow $withfe, vce(cluster dist)
eststo POLSfe
*TOBIT
version 14: tobit flow $withfe, ll(0) vce(cluster dist) nolog
eststo TOBITfe
*PPML
ppml flow $withfe, cluster(dist) 
eststo PPMLfe
*LH
capture drop fit*
churdle exponential flow $withfe , select($withfe) ll(0) vce(cluster dist) nolog
eststo LHfe

esttab using Results_2ndsubmission.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N  ll_0 ll ) ///
se(3) b(3) nodepvars drop (  y* *id*) noomitted nogaps title(Table: Results for flow, comparable to Table 6) compress append



*===================== No augmented set of variables

use DATA_revised, clear
global withfe sumgdp gdpdifsq  gdpter tradecost_s  tradecost_h  terdif tradeter investcost_h  dist y* idh* ids*
global nofe   sumgdp gdpdifsq  gdpter tradecost_s  tradecost_h  terdif tradeter investcost_h  dist  y* 
corr 
*OLS

eststo clear
reg stock0 $withfe, vce(cluster dist)
eststo POLSfe
*TOBIT
version 14: tobit stock0 $withfe, ll(0) vce(cluster dist) nolog
eststo TOBITfe
*PPML
ppml stock0 $withfe, cluster(dist) 
eststo PPMLfe
*LH
capture drop fit*
churdle exponential stock0 $withfe , select($withfe) ll(0) vce(cluster dist) nolog
eststo LHfe

esttab using Results_2ndsubmission.rtf, star(* 0.1 ** 0.05 *** 0.01) stats (N  ll_0 ll ) ///
se(3) b(3) nodepvars drop (  y* *id*) noomitted nogaps title(Table: Table 6 without augmented variables) compress append

corr stock0 sumgdp gdpdifsq  gdpter tradecost_s  tradecost_h  terdif tradeter investcost_h  dist gdpdif bit contig comlang_ethno comcol


log close
exit



