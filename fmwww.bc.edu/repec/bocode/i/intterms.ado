*!  version 1.0.0   27apr1998                          (statalist distribution)program define intterms    version 5.0    local varlist "required existing"    local options "noDROP FULL GEN(string) Index"    local if "optional"    local in "optional"    parse "`*'"    parse "`varlist'", parse(" ")    if "`gen'" == "" {        di in red "gen(variable_stub) is required"        exit 198    }    tempname touse    mark `touse' `weight' `if' `in'    markout `touse' `varlist'    tempname vals1 vals2 cats    qui tab `1'  if `touse' , matrow(`vals1')    qui tab `2'  if `touse' , matrow(`vals2')    local vlist     local k1 = rowsof(`vals1')    local i 1    while `i' <= `k1' {        local val1 = `vals1'[`i',1]        local k2 = rowsof(`vals2')        local j 1        while `j' <= `k2' {            local val2 = `vals2'[`j',1]            if "`index'" == "" {                local varname "`gen'`val1'_`val2'"            }             else { local varname "`gen'`i'_`j'" }            if length("`varname'") > 8 {                drop `vlist'                di in red  "cannot create indicator variable, " /*                    */ "variable name too long"                exit 198            }            gen byte `varname' = (`1' == `val1' & `2' == `val2')            qui tab `varname'  if `touse' , matrow(`cats')            if "`full'" == "" & rowsof(`cats') != 2 {                drop `varname'             }            else {                if "`drop'" == "" & (`i' == 1 & `j' == 1 ) {                     drop `varname'                 }                else { local vlist "`vlist' `varname'" }            }            local j = `j' + 1        }        local i = `i' + 1    }end