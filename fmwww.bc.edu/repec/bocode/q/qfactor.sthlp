{smcl}
{* *! Version 2.40 24MAY2022}{...}

{title:Title}

{phang}
{bf:qfactor} {hline 2} Q Factor analysis
    

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:qfactor} {varlist} {ifin}
{cmd:,}
{cmdab:nfa:ctor(#)} [{cmdab:ext:raction(string)} {cmdab:rot:ation(string)} {cmdab:sco:re(string)} 
{cmdab:es:ize(string)} {cmdab:bip:olar(string)} {cmdab:stl:ength(#)} {cmdab:min:imum}] 

{p}
{bf:varlist} includes Q-sorts that need to be factor-analyzed.

{title: Description}

{pstd}
{cmd:qfactor} performs factor analysis on Q-sorts.  The command performs factor analysis based on principal 
factor, iterated principal factor, principal-component factor, and maximum-likelihood factor extraction methods. 
{cmd:qfactor} also rotate factors based on all factor rotation techniques available in Stata (orthogonal and oblique)
including varimax, quartimax, equamax, obminin, and promax. 
{cmd:qfactor} displays the eigenvalues of the correlation matrix, the factor loadings, and the uniqueness of the variables. 
It also provides number of Q-sorts loaded on each factor, distinguishing statements for each factor, and consensus statements. 
{cmd:qfactor} is able to handle bipolar factors and identify distinguishing statements based on {it:Cohen's effect size (d)}.

{pstd}
{cmd:qfactor} expects data in the form of variables and can be run for subgroups using “if” and “in” options. 

{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt nfactor(#)}}maximum number of factors to be retained{p_end}
{synopt :{opt extraction(string)}}factor extraction method which includes:{p_end}
{synoptline}
      {bf:pf}             principal factor
      {bf:pcf}            principal-component factor
      {bf:ipf}            iterated principal factor; the default
      
{synopt :{opt rotation(string)}}{cmd:qfactor} accommodates almost every rotation technique in Stata including:{p_end}
{synoptline}
{synopt:{opt none}}this option is used if no rotation is required{p_end}
{synopt:{opt varimax}}varimax; {ul:varimax is the default option}{p_end}
{synopt:{opt quartimax}}quartimax{p_end}
{synopt:{opt equamax}}equamax{p_end}
{synopt:{opt promax(#)}}promax power # (implies oblique); default is promax(3){p_end}
{synopt:{opt oblimin(#)}}oblimin with gamma=#; default is oblimin(0){p_end}
{synopt:{opt target(Tg)}}rotate toward matrix Tg; this option accommodates theoretical rotation{p_end}

{synopt :{opt sco:re(string)}}it identifies how the factor scores to be calculated. The options include:{p_end}
{synoptline}
{synopt:{opt brown}}factor scores are calculated as described by Brown (1980); brown is the default approach.{p_end}
{synopt:{opt r:egression }}regression scoring method{p_end}
{synopt:{opt b:artlett}}Bartlett scoring method{p_end}
{synopt:{opt t:hompson}}Thompson scoring method{p_end}

{synopt :{opt es:ize(string)}}it specifies how the distinguishing statements to be identified for each factor. The options include:{p_end}
{synoptline}
{synopt:{opt stephenson}}distinguishing statements are identified based on Stephenson's formula as described by Brown (1980); {ul:this is the default option}.{p_end}
{synopt:{opt any #}}for any # between zero and one (0<#≤1) distinguishing statements are identified based on Cohen's d.{p_end}

{synopt :{opt bip:olar(string)}}it identifies the criteria for bipolar factor and calculates the factor scores for any bipolar factor. Currently,  bipolar() option works only with Brown’s factor scores.The options include:{p_end}
{synoptline}
{synopt:{opt 0 or no}}indicates no assessment of a bipolar factor; the default option{p_end}
{synopt:{opt any #}}any number more than 0 indicates number of negative loadings required for a bipolar factor.{p_end}

{synopt :{opt stl:ength(#)}}it identifies the maximum length of characters for each statement to be displayed; {ul:the default length is 50 characters}.{p_end}

{synopt :{opt min:imum}}a minimum amount of output is displayed which includes factor scores, distinguishing statements, and consensus statements}.{p_end}

{title: Options for factor extraction}

{phang}
{opt pf}, {opt pcf}, and {opt ipf}
indicate the type of extraction to be used. The default is {opt ipf}.

{phang2}
{opt pf} 
specifies that the principal-factor method be used to analyze the correlation matrix. 
The factor loadings, sometimes called the factor patterns, are computed using the 
squared multiple correlations as estimates of the communality.  

{phang2}
{opt pcf} 
specifies that the principal-component factor method be used to analyze the correlation matrix. 
The communalities are assumed to be 1.

{phang2}
{opt ipf} 
specifies that the iterated principal-factor method be used to analyze the correlation matrix. 
This reestimates the communalities iteratively. ipf is the default.


{title:Stored results}

{phang}
In addition to the displayed results, qfactor stores two matrices in r().
The first matrix is r(fctrldngs) and its columns includes variables such as Q-sort number, 
unrotated and rotated factor loadings, uniqueness and communality of each Q-sort, 
and Factor which indicates which Q-sort was loaded on what factor. The second matrix 
is r(fctrscrs) which stores factor scores for all statements. This matrix contains 
z-scores and ranked scores for the extracted factors. These matrices can be retrieved 
and used in subsequent analysis, e.g., to compare factors scores based on different 
factor extraction techniques, to compare demographic and other background variables 
among the extracted factors, or to graphically display rotated and unrotated factor loadings.


{title:Examples of qfactor}

{phang} 
{bf:mldataset.dta:} This dataset includes 40 participants on their views on marijuana legalization. 
The study was conducted using 19 statements. Each column in the dataset represents one Q-sort and Q-sorts are named qsort1, qsort2,…, qsort40.{p_end} 
{phang}
The following commands conduct qfactor analysis to extract 3 principal component factors using varimax:{p_end}

{phang2}
{bf:qfactor qsort1-qsort40, nfa(3) ext(pcf)}

{phang}
or

{phang2}
{bf:qfactor qsort*, nfa(3) ext(pcf)}

{phang}
The same as above using quartimax rotation:

{phang2}
{bf:qfactor qsort*, nfa(3) ext(pcf) rot(quartimax)}

{phang}
Same as above with varimax rotation but if there is 2 or more negative loadings on any factor it treats it as bipolar factor:

{phang2}
{bf:qfactor qsort1-qsort30, nfa(3) ext(pcf) bip(2)}

{phang}
Same as above without bipolar option but Cohen's d=0.80:

{phang2}
{bf:qfactor qsort1-qsort30, nfa(3) ext(pcf) es(0.80)}

{phang}
The following command runs qfactor on only 30 Q-sorts and uses iterated principal factors (ipf) to extract 3 factors using varimax rotation:

{phang2}
{bf:qfactor qsort1-qsort30, nfa(3) ext(ipf)}

{phang2}
{bf:qfactor qsort1-qsort30, nfa(3)} 

{phang}
The same as above but with 40 Q-sorts and promax(3) rotation:

{phang2}
{bf:qfactor qsort1-qsort40, nfa(3) rot(promax(3))}

{phang}
The following command extracts 3 principal component factors using varimax rotation and sets the length of 
each statement to a maximum of 30 characters in the output:{p_end}

{phang2}
{bf:qfactor qsort1-qsort40, nfa(3) ext(pcf) stl(30)}

{phang}
The following command extracts 4 principal component factors using varimax rotation. It displays a minimum amount of output which includes factor scores, distinguishing statements and consensus statements:{p_end}

{phang2}
{bf:qfactor qsort1-qsort40, nfa(4) ext(pcf) min}

{title:Author}

{pstd}
{bf:Noori Akhtar-Danesh} ({ul:daneshn@mcmaster.ca}), McMaster University, Hamilton, CANADA

{title:Reference}

{pstd}
{bf:Akhtar-Danesh N.} qfactor: A command for Q-methodology analysis. {it:The Stata Journal}. 2018;18(2):432-446.
