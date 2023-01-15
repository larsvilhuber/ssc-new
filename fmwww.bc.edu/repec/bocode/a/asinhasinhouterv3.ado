program asinhasinhouterv3
version 13
args lnf mu theta lsigma
tempvar sigma 
quietly gen double `sigma' = exp(`lsigma')
quietly replace `lnf' = ln((exp((`theta') + asinh((1 - 2*$ML_y1 + 2*$ML_y1*(`mu') - 2*$ML_y1^2*(`mu'))/(2*$ML_y1*(`sigma') - 2*$ML_y1^2*(`sigma'))))*(1 - 2*$ML_y1 + 2*$ML_y1^2))/((exp(`theta') + exp(asinh((1 - 2*$ML_y1 + 2*$ML_y1*(`mu') - 2*$ML_y1^2*(`mu'))/(2*$ML_y1*(`sigma') - 2*$ML_y1^2*(`sigma')))))^2*(-1 + $ML_y1)^2*$ML_y1^2*(`sigma')*sqrt((1 + 4*$ML_y1*(-1 + (`mu')) + 4*$ML_y1^4*((`mu')^2 + (`sigma')^2) + 4*$ML_y1^2*(1 - 3*(`mu') + (`mu')^2 + (`sigma')^2) - 8*$ML_y1^3*(-(`mu') + (`mu')^2 + (`sigma')^2))/((-1 + $ML_y1)^2*$ML_y1^2*(`sigma')^2)))) /// 
   if $ML_y1 > 0 & $ML_y1 < 1
quietly replace `lnf' = ln(`sigma'*exp(`theta')) if $ML_y1 ==0
quietly replace `lnf' = ln(`sigma'/exp(`theta')) if $ML_y1 ==1
end
