*! Version 1.0.3 26-09-2022 
*  Version 1.0.2 28-03-2022 
*  Version 1.0.1 09-07-2021 

cap prog drop winratio 
prog winratio , rclass 
syntax varlist(min=2 max=2) , outcomes(string) [ STRata(varname) STWeight(string)  PFormat(string)  WRFormat(string) saving(string)  *  ]

version 12.0
preserve 

tokenize `varlist'
local idvar `1'
local trtvar `2'

	
if "`wrformat'"=="" {
	local wrformat %03.2f
	}
if "`pformat'"=="" {
	local pformat %05.4f
	}

if "`saving'"!="" {
gettoken saving replace:saving , parse(",")
local saving=trim("`saving'")
}

* -----------------------------------------------
* Checks
* -----------------------------------------------
* Check if elements in `outcomes' is >3 which indicates version 1.0.1 or 1.0.2 (no longer works) 
local comp_n=wordcount("`outcomes'")
if `comp_n'>3 {
	di in r "Option outcomes is a repeated option since Version 1.0.3. Each instance of outcomes must include exactly 3 elements since Version 1.0.3. Please see the help file for further details."
	exit 
	}

* Check elements in `outcomes' is not <3
if `comp_n'<3 {
	di in r "Option outcomes must contain 3 elements. See help winratio."
	exit
	}

if "`strata'"!="" & "`stweight'"=="" {
	local stweight="unweighted"
	}
	
if "`strata'"!="" & !inlist("`stweight'", "iv", "mh", "unweighted") {
	di in r "Invalid option for stweight"
	exit
	}

qui sum `trtvar'
if r(min)!=0 | r(max)!=1 {
	di in r "Treatment group variable should be 0/1"
	exit	
	}
qui duplicates report `idvar' 
if r(unique_value)!=r(N) {
    di in r "Duplicate or missing values in ID variable"
	exit
	}
qui count if missing(`idvar')
if r(N)>0 {
	di in r "Missing values in ID variable"
	exit
	}

if "`saving'"!="" {
	tempname post_results
	tempfile wr_results
	postfile `post_results' level wins ties losses strata using `wr_results'
	}

* -----------------------------------------------------
* Separate into c outcomes, types, time/direction  
* -----------------------------------------------------

* Put each set of outcomes into local macros out1, out2, etc. 
local outcome1 `outcomes'

local i=1
while (`"`options'"'!="")  {
	local ++i
	local outcomes
	local 0 , `options'
	syntax , [OUTcomes(string) * ]
		if (`"`outcomes'"'=="")  {
		di as err `"invalid option `options'"'
		exit 198 
		}
		local outcome`i' `outcomes'
}

local comp_n=`i'  // number of levels 


* -------------------------------------------
* Extract the 3 elements for each level 
* -------------------------------------------
forvalues c=1/`comp_n' {
	local out`c':word 1 of `outcome`c''
	local type`c':word 2 of `outcome`c''

	if substr("`type`c''",1,1)=="r" {
			local HasNumber=regexm("`type`c''", "[0-9]")		
			if `HasNumber'!=1 {
			di in r "Need to specify r# where # is maximum repeat events (syntax changed at version 1.0.2)"
			exit
			                  }
	
	local rx=substr("`type`c''", 2,.)
	capture confirm number `rx'
			if _rc!=0 {
			di in r "Need to specify r# where # is maximum repeat events (syntax changed at version 1.0.2)"
			exit 
					  }
									}
	local tdvar`c':word 3 of `outcome`c''
					}
* ------------------------------------------- 
						
* -----------------------------------------------
* Loop through program once if unstratified
* or M times if stratified
* -----------------------------------------------
local TotalWeight=0

if "`strata'"~="" {
	qui levelsof `strata' , local(M)
	local nstrata=r(r)
	}

else {
	local M=1
	}

foreach m of numlist `M' {

	if "`strata'"!="" {
	local stratlab:label (`strata') `m' 
	qui keep if `strata'==`m'
	}

* ------------------------------------------
* Number overall, per group and comparisons 
* for output later
* ------------------------------------------
qui count
	local NP=r(N)
qui tab `idvar' if `trtvar'==0
	local NP0=r(r)
qui tab `idvar' if `trtvar'==1
	local NP1=r(r)
	local Ncomps=`NP0'*`NP1'

* -----------------------------------
* Cross dataset (full cross)
* -----------------------------------
tempfile file_j
rename * *_j
qui save `file_j'	 
rename *_j *_i
cross using `file_j'
* ------------------------------------------------
* Loop through i outcomes in sequence-creating 
* a comp`i' variable for each 
* ------------------------------------------------
forvalues i=1/`comp_n' {
    	decide_winner, out(`out`i'') type(`type`i'') tdvar(`tdvar`i'')  i(`i') 

		if "`r(errorvar)'"!="" {
		disp in r "Variable `r(errorvar)' not in dataset"
  		continue , break 
		}		
	
		if "`r(errortype)'"=="1" {
  		di in r "Type should be one of c, tf, ts, r#" 
		continue , break 
		}		

		if "`r(errortdvar)'"=="1" {
  		di in r "Margin for comparison should be <[#] or >[#]" 
		continue , break 
		}
		
		if "`r(errormargin)'"=="1" {
  		di in r "Margin for comparison should be <[#] or >[#]" 
		continue , break 
		}
		
		}
		if "`r(errortype)'"=="1" | "`r(errorvar)'"!="" | "`r(errorrepvar)'"!="" | "`r(errortdvar)'"=="1" | "`r(errormargin)'"=="1" {
		 exit 
		}		
			
* --------------------------------------------
* Create single variable u_ij containing WLT 
* across hierarchy of components
* -------------------------------------------- 
tempvar u_ij
qui gen `u_ij'=X_comp1

* Wins/Losses at level 1
qui count if `u_ij'==1 & (`trtvar'_i==1 & `trtvar'_j==0)
	local w1=r(N)
qui count if `u_ij'==-1 & (`trtvar'_i==1 & `trtvar'_j==0)
	local l1=r(N)

local wcum=`w1'
local lcum=`l1'

* Replace untied values with wins/losses at subsequent levels
forvalues i=2/`comp_n' {
	qui replace `u_ij'=X_comp`i' if `u_ij'==0

* Count wins/losses at levels 2,3,...
	qui count if `u_ij'==1 & (`trtvar'_i==1 & `trtvar'_j==0)
	local w`i'=r(N)-`wcum'
	qui count if `u_ij'==-1 & (`trtvar'_i==1 & `trtvar'_j==0)
	local l`i'=r(N)-`lcum'
	local wcum=`wcum'+`w`i''
	local lcum=`lcum'+`l`i''
	}

* Final ties (includes possibilty of u_ij being missing if
* missing values in outcomes)
qui count if inlist(`u_ij', 0 , .) & (`trtvar'_i==0 & `trtvar'_j==1)
	local ties`m'=r(N)

* ---------------------------------------
* For Win Ratio compare wins/losses 
* only for Trt_1 v Trt_2 comparisons
* ---------------------------------------
qui count if `u_ij'==1 & (`trtvar'_i==1 & `trtvar'_j==0)
	local W`m'=r(N)
qui count if `u_ij'==-1 & (`trtvar'_i==1 & `trtvar'_j==0)
	local L`m'=r(N)
	local wr`m'=`W`m''/`L`m''

* ------------------------------------------------
* P-value/asymptotic CI
* ------------------------------------------------
* Step 1: calculate u_i for each person 
* 		 i.e. sum of u_ij for j=1 to N 
* ------------------------------------------------
tempvar u_i T 
qui bysort `idvar'_i:egen `u_i'=sum(`u_ij')
qui bysort `idvar'_i:keep if _n==1  
* ------------------------------------------------
* Step 2: calculate T = sum(u_i x d_i) where d_i 
*         is 1 if patient in active group 
*		  T is single value (not variable) 
* ------------------------------------------------
egen `T'=sum(`u_i'*(`trtvar'_i==1))
* ------------------------------------------------
* Step 3: Variance = (N1xN2)/(Nx(1-N))xSum(u_i^2)
* ------------------------------------------------
tempvar u_isq U_isq
qui gen `u_isq'=`u_i'^2 if `trtvar'_i==1
qui egen `U_isq'=sum(`u_i'^2)
qui sum `U_isq'
	local sumUisq=r(max)
qui count if `trtvar'_i==0
	local N1=r(N)
qui count if `trtvar'_i==1
	local N2=r(N)
	local N=`N1'+`N2'
	local V`m'=(`N1'*`N2')/(`N'*(`N'-1))*`sumUisq'

* -----------------------------------------------
* Step 4: calculate Z = T/sqrt(V)  -> p-value
* ------------------------------------------------
qui sum `T' 
	local T`m'=r(max)
local z=`T`m''/sqrt(`V`m'')
local p`m'=2*(1-normal(abs(`z')))
local pstr`m'=string(`p`m'',"`pformat'") 

* -----------------------------------------
* Step 5: Approximate 95% CI 
* -----------------------------------------
* See supplement to EHJ win ratio paper

local logwr`m'=log(`wr`m'')
local s`m'=`logwr`m''/`z'
local ll=string(exp(`logwr`m''-1.96*`s`m''),"`wrformat'")
local ul=string(exp(`logwr`m''+1.96*`s`m''),"`wrformat'")
local ci "(`ll', `ul')"
local wrrep`m'=string(`wr`m'', "`wrformat'")

* -------------------------------------
* Output
* -------------------------------------
if `m'==1 {
di in smcl in gr "{hline 60}
}

if "`strata'"!="" {
disp in gr "Strata: `stratlab'"
di in smcl in gr "{hline 60}
}

di "Total number of patients: " _col(35) `NP'
di "Number in control group: " _col(35) `NP0'
di "Number in active group: " _col(35) `NP1'
di "Number of comparisons: " _col(35) `Ncomps' 

di in smcl in gr "{hline 60}
di _col(20) "Wins"  _col(30) "Losses" _col(40) "Ties"
di in smcl in gr "{hline 60}

forvalues j=1/`comp_n' {
di "Outcome `j'" _col(20) `w`j''  _col(30) `l`j''
}

if "`saving'"!="" {
	local total_wins=0
	local total_losses=0
	forvalues j=1/`comp_n' {
		local total_wins=`total_wins'+`w`j''
		local total_losses=`total_losses'+`l`j''
		local ties=`Ncomps'-`total_wins'-`total_losses'
		post `post_results' (`j') (`w`j'') (`ties') (`l`j'') (`m')
		}
	}

di in smcl in gr "{hline 60}
di "Total" _col(20) `W`m''  _col(30) `L`m'' _col(40) `ties`m''
di in smcl in gr "{hline 60}

di "Win Ratio: `wrrep`m'', 95% CI`ci' P=`pstr`m''"
di in smcl in gr "{hline 60}

*-----------------------------------------
*Defining strata weights
*-----------------------------------------
if "`stweight'"=="unweighted"  {
	local weight`m'=1	
	local TotalWeight=`TotalWeight'+`weight`m''	
	}
if "`stweight'"=="mh" {
	local weight`m'=1/`N'
	local TotalWeight=`TotalWeight'+`weight`m''	
	}
if "`stweight'"=="iv" {
	local weight`m'=1/`V`m''
	local TotalWeight=`TotalWeight'+`weight`m''	
	}

restore , preserve  
}  // end of strata loop 


*-------------------------------------
* Stratified WR
* -------------------------------------
if "`strata'"!="" {
	local wsum=0
	local lsum=0
	local Tsum=0
	local Vsum=0
	local vstrat=0
	
foreach m of local M {
* Weighted sum of winners
	local wsum=`wsum'+`weight`m''*`W`m''	
* Weighted sum of losers 
	local lsum=`lsum'+`weight`m''*`L`m''	
	
* Alternative methodology as per ATTRACT/PARTNER trials
* Calculate sum of test statistic and sum of variance of test statistic and use this
if "`stweight'"=="unweighted" {
	local Tsum=`Tsum'+`T`m''
	local Vsum=`Vsum'+`V`m''
	}
	
	local ScaledWeight`m'=`weight`m''/`TotalWeight'          
	local var_contrib=`ScaledWeight`m''^2 * `s`m''^2
	local vstrat=`vstrat'+`var_contrib'  
	}	

/*
For unweighted win ratio the p-value is calculated by taking the sum of test statistics and comparing to the sum of variances. This approach has been used in ATTR-ACT (N Engl J Med 2018; 379:1007-1016) and PARTNER trials
*/ 
if "`stweight'"=="unweighted" {
	local wrstrat=`wsum'/`lsum'
	local z=`Tsum'/sqrt(`Vsum')
	local p=2*(1-normal(abs(`z')))
	local pstr=string(`p',"`pformat'") 
	local se_logwr=log(`wrstrat')/`z'
	local lci=string(exp(log(`wrstrat')-1.96*`se_logwr'),"`wrformat'")
	local uci=string(exp(log(`wrstrat')+1.96*`se_logwr'),"`wrformat'")
	}	

*For MH or IV weighting the p-value is calculated from the weighted null standard error 
if "`stweight'"!="unweighted" {
	local wrstrat=`wsum'/`lsum'
	local se_logwr=sqrt(`vstrat')
	local z=log(`wrstrat')/`se_logwr'
	local p=2*(1-normal(abs(`z')))
	local pstr=string(`p',"`pformat'") 
	local lci=string(exp(log(`wrstrat')-1.96*`se_logwr'),"`wrformat'")
	local uci=string(exp(log(`wrstrat')+1.96*`se_logwr'),"`wrformat'")
	}

local wrstrat1=string(`wrstrat' , "`wrformat'")

disp "Stratified Win Ratio: `wrstrat1' 95% CI (`lci', `uci') P=`pstr'"
di in smcl in gr "{hline 60}	
}

* ---------------------------------------
* Returned values 
* ---------------------------------------
if "`strata'"!="" {
foreach i of numlist `M'  {
	return scalar logwr`i' = log(`wr`i'')
	return scalar wr`i' = `wr`i''
	return scalar se`i' = `s`i''
	return scalar p`i' = `p`i''
	}
	}

	
if "`strata'"!="" {
	return scalar logwr = log(`wrstrat')
	return scalar wr = `wrstrat'
	return scalar se_logwr = `se_logwr'
	return scalar p = `p'
	}

if "`strata'"=="" {
	return scalar logwr = log(`wr1')
	return scalar wr = `wr1'
	return scalar se_logwr = `s1'
	return scalar p = `p1'
	}

	
if "`saving'"!="" {
	postclose `post_results'
	use `wr_results', clear
	save `"`saving'"'    `replace'
	}
* ---------------------------------------

end 






