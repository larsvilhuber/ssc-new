*! version 1.0.0  31jan2022
*! requires arimaauto from SSC

program define xtarimau, rclass
	version 13.0
	/*
		Finds the best [S]ARIMA[X] models in heterogeneous panels with the help 
		of arimaauto (SSC). The user can run a command or program (= multiple   
		commands at a time) prior to and after the estimation, generating       
		eventual new variables. The estimates can be exported to a .ster file.  
		
		Author: Ilya Bolotov, MBA, Ph.D.                                        
		Date: 15 January 2022                                                   
	*/
	tempname timevar panelvar panelval ictests icarima limits models		///
			 title rspec cspec tmp
	tempfile tmpf

	// install dependencies, arimaauto                                          
	cap which arimaauto
	if _rc {
		ssc install arimaauto
	}

	// replay last result                                                       
	if replay() {
		if _by() {
			error 190
		}
		cap confirm mat r(models)
		if _rc {
			di as err "results of xtarimau not found"
			exit 301
		}
		/* copy return values                                                 */
		loc `ictests' `=r(ictests)'
		loc `icarima' `=r(icarima)'
		mat `limits'  = r(limits)
		mat `models'  = r(models)
		/* print output                                                       */
		cap confirm mat `models'
		if ! _rc {
			di as res _n "Best models for each time series:"
			loc `rspec' = "& - `= "& " * rowsof(`models')'"
			loc `cspec' = "& %12s | %5.0f & %5.0f & %5.0f & %5.0f & " +		///
						  "%5.0f & %5.0f & %6.0f | %12.4f &"
			matlist `models', title(``title'') rspec(``rspec'') cspec(``cspec'')
		}
		/* return output                                                      */
		cap ret        loc ictests  ``ictests''
		cap ret        loc icarima  ``icarima''
		cap ret hidden mat limits = `limits'
		cap ret        mat models = `models'
		exit 0
	}

	// syntax                                                                   
	syntax																	///
	[varlist(ts fv)] [if] [in] [iw] [,										///
		PREestimation(string asis) POSTestimation(string asis)				///
		export(string asis) *												///
	]

	// adjust and preprocess options                                            
	loc `tmp' = ustrregexm(`"`options'"', ".*ic\((\w+)\).*", 1)
	loc ic    = cond(ustrregexs(1) == "", "aic", ustrregexs(1))

	// get timevar, panelvar and panelval                                       
	qui tsset, noq
	loc `timevar'  = r(timevar)
	loc `panelvar' = r(panelvar)
	qui levelsof ``panelvar'', matrow(`panelval')
	loc `tmp'      = r(r) 

	// check if system limit is not exceeded                                    
	qui estimates dir
	if (`: word count `r(names)'' + ``tmp'') > 300 & `"`export'"' == "" {
		di as err															///
		"operation will exceed system limit, please add an export() option"
		exit 1000
	}

	// perform estimation                                                       
	qui ds ``panelvar'' ``timevar'', not			 // get the initial varlist
	loc `tmp' = r(varlist)
	cap estimates drop ts_*							 // drop xtarimau estimates
	mata: MS = J(0,8,.)								 // MS -> r(models)
	preserve
	forv i = 1/`=rowsof(`panelval') + 1' {
		/* restore, add eventual variables to the initial varlist             */
		restore
		if "`r(varlist)'" != "" {
			qui merge 1:1 ``panelvar'' ``timevar'' using `tmpf', update nogen
		}
		/* preserve, reduce the dataset to 1 time series and re-set the data  */
		preserve
		qui {
			keep ``panelvar'' ``timevar'' ``tmp''	 // the initial dataset
			keep if ``panelvar'' == `panelval'[`i',1]
			if `=_N' {								 // continue or break loop
				tsset, clear
				tsset ``timevar''
			}
			else {
				continue, break
			}
		}
		/* run preestimation command/program (= multiple commands)            */
		if `"`preestimation'"' != "" {
			`=cond(! strpos(`"`options'"', "trace"), "qui", "")'			///
			`preestimation'
		}
		/* run arimaauto, store/save estimates and fill MS -> r(models)       */
		`=cond(! strpos(`"`options'"', "trace"), "qui", "")'				///
		arimaauto `varlist' `if' `in' [`weight'`exp'], `options'
		mata: t  = st_matrix("r(tests)"); ms = st_matrix("r(models)");
		mata: u  = (mod(rows(t), 2) ? (floor((colsum(t[,1]) - 1) / 2),1)    ///
		                            : (floor(colsum(t[,1])       / 2),0))
		mata: c  = ("`ic'":==("llf", "aic","sic")) * (6::8)
		mata: r  = selectindex(ms[,c] :== (c == 6 ? max(ms[,c])             ///
		                                          : min(ms[,c])))
		mata: MS = MS\(ms[r,1],u[1],ms[r,2..3],u[2],ms[r,4..5],ms[r,c])
		loc `ictests' `=r(ictests)'					 // read from r(...)
		loc `icarima' `=r(icarima)'
		mat `limits'  = r(limits)
		if `"`export'"' == "" {
			qui estimates store ts_`i'
		}
		else {
			qui estimates save `"`export'"', append
		}
		cap drop _*									 // drop ancillary vars
		/* run postestimation command/program (= multiple commands)           */
		if `"`postestimation'"' != "" {
			`=cond(! strpos(`"`options'"', "trace"), "qui", "")'			///
			`postestimation'
		}
		/* pass eventual new variables to the dataset                         */
		qui {
			drop ``tmp''
			ds ``panelvar'' ``timevar'', not
			save `tmpf', replace
		}
		/* draw a dot                                                         */
		if ! strpos(`"`options'"', "trace") {
			di as txt "." _continue
		}
	}
	qui {
		tsset, clear								 // re-set the data
		tsset ``panelvar'' ``timevar''
	}
	
	// get models                                                               
	mata: st_matrix("`models'", MS)
	mata: if (rows(MS)) st_matrixrowstripe(                                 ///
		"`models'", (J(rows(MS),1,""),strofreal(1::rows(MS)))               ///
	);;
	mata: if (rows(MS)) st_matrixcolstripe(                                 ///
		"`models'", (J(8,1,""),("p","d","q","P","D","Q","const",            ///
		                        strupper("`ic'"))')                         ///
	);;

	// print output                                                             
	cap confirm mat `models'
	if ! _rc {
		di as res _n "Best models for each time series:"
		loc `rspec' = "& - `= "& " * rowsof(`models')'"
		loc `cspec' = "& %12s | %5.0f & %5.0f & %5.0f & %5.0f & " +			///
					  "%5.0f & %5.0f & %6.0f | %12.4f &"
		matlist `models', title(``title'') rspec(``rspec'') cspec(``cspec'')
	}

	// return output                                                            
	cap ret        loc ictests  ``ictests''
	cap ret        loc icarima  ``icarima''
	cap ret hidden mat limits = `limits'
	cap ret        mat models = `models'

	// clear memory                                                             
	estimates drop .
	mata: mata drop MS t ms u c r
end
