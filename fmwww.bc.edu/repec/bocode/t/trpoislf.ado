*! version 1.0 14Dec1997 Joseph Hilbe* LL for 0-truncated Poisson regressionprogram define trpoislf        local lnf "`1'"        local I "`2'"        local depvar="$S_mldepn"	if "$S_mloff" != "" {			tempvar Io		qui gen double `Io' = `I' + $S_mloff	}	else    local Io "`I'"        quietly replace `lnf'= -exp(`Io')+`depvar'*`Io' -lngamma(`depvar'+1) - ln(1-exp(-exp(`Io')))end