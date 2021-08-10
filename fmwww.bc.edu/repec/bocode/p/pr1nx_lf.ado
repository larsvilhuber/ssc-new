*! CFB/PG 0118 rev 0120 per VLW rev 0130 for atanh rhoprogram define pr1nx_lf        version 6        args lnf theta1 theta2 theta3 theta4        tempvar term1 term2        tempname kappa rho        qui {        scalar `kappa' = `theta2'        if `kappa' < -14 { scalar `kappa' = -14 }	if `kappa' >  14 { scalar `kappa' =  14 }	scalar `rho' = (exp(2*`kappa')-1) / (exp(2*`kappa')+1)         gen double `term1' = ln(normd(($ML_y2-`theta3')/`theta4'))-ln(`theta4')        gen double `term2' = ln(normprob(`theta1'+($ML_y2-`theta3')*`rho')) if $ML_y1==1        replace `term2' = ln(1-normprob(`theta1'+($ML_y2-`theta3')*`rho')) if $ML_y1==0        replace `lnf'=`term1'+`term2'        }end