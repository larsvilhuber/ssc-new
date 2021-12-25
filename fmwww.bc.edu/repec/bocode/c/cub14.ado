********************************************************************************
*! "cub14", v.29, Cerulli, 14dic2021
********************************************************************************
* CUB14 --> CUB14 (no-shelter)
********************************************************************************
program cub14 , eclass
version 14.1
args todo b lnf
tempvar theta1 theta2
mleval `theta1' = `b', eq(1)
mleval `theta2' = `b', eq(2)
local y "$ML_y1" // this is just for readability
local m=e(M)
tempvar p M R S D
* Calculate p
quietly generate double `p' = 1/(1+exp(-`theta1'))
* Calculate M
local c = exp(lnfactorial(`m'-1))
tempname cmb
mat `cmb' = J(`m',1,.)
levelsof `y' , local(LEV_Y) 
*di in red "m = " `m'
*di in red "`LEV_Y'"
********************************************************************************
forvalues  i=1/`m'{
foreach j of local LEV_Y {
if `j'==`i'{	
  scalar d = (exp(lnfactorial(`j'-1))*exp(lnfactorial(`m'-`j')))
  mat `cmb'[`i',1] = `c'/d
}
}
}
********************************************************************************
qui gen double `M' = `cmb'[`y',1]
********************************************************************************
* Calculate R 
quietly generate double `R' = ((exp(-`theta2'))^(`y'-1))/((1+exp(-`theta2'))^(`m'-1))
* Calculate S
quietly generate double `S' = 1/`m'
mlsum `lnf' = ln(`p'*(`M'*`R'-`S')+`S')  
ereturn scalar M=`m'
end
********************************************************************************
* END
********************************************************************************