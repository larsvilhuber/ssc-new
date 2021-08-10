
	/*
	Author E. F. Haghish
	University of Freiburg, Germany
	http://www.stata-blog.com/
	
	
	this file includes Stata commands and Functions in two separate lists. 
	In order to make sure the syntax highlighter does not confuse commands with
	functions (given the similrity in names) the functions are specified with
	open parentheses. The syntax highlighter automatically removes the 
	parentheses. The first wordlist are Stata commands and the second wordlist
	are Stata functions.
	*/
	

	program synlightlist
	version 11
	
	global synlightlist ///
	/// /* Codes written by Haghish */
	markdoc weave weavend codes cod results res highlight hight high hlt div ///
	html linebreak pagebreak knit quote img markup markdown synlight syn ///
	/// /* Stata commands */
	set about ado an ano anov anova anovadef ap app appe appen append args ///
	as ass asse asser assert br break bro brow brows browse by bys byso ///
	bysor bysort cap capt captu captur capture cat cd char chdir checksum ///
	chelp cl cli clis clist cmdlog compress conf confi confir confirm cons ///
	const constr constra constrai constrain constraint continue copy cor ///
	corr corre correl correla correlat correlate cou coun count cox cret ///
	cretu cretur creturn datasig datasign datasigna datasignat datasignatu ///
	datasignatur datasignature dec deco decod decode di di_g dir dis discard ///
	disp displ displa display do doe doed doedi doedit drop e ed edi edit ///
	else en enc enco encod encode erase eret eretu eretur ereturn err erro ///
	error ex exi exit expand fdades fdadesc fdadescr fdadescri fdadescrib ///
	fdadescribe fdasav fdasave fdause file filefilter fl fli flis flist ///
	foreach form forma format forv forva forval forvalu forvalue forvalues ///
	g ge gen gene gener genera generat generate gettoken gl glo glob globa ///
	global gprefs gr7 graph7 haver hexdump if include inf infi infil infile ///
	infix inp inpu input ins insheet insp inspe inspec inspect keep l la ///
	lab labe label li lis list loc loca local log lookup ls m ma mac macr ///
	macro man manova manovatest mark markin markout marksample mat ///
	mat_put_rr mata mata_clear mata_describe mata_drop mata_memory ///
	mata_mlib mata_mosave mata_rename mata_which matr matri matrix memory ///
	mkdir mleval mlmatbysum mlmatsum mlsum mlvecsum mor more mov move n net ///
	news no nobreak noi nois noisi noisil noisily notes_dlg numlist odbc on ///
	one onew onewa oneway order ou out outf outfi outfil outfile outs outsh ///
	outshe outshee outsheet parse pl plo plot plugin post postclose ///
	postfile postutil pr preserve pro prog progr progra program pwd q qu ///
	que quer query qui quie quiet quietl quietly ren rena renam rename ///
	replace restore ret retu retur return rmdir ru run sa sav save sca scal ///
	scala scalar se search serset  sh she shel shell sleep so sor sort sret ///
	sretu sretur sreturn su sum summ summa summar summari summariz summarize ///
	syntax sysdir ta tab tabd tabdi tabdis tabdisp tabu tabul tabula tabulat ///
	tabulate tempfile tempname tempvar timer token tokeni tokeniz tokenize ///
	translate translator transmap tsrevar ty typ type u unabcmd update us ///
	use vers versi versio version view wh whi which whil while win wind ///
	windo window winexec xmlsav xmlsave xmluse xsh xshe xshel xshell ac ///
	ac_7 acprplot acprplot_7 adjust adopath adoupdate alpha ameans ///
	anova_estat anova_terms aorder arch arch_dr arch_estat arch_p archlm ///
	areg areg_p arima arima_dr arima_estat arima_p asmprobit ///
	asmprobit_estat asmprobit_lf asmprobit_mfx__dlg asmprobit_p avplot ///
	avplot_7 avplots avplots_7 bcskew0 bgodfrey binreg bip0_lf biplot ///
	bipp_lf bipr_lf bipr_p biprobit bitest bitesti bitowt blogit bmemsize ///
	boot bootsamp bootstrap bootstrap_8 boxco_l boxco_p boxcox boxcox_6 ///
	boxcox_p bprobit brier brr brrstat bs bs_7 bsampl_w bsample bsample_7 ///
	bsqreg bstat bstat_7 bstat_8 bstrap bstrap_7 ca ca_estat ca_p cabiplot ///
	camat canon canon_8 canon_8_p canon_estat canon_p caprojection cc ///
	cchart cchart_7 cci censobs_table centile cf checkdlgfiles ///
	checkestimationsample checkhlpfiles ci cii classutil clear clo clog ///
	clog_lf clog_p clogi clogi_sw clogit clogit_lf clogit_p clogitp ///
	clogl_sw cloglog clonevar clslistarray cluster cluster_measures ///
	cluster_stop cluster_tree cluster_tree_8 clustermat cnr cnre cnreg ///
	cnreg_p cnreg_sw cnsreg codebook collaps4 collapse colormult_nb ///
	colormult_nw compare conren contract copyright copysource corc ///
	corr2data corr_anti corr_kmo corr_smc corrgram cox_p cox_sw coxbase ///
	coxhaz coxvar cprplot cprplot_7 crc cross cs cscript cscript_log csi ct ///
	ct_is ctset ctst_5 ctst_st cttost cumsp cumsp_7 cumul cusum cusum_7 ///
	cutil d datetof db dbeta de deff des desc descr descri describ describe ///
	destring dfbeta dfgls dfuller dirstats disp_res disp_s dotplot dotplot_7 ///
	dprobit drawnorm ds ds_util dstdize duplicates durbina dwstat dydx egen ///
	eivreg emdef eq ereg ereg_lf ereg_p ereg_sw ereghet ereghet_glf ///
	ereghet_glf_sh ereghet_gp ereghet_ilf ereghet_ilf_sh ereghet_ip est ///
	est_cfexist est_cfname est_clickable est_expand est_hold est_table ///
	est_unhold est_unholdok estat estat_default estat_summ estat_vce_only ///
	esti estimates etodow etof etomdy expandcl fac fact facto factor ///
	factor_estat factor_p factor_pca_rotated factor_rotate factormat fcast ///
	fcast_compute fcast_graph fh_st fillin find_hlp_file findfile findit ///
	findit_7 fit for for5_0 fpredict frac_154 frac_adj frac_chk frac_cox ///
	frac_ddp frac_dis frac_dv frac_in frac_mun frac_pp frac_pq frac_pv ///
	frac_wgt frac_xo fracgen fracplot fracplot_7 fracpoly fracpred fron_ex ///
	fron_hn fron_p fron_tn fron_tn2 frontier ftodate ftoe ftomdy ftowdate ///
	gamhet_glf gamhet_gp gamhet_ilf gamhet_ip gamma gamma_d2 gamma_p ///
	gamma_sw gammahet gdi_hexagon gdi_spokes genrank genstd genvmean ///
	gladder gladder_7 glim_l01 glim_l02 glim_l03 glim_l04 glim_l05 ///
	glim_l06 glim_l07 glim_l08 glim_l09 glim_l10 glim_l11 glim_l12 glim_lf ///
	glim_mu glim_nw1 glim_nw2 glim_nw3 glim_p glim_v1 glim_v2 glim_v3 ///
	glim_v4 glim_v5 glim_v6 glim_v7 glm glm_6 glm_p glm_sw glmpred glogit ///
	glogit_8 glogit_p gmeans gnbre_lf gnbreg gnbreg_5 gnbreg_p gomp_lf ///
	gompe_sw gomper_p gompertz gompertzhet gomphet_glf gomphet_glf_sh ///
	gomphet_gp gomphet_ilf gomphet_ilf_sh gomphet_ip gphdot gphpen gphprint ///
	gprobi_p gprobit gprobit_8 gr gr_copy gr_current gr_db gr_describe ///
	gr_dir gr_draw gr_draw_replay gr_drop gr_edit gr_editviewopts ///
	gr_example gr_example2 gr_export gr_print gr_qscheme gr_query gr_read ///
	gr_rename gr_replay gr_save gr_set gr_setscheme gr_table gr_undo gr_use ///
	graph grebar greigen greigen_7 greigen_8 grmeanby grmeanby_7 ///
	gs_fileinfo gs_filetype gs_graphinfo gs_stat gsort gwood h hadimvo ///
	hareg hausman he heck_d2 heckma_p heckman heckp_lf heckpr_p heckprob hel ///
	help hereg hetpr_lf hetpr_p hetprob hettest hilite hist hist_7 ///
	histogram hlogit hlu hmeans hotel hotelling hprobit hreg hsearch icd9 ///
	icd9_ff icd9p iis impute imputed imtest inbase integ inten intreg intreg_7 ///
	intreg_p intrg2_ll intrg_ll intrg_ll2 ipolate iqreg ir irf irf_create ///
	irfm iri is_svy is_svysum isid istdize ivprob_1_lf ivprob_lf ivprobit ///
	ivprobit_p ivreg ivreg_footnote ivtob_1_lf ivtob_lf ivtobit ivtobit_p ///
	jackknife jacknife jknife jknife_6 jknife_8 jkstat joinby kalarma1 kap ///
	kap_3 kapmeier kappa kapwgt kdensity kdensity_7 ksm ksmirnov ktau ///
	kwallis labelbook ladder levels levelsof leverage lfit lfit_p lincom ///
	line linktest lloghet_glf lloghet_glf_sh lloghet_gp lloghet_ilf ///
	lloghet_ilf_sh lloghet_ip llogi_sw llogis_p llogist llogistic ///
	llogistichet lnorm_lf lnorm_sw lnorma_p lnormal lnormalhet lnormhet_glf ///
	lnormhet_glf_sh lnormhet_gp lnormhet_ilf lnormhet_ilf_sh lnormhet_ip ///
	lnskew0 loadingplot logi logis_lf logistic logistic_p logit logit_estat ///
	logit_p loglogs logrank loneway lookfor lowess lowess_7 lpredict ///
	lrecomp lroc lroc_7 lrtest lsens lsens_7 lsens_x lstat ltable ltable_7 ///
	ltriang lv lvr2plot lvr2plot_7 makecns manova_estat manova_p mantel ///
	mat_capp mat_order mat_rapp mata_matdescribe mata_matsave mata_matuse ///
	matalabel matcproc matlist matname matrix_input__dlg matstrik mcc mcci ///
	md0_ md1_ md1debug_ md2_ md2debug_ mds mds_estat mds_p mdsconfig mdslong ///
	mdsmat mdsshepard mdytoe mdytof me_derd mean means median memsize ///
	meqparse mer merg merge mfp mfx mhelp mhodds mi minbound mixed_ll ///
	mixed_ll_reparm mkassert mkmat mkspline ml ml_5 ml_adjs ml_bhhhs ///
	ml_c_d ml_check ml_clear ml_cnt ml_debug ml_defd ml_e0 ml_e0_bfgs ///
	ml_e0_cycle ml_e0_dfp ml_e0i ml_e1 ml_e1_bfgs ml_e1_bhhh ml_e1_cycle ///
	ml_e1_dfp ml_e2 ml_e2_cycle ml_ebfg0 ml_ebfr0 ml_ebfr1 ml_ebh0q ml_ebhh0 ///
	ml_ebhr0 ml_ebr0i ml_ecr0i ml_edfp0 ml_edfr0 ml_edfr1 ml_edr0i ml_eds ///
	ml_eer0i ml_egr0i ml_elf ml_elf_bfgs ml_elf_bhhh ml_elf_cycle ml_elf_dfp ///
	ml_elfi ml_elfs ml_enr0i ml_enrr0 ml_erdu0 ml_erdu0_bfgs ml_erdu0_bhhh ///
	ml_erdu0_bhhhq ml_erdu0_cycle ml_erdu0_dfp ml_erdu0_nrbfgs ml_exde ///
	ml_footnote ml_geqnr ml_grad0 ml_graph ml_hbhhh ml_hd0 ml_hold ///
	ml_init ml_inv ml_log ml_max ml_mlout ml_mlout_8 ml_model ml_nb0 ///
	ml_opt ml_p ml_plot ml_query ml_rdgrd ml_repor ml_s_e ml_score ml_searc ///
	ml_technique ml_unhold mlf_ mlog mlogi mlogit mlogit_footnote mlogit_p ///
	mlopts mnl0_ mprobit mprobit_lf mprobit_p mrdu0_ mrdu1_ mvdecode ///
	mvencode mvreg mvreg_estat nbreg nbreg_al nbreg_lf nbreg_p nbreg_sw ///
	nestreg newey newey_7 newey_p nl nl_7 nl_9 nl_9_p nl_p nl_p_7 nlcom ///
	nlcom_p nlexp2 nlexp2_7 nlexp2a nlexp2a_7 nlexp3 nlexp3_7 nlgom3 ///
	nlgom3_7 nlgom4 nlgom4_7 nlinit nllog3 nllog3_7 nllog4 nllog4_7 ///
	nlog_rd nlogit nlogit_p nlogitgen nlogittree nlpred note notes ///
	nptrend numlabel old_ver olo olog ologi ologi_sw ologit ologit_p ///
	ologitp op_colnm op_comp op_diff op_inv op_str opr opro oprob ///
	oprob_sw oprobi oprobi_p oprobit oprobitp opts_exclusive orthog ///
	orthpoly ovtest pac pac_7 palette parse_dissim pause pca pca_8 ///
	pca_display pca_estat pca_p pca_rotate pcamat pchart pchart_7 pchi ///
	pchi_7 pcorr pctile pentium pergram pergram_7 permute permute_8 ///
	personal peto_st pkcollapse pkcross pkequiv pkexamine pkexamine_7 ///
	pkshape pksumm pksumm_7 pnorm pnorm_7 poisgof poiss_lf poiss_sw ///
	poisso_p poisson poisson_estat pperron prais prais_e prais_e2 prais_p ///
	predict predictnl print prob probi probit probit_estat probit_p ///
	proc_time procoverlay procrustes procrustes_estat procrustes_p ///
	profiler prop proportion prtest prtesti pwcorr qby qbys qchi qchi_7 ///
	qladder qladder_7 qnorm qnorm_7 qqplot qqplot_7 qreg qreg_c qreg_p ///
	qreg_sw quadchk quantile quantile_7 range ranksum ratio rchart ///
	rchart_7 rcof recast recode reg reg3 reg3_p regdw regr regre regre_p2 ///
	regres regres_p regress regress_estat regriv_p register regist remap renpfix ///
	repeat reshape robvar roccomp roccomp_7 roccomp_8 rocf_lf rocfit rocfit_8 ///
	rocgold rocplot rocplot_7 roctab roctab_7 rolling rologit rologit_p ///
	rot rota rotat rotate rotatemat rreg rreg_p runtest rvfplot rvfplot_7 ///
	rvpplot rvpplot_7 safesum sample sampsi savedresults saveold sc ///
	scatter scm_mine sco scob_lf scob_p scobi_sw scobit scor score scoreplot ///
	scoreplot_help scree screeplot screeplot_help sdtest sdtesti separate ///
	seperate serrbar serrbar_7 set_defaults sfrancia shewhart shewhart_7 ///
	signestimationsample signrank signtest simul simul_7 simulate simulate_8 ///
	sktest slogit slogit_d2 slogit_p smooth snapspan spearman spikeplot ///
	spikeplot_7 spikeplt spline_x split sqreg sqreg_p ssc st st_ct st_hc ///
	st_hcd st_hcd_sh st_is st_issys st_note st_promo st_set st_show st_smpl ///
	st_subid stack statsby statsby_8 stbase stci stci_7 stcox stcox_estat ///
	stcox_fr stcox_fr_ll stcox_p stcox_sw stcoxkm stcoxkm_7 stcstat stcurv ///
	stcurve stcurve_7 stdes stem stepwise stereg stfill stgen stir stjoin ///
	stmc stmh stphplot stphplot_7 stphtest stphtest_7 stptime strate ///
	strate_7 streg streg_sw streset sts sts_7 stset stsplit stsum sttocc ///
	sttoct stvary stweib suest suest_8 sunflower sureg survcurv survsum svar ///
	svar_p svmat svy svy_disp svy_dreg svy_est svy_est_7 svy_estat svy_get ///
	svy_gnbreg_p svy_head svy_header svy_heckman_p svy_heckprob_p ///
	svy_intreg_p svy_ivreg_p svy_logistic_p svy_logit_p svy_mlogit_p ///
	svy_nbreg_p svy_ologit_p svy_oprobit_p svy_poisson_p svy_probit_p ///
	svy_regress_p svy_sub svy_sub_7 svy_x svy_x_7 svy_x_p svydes ///
	svydes_8 svygen svygnbreg svyheckman svyheckprob svyintreg svyintreg_7 ///
	svyintrg svyivreg svylc svylog_p svylogit svymarkout svymarkout_8 ///
	svymean svymlog svymlogit svynbreg svyolog svyologit svyoprob svyoprobit ///
	svyopts svypois svypois_7 svypoisson svyprobit svyprobt svyprop ///
	svyprop_7 svyratio svyreg svyreg_p svyregress svyset svyset_7 svyset_8 ///
	svytab svytab_7 svytest svytotal sw sw_8 swcnreg swcox swereg swilk ///
	swlogis swlogit swologit swoprbt swpois swprobit swqreg swtobit swweib ///
	symmetry symmi symplot symplot_7 sysdescribe sysuse szroeter tab1 tab2 ///
	tab_or tabi table tabodds tabodds_7 tabstat te tes test testnl testparm ///
	teststd tetrachoric time_it tis tob tobi tobit tobit_p tobit_sw tostring ///
	total treat_ll treatr_p treatreg trim trnb_cons trnb_mean trpoiss_d2 ///
	trunc_ll truncr_p truncreg tsappend tset tsfill tsline tsline_ex ///
	tsreport tsrline tsset tssmooth tsunab ttest ttesti tut_chk tut_wait ///
	tutorial tw tware_st two twoway twoway__fpfit_serset ///
	twoway__function_gen twoway__histogram_gen twoway__ipoint_serset ///
	twoway__ipoints_serset twoway__kdensity_gen twoway__lfit_serset ///
	twoway__normgen_gen twoway__pci_serset twoway__qfit_serset ///
	twoway__scatteri_serset twoway__sunflower_gen twoway_ksm_serset ///
	typeof unab unabbrev uselabel var var_mkcompanion var_p varbasic ///
	varfcast vargranger varirf varirf_add varirf_cgraph varirf_create ///
	varirf_ctable varirf_describe varirf_dir varirf_drop varirf_erase ///
	varirf_graph varirf_ograph varirf_rename varirf_set varirf_table ///
	varlmar varnorm varsoc varstable varstable_w varstable_w2 varwle vce ///
	vec vec_fevd vec_mkphi vec_p vec_p_w vecirf_create veclmar veclmar_w ///
	vecnorm vecnorm_w vecrank vecstable verinst viewsource vif vwls wdatetof ///
	webdescribe webseek webuse weib1_lf weib2_lf weib_lf weib_lf0 ///
	weibhet_glf weibhet_glf_sh weibhet_glfa weibhet_glfa_sh weibhet_gp ///
	weibhet_ilf weibhet_ilf_sh weibhet_ilfa weibhet_ilfa_sh weibhet_ip ///
	weibu_sw weibul_p weibull weibull_c weibull_s weibullhet whelp wilc_st ///
	wilcoxon wntestb wntestb_7 wntestq xchart xchart_7 xcorr xcorr_7 xi xi_6 ///
	xpose xt_iis xt_tis xtab_p xtabond xtbin_p xtclog xtcloglog xtcloglog_8 ///
	xtcloglog_d2 xtcloglog_pa_p xtcloglog_re_p xtcnt_p xtcorr xtdata xtdes ///
	xtfront_p xtfrontier xtgee xtgee_elink xtgee_estat xtgee_makeivar ///
	xtgee_p xtgee_plink xtgls xtgls_p xthaus xthausman xtht_p xthtaylor ///
	xtile xtint_p xtintreg xtintreg_8 xtintreg_d2 xtintreg_p xtivp_1 xtivp_2 ///
	xtivreg xtline xtline_ex xtlogit xtlogit_8 xtlogit_d2 xtlogit_fe_p ///
	xtlogit_pa_p xtlogit_re_p mixed xtmixed xtmixed_estat xtmixed_p xtnb_fe ///
	xtnb_lf xtnbreg xtnbreg_pa_p xtnbreg_refe_p xtpcse xtpcse_p xtpois ///
	xtpoisson xtpoisson_d2 xtpoisson_pa_p xtpoisson_refe_p xtpred xtprobit ///
	xtprobit_8 xtprobit_d2 xtprobit_re_p xtps_fe xtps_lf xtps_ren xtps_ren_8 ///
	xtrar_p xtrc xtrc_p xtrchh xtrefe_p xtreg xtreg_be xtreg_fe xtreg_ml ///
	xtreg_pa_p xtreg_re xtregar xtrere_p xtset xtsf_ll xtsf_llti xtsum xttab ///
	xttest0 xttobit xttobit_8 xttobit_p xttrans yx yxview__barlike_draw ///
	yxview_area_draw yxview_bar_draw yxview_dot_draw yxview_dropline_draw ///
	yxview_function_draw yxview_iarrow_draw yxview_ilabels_draw ///
	yxview_normal_draw yxview_pcarrow_draw yxview_pcbarrow_draw ///
	yxview_pccapsym_draw yxview_pcscatter_draw yxview_pcspike_draw ///
	yxview_rarea_draw yxview_rbar_draw yxview_rbarm_draw yxview_rcap_draw ///
	yxview_rcapsym_draw yxview_rconnected_draw yxview_rline_draw ///
	yxview_rscatter_draw yxview_rspike_draw yxview_spike_draw ///
	yxview_sunflower_draw zap_s zinb zinb_llf zinb_plf zip zip_llf zip_p ///
	zip_plf zt_ct_5 zt_hc_5 zt_hcd_5 zt_is_5 zt_iss_5 zt_sho_5 zt_smp_5 ///
	ztbase_5 ztcox_5 ztdes_5 ztereg_5 ztfill_5 ztgen_5 ztir_5 ztjoin_5 ztnb ///
	ztnb_p ztp ztp_p zts_5 ztset_5 ztspli_5 ztsum_5 zttoct_5 ztvary_5 ///
	///
	tabmiss wide misstable patterns regular chained pmm install ///
	ztweib_5 export connected function ///
	

	
	/* LIST OF FUNCTIONS */  
	global synfunclist ///
	abs( acos( acosh( asin( asinh( atan( atan2( atanh( ceil( cloglog( comb( ///
	cos( cosh( digamma( exp( floor( int( invcloglog( invlogit( ln( ///
	lnfactorial( lngamma( log( log10( logit( max( min( mod( reldif( round( ///
	sign( sin( sinh( sqrt( sum( tan( tanh( trigamma( trunc( ibeta( betaden( ///
	ibetatail( invibeta( invibetatail( nibeta( nbetaden( invnibeta( ///
	binomial( binomialp( binomialtail( invbinomial( invbinomialtail( chi2( ///
	chi2den( chi2tail( invchi2( invchi2tail( nchi2( nchi2den( nchi2tail( ///
	invnchi2( invnchi2tail( npnchi2( dunnettprob( invdunnettprob( F( Fden( ///
	Ftail( invF( invFtail( nF( nFden( nFtail( invnFtail( npnF( gammap( ///
	gammaden( gammaptail( invgammap( invgammaptail( dgammapda( dgammapdada( ///
	dgammapdadx( dgammapdx( dgammapdxdx( hypergeometric( hypergeometricp( ///
	nbinomial( nbinomialp( nbinomialtail( invnbinomial( invnbinomialtail( ///
	binormal( normal( normalden( normalden( normalden( invnormal( lnnormal( ///
	lnnormalden( lnnormalden( lnnormalden( poisson( poissonp( poissontail( ///
	invpoisson( invpoissontail( t( tden( ttail( invt( invttail( nt( ntden( ///
	nttail( invnttail( npnt( tukeyprob( invtukeyprob( runiform( rbeta( ///
	rbinomial( rchi2( rgamma( rhypergeometric( rnbinomial( rnormal( rnormal( ///
	rnormal( rpoisson( rt( abbrev( char( indexnot( itrim( length( lower( ///
	ltrim( plural( proper( real( regexm( regexr( regexs( reverse( rtrim( ///
	soundex( soundex_nara( strcat( strdup( string( strlen( strlower( ///
	strltrim( strmatch( strofreal( strofreal( strpos( strproper( strreverse( ///
	strrtrim( strtoname( strtoname( strtrim( strupper( subinstr( subinword( ///
	substr( trim( upper( word( wordcount( autocode( byteorder( c( _caller( ///
	chop( clip( cond( e( epsdouble( epsfloat( fileexists( fileread( ///
	filereaderror( filewrite( float( fmtwidth( has_eprop( inlist( inrange( ///
	irecode( matrix( maxbyte( maxdouble( maxfloat( maxint( maxlong( mi( ///
	minbyte( mindouble( minfloat( minint( minlong( missing( r( recode( ///
	replay( return( s( scalar( smallestdouble( bofd( Cdhms( Chms( Clock( ///
	clock( Cmdyhms( Cofc( cofC( Cofd( cofd( daily( date( day( dhms( dofb( ///
	dofC( dofc( dofh( dofm( dofq( dofw( dofy( dow( doy( halfyear( ///
	halfyearly( hh( hhC( hms( hofd( hours( mdy( mdyhms( minutes( mm( mmC( ///
	mofd( month( monthly( msofhours( msofminutes( msofseconds( qofd( ///
	quarter( quarterly( seconds( ss( ssC( tC( tc( td( th( tm( tq( tw( week( ///
	weekly( wofd( year( yearly( yh( ym( yofd( yq( yw( tin( twithin( ///
	cholesky( corr( diag( get( hadamard( I( inv( invsym( J( matuniform( ///
	nullmat( sweep( vec( vecdiag( colnumb( colsof( det( diag0cnt( el( ///
	issymmetric( matmissing( mreldif( rownumb( rowsof( trace(
	
	end	
	
	
	
	
	
	
	
	
	
