*! version lfsummvl 2.0 8/26/00 search for variable fragments for -summvl-*! syntax -lfsummvl (use fragments), (exclude fragments)program define lfsummvl	version 6   gettoken left  right : 0, parse(",")   local 0 `left'   tokenize `0'      local index = index(`"`right'"',",")   local right = substr(`"`right'"',`index' + 1,.)   	if `"`0'"'=="" { error 198 }	local i 1 	while `"``i''"'!="" {		local l`i'=lower(`"``i''"')		local i=`i'+1	}	local nl=`i'-1  	local 0 "_all"	syntax varlist	tokenize `varlist'	local i 1	while `"``i''"'!="" {		local touse 0		local j 1		while (`touse'==0 & `j'<=`nl') {			if index(lower(`"``i''"'),`"`l`j''"'){				local touse 1			}			local j=`j'+1		}		if `touse' {			local list "`list' ``i''"		}		local i=`i'+1	}   if `"`list'"' != ""{   tokenize `right'      if `"`right'"' != ""{         while `"`1'"' != ""{          dellist `"`list'"',d(`"`1'"')         local list `r(list)'         mac shift         }      summvl `r(list)'      }      else {summvl `list'}   }   end