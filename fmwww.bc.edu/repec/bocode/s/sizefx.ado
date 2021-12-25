*! sizefx v1.3 MSOpenshaw 01Apr2010
* Program to calculate Cohen's d & Hedges' g
program define sizefx, rclass byable(recall)
version 10.1

*ENSURES N > 0
     marksample touse
     quietly count if `touse'
     if `r(N)' == 0 {
          error 2000
     }
    
*Define temporary variables


*Calculate pooled variance for Cohen's d and Hedges' g
     scalar `numr' = ((`n1'-1)*`s1') + ((`n2'-1)*`s2')
     scalar `dfg' = `n1'+`n2'-2
di as txt "ES correlation {it:r} = " `es_r'

     return scalar N = r(N)
     return scalar Cd = `dvalue'
     return scalar Hg = `hedgesg'
     return scalar ESr = `es_r'

end