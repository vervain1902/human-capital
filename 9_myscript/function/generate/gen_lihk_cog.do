cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - estimate lihk index [with cog]
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.10.31

==================================================*/

*---1 estimate 4 Mincer equations [urban*gender] by year
*------1.1 full-sample regression
// reg without x-terms
forvalues i = 2010(2)2020 {
	cd "$mydir\3_LIHK"
	use 2_Macro_Pop0_pCog0_aEduy0_Cog_Inc, clear
	duplicates drop cyear pid, force 
	keep if cyear == `i'

	foreach a in 1 0 {
		foreach b in 1 0 {
			di("*--------------------------------------------------------*")
			di("Coefficients of Variable eduy, st_cog, exp, exp2 for Year `i' is Estimated.")
			di("Subgroup: Gender = `a' and Urban = `b'.")
			di("*--------------------------------------------------------*")
			local vars "Linc eduy st_cog exp exp2"
			reg `vars' if gender == `a' & urban == `b'
			sum `vars' if gender == `a' & urban == `b'
		}
	}

// reg with x-terms
	local vars "cons eduy eduy_wy st_cog cog_wy exp exp2 avwage"
	foreach v in `vars' {
		gen b_`v' = .
	}
	gen a = .
	
	// model00: without x-terms
	di _newline(3)
	di("*--------------------------------------------------------*")
	di "reg Linc eduy st_cog exp exp2"
	di("*--------------------------------------------------------*")
	reg Linc eduy st_cog exp exp2

	// model01: with x-terms [eduy*wy]
	di _newline(3)
	di("*--------------------------------------------------------*")
	di "reg Linc eduy eduy_wy st_cog cog_wy exp exp2 avwage"	
	di("*--------------------------------------------------------*")
	reg Linc eduy eduy_wy st_cog cog_wy exp exp2 avwage

*------1.2 by-sample regression [urban male/urban female/rural male/rural female]
	foreach a in 0 1 {     
		foreach b in 0 1 { 
			di "urban = "`a'
			di "gender = "`b'

			// model0: without x-terms
			local vars "Linc eduy st_cog exp exp2"
			reg `vars' if urban == `a' & gender == `b'
			sum `vars' if urban == `a' & gender == `b'
			predict ooo, xb    
			gen lyhat = exp(ooo) if urban == `a' & gender == `b'
			reg Linc lyhat, nocon
			drop ooo lyhat
			
			// model1: with x-terms [eduy*wy]
			di "reg Linc eduy eduy_wy st_cog cog_wy exp exp2 avwage"
			reg Linc avwage eduy eduy_wy st_cog cog_wy exp exp2 ///
				if urban == `a' & gender == `b'
			
			// 保存Mincer系数
			replace b_cons = _b[_cons] if urban == `a' & gender == `b'  
			local vars "avwage eduy eduy_wy st_cog cog_wy exp exp2 avwage"
			foreach v in `vars' {
				replace b_`v' = _b[`v'] if urban == `a' & gender == `b'
			}
			
			//计算alpha
			predict idx, xb                   
			gen mi = exp(idx) if urban ==`a' & gender ==`b'           
			reg Linc mi, noconstant       
			replace a = _b[mi] if urban ==`a' & gender ==`b'
			drop idx mi
		}		
	}	

*------1.3 adjust beta of Mincer equation by avg_wage of province and urban
	gen intercept = b_cons + b_avwage * avwage
	gen idx_eduy = b_eduy + b_eduy_wy * pgdp_w / 1000
	gen idx_cog = b_cog + b_cog_wy * pgdp_w / 1000
	gen idx_exp = b_exp
	gen idx_exp2 = b_exp2

	keep cyear provcd age urban gender eduy* st_cog cog_wy exp* idx* intercept b_*
	cd "$mydir\3_LIHK"
	save `i'_param_cog, replace
}

// save adjusted intercept of Mincer equation by urban and gender 
forvalues i = 2010(2)2020 {
	foreach j in 0 1 {
		foreach k in 0 1 {
			use `i'_param_cog, clear
			keep if urban == `j' * gender == `k'
			keep provcd cyear intercept 
			rename intercept int`j'`k'
			duplicates drop cyear provcd, force
			save `i'_int`j'`k'_cog, replace
		}
	}
	use `i'_param_cog, clear
	merge m:1 provcd using `i'_int00_cog, keep(match) nogen	// urban == 0 & gender == 0
	merge m:1 provcd using `i'_int01_cog, keep(match) nogen	// urban == 0 & gender == 1
	merge m:1 provcd using `i'_int10_cog, keep(match) nogen	// urban == 1 & gender == 0
	merge m:1 provcd using `i'_int11_cog, keep(match) nogen	// urban == 1 & gender == 1
	save `i'_param_cog, replace
	erase `i'_int00_cog.dta
	erase `i'_int01_cog.dta
	erase `i'_int10_cog.dta
	erase `i'_int11_cog.dta
}

*------1.4 merge betas and intercept of Mincer Eq and save micro data 
cd "$mydir\3_LIHK"
use 2010_param_cog, clear
forvalues i = 2012(2)2020 {
	ap using `i'_param_cog
	erase `i'_param_cog.dta 
}
erase 2010_param_cog.dta 
keep cyear provcd urban gender age eduy st_cog cog_wy exp* idx* int* 
save 2_param_cog, replace

*------1.5 regress betas and intercept to year, and generate estimated parameters
cd "$mydir\3_LIHK"
use 2_param_cog, clear

local vars "provcd urban gender"
duplicates drop cyear `vars', force

sor `vars'
egen id = group(`vars') // 按省份、城乡、性别分组
cap gen cyear2 = cyear ^ 2

// 生成变量
gen intercept_fit = .
gen idx_eduy_fit = . 
gen idx_cog_fit = .
gen idx_exp_fit = .
gen idx_exp2_fit = .

// estimate
levelsof id, local(id_list)
foreach i in `id_list' {

	quietly count if id == `i'
	    if r(N) < 2 {
	        // 如果样本量小于 2，则设置拟合值为 NA
	        replace intercept_fit = . if id == `i'
	        replace idx_eduy_fit = . if id == `i'
	        replace idx_cog_fit = . if id == `i'
	        replace idx_exp_fit = . if id == `i'
	        replace idx_exp2_fit = . if id == `i'
	        continue
	    }

	cap gen cyear2 = cyear ^ 2

	qui reg intercept cyear if id == `i'
 	gen tem1 = _b[cyear]
	gen tem3 = _b[_cons]
	gen tem4 = tem1 * cyear + tem3 if id == `i'
	replace intercept_fit = tem4 if id == `i'
	drop tem*
	
	qui reg idx_eduy cyear cyear2 if id == `i'
	gen tem1 = _b[cyear]
	gen tem2 = _b[cyear2]
	gen tem3 = _b[_cons]
	gen tem4 = tem1 * cyear + tem2 * cyear2 + tem3 if id == `i'
	replace idx_eduy_fit = tem4 if id == `i' 
	drop tem*

	qui reg idx_cog cyear cyear2 if id == `i'
	gen tem1 = _b[cyear]
	gen tem2 = _b[cyear2]
	gen tem3 = _b[_cons]
	gen tem4 = tem1 * cyear + tem2 * cyear2 + tem3 if id == `i'
	replace idx_cog_fit = tem4 if id == `i' 
	drop tem*
	
	qui reg idx_exp cyear cyear2 if id == `i'
	gen tem1 = _b[cyear]
	gen tem2 = _b[cyear2]
	gen tem3 = _b[_cons]
	gen tem4 = tem1 * cyear + tem2 * cyear2 + tem3 if id == `i'
	replace idx_exp_fit = tem4 if id == `i'
	drop tem*
	
	qui reg idx_exp2 cyear if id == `i'
	gen tem1 = _b[cyear]
	gen tem3 = _b[_cons]
	gen tem4 = tem1 * cyear + tem3 if id == `i'
	replace idx_exp2_fit = tem4 if id == `i'
	drop tem*
}

local vars "cyear provcd gender urban"
merge 1:m `vars' using 2_param_cog, nogen keep(match)
save 3_param_cog_fitted, replace

*------1.6 generate lihk index using estimated params
// 标准工人：农村女性
cd "$mydir\3_LIHK"
use 3_param_cog_fitted, clear
gen lnh = eduy*idx_eduy_fit + st_cog*idx_cog_fit + exp*idx_exp_fit + exp2*idx_exp2_fit
replace lnh = int01-int00 + eduy*idx_eduy_fit + st_cog*idx_cog_fit + exp*idx_exp_fit + exp2*idx_exp2_fit ///
	if urban == 0 & gender == 1
replace lnh = int10-int00 + eduy*idx_eduy_fit + st_cog*idx_cog_fit + exp*idx_exp_fit + exp2*idx_exp2_fit ///
	if urban == 1 & gender == 0
replace lnh = int11-int00 + eduy*idx_eduy_fit + st_cog*idx_cog_fit + exp*idx_exp_fit + exp2*idx_exp2_fit ///
	if urban == 1 & gender == 1

gen idx_h = exp(lnh)
label var idx_h "micro lihk index"

// 分年份、分省份、分城乡、性别、年龄、受教育分组，取人力资本指数的均值，作为4分人口的平均人力资本指数
gen sch = 0
replace sch = 6 if eduy < 9 & eduy >= 6
replace sch = 9 if eduy < 12 & eduy >= 9
replace sch = 12 if eduy < 15 & eduy >= 12
replace sch = 15 if eduy == 15
replace sch = 16 if eduy >= 16

local vars "cyear provcd urban gender age sch"
bys `vars': egen idx_h4 = mean(idx_h)
duplicates drop `vars', force 
keep `vars' idx_h4
cd "$mydir\2_Cog\worker"
local vars "cyear provcd urban gender age sch"
merge 1:1 `vars' using 2_Macro_Pop4_pCog4, nogen keep(match) 
gen lihk4 = idx_h4 * pop
label var lihk4 "lihk stock of 4-fold pop"
cd "$mydir\3_LIHK"
save 4_Macro_Pop4_pCog4_LIHK4_cog, replace

*---2 generate lihk stock by year and prov 
local vars "cyear provcd"
bys `vars': egen lihk0 = total(lihk4)
duplicates drop `vars', force
cd "$mydir\2_Cog\worker"
mer 1:1 `vars' using 8_Macro_Pop0_pCog0_aEduy0, nogen
label var lihk0 "lihk stock of 0-fold"
drop urban gender age sch pcog pop age* 
cd "$mydir\3_LIHK"
save 5_Macro_Pop0_pCog0_aEduy0_Cog_Inc_LIHK0_cog, replace
