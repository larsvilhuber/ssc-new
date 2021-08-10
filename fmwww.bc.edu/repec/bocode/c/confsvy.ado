*! version 0.1 ZWANG Nov 1998, Menzies School of Health Research program define confsvyversion 5.0local varlist "req ex min(2)"local if "opt"local in "opt"# delimit ;local options "Model(string) CAT(string) CON(string)    Backward NOGraph DETail COeff Level(real 95) YLAbel(string)     * ";# delimit crparse "`*'"parse "`varlist'", parse(" ")preservecapture keep `if'capture keep `in'local i 1while "``i''" ~="" {    qui drop if ``i'' == .    local i =`i'+1}global yvar="`1'"lab var $yvar "`1'" mac shiftglobal xvar="`1'"lab var $xvar "`1'" mac shiftif "`con'" ~="" {	conname `con'}	if "`cat'" ~=""{	catname `cat'}global detail "`detail'"global allvar "$con $cat"global z=invnorm(`level'/100+(1-`level'/100)/2)didi in g "Assessment of Confounding Effects Using Change-in-EstimateMethod" di in g _dup(59) "-" di in g "  Outcome:    " _quote "$yvar" _quote  di in g "  Exposure:   " _quote "$xvar" _quotedi in g "  N =          " in y _N svysetdi in g _dup(59) "-"diif "`backward'"==""{forewrd, `options'}if "`backward'"!=""{backwrd, `options'}* SETUP for GRAPH and SUMMARY    clearqui{    set obs $vnum        gen  or = .        gen lor = .        gen uor = .        gen  se = .        gen   b = .        gen  lb = .        gen  ub = .        gen step=_n        if "`backward'"==""{            lab def step 1 "Crude"            gen str10 stepstr="Crude" in 1        }                         else {            lab def step 1 "Adj. all"            gen str10 stepstr="Crude" in 1        }    local i = 1    while `i' <=$vnum {        local k=`i'+1 		        replace or = ${or`i'}  if `i'==step	        replace lor = ${lor`i'}  if `i'==step	        replace uor = ${uor`i'}  if `i'==step        replace b  = ${b`i'}  if `i' == step        replace lb = ${lb`i'} if `i' == step        replace ub = ${ub`i'} if `i' == step        replace se = ${se`i'} if `i'==step                if "`backward'"~=""{            lab def step `k' "-${pv`i'}", modify            replace stepstr="-${pv`i'}" if `k'==step            if `k'==$vnum {                lab def step `k' "-${pv`i'}*", modify                replace stepstr="-${pv`i'}*" if `k'==step             }                    }        else {            lab def step `k' "+${pv`i'}", modify            replace stepstr="+${pv`i'}"  if `k'==step            if `k'==$vnum {                lab def step `k' "+${pv`i'}*", modify                replace stepstr="+${pv`i'}" if `k'==step            }          }                             local i = `i'+1    }    label val step step*Run Nick Cox's vallist subroutine    vallist step    local labelx "$S_1"*    lab var b "Coefficient and `level' %"    lab var or "Odds Ratio and `level'% CI"    gen change = ((or[_n]-or[_n-1])/or[_n-1])*100    gen se2=se^2        gen wald = 0 if _n! = 1     tempvar form1 form2 form3 form4         gen `form1'= (b[_n]-b[_n-1])    gen `form2' = sqrt(se2[_n] - se2[_n-1])    gen `form3' = sqrt(se2[_n-1] - se2[_n])    if "`backward'" == ""{        replace wald = `form1'/`form2' if se2[_n]>se2[_n-1]         gen pvalue = (1-normprob(abs(wald)))*2    }    if "`backward'" != ""{        replace wald = `form1'/`form3' if se2[_n-1]>se2[_n]         gen pvalue = (1-normprob(abs(wald)))*2    }}local title1 "Potential confounders were"local title2 "removed one at a time sequentially"local title3 "added one at a time sequentially"* SUMMARYif "`backward'"=="" {    di in g "Forward approach"    di in g "`title1' `title3'"}if "`backward'"!="" {    di in g "Backward approach"    di in g "`title1' `title2'"}dis in g _dup(10) "-"  "+" _dup(49) "-" dis in g _col(11) "|" _col(38) "Change in Odds ratio" dis in g " Adj Var" _col(11) "|" _col(13) /*   */ "Odds Ratio   " _col(26) "`level'% CI" /*   */ _col(37) _dup(21) "-"dis in g  _col(11) "|" _col(41) "%" _col(50) "p>|z|" dis in g _dup(10) "-"  "+" _dup(49) "-" local i 1while `i'<=_N {    local strsize = length(stepstr[`i'])    local coln=11-`strsize'    dis in g _col(`coln') stepstr[`i']  _col(11) "|" /*        */ in y %6.2f /*        */ _col(12) %5.2f or[`i'] _col(22) %5.2f /*        */ lor[`i'] "," %5.2f uor[`i'] /*        */ _col(38) %6.1f change[`i'] /*        */ _col(48) %6.5f pvalue[`i']            local i = `i'+1 }dis in g _dup(10) "-"  "+" _dup(49) "-" if "`backward'"=="" {    di in g "*Adjusted for all potential confounders"}if "`backward'"!="" {    di in g "*Crude estimate"}* GRAPHif "`ylabel'" == "" { local ylabel "yla" }else local ylabel "yla(`ylabel')"if "`nograph'" =="" {    if "`backward'"~="" {         if "`coeff'"==""{            gr or uor lor step, c(.II) s(Sii) xlab(`labelx') /*	      */ b2("*Crude") t1("`title1'" "`title2'") /*            */ `ylabel' `options'        }			                                  if "`coeff'"!=""{            gr b ub lb step, c(.II) s(Sii) xlab(`labelx') /*	      */ b2("*Crude") t1("`title1'" "`title2'") /*            */ `ylabel' `options'        }            }    else{        if "`coeff'"==""{            gr or uor lor step, c(.II) s(Sii) xlab(`labelx') /*	      */b2(*Adj. all) t1("`title1'" "`title3'") /*            */ `ylabel' `options'        }        if "`coeff'"!=""{            gr b ub lb step, c(.II) s(Sii) xlab(`labelx') /*    	      */b2(*Adj. all) t1("`title1'" "`title3'") /*            */ `ylabel' `options'        }    }   }mac drop _allend*! version 1.2.0 NJC 8 Oct 1998program define vallist        version 5.0        local varlist "max(1)"        local if "opt"        local in "opt"        parse "`*'"        capture confirm string variable `varlist'        if _rc != 7 {                di in r "not possible with string variable"                exit 108        }        tempname vals        qui tab `varlist' `if' `in', matrow(`vals')        local r = _result(2)        global S_1 = `vals'[1,1]        local i 2        while `i' <= `r' {                local val = `vals'[`i',1]                global S_1 "$S_1, `val'"                local i = `i' + 1        }end*Foreward subroutineprogram define forewrd    local yvar $yvar    local xvar $xvar    local z $z        local model "svylogit"    local expos $expos    local detail $detail    parse "$allvar", parse(" ")    local i 1    while "``i''" ~="" {        local var`i'="``i''"        local i =`i'+1    }    local vnum = `i'    global vnum =`i'    local list "`yvar'  `xvar'"     local ii=1    while `ii' <= `vnum' {		qui xi: `model' `list'        global   b`ii' = _b[`xvar']        global ub`ii' =  _b[`xvar']+`z'*_se[`xvar']        global lb`ii' =  _b[`xvar']-`z'*_se[`xvar']        global  or`ii' = exp(_b[`xvar'])        global  se`ii' = _se[`xvar']        global uor`ii' = exp(_b[`xvar']+`z'*_se[`xvar'])        global lor`ii' = exp(_b[`xvar']-`z'*_se[`xvar'])        if "`detail'"!=""{            dis in g "Step `ii': " /*                */ "Baseline Logistic " in g _quote /*                */ "`list'"  _quote            dis in g "Adj Var" _col(12) "|" _col(14) /*                */ "Odds Ratio   " _col(30) "`level'% CI" /*                */ _col(43)   "Change %"            dis in g _dup(11) "-"  "+" _dup(47) "-"             dis in g " Baseline "  _col(12) "|" in y %6.2f /*                */  _col(14) %6.2f ${or`ii'} _col(26) %6.2f /*                */ ${lor`ii'} "," %6.2f ${uor`ii'}        }        local Maxch=0        local i= 1         while "``i''" ~="" {            qui xi: `model' `list' ``i''            local adjor`i' = exp(_b[`xvar'])            local adjse`i' = _se[`xvar']            local uadj`i' =exp(_b[`xvar']+`z'*_se[`xvar'])            local ladj`i' =exp(_b[`xvar']-`z'*_se[`xvar'])            local chg`i'=((`adjor`i''-${or`ii'})/${or`ii'})*100            local strsize = length("``i''")            local coln=11-`strsize'            if "`detail'"!=""{                di in g _col(`coln') "+``i''" _col(12) "|" /*                    */ in y %6.2f _col(14) `adjor`i'' _col(26) /*                    */ %6.2f  `ladj`i'' "," %6.2f `uadj`i'' /*                    */ _col(43) %6.1f `chg`i''            }            local abch`i'=abs(`chg`i'')        *** Pick up the most important confounder ***	            if `abch`i''>`Maxch' {local Maxch=`abch`i''                local pick`ii' = `i'                global pv`ii' = "``i''" 		            }            local i = `i' +1        }        local i = 1        local alist ""        while "``i''" ~="" {            if `i'~=`pick`ii'' {local alist "`alist' ``i''" }            local i = `i' +1        }        local list "`list' ``pick`ii'''"        parse "`alist'", parse(" ")        local ii = `ii'+1        if "`detail'"!=""{di}    }end* backward routineprogram define backwrd    local yvar $yvar    local xvar $xvar    local z $z        local model "svylogit"    local expos $expos    local detail $detail    parse "$allvar", parse(" ")    local i 1    while "``i''" ~="" {        local var`i'="``i''"        local i =`i'+1    }    local vnum = `i'    global vnum =`i'    local i=1     local list ""    while "``i''" ~=""{        local list "`list' ``i''"        local i = `i' + 1    }    local ii=1    while `ii'<=`vnum' {        qui xi: `model' `yvar' `xvar' `list'        global b`ii' = _b[`xvar']        global ub`ii'= _b[`xvar']+`z'*_se[`xvar']        global lb`ii'= _b[`xvar']-`z'*_se[`xvar']        global or`ii' = exp(_b[`xvar'])        global se`ii' = _se[`xvar']        global uor`ii'= exp(_b[`xvar']+`z'*_se[`xvar'])        global lor`ii'= exp(_b[`xvar']-`z'*_se[`xvar'])        if "`detail'"!=""{            dis in g "Step `ii': " "Baseline logistic " /*                */ in g _quote /*                */ "`yvar' `xvar' `list'"  _quote            dis in g "Adj Var" _col(11) "|" _col(13) /*                */ "Odds Ratio   " _col(28) "`level'% CI" /*                */ _col(43) "Change %"            dis in g _dup(10) "-"  "+" _dup(49) "-"             dis in g " Baseline "  _col(10) "|" in y %6.2f /*                */ _col(12) %6.2f ${or`ii'} _col(24) %6.2f /*                */${lor`ii'} "," %6.2f ${uor`ii'}        }        local Minch=1000        local i= 1         while "``i''" ~="" {            local list2 ""            local k=1            while "``k''" ~=""{                if `k'~=`i' {local list2 "`list2' ``k''"}                local k = `k'+1            }            qui xi: `model' `yvar' `xvar' `list2'            local adjor`i' = exp(_b[`xvar'])            local adjse`i' = _se[`xvar']            local uadj`i' = exp(_b[`xvar']+`z'*_se[`xvar'])            local ladj`i' = exp(_b[`xvar']-`z'*_se[`xvar'])            local chg`i'=((`adjor`i''-${or`ii'})/${or`ii'})*100            local strsize = length("``i''")            local coln=11-`strsize'            if "`detail'"!=""{                dis in g _col(`coln') "-``i'' " _col(10) "|" /*                    */ in y %6.2f _col(12) `adjor`i'' _col(24) /*                     */ %6.2f  `ladj`i'' "," %6.2f `uadj`i'' /*                    */ _col(43) %6.1f `chg`i''            }            local abch`i'=abs(`chg`i'')            *** Pick up the least important confounder ***	            if `abch`i''<`Minch' {local Minch=`abch`i''                local pick`ii' = `i'                global pv`ii' = "``i''" 		            }            local i = `i' +1        }        local i = 1        local list ""        while "``i''" ~="" {            if `i'~=`pick`ii'' {local list "`list' ``i''" }            local i = `i' +1        }        parse "`list'", parse(" ")        local ii = `ii'+1        if "`detail'"!=""{di}    }endprogram define catnamelocal varlist "req ex"parse "`*'"parse "`varlist'", parse(" ")local cat1 "i.`1'"local i=2while "``i''" ~="" {    local cat1 "`cat1' i.``i''"    local i =`i'+1}global cat "`cat1'"endprogram define connamelocal varlist "req ex"parse "`*'"parse "`varlist'", parse(" ")local con1 "`1'"local i=2while "``i''" ~="" {    local con1 "`con1' ``i''"    local i =`i'+1}global con "`con1'"end