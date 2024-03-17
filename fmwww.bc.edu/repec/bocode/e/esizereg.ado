*! 3.0.0 Ariel Linden 07Mar2024 // added Hedges g option
								// -esizereg- now uses variance produced by margins to compute pooled std. dev. 
*! 2.0.2 Ariel Linden 26Feb2024 // added -intreg-, -meintreg- and -metobit- models
*! 2.0.1 Ariel Linden 27Oct2021 // changed 'est' to a scalar to avoid issues with squaring negative values (which happens with local)
*! 2.0.0 Ariel Linden 29May2019 // made esizereg a postestimation command and converted version 1.0.0 to an immediate command (esizeregi)
*! 1.0.0 Ariel Linden 02Feb2019

capture program drop esizereg
program define esizereg, rclass
version 11.0

			syntax anything [, COHensd HEDgesg LEVel(cilevel) ] 
			
			gettoken treat : 0
			// * store model estimates * //
			if "`e(cmd)'" == "margins" {
				di as err "You must re-estimate the regression model"
				exit 198				
			}
			else estimates store results

			if !inlist("`e(cmd)'", "regress", "tobit", "truncreg", "hetregress", "xtreg", "intreg") & !inlist("`e(cmd2)'", "meintreg", "metobit") {
				di as err `"`e(cmd)' is not supported by {bf:esizereg}"'
				exit 198
			}	
			
			// * verify that the previous model estimates are available * //
			capture assert matrix list r(table)
				if _rc { 
					qui estimates restore results
					qui estimates replay results
				}
	
			// * save table of estimates as matrix * //
			qui matrix b = r(table)
			
			
			// * generate error if treat(name) is not in regression table * //  
			local colnames : colnames b
			if !`: list treat in colnames' {
				di as err "The regressor {bf:`treat'} is not found." ///
				" Use the model's option -coeflegend- to display coefficient names"
				exit 498
			}
			
			tempname est
			scalar `est' = b[1,colnumb(matrix(b),"`treat'")]
			
			local weightexp `e(wtype)' `e(wexp)'
				
			// extract treat varname from that produced in -regress- using factor variables (e.g. 1.treat) 
			local treatvar = substr("`treat'", strpos("`treat'", ".") + 1, .)
				
			// * ensure binary variable *
			qui tabulate `treatvar' if e(sample) 
				if r(r) != 2 { 
					di as err "With a binary treatment, {bf:`treatvar'} must have exactly two values (coded 0 or 1)."
					exit 420  
				} 
			else if r(r) == 2 { 
				capture assert inlist(`treat', 0, 1) if e(sample)
				if _rc { 
					di as err "With a binary treatment, {bf:`treatvar'} must be coded as either 0 or 1."
					exit 450 
				}
			}
			
			// * get N per group * //
			qui count if `treatvar' == 1 & e(sample)
			local n1 = r(N)
			qui count if `treatvar' == 0 & e(sample)
			local n0 = r(N)

			// * get variance of model using margins * //
			tempname V  N sdpooled d v se iz CohensD_Lower CohensD_Upper 
			
			if "`e(cmd)'" == "meglm" {
				qui margins, post predict(mu fixed)
			}
			else {
				qui margins, post
			}
			matrix `V' = r(V)
			scalar `V' = `V'[1,1]
			scalar `N' = `n1' + `n0'

			// CALCULATE COHEN'S D
			// ==============================================================
			scalar `sdpooled' = sqrt(`V' * `N')		
			scalar `d' = `est' / `sdpooled'
			scalar `v' = (`n1' + `n0') / (`n1' * `n0') + (`d'^2) / (2 *(`n1' + `n0'))
			scalar `se' = sqrt(`v')
			scalar `iz' = invnorm(1-(1-`level'/100)/2)
			scalar `CohensD_Lower' = `d' - `iz' * sqrt(`v')
			scalar `CohensD_Upper' = `d' + `iz' * sqrt(`v')
			
			// CALCULATE HEDGE'S G 
			// =================================================================
			// EXACT BIAS CORRECTION: Hedges (1981) pg 111, Equation 6e
			tempname m BiasCorrectionFactor g HedgesG_Lower HedgesG_Upper
			scalar `m' = (`n1'+`n0'- 2)
			scalar `BiasCorrectionFactor' = exp(lngamma(`m'/2) - 1/2 * ln(`m'/2) - lngamma((`m'-1)/2))
			// Turner & Bernard (2006) , Eq 4
			scalar `g' = `d' * `BiasCorrectionFactor'
			scalar `HedgesG_Lower' = `CohensD_Lower' * `BiasCorrectionFactor'
			scalar `HedgesG_Upper' = `CohensD_Upper' * `BiasCorrectionFactor'


			// DISPLAY OUTPUT
			// ====================================================================
			// SET DEFAULT OUTPUT
			if "`cohensd'"== "" & "`hedgesg'"== "" {                       
				local cohensd "cohensd"
				local hedgesg "hedgesg"
			}

			
			// Display Title (weighted or unweighted)
			if "`weightexp'" == "" {
				disp _newline as text "Effect size based on the regression coefficient of the treatment (exposure) variable"
            }
			else {
				disp _newline as text "{bf:Weighted} effect size based on the regression coefficient of the treatment (exposure) variable"
			}
			
			// Display table header information 
			disp _newline %45s "Obs per group:"
			disp %47s "Group 1 = " %10.0fc `n1'
			disp %47s "Group 2 = " %10.0fc `n0'
      
			// Display output table
			tempname mytab
			.`mytab' = ._tab.new, col(5) lmargin(0)
			.`mytab'.width    20   |11  12  12    12
			.`mytab'.titlefmt  .     .   . %24s   .
			.`mytab'.pad       .     1   1  3     3
			.`mytab'.numfmt    . %9.6f %9.6f %9.6f %9.6f
			.`mytab'.strcolor result  .  .  .  .
			.`mytab'.strfmt    %19s  .  .  .  .
			.`mytab'.strcolor   text  .  .  .  .
			.`mytab'.sep, top
			.`mytab'.titles "Effect Size"							/// 1
							"Estimate"								/// 2
							"Std. Err."								/// 3
							"[`level'% Conf. Interval]" ""          //  4 5
			.`mytab'.sep, middle
                .`mytab'.strfmt    %24s  .  .  .  .
			if "`cohensd'" != "" {
                .`mytab'.row    "Cohen's {it:d}"        ///
                        `d' 	                      	///
                        `se'							///
						`CohensD_Lower'                 ///
                        `CohensD_Upper'
			}	
			if "`hedgesg'" != "" {
                .`mytab'.row    "Hedges's {it:g}"       ///
                        `g' 	                      	///
                        `se'							///
						`HedgesG_Lower'                 ///
                        `HedgesG_Upper'
			}
				.`mytab'.sep, bottom

			// Return results
			if "`hedgesg'" != "" {
                return scalar ub_g = `HedgesG_Upper'
                return scalar lb_g = `HedgesG_Lower'
                return scalar g = `g'
			}
			if "`cohensd'" != "" {
                return scalar ub_d = `CohensD_Upper'
                return scalar lb_d = `CohensD_Lower'
                return scalar d = `d'
			}
			
			return scalar se = `se'
			return scalar n2 = `n0'
			return scalar n1 = `n1'
			return scalar sdpooled = `sdpooled'
			return scalar V = `V'			
			return scalar est = `est'
	
			// Make a c_local macro of d, g and se 
			c_local d = `d'
			c_local g = `g'			
			c_local se = `se'

end
