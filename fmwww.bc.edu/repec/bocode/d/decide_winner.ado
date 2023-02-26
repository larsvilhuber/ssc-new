*!  Version 1.0.3 08-02-2023
* Version 1.0.2 28-03-2022 
* Version 1.0.1 09-07-2021 

program define decide_winner , rclass  
syntax, out(string) type(string) tdvar(string) i(integer) 

local notype=1

if inlist("`type'" , "tf" ,  "ts" , "c")  {
	cap confirm  variable `out'_j
		if _rc!=0 {
		return local errorvar `out'
		exit 
			}
		}

if inlist("`type'" , "tf" ,  "ts" )  { 
		cap confirm variable `tdvar'_j 
		if _rc!=0 {
		return local errorvar `tdvar'
		exit 
			}
		}								

* --------------------------------------
* 1a. Outcome type: time to event (failure e.g. death, MI)
* --------------------------------------

if "`type'"=="tf" {

qui gen X_comp`i'=((`out'_j==1 & `tdvar'_i>`tdvar'_j) | (`out'_j==1 & `out'_i==0 & `tdvar'_i==`tdvar'_j))+((`out'_i==1 & `tdvar'_j>`tdvar'_i) | (`out'_i==1 & `out'_j==0 & `tdvar'_j==`tdvar'_i))*-1  if !missing(`out'_i , `out'_j , `tdvar'_i , `tdvar'_j)
local notype=0  
				 }
* --------------------------------------
* 1b. Outcome type: time to event (success e.g. discharge)
* --------------------------------------
if "`type'"=="ts" {  	
qui gen X_comp`i'=((`out'_i==1 & `tdvar'_i<`tdvar'_j) | (`out'_i==1 & `out'_j==0 & `tdvar'_i==`tdvar'_j))+((`out'_j==1 & `tdvar'_i>`tdvar'_j) | (`out'_j==1 & `out'_i==0 & `tdvar'_j==`tdvar'_i))*-1 if !missing(`out'_i , `out'_j , `tdvar'_i , `tdvar'_j) 
local notype=0  
				 }
* --------------------------------------
* 2. Outcome type: continuous/categorical/binary
* --------------------------------------
if "`type'"=="c" {

if  "`tdvar'"=="<" | "`tdvar'"==">"    {
		local tdvar `tdvar'0
		}    

local checktdvar=substr("`tdvar'", 1 , 1)
	local errortdvar = inlist("`checktdvar'" , "<" , ">" )
	if `errortdvar'!=1 {
	return scalar errortdvar = 1
	exit
	}

if substr("`tdvar'",2,1)=="=" {

	local checkmargin=substr("`tdvar'", 3, .) 
	cap confirm number `checkmargin'
	if _rc!=0 {
		return scalar errormargin = 1
		exit
		}

	local gol=substr("`tdvar'",1,2)
	local marg=substr("`tdvar'",3,.)
	local tdvar `gol'float(`marg')
	}

else { 
	
	local checkmargin=substr("`tdvar'", 2, .) 
	cap confirm number `checkmargin'
	if _rc!=0 {
		return scalar errormargin = 1
		exit
		}
	
	local gol=substr("`tdvar'",1,1)
	local marg=substr("`tdvar'",2,.)
	local tdvar `gol'float(`marg')
	}

cap confirm integer number `checkmargin' 
	if _rc!=0 {
	cap confirm double v `out'_i `out'_j
	if _rc!=0 {
	return scalar marginwarning = 1
	}
	}

qui gen X_comp`i'=(float(`out'_i - `out'_j)`tdvar')+(float(`out'_j - `out'_i)`tdvar')*-1 if !missing(`out'_i , `out'_j) 
local notype=0 
		}		
* --------------------------------------
* 3. Outcome type: repeat events
* --------------------------------------
if substr("`type'",1,1)=="r" {

tempvar fu_min events_i events_j 

* Max number of repeat events
local repev=substr("`type'",2,.)

cap confirm  variable `out'`repev'_i
	if _rc!=0 {
	return local errorvar `out'`repev'
	exit
	}
	
/* Event qualifies only if it occurs during the shared follow up of two patients...set events after the end of shared follow up to 0 */
qui egen `fu_min'=rowmin(`tdvar'`repev'_i `tdvar'`repev'_j)

local listi 
local listj 

forvalues r=1/`repev' {
	
	cap confirm  variable `out'`r'_i
		if _rc!=0 {
		return local errorvar `out'`r'
		exit
		}
	
	qui replace `out'`r'_i=0 if `fu_min'<`tdvar'`r'_i & !missing(`fu_min', `tdvar'`r'_i)
	qui replace `out'`r'_j=0 if `fu_min'<`tdvar'`r'_j & !missing(`fu_min', `tdvar'`r'_j)
	local listi `listi' `out'`r'_i
	local listj `listj' `out'`r'_j
	}

* Calculate number of events for i and j
qui egen `events_i'=rowtotal(`listi')
qui egen `events_j'=rowtotal(`listj')

* WLT
qui gen X_comp`i'=(`events_i'<`events_j')+(`events_i'>`events_j')*-1 if !missing(`events_i', `events_j')
local notype=0  
} 	// end of repeat events type 

return scalar errortype = `notype'

end

