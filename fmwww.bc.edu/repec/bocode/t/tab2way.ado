*! Cross-tabulation of 2 variables with display of percentages*! version 1.01 2002-08-28*! Philip Ryan, University of Adelaide, South Australiaprogram def tab2way, sortpreserve byable(recall)version 7#delimit ;syntax varlist (min=2 max=2) [if] [in] [fw /]                             [ , noFREQ CELLPct ROWPct COLPct ALLPct                                 ROWTot COLTot  ALLTot                                 Format(string) usemiss *] ;tempvar touse tempfwt v1 v2  freqcy rp strfreq cp lp;tempname origN;tempfile basal extrar extrac extrarc  extral;mark `touse' `if' `in';if "`usemiss'" == "" {;markout `touse' `varlist', strok;};***********************************;* gotta specify something ;***********************************;if "`freq'" == "nofreq" & "`rowpct'" == "" & "`colpct'" == "" & "`cellpct'" == "" & "`allpct'" == "" {;di as error "no cell content specified";#delimit crexit}***********************************;#delimit crpreserve /* orig data */************************************ look after frequency weights***********************************qui {if "`weight'" =="fweight" {gen double `tempfwt' = `exp'drop if `tempfwt' < 1|`tempfwt' ==.expand `tempfwt'local wflag 1}}*********************************************************************** keep original obs count***********************************qui count if `touse'scalar def `origN' = r(N)********************************************************************** deals with tricky <space><comma> syntax problems at options boundary**********************************tokenize `varlist'********************************************************************** change string vars to numeric for easier addition of missing/total categs***********************************qui {forvalues i = 1/2 {local typev`i': type ``i''if substr("`typev`i''",1,3) == "str" {encode ``i'', gen(`v`i'')local xlabel: variable label ``i''if "`xlabel'" == "" {lab var `v`i'' "``i''"}}else {gen long `v`i'' = ``i''local varlab: var label ``i''if "`varlab'" == "" {lab var `v`i'' "``i''}else {label var `v`i'' "`varlab'"}local vallab: value label ``i''lab val `v`i'' `vallab'}sum `v`i''local max`i' = r(max)} /* end -for- */} /* end qui */*********************************************************************** specify values for new categories for missing and totals***********************************local max12 =  2 + max(`max1', `max2')local missval = `max12'-1if "`usemiss'" != "" {qui mvencode `v1' `v2', mv(`missval')}*********************************************************************** specify display format for percents***********************************if "`format'" == "" {local format "%8.2f"}else if substr("`format'", 1,1) != "%" {di as error "invalid format specified - first character must be " as input "%"exit}*********************************************************************** set macros as flags for desired percents***********************************if "`allpct'" != "" {local rowpct 1local colpct 1local cellpct 1}else {if "`rowpct'" != "" {local rowpct 1}if "`colpct'" != "" {local colpct 1}if "`cellpct'" != "" {local cellpct 1}}***********************************qui save "`basal'"local anytot = "`rowtot'" !=""|"`coltot'"!=""|"`celltot'"!=""|"`alltot'"!=""************************************ calculate totals and save data to temp files***********************************if `anytot' {****** begin row totalqui {collapse (count) `v2' if `touse' , by(`v1')expand `v2'replace `v2' = `max12'save "`extrar'"}****** end of row totalqui use "`basal'", clear****** begin col totalqui {collapse (count) `v1' if `touse' , by(`v2')expand `v1'replace `v1' = `max12'save "`extrac'"}****** end of col totalqui use "`basal'", clear****** begin row/col totalqui {collapse (count) `v1' `v2' if `touse'expand `v1'replace `v1' = `max12'replace `v2' = `max12'save "`extrarc'"}****** end of row/col total}  /* end if anytot */***********************************qui use "`basal'", clear************************************ augment data set with totals if specified***********************************if `anytot' {qui {if "`rowtot'" != "" | "`alltot'" != "" {local rt  1append using "`extrar'"}if "`coltot'" != "" | "`alltot'" != "" {local ct  1append using "`extrac'"}if ("`rowtot'" != "" & "`coltot'" != "") | "`alltot'" != "" {local rct  1append using "`extrarc'"}} /* end qui */} /* end if anytot */*********************************************************************** labels***********************************local rowlab: value label `v2'local collab: value label `v1'if "`rowlab'" == "" {lab def `v2' `missval' "missing", modifylab val `v2' `v2'}else {lab def `rowlab' `missval' "missing", modify}if "`collab'" == "" {lab def `v1' `missval' "missing", modifylab val `v1' `v1'}else {lab def `collab' `missval' "missing", modify}if `anytot' {if "`rt'" == "1" {if "`rowlab'" == "" {lab def `v2' `max12' "TOTAL", modifylab val `v2' `v2'}else {lab def `rowlab' `max12' "TOTAL", modify}}if "`ct'" == "1" {if "`collab'" == "" {lab def `v1' `max12' "TOTAL", modifylab val `v1' `v1'}else {lab def `collab' `missval' "missing" `max12' "TOTAL", modify}}} /* end anytot */*********************************************************************** calculate percentages***********************************bysort `touse' `v1'  `v2' : gen long `freqcy' = _Nbysort `touse' : gen long `lp' = `origN'qui replace `lp' = 100 * `freqcy' / `lp'bysort `touse'  `v1' : gen long `rp' = _Nqui replace `rp' = 100 * `freqcy' / `rp'if "`rt'" == "1" {qui replace `rp' = 2* `rp' if `v1' == `max12'}bysort `touse'   `v2' : gen long `cp' = _Nqui replace `cp' = 100 * `freqcy' / `cp'if "`ct'" == "1" {qui replace `cp' = 2*`cp' if `v2' == `max12'}*********************************************************************** change counts to strings for display***********************************qui {if "`freq'" != "nofreq" {gen str1 `strfreq' = ""replace `strfreq' = string(`freqcy')local freqyes " cell frequencies and"}else {local strfreq ""}}*********************************************************************** use -tabdisp- to display table***********************************di _newif "`wflag'" != "" {display as text "Frequency weights are based on the expression: " as res "`exp'"}if "`rowpct'" == "1" & "`colpct'" == "1" & "`cellpct'" == "1" {display as text "Table entries are`freqyes' cell, row and column percentages"if "`usemiss'" =="" {di as text "Missing categories ignored"}tabdisp `v1'  `v2'   if `touse', c(`strfreq' `lp' `rp' `cp' ) /**/ format(`format') `options'}else if "`rowpct'" == "1" & "`cellpct'" == "1" {display as text "Table entries are`freqyes' cell percentages and row percentages"if "`usemiss'" =="" {di as text "Missing categories ignored"}tabdisp `v1'  `v2'   if `touse', c(`strfreq' `lp' `rp') /**/ format(`format') `options'}else if "`colpct'" == "1" & "`cellpct'" == "1" {display  as text "Table entries are`freqyes' cell percentages and column percentages"if "`usemiss'" =="" {di as text "Missing categories ignored"}tabdisp `v1'  `v2'   if `touse', c(`strfreq' `lp' `cp') /**/ format(`format') `options'}else if "`rowpct'" == "1" & "`colpct'" == "1" {display as text "Table entries are`freqyes' row percentages and column percentages"if "`usemiss'" =="" {di as text "Missing categories ignored"}tabdisp `v1'  `v2'   if `touse', c(`strfreq' `rp' `cp') /**/ format(`format') `options'}else if "`rowpct'" == "1" {display as text "Table entries are`freqyes' row percentages"if "`usemiss'" =="" {di as text "Missing categories ignored"}tabdisp `v1'  `v2'   if `touse', c(`strfreq' `rp' ) /**/ format(`format') `options'}else if "`colpct'" == "1" {display as text "Table entries are`freqyes' column percentages"if "`usemiss'" =="" {di as text "Missing categories ignored"}tabdisp `v1'  `v2'   if `touse', c(`strfreq' `cp' ) /**/ format(`format') `options'}else if "`cellpct'" == "1" {display as text "Table entries are`freqyes' cell percentages"if "`usemiss'" =="" {di as text "Missing categories ignored"}tabdisp `v1'  `v2'   if `touse', c(`strfreq' `lp' ) /**/ format(`format') `options'}else {display as text "Table entries are cell frequencies"if "`usemiss'" =="" {di as text "Missing categories ignored"}tabdisp `v1' `v2'  if `touse', c(`strfreq') /**/ format(`format') `options'}restoreend