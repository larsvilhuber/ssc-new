*************************************************************************                                                                      **       RATS CODE FOR COINTEGRATION TESTS IN HETEROGENEOUS PANELS      **                      WITH MULTIPLE REGRESSORS                        **                                                                      **   Author: Peter Pedroni, Indiana University, ppedroni@indiana.edu    **                                                                      **                                                                      **                            REFERENCES:                               **                                                                      ** For general discussion and m > 1 critical values:                    **                                                                      ** Pedroni, Peter (1999) "Critical Values for Cointegration Tests in    ** Heterogeneous Panels with Multiple Regressors," Oxford Bulletin of   ** Economics and Statistics, 61, 653-70.                                **                                                                      ** For distribution theory, monte carlos and m = 1 critical values:     * *                                                                      ** Pedroni, Peter (1995) "Panel Cointegration; Asymptotic and Finite    ** Sample Properties of Pooled Time Series Tests with an Application to ** the PPP Hypothesis," Indiana University Working Papers in Economics, ** No. 95-013. Revised 4/97, 8/01.                                      **                                                                      ** version multi-pc2d:  extended to allow for raw panel unit root tests **                    by setting m=0 and setting variable as datavec(1) *************************************************************************environment noecho                ***  USER INPUT SECTION ***compute Tperiods = 100       ;* time series dimension, T, if balancedcompute Nsecs = 20           ;* cross section dimension, Ncompute m = 2                ;* number of RHS regressorsallocate 0 Tperiods*Nsecs    ;* set allocate to at least N*Tcompute Tdum = 0             ;* set to 1 to subract out time meanscompute yestrend = 0         ;* set to 1 for hetero trends, else 0			     ;*  - fixed effects always included by defaultcompute klag =  3            ;* lag truncation value for kernel estimatorscompute mlag =  4            ;* maximum starting truncation for step down 			     ;*	procedure to select ADF lags for each indv open data dataset.wks        ;* name of data setdata(org=obs,format=wks)     ;* one column of length N*T per variable                             ;* stacked as i=1,t=1...T, i=2,t=1,,,T, etc.dec vec[series] datavec(m+1)   ;* define data variables belowset datavec(1) = y             ;* LHS variableset datavec(2) = x             ;* first RHS variable -delete otherwiseset datavec(3) = z             ;* second RHS variable, and so forthcompute unbal = 0             ;* set to 1 for unbalanced panel, else 0dec vec Tvec(Nsecs)           ;* if unbal=1 will override Tperiods value			      ;* do not use this option when Tdum = 1	* Note: published adjustment values are automatically applied by the *    program so that computed values are distributed N(0,1) under null ** For unbalanced panels, fill in the value below for T for each member*     in the order in which they appear in the stacked panel*    (data must still be stacked with no spaces between members)*                                                                        * compute Tvec = ||100,100,100 ... one value for each member .... 100, ||*************************************************************************   * (do not change anything below this line for standard run) *                   *** MAIN SOURCE CODE ***display ' 'display '      Currently computing panel statistics. Please wait. 'display ' 'dec rect tab(10,7)dec vec muvec(7) vivec(7)compute tab = $|| 8.62, 60.75, -6.02, 31.27, -1.73, $   0.93, -9.05, 35.98, -2.03, 0.66 $| 11.754, 104.546, -9.495, 57.610, -2.177, $  0.964, -12.938, 51.49, -2.453, 0.618 $| 15.197, 151.094, -13.256, 81.772, -2.576, $  0.923, -16.888, 67.123, -2.827, 0.585 $| 18.910, 190.661, -17.163, 99.331,-2.930, $  0.843, -20.841, 81.835, -3.157, 0.560 $| 22.715, 231.864, -21.013, 119.546, -3.241, $  0.800, -24.775, 98.278, -3.452, 0.553 $| 26.603, 270.451, -24.944, 134.341, -3.531, $  0.750, -28.720, 113.131, -3.726, 0.542 $| 30.457, 293.431, -28.795, 144.615, -3.795, $0.685, -32.538, 126.059, -3.976, 0.525 ||if yestrend == 1{compute tab = $||17.86, 101.68, -10.54, 39.52, -2.29, $   0.66, -13.65, 50.91, -2.53, 0.56 $| 21.162, 160.249, -14.011, 64.219, -2.648, $  0.690, -17.359, 66.387, -2.872, 0.555 $| 24.556, 198.167, -17.600, 83.815, -2.967, $  0.686, -21.116, 81.832, -3.179, 0.548 $| 28.046, 239.425, -21.287, 103.905, -3.262, $  0.688, -24.930, 97.362, -3.464, 0.543 $| 31.738, 276.997, -25.130, 124.613, -3.545, $  0.686, -28.849, 113.145, -3.737, 0.538 $| 35.537, 310.982, -28.981, 138.227, -3.806, $  0.654, -32.716, 127.989, -3.986, 0.530 $| 39.231, 348.217, -32.756, 154.378, -4.047, $  0.638, -36.494, 140.756, -4.217, 0.518 ||}end ifif m >= 1{compute muvec = ||tab(m,1), tab(m,3), tab(m,5), tab(m,5), tab(m,7), $tab(m,9), tab(m,9)||compute vivec = ||tab(m,2), tab(m,4), tab(m,6), tab(m,6), tab(m,8), $tab(m,10), tab(m,10)||}end ifif m == 0{compute muvec = ||0.00, -3.00, -1.53, -1.53, 0.00, 0.00, -1.54||compute vivec = ||0.00, 10.20, 1.25, 1.25, 0.00, 0.00, 0.71||}end ifif yestrend == 1 .and. m==0 {   compute muvec = ||0.00, -7.50, -1.94, -1.94, 0.00, 0.00, -2.18||   compute vivec = ||0.00, 5.76, 1.62, 1.62, 0.00, 0.00, 0.56|| }end ifif tdum == 1{calander(panelobs=Tperiods)do K=1,m+1  panel datavec(K) / datavec(K) * entry 1.0 indiv 0.0 time -1.0end do Kcalander}end ifdec vec[series] dvec(m+1) rvec(m+1)dec vec[real] N(Nsecs) D(Nsecs) N2(Nsecs) D2(Nsecs) N3(Nsecs) D3(Nsecs) $  Nadf(Nsecs) Dadf(Nsecs) Sadf(Nsecs) S(Nsecs) N3adf(Nsecs) D3adf(Nsecs) $  S3adf(Nsecs) S3(Nsecs) V3(Nsecs) DD(Nsecs) DD3(Nsecs) NN3(Nsecs) $  GR(Nsecs) GP(Nsecs) GA(Nsecs) statvec(7) Tval               ***  SETUP DATA VARIABLES ***do J=1,Nsecsif unbal == 0 ; {; compute Tvec(J) = Tperiods; }if unbal == 1 ; {; compute Tperiods = fix(Tvec(J)); }overlay Tvec(1) with Tval(J-1)  do K=1,M+1    set dvec(K) 1 Tperiods = datavec(K)(T+fix(%sum(Tval)))    diff dvec(K) 2 Tperiods rvec(K)  end do K  set trend = T         *** DO INDIVIDUAL COINTEGRATING REGRESSIONS ***if m >= 1{ linreg(noprint) dvec(1) 1 Tperiods ehat    # dvec(2) to dvec(m+1) constant} if yestrend == 1 .and. m>=1    {; linreg(noprint) dvec(1) 1 Tperiods ehat    # dvec(2) to dvec(m+1) constant trend ;}if m == 0{ linreg(noprint) dvec(1) 1 Tperiods ehat    # constant}if m == 0 .and. yestrend == 1{ linreg(noprint) dvec(1) 1 Tperiods ehat    # constant trend}if m>=1{ linreg(noprint) rvec(1) 2 Tperiods nhat    # rvec(2) to rvec(m+1)}  diff ehat / dehatif m==0{ linreg(noprint) dehat 2 Tperiods nhat    # ehat}                *** COMPUTE ADF LAG TRUNCATIONS ***do llags=mlag,1,-1   linreg(noprint) dehat 2 Tperiods   # ehat{1} dehat{1 to llags}   compute mtratio = %beta(llags+1)/sqrt(%seesq*%xx(llags+1,llags+1))   if abs(mtratio) >= 1.64   { ; compute maxlag=llags ; break ; }end do llags   if llags == 1 .and. abs(mtratio) < 1.64   { ; compute maxlag = 0 ; }*display 'J=' J 'maxlag=' maxlag            *** COMPUTE INDIVIDUAL MEMBER SAMPLE STATS ***if maxlag == 0{   linreg(noprint) dehat 2 Tperiods   # ehat{1}     compute sadf(J) = %seesq    cmoment(noprint) 2+maxlag Tperiods     # dehat ehat{1}     compute nadf(J) = %cmom(2,1)     compute dadf(J) = %cmom(2,2)}if maxlag >= 1{   linreg(noprint) dehat 2 Tperiods     # ehat{1} dehat{1 to maxlag}     compute sadf(J) = %seesq   linreg(noprint) dehat 2 Tperiods destar     # dehat{1 to maxlag}   set ehatlag 1 Tperiods = ehat{1}   linreg(noprint) ehatlag 2 Tperiods estar     # dehat{1 to maxlag}    cmoment(noprint) 2+maxlag Tperiods     # destar estar     compute nadf(J) = %cmom(2,1)     compute dadf(J) = %cmom(2,2)}   linreg(noprint) dehat 2 Tperiods uresid    # ehat{1}     compute d(J) = 1.0/%xx(1,1)   cmoment(noprint,lastreg) 2 Tperiods     compute n(J) = %cmom(2,1)   mcov(damp=1.0,lags=klag) 2 Tperiods    # uresid     compute su = sqrt(%seesq*%ndf/(Tperiods-1.0))     compute st = sqrt(%cmom(1,1)/(Tperiods-1.0))     compute lambda = 0.5*(st**2-su**2)     compute S(J) = st**2   mcov(damp=1.0,lags=klag,noprint) 2 Tperiods    # nhat      compute L11var = (1.0/(Tperiods-1.0))*%CMOM(1,1)          *** CONSTRUCT NUMERATOR AND DENOMINATOR TERMS ***compute N2(J) = N(J) - lambda*Tperiodscompute D2(J) = D(J)compute N3(J) = N2(J)/L11varcompute D3(J) = D2(J)/L11varcompute N3adf(J) = Nadf(J)/L11varcompute D3adf(J) = Dadf(J)/L11varcompute S3adf(J) = Sadf(J)/L11varcompute S3(J) = S(J)/L11varcompute DD(J) = D(J)*S(J)compute DD3(J) = D3(J)*S3(J)compute GR(J) = N2(J)/D2(J)compute GP(J) = N2(J)/sqrt(D2(J)*S(J))compute GA(J) = Nadf(J)/sqrt(Dadf(J)*Sadf(J))end do J        *** CONSTRUCT PANEL COINTEGRATION STATISTICS ***if unbal == 0 ; {; ewise Tvec(I) = Tperiods ; } ; end ifewise V3(I) = D3(I)*(1.0/(Tvec(I)**2))ewise NN3(I) = N3(I)*(Tvec(I)/1.0)ewise GR(I) = GR(I)*(Tvec(I)/1.0)compute statvec(1) = sqrt(Nsecs**3)/%sum(V3)compute statvec(2) = (sqrt(Nsecs)*%sum(NN3))/%sum(D3)compute statvec(3) = %sum(N3)/(sqrt(%sum(D3)*%sum(S3)/Nsecs))compute statvec(4) = %sum(N3adf)/(sqrt(%sum(D3adf)*(%sum(S3adf)/Nsecs)))compute statvec(5) = %sum(GR)/sqrt(Nsecs)compute statvec(6) = %sum(GP)/sqrt(Nsecs)compute statvec(7) = %sum(GA)/sqrt(Nsecs)do K=1,7compute statvec(K) = (statvec(K) - muvec(K)*sqrt(Nsecs))/sqrt(vivec(K))end do K                *** DISPLAY RESULTS ***if m>=1{display '                           RESULTS:'display '         ******************************************** 'display '               panel v-stat     = ' statvec(1)display '               panel rho-stat   = ' statvec(2)display '               panel pp-stat    = ' statvec(3)display '               panel adf-stat   = ' statvec(4)display ' 'display '               group rho-stat   = ' statvec(5)display '               group pp-stat    = ' statvec(6)display '               group adf-stat   = ' statvec(7)display ' '}if m==0{display '                           RESULTS:'display '         ******************************************** 'display '             -raw panel unit root test results-       'display ' 'display '             Levin-Lin rho-stat   = ' statvec(2)display '             Levin-Lin t-rho-stat = ' statvec(3)display '             Levin-Lin ADF-stat   = ' statvec(4)display ' 'display '                 IPS ADF-stat   = ' statvec(7)display '             (using large sample adjustment values)    'display ' '}if unbal == 0{display '        Nsecs =' Nsecs ', Tperiods =' Tperiods $                    ', no. regressors =' M}if unbal == 1display '        Nsecs =' Nsecs ', Tperiods = (unbalanced)' $                    ', no. regressors =' Mdisplay '         ******************************************** 'end