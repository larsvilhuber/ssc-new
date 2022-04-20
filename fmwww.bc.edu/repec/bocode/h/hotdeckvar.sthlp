{smcl}
{hline}
help for {hi:hotdeckvar}{right:{hi: Matthias Schonlau}}
{hline}

{title:Creating imputed variables through single hotdeck imputation}

{p 8 27}
{cmd:hotdeckvar} 
[{it:varlist}]
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
{cmd:,} 
[
{cmdab:su:ffix(}{it:str}{cmd:)} 
]


{title:Description}
{p} The algorithm identifies all donor observations 
that have no missing values
for any of the variables specified.  Missing values from the 
same observation are replaced with values from the same donor 
observation to preserve correlations. 
Donor observations are chosen at 
random.

{p}
Generates imputed variables named <varname>`suffix'. By default `suffix' is "_i".
The new variables are identical with the old ones except that missing values 
are replaced by random values of the old variables.
If a variable contains no missing values no imputed variable is created.
If a variable contains only missing values an error is given.
<varlist> must contain only numerical variables. 
Variables specified in a by statement may be either numerical or string variables.

{p} If [in] or [if] is specified both the values to be imputed as well as 
the pool of values imputed from is the values specified by [in] and [if]. 
{cmd:by} can be used with this command to impute within categories defined by the 
by -variables. If any by-group contains only missing values 
the command will give an error and exit.

{p} Hotdeck imputation is especially useful for discrete variables (e.g 0/1 dummy variable)
where the imputed values shouldn't take any other values. Regression imputation with {cmd:impute} 
would result into intermediate values (e.g. 0.56 for 0/1 dummy variables).

{p} Note: hotdeckvar will impute both normal missing
values (.) and extended missing values (.a,.b,...,.z).
This is due to version control (V7).

{title:Options}

{p 0 4}{cmd:suffix(}{it:str}{cmd:)} specifies the suffix that imputed variable 
names take. By default the suffix is "_i". For example, the imputed variable "x" 
will be named "x_i"




{title:Examples Imputing completely at random}

{p}	Impute variables var1 and var2 and store results in "var1_m" and "var2_m":

{p 4 8 }{inp:. hotdeckvar var1 var2, suffix("_m") }

{p}	Impute all variables in memory that have missing values and generate 
    variables "<varname>_i " for the imputed variables (Note: this will not work if any 
	variables in memory are string variables.):

{p 4 8 }{inp:. hotdeckvar}

{p}  Impute the housevalue where missing for respondents who own houses

{p 4 8 }{inp:. hotdeckvar housevalue if own_house==1}


{title:Example:  Specifying a donor pool of observations }

{p} Often you don't want to impute completely at random, but rather from a pool of observations  defined by a combination of a small number of categorical variables: 

{p 4 8 }{inp:. bysort classvar1 classvar2: hotdeckvar y }

{p} If the donor pool of observations is empty (that is, if a combination of classvar1 and classvar2  has only missing values) then you will get an error mesage.

{p}  The sort in "bysort" is not stable. If you are want to make this reproducible,
in addition to setting a seed value you need to specify a stable sorting algorithm: 

{p 4 8 }{inp:. set seed  5844 }

{p 4 8 }{inp:. sort classvar1 classvar2,stable }

{p 4 8 }{inp:. by classvar1 classvar2: hotdeckvar y }


{title:Example: Multiple imputation.}

{p} Suppose we have 3 variables with missing values, x5, x2, and x8. We use the categorical variables x3 and x4 to form pool of observations from which missing values are imputed. That is, we only impute among observations that have the same combinations of values for x3 and x4.

{p} In this example we impute 5 times. All 5 data sets remain in memory.  (In Mander's function "hotdeck" imputations are written into an external file).
The five data sets can be identified  through the variable imputation.

{p 4 8}{inp:.gen seq=_n}

{p 4 8}{inp:.expand 5}

{p 4 8}{inp:.sort seq }

{p 4 8}{inp:.by seq: gen imputation= _n}

{p} We specify all three variables with missing values in the same command. In case  an observation has missing values for more than one of the x-variables, this ensures that the same donor observation is used for the imputation.

{p 4 8}{inp:.bysort imputation x3 x4 : hotdeckvar x5 x2 x8 }

{p} micombine is a user written function that works with most regression functions for multiply imputed data. We use the imputed version of the variables (with suffix _i). Because previously we identified x3 and x4 as categorical variables, we use the i. prefix to create indicator variables.

{p 4 8}{inp:.micombine regress y x1 x2_i i.x3 i.x4 x5_i x6 x7 x8_i, obsid(seq) impid(imputation)}


{title:Author}

Matthias Schonlau
schonlau at uwaterloo dot ca
{browse "http://www.schonlau.net":www.schonlau.net}


{title:Also see}

{p} On-Line: {hi: hotdeck} in STB54, sg116.1 by A. Mander and D. Clayton

{p 4 4} This ado file performs multiple imputations by subgroups.  Each imputation is output to a different file which has to be merged back to the main data set. Therefore it is more cumbersome to use when a single imputation is desired.

{p} On-Line: {hi: micombine} by Patrick Royston

{p} Manual: {hi:[R] impute}
      