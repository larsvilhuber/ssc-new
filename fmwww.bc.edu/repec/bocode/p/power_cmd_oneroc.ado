*! 1.0.1 Ariel Linden 01Jul2022 // fixed default null hypothesis, various error messages, and added return scalar for variance function  
*! 1.0.0 Ariel Linden 21Jun2022

capture program drop power_cmd_oneroc
program power_cmd_oneroc, rclass
	
version 11.0
	
	
        /* obtain settings */
		syntax anything(id="numlist"),	///
			[ Alpha(real 0.05) 		/// significance level
			n(string) 				/// total sample size
			n1(string) n0(string) 	/// group sample sizes (n1 = cases; n0 = controls)
			Kappa(real 1)			/// ratio N0 (controls) / N1 (cases)
			Power(string)  			///
			ONESIDed				///
			]						///

			gettoken auc1 rest : anything
			gettoken auc0 rest : rest
			
			numlist "`anything'", min(1) max(2)
			local variable_tally : word count `anything'
			
			if `auc1' < 0.50 | `auc1' > 1.0 { 
				di as err "auc1 must contain numbers between 0.50 and 1.0"
				exit 198
			}
			
			// set default null hypothesis to 0.50 if not specfied
			if (`variable_tally' == 1) {
				local auc0 = 0.50
			}
			
			if `auc0' < 0.50 | `auc0' > 1.0 { 
				di as err "auc0 must contain numbers between 0.50 and 1.0"
				exit 198
			}
			
			// set default test type to "twosided"  
			if "`onesided'" == "" {
				local test = `alpha'/ 2
			}
			else local test = `alpha'

			*******************************
			**** compute sample size ******
			*******************************
			if (`"`n'`n1'`n0'"' == "") {
				tempname zalpha zbeta v0 delta A vA n1 n0 n
				scalar `zalpha' = invnorm(1-`test')
				scalar `zbeta' = invnorm(`power')
				scalar `v0' = 0.0792 * (1 + 1 / `kappa')
				scalar `delta' = `auc1' - `auc0'
				scalar `A' = invnorm(`auc1') * 1.414
				scalar `vA' = (0.009 * exp(-`A'^2 / 2)) * ((5 * `A'^2 + 8) + (`A'^2 + 8) / `kappa')
				scalar `n1' = ceil(((`zalpha' * sqrt(`v0') + `zbeta' * sqrt(`vA')) ^ 2 / `delta' ^ 2))
				scalar `n0' = ceil(`n1' * `kappa')
				scalar `n' = `n1' + `n0'
			} // end sample size
	
			*************************
			**** compute power ******
			*************************
			else if (`"`n'`n1'`n0'"' != "") {	
				
				//complete sample-size specifications
				if (`"`n'"'=="") {
					tempname n
					if (`"`n0'"'=="") {
					tempname n0
					scalar `n0' = ceil(`kappa'*`n1')
					}
					else if (`"`n1'"'=="") {
						tempname n1
						scalar `n1' = ceil(`n0'/`kappa')
					}
					scalar `n' = `n1'+`n0'
					local nratio = `n0'/`n1'
				} // end n == ""
				else {
					if (`"`n1'"'!="") {
						tempname n0
						scalar `n0' = `n' - `n1'
					}
					else if (`"`n0'"'!="") {
						tempname n1
						scalar `n1' = `n' - `n0'
					}
					else {
						tempname n1 n0
						scalar `n1' = ceil(`n'/(1+`kappa'))
						scalar `n0' = `n'-`n1'
					}
				} // end sample-size specifications
				
				tempname zalpha v0 delta A vA power 
				scalar `zalpha' = invnorm(1-`test')
				scalar `v0' = 0.0792 * (1 + 1 / `kappa')
				scalar `delta' = `auc1' - `auc0'
				scalar `A' = invnorm(`auc1') * 1.414
				scalar `vA' = (0.009 * exp(-`A'^2 / 2)) * ((5 * `A'^2 + 8) + (`A'^2 + 8) / `kappa')
				scalar `power' = normal(((sqrt(`n1' * `delta' ^ 2) - `zalpha' * sqrt(`v0')) / sqrt(`vA')))
			} // end power
		
			// saved results
			return scalar N = `n'
			return scalar N1 = `n1'
			return scalar N0 = `n0'
			return scalar alpha = `alpha'
			return scalar power = `power'
			return scalar auc1 = `auc1'
			return scalar auc0 = `auc0'
			return scalar delta = `delta'
			return scalar kappa = `kappa'
			return scalar variance = `vA'
		
end
