{smcl}
{* *! version 1.1.0  28Oct2016}{...}
{* *! version 1.0.0  21Aug2016}{...}
{cmd:help pstrata}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:pstrata} {hline 2}}Optimal propensity score stratification {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
		{cmd:pstrata} {it:{help varname:treat}} {ifin} 
		{cmd:,}
		{opt ps:core}({it:{help varlist:varlist}})
		[ {opt smi:n(#)}
		{opt sma:x(#)}
		{opt p:level(#)}
		{opt com:mon}
		{opt repl:ace} 
		{opt pre:fix}({it:string})
		]

		
{p 4 4 2}
{it:{help varname: treat}} must contain integer values representing the treatment levels


{synoptset 19 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt ps:core}{cmd:(}{it:{help varlist:varlist}}{cmd:)}}{cmd:required.} One or more propensity scores must be provided, depending on the number of treatment levels{p_end}
{synopt:{opt smi:n}{cmd:(#}{cmd:)}}minimum number of quantiles to start with; default is {cmd:5}{p_end}
{synopt:{opt sma:x}{cmd:(#}{cmd:)}}maximum number of quantiles to be tested; default is {cmd:50}{p_end}
{synopt:{opt p:level}{cmd:(#}{cmd:)}}significance level of the test for assessing balance on the propensity score; default is {cmd:0.05}{p_end}
{synopt:{opt com:mon}}use only those observations within the region of common support when generating quantiles {p_end}
{synopt:{opt repl:ace}}replace the strata variables created by {cmd:pstrata} if they already exist {p_end}
{synopt:{opt pre:fix}}adds a prefix to the names of the strata variables created by {cmd:pstrata}; default name is {it:strata1}, {it:strata2}, etc. {p_end}
{synoptline}
{p2colreset}{...}
		
{p 4 6 2}

{title:Description}

{pstd}
{opt pstrata} stratifies the propensity score into an optimal number of quantiles (meaning, strictly, quantile-based bins), where {it:optimal} means that no statistical 
differences are found between treatment groups within any quantile of the propensity score. In general, stratification (also referred to as {it:subclassification}) allows the 
investigator to analyze outcomes between treatment groups within each quantile as well as to observe overall differences between groups across all quantiles (Linden & Adams 2008). 
It has been shown that stratification of the propensity score into five quantiles can remove over 90% of the initial bias due to the covariates used to create 
the propensity score (Cochran 1968; Rosenbaum & Rubin 1984). While the strata generated by {opt pstrata} can be used in any subsequent analysis, it was specifically intended 
for use in conjunction with {help mmws}; which can be downloaded from {help ssc:SSC}.

{pstd}
Before using {opt pstrata}, the propensity score for a given treatment must be estimated. A logit or probit regression model can be used for estimating the propensity score 
for a binary treatment and a multinomial logistic or probit regression can be used for estimating propensity scores for multiple treatment levels. {opt pstrata} then generates 
one or more strata variables (named {it:strata1}, {it:strata2}, etc.), depending on the number of treatment groups in the study. 


{title:Remarks}

{pstd}
{opt pstrata} implements an iterative process to generate the optimal number of quantiles of the propensity score. {help xtile} initially stratifies the propensity
score into 5 quantiles (or any other user-specified minimum number, using {opt smin()}). The propensity score is then regressed on the treatment variable 
within each quantile to assess whether the propensity score is balanced between the treatment groups under study (i.e. treatment groups are not statistically different, 
based on {opt plevel()}). If the propensity score is imbalanced within any quantile, xtile is reissued adding one additional quantile, and balance is again assessed. 
This procedure continues until one of the following conditions are met: 

{pstd}
(1) the propensity score is balanced within all quantiles or, 

{pstd}
(2) there is at least one treatment group within a given stratum with zero observations or, 

{pstd}
(3) the maximum number of quantiles has been reached (i.e. {opt smax()}) but balance is not achieved or, 

{pstd}
(4) there is an insufficient number of observations within any given quantile to statistically test balance. 

{pstd}
If the first condition is met, then the program ends with the optimal number of quantiles being determined (that is, the minimum number of quantiles has been found with 
no statistically significant differences on the propensity score between treatment groups). If any of conditions 2-4 are met, the program terminates and an error
message is displayed indicating in which strata the error was identified. When the study involves multiple treatment levels (groups), this process continues iteratively 
across each respective propensity score. With multiple treatments, it is imperative that balance be achieved across all propensity scores, not only a subset. Thus {opt pstrata} 
will error out if conditions 2-4 are met within any of the propensity scores.

{pstd}
When {opt pstrata} errors out due to conditions 2-4, the user should consider re-estimating the propensity score(s), collapsing one or more treatment arms, and/or experimenting 
with the various command options, until a viable solution is achieved.    

{pstd}
It is important to note that balance on the propensity score does not ensure that balance has been achieved on the underlying covariates. Thus, after implementing {opt pstrata},
balance should be tested on the covariates underlying each propensity score, and within each strata using {help covbal}; downloadable from {help ssc:SSC}. If
covariate balance has not been achieved, or if balance on the propensity score itself has not achieved, the propensity score(s) should be re-estimated using additional 
covariates (if available) as well as interactions between covariates and polynomials of continuous variables. At least in theory, a well estimated propensity score should accurately
represent the underlying covariates. 

		
{title:Options}

{phang}
{opth pscore(varlist)} {cmd:required.} For binary or ordinal level treatments, one propensity score must 
be provided. For multiple nominal level treatments, one propensity score must be provided for {it:each} treatment level and they must be 
ordered correspondingly (e.g. ps1 ps2 ps3 correspond to treatment levels 0 1 2, respectively).{p_end}

{phang}
{opth smin(#)} indicates the number of quantiles that {opt pstrata} will start with; the default is {cmd:5}.{p_end}

{phang}
{opth smax(#)} indicates the maximum number of quantiles that {opt pstrata} will test; the default is {cmd:50}.{p_end}

{phang}
{opth plevel(#)} indicates the significance level of the ANOVA model used for testing balance on the propensity score; the default is {cmd:0.05}.{p_end}

{phang}
{opt common} restricts generation of quantiles to those observations within the region of common support.{p_end}

{phang} 
{opt replace} replaces the strata variables created by {cmd:pstrata} if they already exist. If {cmd:prefix()} is specified, only the strata variables created by {cmd:pstrata} with
the same prefix will be replaced.{p_end}

{phang}
{opt prefix(string)} adds a prefix to the names of the strata variables created by {cmd:pstrata}. Short prefixes are recommended.{p_end}


{title:Examples}

{pstd}Load example data{p_end}
{p 4 8 2}{stata "webuse cattaneo2, clear":. webuse cattaneo2, clear}{p_end}

{pstd}
{opt (1) Binary treatment:}{p_end}

{pstd}Estimate propensity score for the binary treatment {cmd:mbsmoke} and use {opt pstrata} to generate an optimal number of quantiles with the default settings{p_end}
{p 4 8 2}{stata "logit mbsmoke mmarried mage c.mage#c.mage fbaby medu":. logit mbsmoke mmarried c.mage##c.mage fbaby medu}{p_end}
{p 4 8 2}{stata "predict pscore, pr":. predict pscore, pr}{p_end}
{p 4 8 2}{stata "pstrata mbsmoke, ps(pscore)":. pstrata mbsmoke, ps(pscore)}{p_end}

{pstd}Review the p-values estimated for each stratum{p_end}
{p 4 8 2}{stata "matrix list r(pval1)":. matrix list r(pval1)}{p_end}

{pstd}Use the strata variable generated by {opt pstrata} to generate {helpb mmws} weights{p_end}
{p 4 8 2}{stata "mmws mbsmoke, pscore(pscore) strata(strata1)":. mmws mbsmoke, pscore(pscore) strata(strata1)}{p_end}

{pstd}Examine covariate balance, within strata, with {helpb covbal} using the weights generated in the previous run {p_end}
{p 4 8 2}{stata "bys strata1: covbal mbsmoke pscore mmarried mage fbaby medu, abs for(%9.3f) wt( _mmws)":. bys strata1: covbal mbsmoke pscore mmarried mage fbaby medu, abs for(%9.3f) wt( _mmws)}{p_end}

{pstd}Estimate average treatment effects of {cmd:mbsmoke} on {cmd:bweight} using MMWS weights generated in the previous run {p_end}
{p 4 8 2}{stata "regress bweight mbsmoke [pw=_mmws], robust":. regress bweight mbsmoke [pw=_mmws], robust}{p_end}


{pstd}
{opt (3) Multiple treatments:}{p_end}

{pstd}Load example data{p_end}
{p 4 8 2}{stata "webuse cattaneo2, clear":. webuse cattaneo2, clear}{p_end}

{pstd}Estimate propensity scores for the four treatment levels of {cmd:msmoke} and generate four strata variables corresponding to each treatment, respectively. {p_end}
{p 4 8 2}{stata "mlogit msmoke mage medu fage fedu c.mage#c.mage c.mage#c.medu c.mage#c.fage c.mage#c.fedu c.medu#c.medu, base(0)":. mlogit msmoke mage medu fage fedu c.mage#c.mage c.mage#c.medu c.mage#c.fage c.mage#c.fedu c.medu#c.medu, base(0)}{p_end}

{p 4 8 2}{stata "predict double (ps1 ps2 ps3 ps4), pr":. predict double (ps1 ps2 ps3 ps4), pr}{p_end}
{p 4 8 2}{stata "pstrata msmoke, ps(ps1 ps2 ps3 ps4)":. pstrata msmoke, ps(ps1 ps2 ps3 ps4)}{p_end}


{pstd}Generate weights for nominal treatments using the strata variable created in the previous step {p_end}
{p 4 8 2}{stata "mmws msmoke, pscore(ps1 ps2 ps3 ps4) nominal strata(strata1 strata2 strata3 strata4)":. mmws msmoke, pscore(ps1 ps2 ps3 ps4) nominal strata(strata1 strata2 strata3 strata4)}{p_end}

{pstd}Estimate average treatment effect of each level of {cmd:msmoke} on {cmd:bweight} using MMWS weights generated in the previous run {p_end}
{p 4 8 2}{stata "regress bweight i.msmoke [pw=_mmws], robust":. regress bweight i.msmoke [pw=_mmws], robust}{p_end}

{pstd}Run margins to get reweighted mean {cmd:bweight} for each level of {cmd:msmoke}{p_end}
{p 4 8 2}{stata "margins msmoke":. margins msmoke}{p_end}

{pstd}Run marginsplot to visually display reweighted mean {cmd:bweight} for each level of {cmd:msmoke}{p_end}
{p 4 8 2} {stata "marginsplot,  plotopts(connect(i))": . marginsplot,  plotopts(connect(i))}{p_end}

{pstd}Run pairwise comparisons between reweighted treatment levels, with Bonferroni adjustment for multiple tests  {p_end}
{p 4 8 2}{stata "margins msmoke, pwcompare(effects) mcompare(bonferroni)":. margins msmoke, pwcompare(effects) mcompare(bonferroni)}{p_end}


{title:Saved results}

{p 4 8 2}
By default, {cmd:pstrata} returns the following results, which 
can be displayed by typing {cmd: return list} after 
{cmd:pstrata} is finished (see {help return}).  

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(suppmin)}}the minimum value of common support (will have a suffix for multiple treatments){p_end}
{synopt:{cmd:r(suppmax)}}the maximum value of common support (will have a suffix for multiple treatments){p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(pval)}}the p-values for each quantile (will have a suffix for each respective propensity score, e.g. {it:pval1}) {p_end}


{title:References}

{p 4 8 2}
Cochran, W. G. 1968. The effectiveness of adjustment by subclassification
in removing bias in observational studies. {it:Biometrics} 24: 205{c -}213.

{p 4 8 2}
Linden, A. 2014. Combining propensity score-based stratification and weighting to improve 
causal inference in the evaluation of health care interventions. {it:Journal of Evaluation in Clinical Practice} 20: 1065{c -}1071.

{p 4 8 2}
Linden, A. & Adams, J. L. 2008. Improving participant selection in
disease management programs: insights gained from propensity score
stratification. {it:Journal of Evaluation in Clinical Practice} 14, 914{c -}918.

{p 4 8 2}
Linden, A., Uysal, S. D., Ryan, A., & Adams, J. L. 2016. Estimating causal effects for multivalued treatments: 
A comparison of approaches. {it:Statistics in Medicine} 35: 534{c -}552.

{p 4 8 2} 
Rosenbaum, P. R. & Rubin, D. B. 1984. Reducing bias in observational
studies using subclassification on the propensity score. {it:Journal of the American Statistical Association} 79, 516{c -}524.



{marker citation}{title:Citation of {cmd:pstrata}}

{p 4 8 2}{cmd:pstrata} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, A. 2016. pstrata: Stata module for implementing optimal propensity score stratification. {browse "http://ideas.repec.org/c/boc/bocode/s458232.html": http://ideas.repec.org/c/boc/bocode/s458232.html} {p_end}


{title:Author}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
Ann Arbor, MI, USA{break} 
{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{break}
{browse "http://www.lindenconsulting.org"}{p_end}

        
{title:Acknowledgments} 

{p 4 4 2}
I wish to thank Nicholas J. Cox for his support while developing {cmd:pstrata}.{p_end}


{title:Also see}

{p 4 8 2}Online:  {helpb xtile}, {helpb logit}, {helpb mlogit}, {helpb margins}, {helpb marginsplot}, {helpb teffects},  
 {helpb mmws} (if installed), {helpb covbal} (if installed) {p_end}
