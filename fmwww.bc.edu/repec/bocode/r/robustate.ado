////////////////////////////////////////////////////////////////////////////////
// STATA FOR        Sasaki, Y. & Ura, T. (2022): Estimation and Inference for 
// Moments of Ratios with Robustness against Large Trimming Bias. Econometric 
// Theory, 38 (1), pp. 66-112.
//
// Use it when you want to estimate the average treatment effect (ATE) robustly
// against limited overlaps.
////////////////////////////////////////////////////////////////////////////////
program define robustate, eclass
    version 14.2
 
    syntax varlist(numeric  min=3) [if] [in] [, probit h(real 0.1) k(real 4)]
    marksample touse
 
    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'
 
    tempname b V N cb
	
	local prob = 1
	if "`probit'" == "" {
	  local prob = 0
	}
	
	if( `prob'== 0 ){
		mata: estimate("`depvar'", "`cnames'", "`touse'", `h', `k', ///
					   "`b'", "`V'", "`N'")
	}
	else{
		mata: estimate_probit("`depvar'", "`cnames'", "`touse'", `h', `k', ///
							  "`b'", "`V'", "`N'")
	}
		
	matrix colnames `b' = naiveATE robustATE
	matrix colnames `V' = naiveATE robustATE
	matrix rownames `V' = naiveATE robustATE
	
    ereturn post `b' `V', esample(`touse') buildfvinfo
    ereturn scalar N = `N'
	ereturn scalar h = `h'
	ereturn scalar k = `k'
    ereturn local cmd "robustate"
	if( `prob'==0 ){
	 ereturn local pscore "logit"
	}
	if( `prob'==1 ){
	 ereturn local pscore "probit"
	}
    ereturn display
	di "* robustATE is based on Sasaki, Y., and T. Ura (2022) Estimation and Inference"
	di "for Moments of Ratios with Robustness against Large Trimming Bias. Econometric"
	di "Theory, 38(1), pp. 66–112."
end

		
			
		
mata:
//////////////////////////////////////////////////////////////////////////////// 
// FUNCTION FOR LOGIT ESTIMATION
void logitc(todo, para, dw, crit, g, H){
	n = rows(dw)
	dimdw = cols(dw)
	d = dw[.,1]
	w = dw[.,2..dimdw]
	p = cols(w)
	pr = 1 :/ (1 :+ exp(-1:*((J(n,1,1),w)*(para'))))
	crit = mean( (1:-d):*log(1:-pr:+0.001) :+ d:*log(pr:+0.001) )
}

//////////////////////////////////////////////////////////////////////////////// 
// FUNCTION FOR PROBIT ESTIMATION
void probitc(todo, para, dw, crit, g, H){
	n = rows(dw)
	dimdw = cols(dw)
	d = dw[.,1]
	w = dw[.,2..dimdw]
	p = cols(w)
	pr = normal((J(n,1,1),w)*(para'))
	crit = mean( (1:-d):*log(1:-pr:+0.001) :+ d:*log(pr:+0.001) )
}

void probitobj(para,dw,obj){
	n = rows(dw)
	dimdw = cols(dw)
	d = dw[.,1]
	w = dw[.,2..dimdw]
	p = cols(w)
	pr = normal((J(n,1,1),w)*(para'))
	obj = mean( (1:-d):*log(1:-pr:+0.001) :+ d:*log(pr:+0.001) )
}

void probitgrad(para,dw,grad){
    dimpara = cols(para)
	grad = J(dimpara,1,0)
	real scalar obj, obj_DELTA
	probitobj(para,dw,obj)
	for( idx = 1 ; idx <= dimpara ; idx++ ){
		para_DELTA = para 
		para_DELTA[idx] = para_DELTA[idx] + 0.000001
		probitobj(para_DELTA,dw,obj_DELTA)
		grad[idx,1] = (obj_DELTA - obj) / 0.000001
	}
}

void probithessian(para,dw,hessian){
    dimpara = cols(para)
	hessian = J(dimpara,dimpara,0)
	real vector grad, grad_DELTA
	probitgrad(para,dw,grad)
	for( jdx = 1 ; jdx <= dimpara ; jdx++ ){
		para_DELTA = para 
		para_DELTA[jdx] = para_DELTA[jdx] + 0.000001
		probitgrad(para_DELTA,dw,grad_DELTA)
		hessian[.,jdx] = (grad_DELTA :- grad) :/ 0.000001
	}
}

void probitindgrad(para,dw,indgrad){
	n = rows(dw)
    dimpara = cols(para)
	indgrad = J(dimpara,n,0)
	for( idx = 1 ; idx <= n ; idx++ ){
		real vector grad
		probitgrad(para,dw[idx,.],grad)
		indgrad[,idx] =	grad
	}
}

//////////////////////////////////////////////////////////////////////////////// 
// FUNCTION FOR SMOOTH TRUNCATION
void S(u, sout){
    u = 2 :* ( u :- 0.5 )
	//sout = 3:*u:^4:-8:*u:^3:+6:*u:^2
	sout = 6:*u:^5:-15:*u:^4:+10:*u:^3
	sout = (u :<= 0) :* 0 :+ (0 :< u :& u :< 1) :* sout :+ (1 :<= u) :* 1
}

//////////////////////////////////////////////////////////////////////////////// 
// FUNCTIONS FOR SHIFTED LEGENDRE
void choose(n,k,cout){
 cout = factorial(n):/factorial(n:-k):/factorial(k)
}

void shifted_Legendre01(n, x, lout){
 real vector choose1, choose2
 choose(n,0..n,choose1)
 choose(n:+(0..n),(0..n),choose2)
 lout = (-1)^n*sum(choose1 :* choose2 :* ((-x):^(0..n))) :* (0<x & x<1)
}

void d_shifted_Legendre01(n, x, order, lout){
 real vector choose1, shifted1
 lout = 0
 for( idx = 0 ; idx <= order ; idx++ ){
  choose(order,idx,choose1)
  shifted_Legendre01(n,x:+idx:*0.000001,shifted1)
  lout = lout :+ (-1):^(idx:+order):*choose1:*shifted1:/(0.000001:^order)
 }
}

//////////////////////////////////////////////////////////////////////////////// 
// ESTIMATION OF ATE WITH LOGIT PROPENSITY SCORE USING LOGIT P-SCORE ESTIMATION
void estimate( string scalar yv,     string scalar dwv,	
			   string scalar touse,  real scalar h, 	    real scalar k,
			   string scalar bname,  string scalar Vname,  string scalar nname) 
{
	//printf("\n{hline 78}\n")
	//printf("Executing: Sasaki, Y. & Ura, T. (2022): Moments of Ratios with Robustness  \n")
	//printf("           against Large Trimming Bias. Econometric Theory, 38(1), pp. 66-112.\n")
	//printf("{hline 78}\n")
	
	////////////////////////////////////////////////////////////////////////////
	// DATA ORGANIZATION
    real vector y, d, w
    real scalar n, p
 
    y = st_data(., yv, touse)
    dw = st_data(., dwv, touse)
    n = rows(dw)
	dimdw = cols(dw)
	d = dw[.,1]
	w = dw[.,2..dimdw]
	p = cols(w)
	
	////////////////////////////////////////////////////////////////////////////
	// LOGIT ESTIMATION
	////////////////////////////////////////////////////////////////////////////
	init_gamma = 0
	init = J(1,p+1,0)
	S = optimize_init()
	optimize_init_evaluator(S,&logitc())
	optimize_init_which(S,"max")
	optimize_init_evaluatortype(S,"d0")
	optimize_init_technique(S,"nr")
	optimize_init_singularHmethod(S,"hybrid") 
	optimize_init_argument(S,1,(d,w))
	optimize_init_params(S, init)
	optimize_init_conv_warning(S,"off")
	optimize_init_tracelevel(S,"none")
	gamma_hat=optimize(S)'	
	prob = 1 :/ (1 :+ exp(-1:*((J(n,1,1),w)*gamma_hat)))
	phi_hat = (J(n,1,1),w):*(J(1,p+1,1)#(d-prob)) * luinv( (J(n,1,1),w)'*diag((1:-prob):*prob)*(J(n,1,1),w) )
	
	prob_plus = J(n,p+1,0)
	for( idx = 1 ; idx <= p+1 ; idx++ ){
	 delta = J(p+1,1,0)
	 delta[idx,1] = 0.000001
	 prob_plus[.,idx] = 1 :/ (1 :+ exp(-1:*((J(n,1,1),w)*(gamma_hat:+delta))))
	}
	
	////////////////////////////////////////////////////////////////////////////
	// COMPUTE A AND B (AND A_plus)
	////////////////////////////////////////////////////////////////////////////
	A = d :+ (2:*d:-1):*(prob:-1)
	B = (2:*d:-1) :* y
	
	A_plus = J(n,p+1,0)
	for( idx = 1 ; idx <= p+1 ; idx++ ){
	 A_plus[.,idx] = d :+ (2:*d:-1) :* (prob_plus[.,idx]:-1)
	}
	
	////////////////////////////////////////////////////////////////////////////
	// ESTIMATE beta AND m AND c AND psi
	////////////////////////////////////////////////////////////////////////////
	real scalar lout
	pkappa = J(k,k+1,0)
	for( idx = 0 ; idx <= k-1 ; idx++ ){
	 for( jdx = 0 ; jdx <= k ; jdx++ ){
	  d_shifted_Legendre01(jdx, 0.000001, idx, lout)
	  pkappa[idx+1,jdx+1] = lout
	 }
	}
	
	pA = J(n,k+1,0)
	for( idx = 1 ; idx <= n ; idx++ ){
	 for( jdx = 0 ; jdx <= k ; jdx++ ){
	  shifted_Legendre01(jdx, A[idx], lout)
	  pA[idx,jdx+1] = lout
	 }
	}
	beta_hat = luinv(pA'*pA)*pA'*B

	m_hat = J(k,1,0)
	for( kappa = 0 ; kappa <= k-1 ; kappa++ ){
	 m_hat[kappa+1,1] = pkappa[kappa+1,.]*beta_hat
	}

	m_hat_plus = J(k,p+1,0)
	for( ldx = 1 ; ldx <= p+1 ; ldx++ ){
	 pA_plus = J(n,k+1,0)
	 for(idx = 1 ; idx <= n; idx++ ){
	  for( jdx = 0 ; jdx <= k ; jdx++ ){
	   shifted_Legendre01(jdx, A_plus[idx,ldx], lout)
	   pA_plus[idx,jdx+1] = lout
	  }
	 }
	 beta_hat_plus = luinv(pA_plus'*pA_plus)*pA_plus'*B
	 
	 for( kappa = 0 ; kappa <= k-1 ; kappa++ ){
	  m_hat_plus[kappa+1,ldx] = pkappa[kappa+1,.]*beta_hat_plus
	 }
	}
	
	c_hat = J(k-1,1,0)
	for( kappa = 1 ; kappa <= k-1 ; kappa++ ){
	 c_hat[kappa,1] = mean( A:^(kappa-1):*(0:<A):*(A:<h) :/ factorial(kappa) )
	}
	
	psi_hat = J(n,k-1,0)
	for( kappa = 1 ; kappa <= k-1 ; kappa++ ){
	 psi_hat[.,kappa] = (pA*pkappa[kappa+1,.]') :* (B :- pA*beta_hat)
	}
	
	////////////////////////////////////////////////////////////////////////////
	// GET ESTIMATES
	////////////////////////////////////////////////////////////////////////////
	real vector sout
	S(A:/h,sout)
	
	mean_hat = mean( B:/A )
	trimmed_hat = mean( B:/A:*sout )
	robust_hat = trimmed_hat
	
	for( kappa = 1 ; kappa <= k-1 ; kappa++ ){
	 robust_hat = robust_hat - mean(A:^(kappa-1):*(sout:-1)) / factorial(kappa) * m_hat[kappa+1,1]
	}
	
	////////////////////////////////////////////////////////////////////////////
	// VARIANCE ESTIMATION
	////////////////////////////////////////////////////////////////////////////
	real vector sout_plus
	
	omega1_standard = B :/ A
	omega1 = B :/ A :* sout
	Z_standard = omega1_standard
	Z_robust = omega1
	
	omega1_standard_plus = J(n,p+1,0)
	omega1_plus = J(n,p+1,0)
	d_omega1_standard = J(n,p+1,0)
	d_omega1 = J(n,p+1,0)
	for( idx = 1 ; idx <= p+1 ; idx++ ){
	 S(A_plus[.,idx]:/h,sout_plus)
	 omega1_standard_plus[.,idx] = B :/ A_plus[.,idx]
	 omega1_plus[.,idx] = B :/ A_plus[.,idx] :* sout_plus
	 d_omega1_standard[.,idx] = (omega1_standard_plus[.,idx] :- omega1_standard) :/ 0.000001
	 d_omega1[.,idx] = (omega1_plus[.,idx] :- omega1) :/ 0.000001
	}
	Z_standard = Z_standard :+ phi_hat*mean(d_omega1_standard)'
	Z_robust = Z_robust :+ phi_hat*mean(d_omega1)'
	
	for( kappa = 1 ; kappa <= k-1 ; kappa++ ){
	 omega2 = -A:^(kappa-1) :* (sout :- 1 )
	 Z_robust = Z_robust :+ ( omega2 :* m_hat[kappa+1,.] :+ psi_hat[.,kappa] :* mean(omega2) ) :/ factorial(kappa)
	}
	
	for( kappa = 1 ; kappa <= k-1 ; kappa++ ){
	 omega2 = -A:^(kappa-1) :* ( sout :- 1 )
 	 S(A_plus:/h,sout_plus)
	 omega2_plus = -A_plus:^(kappa-1) :* ( sout_plus :- 1 )
	 d_omega2 = ( omega2_plus :- J(1,p+1,1)#omega2 ) :/ 0.000001
	 d_m_hat = ( m_hat_plus[kappa+1,.] :- m_hat[kappa+1,.] ) :/ 0.000001
	 Z_robust = Z_robust :+ phi_hat*( m_hat[kappa+1,1]:*mean(d_omega2):+mean(omega2):*d_m_hat )' :/ factorial(kappa)
	}

	////////////////////////////////////////////////////////////////////////////
	// Estimation Results
	b = mean_hat, robust_hat
	V = variance(Z_standard)/n, variance(Z_standard,Z_robust)/n \ variance(Z_standard,Z_robust)/n, variance(Z_robust)/n
	
    st_matrix(bname, b)
    st_matrix(Vname, V)
    st_numscalar(nname, n)
	
	printf("\n                                                    Observations: %12.0f\n",n)
	//printf("                                                               h: %12.4f\n",h)
	//printf("                                                               k: %12.0f\n",k)
	printf("                                                    P-Score Estimation:  Logit")
	printf("\nAverage Treatment Effect (ATE):")
	printf("\n       Naive Inverse Propensity Score-Weighed Estimation (naiveATE) &")
	printf("\n       Robust Inverse Propensity Score-Weighed Estimation (robustATE)\n")
}








//////////////////////////////////////////////////////////////////////////////// 
// ESTIMATION OF ATE WITH LOGIT PROPENSITY SCORE USING PROBIT P-SCORE ESTIMATION
void estimate_probit( string scalar yv,     string scalar dwv,	
					  string scalar touse,  real scalar h, 	      real scalar k,
					  string scalar bname,  string scalar Vname,  string scalar nname) 
{
	//printf("\n{hline 78}\n")
	//printf("Executing: Sasaki, Y. & Ura, T. (2022): Moments of Ratios with Robustness  \n")
	//printf("           against Large Trimming Bias. Econometric Theory, 38(1), pp. 66-112.\n")
	//printf("{hline 78}\n")
	
	////////////////////////////////////////////////////////////////////////////
	// DATA ORGANIZATION
    real vector y, d, w
    real scalar n, p
 
    y = st_data(., yv, touse)
    dw = st_data(., dwv, touse)
    n = rows(dw)
	dimdw = cols(dw)
	d = dw[.,1]
	w = dw[.,2..dimdw]
	p = cols(w)
	
	////////////////////////////////////////////////////////////////////////////
	// PROBIT ESTIMATION
	////////////////////////////////////////////////////////////////////////////
	init_gamma = 0
	init = J(1,p+1,0)
	S = optimize_init()
	optimize_init_evaluator(S,&probitc())
	optimize_init_which(S,"max")
	optimize_init_evaluatortype(S,"d0")
	optimize_init_technique(S,"nr")
	optimize_init_singularHmethod(S,"hybrid") 
	optimize_init_argument(S,1,(d,w))
	optimize_init_params(S, init)
	optimize_init_conv_warning(S,"off")
	optimize_init_tracelevel(S,"none")
	gamma_hat=optimize(S)'	
	prob = 1 :/ (1 :+ exp(-1:*((J(n,1,1),w)*gamma_hat)))
	
	real matrix hessian, indgrad
	probithessian(gamma_hat',(d,w),hessian)
	probitindgrad(gamma_hat',dw,indgrad)
	phi_hat = (-1:*luinv(hessian)*indgrad)'
	
	prob_plus = J(n,p+1,0)
	for( idx = 1 ; idx <= p+1 ; idx++ ){
	 delta = J(p+1,1,0)
	 delta[idx,1] = 0.000001
	 prob_plus[.,idx] = 1 :/ (1 :+ exp(-1:*((J(n,1,1),w)*(gamma_hat:+delta))))
	}
	
	////////////////////////////////////////////////////////////////////////////
	// COMPUTE A AND B (AND A_plus)
	////////////////////////////////////////////////////////////////////////////
	A = d :+ (2:*d:-1):*(prob:-1)
	B = (2:*d:-1) :* y
	
	A_plus = J(n,p+1,0)
	for( idx = 1 ; idx <= p+1 ; idx++ ){
	 A_plus[.,idx] = d :+ (2:*d:-1) :* (prob_plus[.,idx]:-1)
	}
	
	////////////////////////////////////////////////////////////////////////////
	// ESTIMATE beta AND m AND c AND psi
	////////////////////////////////////////////////////////////////////////////
	real scalar lout
	pkappa = J(k,k+1,0)
	for( idx = 0 ; idx <= k-1 ; idx++ ){
	 for( jdx = 0 ; jdx <= k ; jdx++ ){
	  d_shifted_Legendre01(jdx, 0.000001, idx, lout)
	  pkappa[idx+1,jdx+1] = lout
	 }
	}
	
	pA = J(n,k+1,0)
	for( idx = 1 ; idx <= n ; idx++ ){
	 for( jdx = 0 ; jdx <= k ; jdx++ ){
	  shifted_Legendre01(jdx, A[idx], lout)
	  pA[idx,jdx+1] = lout
	 }
	}
	beta_hat = luinv(pA'*pA)*pA'*B

	m_hat = J(k,1,0)
	for( kappa = 0 ; kappa <= k-1 ; kappa++ ){
	 m_hat[kappa+1,1] = pkappa[kappa+1,.]*beta_hat
	}

	m_hat_plus = J(k,p+1,0)
	for( ldx = 1 ; ldx <= p+1 ; ldx++ ){
	 pA_plus = J(n,k+1,0)
	 for(idx = 1 ; idx <= n; idx++ ){
	  for( jdx = 0 ; jdx <= k ; jdx++ ){
	   shifted_Legendre01(jdx, A_plus[idx,ldx], lout)
	   pA_plus[idx,jdx+1] = lout
	  }
	 }
	 beta_hat_plus = luinv(pA_plus'*pA_plus)*pA_plus'*B
	 
	 for( kappa = 0 ; kappa <= k-1 ; kappa++ ){
	  m_hat_plus[kappa+1,ldx] = pkappa[kappa+1,.]*beta_hat_plus
	 }
	}
	
	c_hat = J(k-1,1,0)
	for( kappa = 1 ; kappa <= k-1 ; kappa++ ){
	 c_hat[kappa,1] = mean( A:^(kappa-1):*(0:<A):*(A:<h) :/ factorial(kappa) )
	}
	
	psi_hat = J(n,k-1,0)
	for( kappa = 1 ; kappa <= k-1 ; kappa++ ){
	 psi_hat[.,kappa] = (pA*pkappa[kappa+1,.]') :* (B :- pA*beta_hat)
	}
	
	////////////////////////////////////////////////////////////////////////////
	// GET ESTIMATES
	////////////////////////////////////////////////////////////////////////////
	real vector sout
	S(A:/h,sout)
	
	mean_hat = mean( B:/A )
	trimmed_hat = mean( B:/A:*sout )
	robust_hat = trimmed_hat
	
	for( kappa = 1 ; kappa <= k-1 ; kappa++ ){
	 robust_hat = robust_hat - mean(A:^(kappa-1):*(sout:-1)) / factorial(kappa) * m_hat[kappa+1,1]
	}
	
	////////////////////////////////////////////////////////////////////////////
	// VARIANCE ESTIMATION
	////////////////////////////////////////////////////////////////////////////
	real vector sout_plus
	
	omega1_standard = B :/ A
	omega1 = B :/ A :* sout
	Z_standard = omega1_standard
	Z_robust = omega1
	
	omega1_standard_plus = J(n,p+1,0)
	omega1_plus = J(n,p+1,0)
	d_omega1_standard = J(n,p+1,0)
	d_omega1 = J(n,p+1,0)
	for( idx = 1 ; idx <= p+1 ; idx++ ){
	 S(A_plus[.,idx]:/h,sout_plus)
	 omega1_standard_plus[.,idx] = B :/ A_plus[.,idx]
	 omega1_plus[.,idx] = B :/ A_plus[.,idx] :* sout_plus
	 d_omega1_standard[.,idx] = (omega1_standard_plus[.,idx] :- omega1_standard) :/ 0.000001
	 d_omega1[.,idx] = (omega1_plus[.,idx] :- omega1) :/ 0.000001
	}
	Z_standard = Z_standard :+ phi_hat*mean(d_omega1_standard)'
	Z_robust = Z_robust :+ phi_hat*mean(d_omega1)'
	
	for( kappa = 1 ; kappa <= k-1 ; kappa++ ){
	 omega2 = -A:^(kappa-1) :* (sout :- 1 )
	 Z_robust = Z_robust :+ ( omega2 :* m_hat[kappa+1,.] :+ psi_hat[.,kappa] :* mean(omega2) ) :/ factorial(kappa)
	}
	
	for( kappa = 1 ; kappa <= k-1 ; kappa++ ){
	 omega2 = -A:^(kappa-1) :* ( sout :- 1 )
 	 S(A_plus:/h,sout_plus)
	 omega2_plus = -A_plus:^(kappa-1) :* ( sout_plus :- 1 )
	 d_omega2 = ( omega2_plus :- J(1,p+1,1)#omega2 ) :/ 0.000001
	 d_m_hat = ( m_hat_plus[kappa+1,.] :- m_hat[kappa+1,.] ) :/ 0.000001
	 Z_robust = Z_robust :+ phi_hat*( m_hat[kappa+1,1]:*mean(d_omega2):+mean(omega2):*d_m_hat )' :/ factorial(kappa)
	}

	////////////////////////////////////////////////////////////////////////////
	// Estimation Results
	b = mean_hat, robust_hat
	V = variance(Z_standard)/n, variance(Z_standard,Z_robust)/n \ variance(Z_standard,Z_robust)/n, variance(Z_robust)/n
	
    st_matrix(bname, b)
    st_matrix(Vname, V)
    st_numscalar(nname, n)
	
	printf("\n                                                    Observations: %12.0f\n",n)
	//printf("                                                               h: %12.4f\n",h)
	//printf("                                                               k: %12.0f\n",k)
	printf("                                                    P-Score Estimation: Probit")
	printf("\nAverage Treatment Effect (ATE):")
	printf("\n       Naive Inverse Propensity Score-Weighed Estimation (naiveATE) &")
	printf("\n       Robust Inverse Propensity Score-Weighed Estimation (robustATE)\n")
}
end
////////////////////////////////////////////////////////////////////////////////


		
		
		
		
		
		
		
		
		
		
				
