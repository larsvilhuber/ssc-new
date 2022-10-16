{smcl}
{* *! version 1.0.0 30Sep2022}{...}
{title:Title}

{p2colset 5 21 22 2}{...}
{p2col:{hi:power tworoc} {hline 2}} Power analysis for a two-sample (independent or paired) ROC test  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}
Compute sample size

{p 8 43 2}
{opt power tworoc} {it:auc0} {it:auc1} {it:auc2}
[{cmd:,} {opth p:ower(numlist)} {opth a:lpha(numlist)} {opth ratio(numlist)} {opth corr(numlist)} {opt onesid:ed} {opt ord:inal} {opt gr:aph}[{cmd:(}{it:{help power_optgraph##graphopts:graphopts}}{cmd:)}] ]

{phang}
Compute power 

{p 8 43 2}
{opt power tworoc} {it:auc0} {it:auc1} {it:auc2}
[{cmd:,} {opth n(numlist)} {opth n1(numlist)} {opth n0(numlist)} {opth a:lpha(numlist)} {opth ratio(numlist)} {opth corr(numlist)} {opt onesid:ed} {opt ord:inal} 
{opt gr:aph}[{cmd:(}{it:{help power_optgraph##graphopts:graphopts}}{cmd:)}] ]


{phang}
where {it:auc0} is the null (hypothesized) area under the ROC curve (AUC) and
{it:auc1} and {it:auc2} are the alternative (target) AUCs. {it:auc0}, {it:auc1} and {it:auc2} may each be 
specified either as one number or as a list of values in parentheses 
(see {help numlist}).{p_end}


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opth alpha(numlist)}}significance level; default is {cmd:alpha(0.05)} {p_end}
{p2coldent:* {opth power(numlist)}}power; default is {cmd:power(0.80)} {p_end}
{p2coldent:* {opth n(numlist)}}total sample size; required to compute power or effect size {p_end}
{p2coldent:* {opth n1(numlist)}}sample size of the diseased group {p_end}
{p2coldent:* {opth n0(numlist)}}sample size of the non-diseased group {p_end}
{p2coldent:* {opth ratio(numlist)}}ratio of sample sizes, {cmd:N0/N1}; default is {cmd:ratio(1)}, meaning equal group sizes {p_end}
{p2coldent:* {opth corr(numlist)}}correlation between auc1 and auc2 when the same patients are being tested on both tests; default is {cmd:corr(0)}, 
meaning independent samples {p_end}
{synopt :{opt onesid:ed}}one-sided test; default is two sided{p_end}
{synopt :{opt ord:inal}}variance functions computed using Obuchowski et al. (2004) method; default is to use the method by Hanley and McNeil (1982) {p_end}
{synopt :{cmdab:gr:aph}[{cmd:(}{it:{help power_optgraph##graphopts:graphopts}}{cmd:)}]}graph results; see {manhelp power_optgraph PSS-2:power, graph}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* Specifying a list of values in at least two starred options, or 
two command arguments, or at least one starred option and one argument
results in computations for all possible combinations of the values; see
{help numlist}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt power tworoc} computes sample size or power for a two-sample receiver operating characteristic (ROC) analysis. 
When there is no correlation {cmd:corr(0)} between the two alternative AUCs ({it:auc1} and {it:auc2}), {opt power tworoc} 
computes sample size (power) for an independent two-sample test. When the correlation does not equal 0, {opt power tworoc} 
computes sample size (power) for a paired two-sample test. Variance functions are computed using either the method described 
in Obuchowski, Lieber and Wians (2004) for ordinal data assuming a binormal distribution, or the method described by Hanley and McNeil (1982) 
for continuous data which is based on the Mann-Whitney version of the rank-sum test (the default).     



{title:Options}

{phang}
{opth alpha(numlist)} sets the significance level of the test.  The
default is {cmd:alpha(0.05)}.

{phang} 
{opth power(numlist)} specifies the desired power at which sample size is to be computed. 
If {cmd:power()} is specified in conjunction with {cmd:n()}, {cmd:n1()}, or {cmd:n0()}, 
then the actual power of the test is presented.

{phang} 
{opth n(numlist)} specifies the total number of subjects in the study to be used for determining power. 

{phang}
{opth n1(numlist)} specifies the number of subjects in the diseased group to be used for determining power.

{phang} 
{opth n0(numlist)} specifies the number of subjects in the non-diseased group to be used for determining power. 

{phang}
{opth ratio(numlist)} specifies the sample-size ratio of the non-diseased group relative to the diseased group, 
{cmd:N0/N1}. The default is {cmd:ratio(1)}, meaning equal allocation between the two groups.

{phang}
{opth corr(numlist)} specifies the hypothesized correlation between {it:auc1} and {it:auc2}. When the same patients
take both diagnostic tests, we expect a correlation between the AUCs. When different groups of patients take
the two diagnostic tests (i.e. independent samples), we expect the correlation to be 0. The default is 
{cmd:corr(0)}, meaning independent samples.

{phang} 
{cmd:onesided(}{it:#}{cmd:)} indicates a one-sided test. The default is two sided. 

{phang} 
{cmd:ordinal(}{it:#}{cmd:)} uses the Obuchowski, Lieber, and Wians (2004) method for computing the variance functions, 
which is designed for use with ordinal data assuming a binormal distribution. The default is the method described by 
Hanley and McNeil (1982) for continuous data. 

{phang}
{cmd:graph}, {cmd:graph()}; see {manhelp power_optgraph PSS-2: power, graph}.


{title:Remarks: Using power tworoc}

{pstd}
{cmd:power tworoc} computes sample size or power for
a two-sample ROC analysis.  All computations are performed for a two-sided
hypothesis test where, by default, the significance level is set to 0.05. You
may change the significance level by specifying the {cmd:alpha()} option. You
can specify the {cmd:onesided} option to request a one-sided test.

{pstd}
To compute sample size, you must specify the AUCs under 
the null hypothesis ({it:auc0}) and the alternative hypotheses ({it:auc1} and {it:auc2}), 
and the power of the test in the {cmd:power()} option. The default power
is set to 0.80.  

{pstd}
To compute power, you must specify the sample size(s) in any of the {cmd:n()},
{cmd:n1()} or {cmd:n0()} options, along with the AUCs under the null and 
alternative hypotheses, {it:auc0}, {it:auc1} and {it:auc2}, respectively.

{pstd}
By default, the computed sample size is rounded up to the next integer.


{title:Examples}

    {title:Examples: Computing sample size}

{pstd}
    Compute the sample size required to detect a difference between two diagnostic tests
	where the hypopthesized AUCs are 0.70 and 0.90 and the null AUC is 0.50 for two independent
	samples, using a two-sided test and computing variances for continuous data; assume a 5% significance 
	level and 80% power (the defaults) {p_end}
{phang2}{cmd:. power tworoc 0.50 0.70 0.90}

{pstd}
    Same as above, using a power of 90% and a one-sided test, computing variances
	using Obuchowski et al (2004) method {p_end}
{phang2}{cmd:. power tworoc 0.50 0.70 0.90, power(0.90) onesided ordinal}

{pstd}
    Same as above, specifying a 4 to 1 ratio of non-diseased to diseased units, where the same patients are 
	tested on both diagnostic tests and assume a correlation of 0.45 between tests)	{p_end}
{phang2}{cmd:. power tworoc 0.50 0.70 0.90, power(0.90) onesided ordinal ratio(4) corr(0.45)}

{pstd}
    Same as above, but applying a range of AUC values under the {it:auc2}
	and setting alpha levels to 0.05 and 0.01; and graphing the results {p_end}
{phang2}{cmd:. power tworoc 0.50 0.70 (0.75(0.05)0.95), power(0.90) onesided ordinal ratio(4) alpha(0.01 0.05) corr(0.45) graph}


    {title:Examples: Computing power}

{pstd}
    For a total sample of 50 subjects, compute the power to detect a 
	difference between two diagnostic tests where the hypopthesized 
	AUCs are 0.70 and 0.90 and the null AUC is 0.50 for two independent
	samples, using a two-sided test and computing variances for continuous 
	data; assume a 5% significance 	level and 80% power (the defaults){p_end}
{phang2}{cmd:. power tworoc 0.50 0.70 0.90, n(112)}

{pstd}
    For a diseased group of 50 subjects and a ratio of 2 non-diseased patients for each diseased subject, 
	compute the power to detect a difference between two AUCs of 0.70 and 0.90, given a null AUC of 0.50 
	at the 5% significance level, computing variances for ordinal data{p_end}
{phang2}{cmd:. power tworoc 0.50 0.70 0.90, n1(50) ratio(2) ordinal}

{pstd}
    Same as above, but assume that the same patients take both tests and the correlation between AUCs is
	(0.60){p_end}
{phang2}{cmd:. power tworoc 0.50 0.70 0.90, n1(50) ratio(2) ordinal corr(0.25)}

{pstd}
    For a diseased group of 50 subjects and a non-diseased group of 80 subjects who took both diagnostic tests, 
	compute the power to detect a difference between two AUCs of 0.70 and 0.90, 
	given a null AUC of 0.50 at the 1% significance level, computing variances 
	for ordinal data and a correlation between AUCs of 0.30{p_end}
{phang2}{cmd:. power tworoc 0.50 0.70 0.90, n1(50) n0(80) alpha(0.01) ordinal corr(0.30)}

{pstd}
	Compute powers for a range of {it:auc2} and total sample sizes when {it:auc1} is 0.70 and the null ({it:auc0}) 
	is 0.50, graphing the results{p_end}
{phang2}{cmd:. power tworoc 0.50 0.70 (0.75(.05)0.95), n(10(5)120) graph}


{title:Stored results}

{pstd}
{cmd:power tworoc} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd: r(alpha)}}significance level{p_end}
{synopt:{cmd: r(auc0)}}null AUC{p_end}
{synopt:{cmd: r(auc1)}}alternative AUC1{p_end}
{synopt:{cmd: r(auc2)}}alternative AUC2{p_end}
{synopt:{cmd: r(beta)}}probability of a type II error{p_end}
{synopt:{cmd: r(delta)}}effect size{p_end}
{synopt:{cmd: r(divider)}}1 if divider is requested in the table, 0 otherwise{p_end}
{synopt:{cmd: r(ratio)}}ratio of sample sizes, N0/N1{p_end}
{synopt:{cmd: r(corr)}}correlation between AUC1 and AUC2{p_end}
{synopt:{cmd: r(N)}}total sample size{p_end}
{synopt:{cmd: r(N0)}}sample size of the non-diseased group {p_end}
{synopt:{cmd: r(N1)}}sample size of the diseased group {p_end}
{synopt:{cmd: r(onesided)}}1 for a one-sided test, 0 otherwise{p_end}
{synopt:{cmd: r(power)}}power{p_end}
{synopt:{cmd: r(V0)}}variance function of the null AUC {p_end}
{synopt:{cmd: r(V1)}}variance function of the alternative AUC1 {p_end}
{synopt:{cmd: r(V2)}}variance function of the alternative AUC2 {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(type)}}{cmd:test}{p_end}
{synopt:{cmd:r(method)}}{cmd:tworoc}{p_end}
{synopt:{cmd:r(columns)}}displayed table columns{p_end}
{synopt:{cmd:r(labels)}}table column labels{p_end}
{synopt:{cmd:r(widths)}}table column widths{p_end}
{synopt:{cmd:r(formats)}}table column formats{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(pss_table)}}table of results{p_end}
{p2colreset}{...}


{title:References}

{p 4 8 2} Hanley, J.A., and B. J. McNeil. 1982. The meaning and use of the area under a receiver operating characteristic (ROC) curve. {it:Radiology} 143:29-36 {p_end}

{p 4 8 2} Obuchowski, N.A., Lieber, M.L. and F.H. Wians Jr. 2004. ROC curves in clinical chemistry: uses, misuses, and possible solutions. {it:Clinical chemistry} 50:1118-1125.{p_end}


{marker citation}{title:Citation of {cmd:power tworoc}}

{p 4 8 2}{cmd:power tworoc} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2022). POWER TWOROC: Stata module to compute power and sample size for a two-sample (independent or paired) ROC analysis



{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb roc}, {helpb power}, {helpb power oneroc} (if installed) {p_end}
