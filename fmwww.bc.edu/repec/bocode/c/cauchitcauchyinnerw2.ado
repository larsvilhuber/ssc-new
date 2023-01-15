program cauchitcauchyinnerw2
version 13
args lnf theta lsigma
tempvar sigma 
quietly gen double `sigma' = exp(`lsigma')
quietly replace `lnf' = ln(((`sigma')*cosh((`theta') - asinh(1/tan(_pi*$ML_y1)))* ///
   (1/sin(_pi*$ML_y1)))/((`sigma')^2 + sinh((`theta') - asinh(1/tan(_pi*$ML_y1)))^2)) /// 
   if $ML_y1 > 0 & $ML_y1 < 1
quietly replace `lnf' = ln(`sigma'*exp(`theta')) if $ML_y1 ==0
quietly replace `lnf' = ln(`sigma'/exp(`theta')) if $ML_y1 ==1
end
