program define mktimeversion 4.0local k=`2'local n=`1'scal kf=`3'if kf==1 {exit}if kf < 0  {matrix L = J(1,`2',0)local i=0   while `i' < `k' {   local i=`i'+1   matrix L[1,`i']=`i'   }scal kf=0exit }if  L[1,1] == `n'-`k'+1 {   scal kf=1   exit }if  L[1,`k']<`n' {    matrix L[1,`k']= L[1,`k']+1   exit }   local i=`k'   while `i' > 1 {   local i = `i'-1      if  L[1,`i'] < `n'-`k'+`i'  {          matrix L[1,`i'] =  L[1,`i']+1          local j = `i'            while `j' < `k'  {            local j=`j'+1            matrix L[1,`j']= L[1,`j'-1]+1            }   local i = 1  /* stop the i-loop  */         }      }            exit}end