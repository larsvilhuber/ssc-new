{smcl}
{* *! version 1.0.0 MLB 28Mar2016}{...}
{cmd:help stdtable}
{hline}

{title:Title}

{phang}
{bf:stdtable} {hline 2} Standardize cross-tabulations to pre-specified row and column totals

{title:Syntax}

{p 8 17 2}
{cmd:stdtable} 
{help varname:rowvar} 
{help varname:colvar}
{ifin}
{weight}
{cmd:,} {it:options}


{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{cmd:by(}{it:{varname}}{cmd: [, }{opt base:line(#|string)}{cmd:])}}specifies
        a numeric or string variable to be treated as {it:superrow}. The 
        {cmd:baseline()} sub-option specifies the value in {it:varname} to which 
        the tables are standardized.{p_end}
{synopt:{opt baser:ow(matrix)}}matrix with row totals to which the table(s) are
        standardized{p_end}
{synopt:{opt basec:ol(matrix)}}matrix with column totals to which the table(s) are
        standardized{p_end}

{p 41 43 0}The default is to standardize to row and column totals of all 100s if the table
is square, and to row totals of 100/(number of rows) and column totals of 
100/(number of columns) if the table is not square.

{synopt:{opt row}}Standardize such that they can be interpreted as standardized
row percentages.{p_end}
{synopt:{opt col}}Standardize such that they can be interpreted as standardized
column percentages.{p_end}

{synopt:{opth f:ormat(%fmt)}}specifies the display format for the output{p_end}
{synopt:{opt raw}}also displays the raw counts.{p_end}
{synopt:{opt replace}}replace current data with standardized (and raw) counts.{p_end}

{syntab:IPF options}
{synopt:{opt tol:erance(#)}}tolerance for the standardized counts; default is 1e-6{p_end}
{synopt:{opt iter:ate(#)}}perform maximum of # iterations; default is 
        {cmd:iterate(16000)}{p_end}
{synopt:{opt log}}display an iteration log of the maximum relative change in 
        estimated standardized counts and max relative difference between the row
        totals and target row totals.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:fweight}s, {cmd:aweight}s, and {cmd:iweight}s are allowed; see {help weight}.


{title:Description}

{pstd} {cmd:stdtable} standardizes a cross-tabulation such that the
by fixing the row and column totals (Yule 1912, Mosteller 1968,
Agresti 2002: 345-346). These standardized counts are estimated
using Iterative Proportional Fitting. By default it sets all the
row and column totals to 100 if the number of columns is the same
as the number of rows. Consider the following example from
Featherman and Hauser (1978) using data collected in the USA as a
supplement to the March Current Population Survey by the U.S.
Bureau of the Census in 1973:

{cmd} 
    . preserve
    . use "http://www.maartenbuis.nl/software/mob.dta", clear
    . tab row col [fw=pop],
    . restore
{txt}
{p 4 4 2}({stata "stdtable_ex 1":click to run}){p_end}

{pstd} There are many more people that went from a farm to lower
manual than the other way around. However, the number of people in
agriculture strongly declined so sons had to leave the farm.
Moreover, the number of people in lower manual occupations were on
the increase, offering room for those sons that had to leave their
farm.({help stdtable_foot##fert:1}){marker fert} We may be
interested in knowing if this asymmetry is completely explained by
these changes in the marginal distribution, or if there is more to
it. We could look at row (outflow) percentages, but than we only
control for the distribution of the father's occupation. Similarly,
the column (inflow) percentages only control for the distribution
of son's occupation. What we want is something that does both
simultaneously, i.e. fix both the column totals and the row totals
to 100. This is what {cmd:stdtable} does:

{cmd} 
    . preserve
    . use "http://www.maartenbuis.nl/software/mob.dta", clear
    . stdtable row col [fw=pop],
    . restore
{txt}
{p 4 4 2}({stata "stdtable_ex 2":click to run}){p_end}

{pstd} These standardized counts can be interpreted as the row and
column percentages that would occur if for both fathers and sons
each occupation was equally likely. It appears that the apparent
asymmetry was almost entirely due to changes in the marginal
distributions. Also, it is now much clearer that farming is much
more persistent over generations than the other occupations.

{pstd} This table shows the counts that would have occurred when
the odds ratios (effects) are the same as in the data, but the row
and column totals were all 100. By setting the row and column
totals to all the same number we filter out the effect of the
marginal distribution. Setting the row and column totals to a 100
works when we have the same number of rows and columns. If the
number of rows and columns differ then the total sample size
implied by summing the row totals would not match the total sample
size when summing the column totals. In that case the default
margins will the 100 / (number of columns) for the column totals
and 100 / (number of rows) for row totals. These standardized
counts can be interpreted as the cell percentages that would have
occurred if each category was equally likely to occur.

{pstd} Standardizing tables can also be useful to compare tables
with different marginal distributions. In the example below we look
at the race of husbands and wives in the USA for married couples
whose husbands were born born between 1821 and 1989 using the 1880
till 2000 censuses and the 2001 till 2014 American Comunity
Surveys. We can see that the racial boundaries have become a bit
more permeable over time, but that the USA is still very far
removed from being a melting pot.

{cmd} 
    . preserve
    . use "http://www.maartenbuis.nl/software/interracial.dta", clear
    . stdtable hrace wrace [fw=_freq], by(coh)
    . restore
{txt}
{p 4 4 2}({stata "stdtable_ex 3":click to run}){p_end}

{pstd} The standardized table can be left in memory using the
{cmd:replace} option, which can be useful for graphing that table.
Nick Cox's {stata "ssc desc tabplot":tabplot} is nice for this.

{cmd} 
    . preserve
    . use "http://www.maartenbuis.nl/software/interracial.dta", clear
    . stdtable hrace wrace [fw=_freq], by(coh) replace
    . tabplot hrace coh [iw=std],                       ///
    >    by(wrace, compact cols(3) note(""))            ///
    >    xtitle("husband's birth cohort" "wife's race") ///
    >    xlab(1(2)18,angle(35) labsize(vsmall))
    . restore
{txt}
{p 4 4 2}({stata "stdtable_ex 4":click to run}){p_end}

{pstd} Setting all the row and column totals to a 100 is nice for
filtering out the effect for filtering out the effect of the
marginal distributions, but is unrealistic. If we just want to
filter out the effects of changes in the marginal distributions
over time, we could fix all the margins to be equal to the margins
of one cohort, say 1980.

{cmd} 
    . preserve
    . use "http://www.maartenbuis.nl/software/interracial.dta", clear
    . stdtable hrace wrace [fw=_freq], by(coh, baseline(1980))
    . restore
{txt}
{p 4 4 2}({stata "stdtable_ex 5":click to run}){p_end}


{title:Options}

{dlgtab:Main}

{phang}
{cmd:by(}{it:{varname}}{cmd: [, }{opt base:line(#|string)}{cmd:])} specifies
        a numeric or string variable to be treated as {it:superrow}. The
        {cmd:baseline()} sub-option specifies the value in {it:varname} to which
        the tables are standardized.{p_end}

{phang}
{opt baser:ow(matrix)} matrix with row totals to which the table(s) are
        standardized. The first cell corresponds to the lowest value of {it:rowvar},
        the second cell to the second lowest value of {it:rowvar}, etc.{p_end}

{phang}
{opt basec:ol(matrix)} matrix with column totals to which the table(s) are
        standardized. The first cell corresponds to the lowest value of {it:colvar},
        the second cell to the second lowest value of {it:colvar}, etc.{p_end}

{phang}
The default is to standardize to row and column totals of all 100s if the table
is square. In that case the standardized counts can be interpreted as row percentages
and as column percentages. if the table is not square, then the default is to 
standardize the row totals to 100/(number of rows) and the column totals to 
100/(number of columns). In that case the standardized counts can be interpreted 
as cell percentages.

{phang}
{opt row} Standardize such that the output can be interpreted as standardized
row percentages.

{phang}
{opt col} Standardize such that the output can be interpreted as standardized
column percentages.

{phang}
{opth f:ormat(%fmt)}specifies the display format for the output{p_end}

{phang}
{opt raw} also displays the raw counts.{p_end}

{phang}
{opt replace} replace current data with standardized (and raw) counts. The row
and column totals are returned in observations with missing values on {it:colvar}
and {it:rowvar} respectively.
{p_end}

{dlgtab:IPF options}

{phang}
{opt tol:erance(#)} tolerance for the standardized counts; default is 1e-6. 
Convergance is achieved when the maximum {help f_reldif:relative change} in 
standardized counts from one iteration to the next is less than {it:#}, {it:and} the 
maximum relative difference between the row totals and the target row totals is
less than {it:#}. (Given the order in which the IPF algorithm is implemented the 
difference between the column totals and the target column totals is guaranteed 
be less than {it:#}){p_end}

{phang}
{opt iter:ate(#)} perform maximum of # iterations; default is 
        {cmd:iterate(16000)}. That may seem a lot, but IPF algorithm is known 
        for requiring a lot of iterations before reaching convergence. Fortunately,
        each iteration is very quick. {p_end}

{phang}
{opt log} display an iteration log of the maximum relative change in 
        estimated standardized counts and max relative difference between the row
        totals and target row totals. Some tables have no solution. An indication 
        that this is the case is when the max rel row diff remains well above the 
        tolerance for all iterations. {p_end}


{title:Author}

{pstd}
Maarten L. Buis,{break}University of Konstanz,{break}maarten.buis@uni.kn


{title:References}

{pstd}
Agresti, A. (2002) {it:Categorical Data Analysis}, second edition. Hoboken: 
Wiley Interscience.

{pstd}
Featherman, D.L. and R.M. Hauser (1978) {it:Opportunity and Change}. New York: 
Academic.

{pstd}
Mosteller, F. (1968) Association and estimation in contingency tables, 
{it:Journal of the American Statistical Association}, 63(321): 1-28.

{pstd}
Yule, U. (1912) On the methods of measuring association between two attributes,
{it:Journal of the Royal Statistical Society}, 75(6):579-652.
