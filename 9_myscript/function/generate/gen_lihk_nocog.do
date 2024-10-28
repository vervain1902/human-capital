cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 计算lihk指数（不含认知技能）
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.10.28

==================================================*/

*---1 分年度，估计城市/农村、男性/女性4个Mincer方程
*------1.1 全样本回归
// 不含交互项，估计原始方程
forvalues i = 2010(2)2020 {
	cd "$mydir\3_LIHK"
	use 3_Macro_Pop4_Cog4_Inc, clear
	// use 1_LIHK, clear
	duplicates drop cyear pid, force 
	keep if cyear == `i'

	foreach a in 1 0 {
		foreach b in 1 0 {
			di("*--------------------------------------------------------*")
			di("Coefficients of Variable eduy, cog, exp, exp2 for Year `i' is Estimated.")
			di("Subgroup: Gender = `a' and Urban = `b'.")
			di("*--------------------------------------------------------*")
			// local vars "Linc eduy exp exp2"
			local vars "Linc eduy exp exp2"
			reg `vars' if gender == `a' & urban == `b'
			sum `vars' if gender == `a' & urban == `b'
		}
	}

// 加入交互项
	local vars "cons eduy eduy_wy eduy_indus exp exp2 avwage"
	// local vars "cons eduy exp exp2 avwage"
	foreach v in `vars' {
		gen b_`v' = .
	}
	gen a = .
	
	// 初始模型
	di _newline(3)
	di("*--------------------------------------------------------*")
	di "reg Linc eduy exp exp2"
	di("*--------------------------------------------------------*")
	reg Linc eduy exp exp2

	// 增加教育年限交互项估计
	di _newline(3)
	di("*--------------------------------------------------------*")
	di "reg Linc avwage eduy eduy_wy exp exp2"	
	di("*--------------------------------------------------------*")
	reg Linc avwage eduy eduy_wy eduy_indus exp exp2

*------ 2.2.分样本回归：城市男性/城市女性/农村男性/农村女性
	di _newline(3)
	foreach a in 0 1 {     
		foreach b in 0 1 {
			di "urban = "`a'
			di "gender = "`b'
			// 原始模型：不含交互项
			reg Linc eduy exp exp2 if urban == `a' & gender == `b'
			sum Linc eduy exp exp2 if urban == `a' & gender == `b'
			predict ooo, xb    
			gen lyhat = exp(ooo) if urban == `a' & gender == `b'
			reg Linc lyhat, nocon
			drop ooo lyhat
			
			//增加交互项，重新估计
			di "reg Linc avwage eduy eduy_wy eduy_indus exp exp2"
			reg Linc avwage eduy eduy_wy eduy_indus exp exp2 ///
				if urban == `a' & gender == `b'
			
			//保存Mincer系数
			replace b_cons = _b[_cons] if urban == `a' & gender == `b'  
			local vars "avwage eduy eduy_wy eduy_indus exp exp2"
			foreach v in `vars' {
				replace b_`v' = _b[`v'] if urban == `a' & gender == `b'
			}
			
			//计算alpha
			predict idx, xb                   
			gen mi = exp(idx) if urban==`a' & gender==`b'           
			reg Linc mi, noconstant       
			replace a = _b[mi] if urban==`a' & gender==`b'
			drop idx mi
			di _newline(3)
		}		
	}	

*------ 2.3.根据分省份、城乡的平均工资水平，调整估计出的系数
	gen intercept = b_cons + b_avwage * avwage
	gen idx_eduy = b_eduy + b_eduy_wy * wy / 1000 + b_eduy_indus * indus
	gen idx_exp = b_exp
	gen idx_exp2 = b_exp2

	keep cyear provcd age urban gender eduy exp* idx* intercept b_*
	cd "$mydir\3_LIHK\MincerParam"
	save `i'_param_nocog, replace
}

// 分城乡、性别，保存调整后的Mincer方程截距
forvalues i = 2010(2)2020 {
	foreach j in 0 1 {
		foreach k in 0 1 {
			use `i'_param_nocog, clear
			keep if urban == `j' * gender == `k'
			keep provcd cyear intercept 
			rename intercept int`j'`k'
			duplicates drop cyear provcd, force
			save `i'_int`j'`k'_nocog, replace
		}
	}
	use `i'_param_nocog, clear
	merge m:1 provcd using `i'_int00_nocog, keep(match) nogen	// urban == 0 & gender == 0
	merge m:1 provcd using `i'_int01_nocog, keep(match) nogen	// urban == 0 & gender == 1
	merge m:1 provcd using `i'_int10_nocog, keep(match) nogen	// urban == 1 & gender == 0
	merge m:1 provcd using `i'_int11_nocog, keep(match) nogen	// urban == 1 & gender == 1
	save `i'_param_nocog, replace
	erase `i'_int00_nocog.dta
	erase `i'_int01_nocog.dta
	erase `i'_int10_nocog.dta
	erase `i'_int11_nocog.dta
}

*------ 2.4.合并历年Mincer系数，保存个体层面数据
cd "$mydir\3_LIHK\MincerParam"
use 2010_param_nocog, clear
forvalues i = 2012(2)2020 {
	ap using `i'_param_nocog
	erase `i'_param_nocog.dta 
}
erase 2010_param_nocog.dta 
keep cyear provcd urban gender age eduy exp* idx* int* 
save 1_Param_nocog, replace

*------ 2.5.Mincer方程参数（截距、受教育年限、认知技能、工作经验、工作经验平方项）对时间回归，得到参数拟合值
cd "$mydir\3_LIHK\MincerParam"
use 1_Param_nocog, clear

// 删除样本量不足的省份
local vars "provcd urban gender"
duplicates drop cyear `vars', force
/* bys `vars': gen group_size = _N
drop if group_size < 6 */

sor `vars'
egen id = group(`vars') // 按省份、城乡、性别分组
cap gen cyear2 = cyear^2

// 生成变量
gen intercept_1 = .
gen idx_eduy_1 = . 
gen idx_cog_1 = .
gen idx_exp_1 = .
gen idx_exp2_1 = .

// 拟合
levelsof id, local(id_list)
foreach i in `id_list' {
	cap gen cyear2 = cyear ^ 2
	qui reg intercept cyear if id == `i'
 	gen tem1 = _b[cyear]
	gen tem3 = _b[_cons]
	gen tem4 = tem1 * cyear + tem3 if id == `i'
	replace intercept_1 = tem4 if id == `i'
	drop tem*
	
	qui reg idx_eduy cyear cyear2 if id == `i'
	gen tem1 = _b[cyear]
	gen tem2 = _b[cyear2]
	gen tem3 = _b[_cons]
	gen tem4 = tem1 * cyear + tem2 * cyear2 + tem3 if id == `i'
	replace idx_eduy_1 = tem4 if id == `i' 
	drop tem*
	
	qui reg idx_exp cyear cyear2 if id == `i'
	gen tem1 = _b[cyear]
	gen tem2 = _b[cyear2]
	gen tem3 = _b[_cons]
	gen tem4 = tem1 * cyear + tem2 * cyear2 + tem3 if id == `i'
	replace idx_exp_1 = tem4 if id == `i'
	drop tem*
	
	qui reg idx_exp2 cyear if id == `i'
	gen tem1 = _b[cyear]
	gen tem3 = _b[_cons]
	gen tem4 = tem1 * cyear + tem3 if id == `i'
	replace idx_exp2_1 = tem4 if id == `i'
	drop tem*
}

local vars "cyear provcd gender urban"
keep `vars' *_1
save tmp_idx_nocog, replace

local vars "cyear provcd gender urban"
merge 1:m `vars' using 1_Param_nocog, nogen keep(match)
save 2_Param_estimate_nocog, replace
erase tmp_idx_nocog.dta

*------ 2.6.基于拟合参数，计算人力资本指数
// 标准工人：农村女性
cd "$mydir\3_LIHK\MincerParam"
use 2_Param_estimate_nocog, clear
gen lnh = eduy*idx_eduy_1 + exp*idx_exp_1 + exp2*idx_exp2_1
replace lnh = int01-int00 + eduy*idx_eduy_1 + exp*idx_exp_1 + exp2*idx_exp2_1 ///
	if urban == 0 & gender == 1
replace lnh = int10-int00 + eduy*idx_eduy_1 + exp*idx_exp_1 + exp2*idx_exp2_1 ///
	if urban == 1 & gender == 0
replace lnh = int11-int00 + eduy*idx_eduy_1 + exp*idx_exp_1 + exp2*idx_exp2_1 ///
	if urban == 1 & gender == 1

gen idx_h = exp(lnh)
label var idx_h "人力资本指数"

// 分年份、分省份、分城乡、性别、年龄、受教育分组，取人力资本指数的均值，作为4分人口的平均人力资本指数
gen sch = 0
replace sch = 6 if eduy < 9 & eduy >= 6
replace sch = 9 if eduy < 12 & eduy >= 9
replace sch = 12 if eduy < 15 & eduy >= 12
replace sch = 15 if eduy == 15
replace sch = 16 if eduy >= 16

local vars "cyear provcd urban gender age sch"
bys `vars': egen avg_idx_h = mean(idx_h)
duplicates drop `vars', force 
order `vars'
sor `vars'
keep `vars' avg_idx_h
save 2_ParamGroup1_nocog, replace

*--- 3.分年份、分省份计算人力资本存量
*------3.1.链接CHLR的四分人口
cd "$mydir\3_LIHK\MincerParam"
use 2_ParamGroup1_nocog, clear 
cd "$mydir\2_Cog\worker"
local vars "cyear provcd urban gender age sch"
merge 1:1 `vars' using 9_Macro_Pop4_Cog4, nogen keep(match) 
sor `vars'
order `vars'
gen h = avg_idx_h * pop
label var h "四分人口LIHK存量"
cd "$mydir\3_LIHK"
save 2_LIHKGroup1_nocog, replace

bys cyear provcd: egen H = total(h)
duplicates drop cyear provcd, force
label var H "分省LIHK存量"
cd "$mydir\3_LIHK"
save 2_LIHKGroup2_nocog, replace
