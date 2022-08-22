cap program drop xtgranger
program xtgranger,eclass 
version 12.0

syntax varlist(numeric ts) [if][in][,lags(integer 1) maxlags(integer 0) het nodfc sum csd csd2 csd3 BOOTstrapindex BOOTstrapcmd(string)]

marksample touse
preserve

*** part to allow for ts by JD
gettoken depvar indeps: varlist
tsunab o_depvar: `depvar'
tsunab o_indeps: `indeps'


tsrevar `depvar'
local depvar `r(varlist)'
tsrevar `indeps'
local indeps `r(varlist)'


quietly keep if `touse'

foreach var in `indeps'{
	quietly xtsum `var'
	if(r(sd_w)==0){
		display as error "Some variables are time-invariant."
		exit
	}
}

capture xtset
local t =r(tmax)-r(tmin)+1
local n =(_N)/`t'
local idvar `r(panelvar)'
local tvar `r(timevar)'

tempvar tnew
egen `tnew' = group(`tvar')

if _rc {
	display as error "Panel variable not set; use xtset before running xtgranger."
	exit
}

if (floor(`t'/2)<=1+`lags') {
	display as error "Not enough time series observations. Floor(T/2) must be greater than 1+lags."
	exit
}

if (floor(`t'/2)<=1+`maxlags') {
	display as error "Not enough time series observations. Floor(T/2) must be greater than 1+maxlags."
	exit
}

if (`lags'==0) {
	display as error "Number of lags need to be a positive integer."
	exit
}

if (`maxlags'!=0){
	mata: test0("`depvar'","`indeps'",`t',`n',`maxlags')
	local lags=r(p)
	matrix lag_BIC=r(lag_BIC)
}

*** added support to remove time fixed effects by JD
if "`csd3'" != "" {
	tempvar csdv
	foreach var of varlist `depvar' `indeps' {
		qui by `tvar', sort: egen double `csdv' = mean(`var')
		qui replace `var' = `var' - `csdv'
		drop `csdv'
	}
	sort `idvar' `tvar'
}


*** bootstrap
local bootstrapdraws = 0
if "`bootstrapindex'" != "" {
	local bootstrapdraws = 100
}
if "`bootstrapcmd'" != "" {
	local 0 `bootstrapcmd'
	syntax anything(name=bootstrapdraws) , [seed(string)]

	if "`seed'" != "" set seed `seed'

}

markout `touse' `depvar' L(1/`lags').(`indeps')  L(1/`lags').`depvar'

mata: test1("`depvar'","L(1/`lags').(`indeps')","L(1/`lags').`depvar'","`idvar' `tnew'","`touse'",`t',`n',`lags',"`het'","`dfc'",`bootstrapdraws',(("`csd'"!=""),("`csd2'"!="")))

scalar W_HPJ=r(W_HPJ)
local k=r(k)
local df=`k'*`lags'
local BIC=r(BIC)
scalar rejection_HPJ=W_HPJ>invchi2(`df',0.95)
scalar pvalue_HPJ=chi2tail(`df',W_HPJ)
matrix b_HPJ=r(beta)'
matrix Var_HPJ=r(V)

*** read names back by JD
local depvar `o_depvar'
local indeps `o_indeps'

di as text _dup(78) "-"
di as text  "JKS non-causality test"
di as text ""

if (`k'==1){
	di in gr _col(1) "H0: " "`indeps'" " does not Granger-cause " "`depvar'""."
	di in gr _col(1) "H1: " "`indeps'" " does Granger-cause " "`depvar'" " for at least one panelvar."
}
else{
	di in gr _col(1) "H0: Selected covariates do not Granger-cause " "`depvar'""."
	di in gr _col(1) "H1: H0 is violated."
}
di as text ""
di in gr _col(1) "HPJ Wald test" _col(16) ": "  in ye %6.4f r(W_HPJ) 
di in gr _col(1) "p-value" _col(16) ": "		in ye %6.4f pvalue_HPJ

di as text _dup(78) "-"

if (`maxlags'!=0){
	di in gr "BIC selection:" 
	forvalues lag1=1/`maxlags'{
		if (`lag1'==`lags'){
		di in gr "    lags = " in ye lag_BIC[`lag1',1] in gr ", BIC = " in ye lag_BIC[`lag1',2] "*"
		}
		else{
		di in gr "    lags = " in ye lag_BIC[`lag1',1] in gr ", BIC = " in ye lag_BIC[`lag1',2]
		}
	}
di as text _dup(78) "-"
}

local name1 `indeps'
local names ""
foreach name of local name1{
	forvalues p1=1/`lags'{
		local names "`names' l`p1'.`name'"
	}
} 
matrix colname b_HPJ=`names'
matrix colname Var_HPJ=`names'
matrix rowname Var_HPJ=`names'

if (`lags'>1) {
matrix b_Sum_HPJ=r(beta_sum)'
matrix Var_Sum_HPJ=r(Svar)
matrix colnames b_Sum_HPJ= `indeps'
matrix colname Var_Sum_HPJ=`indeps'
matrix rowname Var_Sum_HPJ=`indeps'
}

tempname beta v
if ("`sum'"!="") & (`lags'>1) {
	di _col(8) "{bf:Sum of Half-Panel Jackknife coefficients across lags (lags>1)}" 
	mat `beta'=b_Sum_HPJ
	mat `v'=Var_Sum_HPJ
}
else{
	di _col(16) "{bf:Results for the Half-Panel Jackknife estimator}"
	mat `beta'=b_HPJ
	mat `v'=Var_HPJ
}
	
if ("`het'"!="") {
	di _col(8) "Cross-sectional heteroskedasticity-robust variance estimation"
	}
if("`dfc'"!=""){
	di _col(10) "No degrees-of-freedom correction in the variance estimator"
}
 
ereturn post `beta' `v'
ereturn display

ereturn scalar N = `n'
ereturn scalar T = `t'-`lags'
ereturn scalar p=`lags'
if(`maxlags'!=0){
	ereturn scalar BIC=`BIC'
}
ereturn scalar W_HPJ=W_HPJ
ereturn scalar pvalue=pvalue_HPJ
ereturn matrix b_HPJ=b_HPJ
ereturn matrix Var_HPJ=Var_HPJ

if (`lags'>1) {
	ereturn matrix b_Sum_HPJ=b_Sum_HPJ
	ereturn matrix Var_Sum_HPJ=Var_Sum_HPJ
}
ereturn local cmd "xtgranger"
ereturn local predict "xtgranger_p"

/// hidden, added by JD for predict
ereturn hidden local depvar "`depvar'"
ereturn hidden local indepvar "`names'"
ereturn hidden local csd "`csd'"
restore
end
	

capture mata mata drop test0() test1() estBeta() ols_inner()
	
mata:
void test0 (string scalar depvar,string scalar indeps, numeric scalar t, numeric scalar n,numeric scalar l)
{
	z1=st_data(.,depvar,.) //the transfer (t*n)*1 matrix
	z2=st_data(.,indeps,.)
	k=cols(z2)
		
	y = colshape(z1',t)'
	x = colshape(z2',t)'

	lag_BIC=J(l,2,0)
	//calculata smallest BIC
	if(l!=0){
		for(z=1; z<=l; z++){
			row=t-z
			cols=z*k
			xi=J(row,cols,.)
			zi=J(row,z+1,.)
			yi=J(row,1,.)
			Mi=J(row,row,0)
			RSS=0	


			for(i=1; i<=n; i++) {
				st_subview(yi,y,(z+1)::t,i) 
				for(m=1; m<=row; m++) { 
					for(q=1; q<=z+1; q++) { 	
						if (q==1) {
							zi[m,q]=1
						}
						else {
							zi[m,q]=y[z+m-q+1,i]
						}
					}		
					for(o=1; o<=k; o++) { 		
						for(j=1; j<=z; j++) { 
							xi[m,(o-1)*z+j]=x[z+m-j,i+(o-1)*n]
						}
					}	
				}

				Mi=I(row)-zi*luinv(zi'*zi)*zi'
				tempxx=xi'*Mi*xi
				tempxy=xi'*Mi*yi
				tempbeta=cross(cholinv(tempxx),tempxy)
				RSS=RSS+(yi-xi*tempbeta)'*Mi*(yi-xi*tempbeta)
			}
			BIC_p_p=n*(t-1-z-z)*log(RSS/(n*(t-1-z-z)))+z*log(n*(t-1-z-z))
			lag_BIC[z,1]=z
			lag_BIC[z,2]=BIC_p_p
			if (z==1) {
					BIC=BIC_p_p
					p=1
				}
				else{
					if(BIC>BIC_p_p){
						BIC=BIC_p_p
						p=z
					}
				}

			
		}
	}	
	st_numscalar("r(p)",p)
	st_matrix("r(lag_BIC)",lag_BIC)
}	
end	



mata:
void test1(string scalar depvar,string scalar indeps, string scalar depvarlag,string scalar idtn, string scalar tousen, numeric scalar t, numeric scalar n,numeric scalar p,string scalar het,string scalar dfc,real scalar bootdraws, real matrix demean)
{
	z1=st_data(.,depvar,tousen) //the transfer (t*n)*1 matrix-y
	z2=st_data(.,indeps,tousen)
	z3=st_data(.,depvarlag,tousen)

	idt = st_data(.,idtn,tousen)
	/// ensure time col points to 1.
	idt[.,2] = idt[.,2] :- min(idt[.,2]):+1

	k=cols(z2)/p

	index = panelsetup(idt,1)

	/// inital draw with no bootstrap
	beta = estBeta(z1,z2,z3,idt,index,(1::n),t,p,demean,RSS=0,b=.)
	
	BIC=n*(t-1-p-p)*log(RSS/(n*(t-1-p-p)))+p*log(n*(t-1-p-p))
	
	/// Mata Output
	stata(`"di in gr ""')
	stata(`"di in gr "Juodis, Karavias and Sarafidis (2021) Granger non-causality Test""')
	stata(`"di as text _dup(78) "-"')

	stata(sprintf(`"di in gr "Number of units" _col(16) "= " in ye %s _col(45) in gr "Obs. per unit (T)" _col(63) "= " _col(64) in ye  %s"',strofreal(n),strofreal((t-p))))
	stata(sprintf(`"di in gr "Number of lags" _col(16) "= "  in ye %s _col(45) in gr "BIC" _col(63) "= " _col(64) in  ye %s"',strofreal(p),strofreal(BIC)))


	/// Variance estimation
	if (bootdraws == 0) {
		var = calcVar(z1,z2,z3,b,idt,index,(1::n),het,dfc,p,demean)
	}
	else {
		stata(`"di as text _dup(78) "-""')
		msg = sprintf("noi _dots 0, title(Bootstrap Variances for HPJ test) reps(%s) ",strofreal(bootdraws))
		stata(msg)
		beta_r = J(bootdraws,rows(beta),0)
		beta_r[bootdraws,.] = beta'

		for (r = 1;r<=bootdraws-1;r++) {
			/// draw from uniform distribution units
			beta_rr = estBeta(z1,z2,z3,idt,index,runiformint(n,1,1,n),t,p,demean,tmp1=0,tmp2=.)
			beta_r[r,.] = beta_rr'
			msg = sprintf("noi _dots %s 0",strofreal(r))
			stata(msg)
		}
		msg = sprintf("noi _dots %s 0",strofreal(bootdraws))
		stata(msg)
		var = quadvariance(beta_r)
	}

	W_HPJ=beta'*luinv(var)*beta	
	
	///calculate the sum of beta
	beta_sum=J(k,1,0)
	for(i=1; i<=k; i++){
		for(j=1; j<=p; j++){
			beta_sum[i]=beta_sum[i]+beta[p*(i-1)+j]
		}
	}
	
	Svar=J(k,k,0)
	for(i=1; i<=k; i++){
		for(j=1; j<=k; j++){
			for(m=1; m<=p; m++){
				for(o=1; o<=p; o++){
					Svar[i,j]=Svar[i,j]+var[m*i,j*o]
				}
			}
		}
	}	
	
	st_numscalar("r(W_HPJ)",W_HPJ) 
	st_numscalar("r(k)",k)
	st_numscalar("r(BIC)",BIC)
	st_matrix("r(beta)",beta)
	st_matrix("r(V)",var) 
	st_matrix("r(beta_sum)",beta_sum)
	st_matrix("r(Svar)",Svar)
}
end


mata:
	function estBeta(real matrix y, real matrix x, real matrix Ly, real matrix idt, real matrix index,  real matrix sel, real scalar t,real scalar p, real matrix demean,real scalar RSS, real matrix b)
	{

		
		pointer(real matrix) yp, xp, Lyp

		if (sum(demean):==0) {
			yp = &y
			xp = &x
			Lyp = &Ly	
		}
		else {
			all=DemeanPartial((y,x,Ly),idt,index,sel,demean[1],demean[2])
			all1 = all[.,1]
			yp = &all1
			all2 = all[.,2..cols(x)+1]
			xp = &all2
			all3 = all[.,cols(x)+2..cols(all)]
			Lyp = &all3
		}

		N = rows(index)

		xx_f = xx_u = xx = J(cols(x),cols(x),0)
		xy_f = xy_u = xy = J(cols(x),1,0)

		RSS = 0
		for (i=N;i>0;i--) {
			ii = sel[i]
			yi = panelsubmatrix(*yp,ii,index)
			xi = panelsubmatrix(*xp,ii,index)
			Lyi = J(rows(yi),1,1),panelsubmatrix(*Lyp,ii,index)
			
			mid = floor(t/2)

			/// full panel
			ols_inner(yi,xi,Lyi,xx,xy,RSS)
			
			/// First part of panel
			ols_inner(yi[|1,. \ mid-p,.|],xi[|1,. \ mid-p,.|],Lyi[|1,. \ mid-p,.|],xx_f,xy_f,tmp=.)

			// Second Part of panel
			ols_inner(yi[|mid+1,. \ .,.|],xi[|mid+1,. \ .,.|],Lyi[|mid+1,. \ .,.|],xx_u,xy_u,tmp=.)

		}

		b=quadcross(cholinv(xx),xy)
		b_f=quadcross(cholinv(xx_f),xy_f)
		b_l=quadcross(cholinv(xx_u),xy_u)
		beta=2*b-(b_f+b_l)/2   //beta 
		return(beta)
	}
end


mata:
	function ols_inner(real matrix y, real matrix x, real matrix z, xx,xy ,RSS)
	{
		Mi = I(rows(z)) - z * luinv(quadcross(z,z)) * z'

		tempxx=x'*Mi*x
		tempxy=x'*Mi*y

		tempbeta=quadcross(cholinv(tempxx),tempxy)
		RSS=RSS + (y-x*tempbeta)'*Mi*(y-x*tempbeta)
		xx = xx + tempxx
		xy = xy + tempxy
	}

end

mata:
	function calcVar(real matrix y, real matrix x, real matrix z, real matrix beta, real matrix idt, real matrix index, real matrix sel, string scalar het,string scalar dfc,real scalar p, real matrix demean)
	{

		panelstats = panelstats(index)
		n = panelstats[1]
		t = panelstats[2]/n

		pointer(real matrix) yp, xp, Lyp

		if (sum(demean):==0) {
			yp = &y
			xp = &x
			zp = &z	
		}
		else {
			mean((y,x,z))
			all=DemeanPartial((y,x,z),idt,index,sel,demean[1],demean[2])
			all1 = all[.,1]
			yp = &all1
			all2 = all[.,2..cols(x)+1]
			xp = &all2
			all3 = all[.,cols(x)+2..cols(all)]
			zp = &all3
			mean((*yp,*xp,*zp))
		}

		xx = J(cols(x),cols(x),0)
		xy =  J(cols(x),1,0)

		sum_het = J(cols(x),cols(x),0)
		sum = 0
		
		for (i=n;i>0;i--) {
			yi = panelsubmatrix(*yp,i,index)
			xi = panelsubmatrix(*xp,i,index)
			zi = J(rows(yi),1,1),panelsubmatrix(*zp,i,index)

			

			Mi = I(rows(zi)) - zi * luinv(quadcross(zi,zi)) * zi'

			xx = xx + xi'*Mi*xi

			ei = yi - xi * beta
			
			if (het=="") {
				tmp = ei'*Mi*ei
				sum = sum + tmp 
			}
			else { 
				tmp = ei'*Mi*xi
				sum_het = sum_het + quadcross(tmp,tmp)
			}
		}
		t = t + p
		if(dfc=="") {
			degree=n*t-n*1-n*p-cols(x)
		}
		else{
			degree=n*t
		}
		
		if (het=="") {	
			var=sum/degree*luinv(xx)
		}	
		else{
			temp=sum_het/degree
			var=luinv(xx)*temp*luinv(xx)*(n*t)
		}

		return(var)
	}

end

capture mata mata drop PartialOut
mata:
	function PartialOut(real matrix y, real matrix csa, real matrix idt, real matrix index, real matrix sel)
	{
		real matrix output
		output = J(rows(y),cols(y),.)
		N = rows(index) 

		for (ii=1;ii<=N;ii++){
			i = sel[ii]
			idti = panelsubmatrix(idt,i,index)
			csai = csa[idti[.,2],.]
			M = I(rows(csai)) - csai * invsym(quadcross(csai,csai)) *csai'
			yi = panelsubmatrix(y,i,index)
			output[|index[i,1],. \ index[i,2],.|] = M* yi
			
		}

		return(output)
	}

end

capture mata mata drop DemeanPartial
mata:
	function DemeanPartial(real matrix x, real matrix idt, real matrix index, real matrix sel, real scalar demean, real scalar csa)

	{
		/// calculate csa
		real matrix output
		output = x

		stats = panelstats(index)
		N = stats[1]
		T = stats[3]

		csam = J(T,cols(x),0)
		cnt = J(T,1,0)
		for (ii=1;ii<=N;ii++) {
			i = sel[ii]
			idti = panelsubmatrix(idt,i,index)			
			xi = panelsubmatrix(x,i,index)
			csam[idti[.,2],.] = csam[idti[.,2],.] + xi
			cnt[idti[.,2],.] = cnt[idti[.,2],.] + J(rows(xi),1,1)
		}
		csam = csam :/ cnt

		if (demean:==1) {
			for (ii=1;ii<=N;ii++) {
				i = sel[ii]
				idti = panelsubmatrix(idt,i,index)
				xi = panelsubmatrix(x,i,index)
				output[|index[i,1],. \ index[i,2],.|] = xi :- csam[idti[.,2],.]
				
			}
		}
		if (csa :== 1) {
			output = PartialOut(output,csam,idt,index,sel)
		}
		return(output)
	}

end
