program def userprog*! NJC 1.1.0 3 May 1999 * NJC 1.0.0 1 April 1999        version 6.0	args who what install 	if "`who'" == "install" | "`what'" == "install" { error 198 } 	local how = cond("`what'" != "", "quietly", "noisily")          capture qui net from http://www.stata.com/users/`who'	if _rc == 0 {		`how' net from http://www.stata.com/users/`who'	}	else if _rc == 661  { 		if "`who'" != "" { 	        	`how' net from http://www.stata.com/users			`how' net link `who' 		}		else error 661 	}	if "`who'" == "ssc-ideas" & "`what'" != "" { 		local which = substr("`what'",1,1) 		net cd `which' 	}		if "`what'" != "" { net describe `what' } 	if "`what'" != "" & "`install'" == "install" { net install `what' }end