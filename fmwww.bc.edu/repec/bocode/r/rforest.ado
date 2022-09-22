capture program drop rforest

program define rforest, eclass
*! version 2.0.1 Sep 19, 2022   default numvars set to floor(sqrt(number of vars))
	version 15.0
	
	syntax varlist(min=2) [if] [in] [,type(string) ITERations(int 100) ///
							Seed(int 1) Depth(int 0) LSize(int 1) ///
							Variance(real 0.049787) NUMDECimalplaces(int 5) ///
							NUMVars(int -9)]
	
	ereturn clear
	return clear
	sreturn clear
	
    local flag = 0

    foreach v of varlist `varlist' {
        capture confirm numeric variable `v'
		if _rc {
		    di as error "Error: Variable `v' is not numeric"
			local flag = 1
	    }
	}

	if (`flag'==1) {
	    exit 108
    }	
	
	if (`variance' < 0){
		di as error "Error: variance incorrectly specified"
		exit 198
	}
	
	// varlist includes y
	local count: word count `varlist'
	if `numvars'==(-9)  local numvars= floor(sqrt(`count'))   // by default use sqrt
	if (`numvars'> `count'-1) {
		di as error "Error: numvars argument specifies more x-variables than are available"
		exit 198
	}
	
	if (`iterations' <= 0 | `depth' < 0 | ///
	    `lsize' < 1 | `numdecimalplaces' < 1 | `numvars' < 1){
		di as error "Error: iterations, depth or numvars incorrectly specified"
		exit 198
	}
		
	quietly count
	local obs = r(N)
	if (`obs' <= 1) {
		di as error "Error: number of observations cannot be less than 2"
		exit 198
	}
	
	if ("`type'" != "reg" && "`type'" != "class"){
		di as error "Specify one of 'type(class)' or 'type(reg)'"
		exit 198
	}
	
	marksample touse , novarlist
	qui count if `touse'
	if (r(N)<1) {
		di as error "There are no observations"
		exit 2000
	}
	
	// check that y does not have missing values
	local y=word("`varlist'",1)
	qui count if missing(`y') & `touse'
	if (r(N)>0) {
		di as error "The dependent variable `y' contains missing values"
		exit 416  // missing value encountered in variable
	}
											 						
	if ("`type'" == "class"){
		quietly count
		local obs = r(N)
		forvalues i = 1/`obs'{
			if (`1'[`i'] < 0){
				di as error "Error: Class values cannot be negative."
				exit 107
			}
		}
		quietly levelsof `1', c
		local classlist = r(levels)
		scalar numClasses = 0
		javacall RF initUniqueClasses, args(classlist) jars(randomforest.jar weka.jar)
		foreach value of local classlist {
			scalar numClasses = numClasses + 1
			local t : label (`1') `value'
			javacall RF parseClassesString, args(t) jars(randomforest.jar weka.jar)
		}
	}
	
	javacall RF RFModel `varlist' `if' `in', args(`iterations' `seed' `depth' `lsize' `variance' `numdecimalplaces' `numvars' `type') jars(randomforest.jar weka.jar)
	ereturn scalar Observations = observations
	ereturn scalar features = attributes
	ereturn scalar Iterations = `iterations'
	if ("`type'" == "reg"){
		ereturn local model_type = "random forest regression"
	} 
	else {
		ereturn local model_type = "random forest classification"
	}
	ereturn local depvar "`1'"
	ereturn local predict "randomforest_predict"
	ereturn local cmd "rforest"
	ereturn scalar OOB_Error = scalar(OOB) // avoid name conflicts with variables starting with OOB
	ereturn matrix importance = VariableImportance
	
end
// Version History
// version 2.0.1 Sep 19, 2022: default numvars set to floor(sqrt(number of vars))
// version 2.0.0 Mar 2022: fixed Java bug; related to not being able to predict on unseen data
// version 1.9.0 Mar 2021: fixed Java bug "one line of dead code"
// version 1.8.0 Feb 2021: fixed Java bug related to reordering of variables in Stata 
// version 1.7.2 Mar 2020: fixed bug: "predict <newvar>" gave error when y didn't have a label. (See Scalar originalValueLabel)
// version 1.7.1 Mar 2020: added 2 error messages for "predict stub*" and "predict var1 var2" when "pr" is not specified
// version 1.7 Dec, 2019: use scalar() for ereturn to avoid name conflicts; missing values for y only on `touse' observations
// version 1.6 Sep, 2019: name change to rforest; "predict stub*" bug
// version 1.5 summer, 2019: check missing values for y