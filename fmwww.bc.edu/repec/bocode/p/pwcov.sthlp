{smcl}
{* 18may2023}{...}
{hline}
help for {hi:pwcov}
{hline}

{title:Generate pairwise covariances}

{p 8 17 2}{cmd:pwcov}
{it:varlist}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{it:weight}] 
[{cmd:,} {cmd:print} {cmd:save} ]


{title:Description}

{p 4 4 2}{cmd:pwcov} computes the variances and pairwise covariances between a number of
variables, using the available observations on each pair of variables to generate
the sample covariances. {cmd:fweights} and {cmd:pweights} are allowed.


{title:Options}

{p 4 8 2}{cmd:print} indicates that the matrix of covariances be printed.

{p 4 8 2}{cmd:save} indicates that four new variables should be created:
{cmd:pw_t}, {cmd:pw_tk}, {cmd:pw_cov} and {cmd:pw_N}. The first two variables
give the row and column indices of the covariance, provided in the third variable, 
while {cmd:pw_N} provides the number of observations used to compute that
covariance. These variables are added to the current data set, and must not already
exist.


{title:Examples}

{p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 
{p 4 8 2}{stata "reshape wide invest mvalue kstock time , i(year) j(company)" :. reshape wide invest mvalue kstock time , i(year) j(company)}

{p 4 8 2}{stata "pwcov invest1 invest2 invest3 invest4 invest5, print save" :. pwcov invest1 invest2 invest3 invest4 invest5, print save}


{title:Author}

{p 4 4 2}Christopher F. Baum, Boston College{break} 
       baum@bc.edu



{title:Acknowledgements}     

{p 4 4 2} The development of this routine was inspired by Peter Gottschalk. The current
version incorporates suggestions from Paul von Hippel and Leonardo Guizzetti on Statalist.
 

{title:Also see}

{p 4 13 2}On-line: {help pwcorr}


