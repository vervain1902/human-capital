/*

Project:			human capital
Author:				liuziyu
Create Date:		2023.12

database used:
	CFPS 2010-2020
	CHLR 2010-2020
	Macrodata

This script is for:
	1) Using data from CFPS 2010-2020 to get eduyear, age, gender, urban, wage each individual;
	2) Using Macro data from CHLR and yearbooks to get average wage and ; 
	3) Using pop data to calculate LIHK stock each province.

*/

*--- 0: Program set up
clear all
cls

global dir "D:\Onedrive\OneDrive - mail.bnu.edu.cn\1 Seminar\Publishs\1031-认知技能\data"
global mydir 	"$dir\mydata"
global rawdir	"$dir\rawdata"
global outdir	"$dir\myoutput"
global provcd "11 12 13 21 31 32 33 35 37 44 46 15 45 50 51 52 53 54 61 62 63 64 65 14 22 23 34 36 41 42 43"
set scheme plotplain, perm

/*
/*==================================================
              #: 按个案链接历年个人收入
==================================================*/
cd "$rawdir\CFPS"
use cfps2020person_202306, clear
keep pid emp_income provcd20
rename emp_income inc20
rename provcd20 provcd
merge 1:1 pid using cfps2018person_202012, nogen keep(match) keepusing(income)
rename income inc18
merge 1:1 pid using cfps2016adult_201906, nogen keep(match) ///
										  keepusing(incomea incomeb incomeb_imp)
foreach i in incomea incomeb incomeb_imp {
	replace `i' = . if `i' < 0
}

drop if incomea == .
drop if incomeb == . & incomeb_imp == .
gen inc16 = incomea + incomeb
replace inc16 = incomea + incomeb_imp if incomeb == .
drop income*

merge 1:1 pid using cfps2014adult_201906, nogen keep(match) keepusing(p_wage)
rename p_wage inc14

merge 1:1 pid using cfps2012adult_201906, nogen keep(match) keepusing(income_adj)
rename income_adj inc12

merge 1:1 pid using cfps2010adult_201906, nogen keep(match) keepusing(income)
rename income inc10

foreach i in 10 12 14 16 18 20 {
    replace inc`i' = . if inc`i' < 0
	misstable sum inc`i'
	drop if inc`i' == .
}
	bys provcd: egen q1inc`i' = pctile(inc`i'), p(25)
	bys provcd: egen q2inc`i' = pctile(inc`i'), p(50)
	bys provcd: egen q3inc`i' = pctile(inc`i'), p(75)
}
*/

*--- 1: 处理历年数据，保留需要的变量
*------ 1.1: 处理2020年个人自答问卷，保留变量	
cd "$rawdir\CFPS"
use cfps2020person_202306, clear
replace cyear = 2020
local vars "provcd20 urban20 cfps2020eduy_im emp_income"
keep pid cyear gender age employ `vars'
rename (`vars') (provcd urban eduy inc)
cd "$mydir\LIHK\1_LIHK"
save LIHK_20, replace

*------ 1.2: 处理2018年个人自答问卷，保留变量
cd "$rawdir\CFPS"
use cfps2018person_202012, clear
replace cyear = 2018
local vars "provcd18 urban18 cfps2018eduy_im income"
keep pid cyear gender age employ `vars'
rename (`vars') (provcd urban eduy inc)
cd "$mydir\LIHK\1_LIHK"
save LIHK_18, replace

*------ 1.3: 处理2016年个人自答问卷，保留变量
cd "$rawdir\CFPS"
use cfps2016adult_201906, clear
replace cyear = 2016
local vars "provcd16 urban16 cfps_gender cfps_age cfps2016eduy_im"
keep pid cyear incomea incomeb incomeb_imp employ `vars'
rename (`vars') (provcd urban gender age eduy)

* 合成个人总收入=一般工作收入+主要工作收入
foreach i in incomea incomeb incomeb_imp {
	replace `i' = . if `i' < 0
	misstable sum `i'
}

drop if incomea == .
drop if incomeb == . & incomeb_imp == .
gen inc = incomea + incomeb
replace inc = incomea + incomeb_imp if incomeb == .
label var inc "总收入"
drop income*
cd "$mydir\LIHK\1_LIHK"
save LIHK_16, replace

*------ 1.4: 处理2014年个人自答问卷，保留变量
cd "$rawdir\CFPS"
use cfps2014adult_201906, clear
replace cyear = 2014
local vars "provcd14 urban14 cfps_gender cfps2014_age cfps2014eduy_im p_wage employ2014"
keep pid cyear `vars'
rename (`vars') (provcd urban gender age eduy inc employ)
cd "$mydir\LIHK\1_LIHK"
save LIHK_14, replace

*------ 1.5: 处理2012年个人自答问卷，保留变量
cd "$rawdir\CFPS"
use cfps2012adult_201906, clear
replace cyear = 2012
local vars "urban12 cfps2012_gender_best cfps2012_age eduy2012 income_adj"
keep pid fid12 cyear provcd qg417* qg420* qg305 qg20* employ `vars'
rename (`vars') (urban gender age eduy inc_1)

// 城市收入计算
/// 工资性收入
gen qg420 = 0
forvalues i = 1/50 {
	replace qg420_a_`i' = 0 if qg420_a_`i' == -8
	replace qg420_a_`i' = . if qg420_a_`i' < 0
	replace qg420 = qg420 + qg420_a_`i'
}

gen qg417 = 0
forvalues i = 1/10 {
	replace qg417_a_`i' = 0 if qg417_a_`i' == -8
	replace qg417_a_`i' = . if qg417_a_`i' < 0
	replace qg417 = qg417 + qg417_a_`i'
}

gen wage = qg417 + qg420
misstable sum wage 
label var wage "工资性收入"

// 农村收入计算
/// 帮工收入
// replace qg305 = 0 if qg305 < 0 

/// 家庭农业生产收入按劳动时间比例分配到个人
forvalues i = 2/6 {
	replace qg20`i' = 0 if qg20`i' == -8 
	replace qg20`i' = . if qg20`i' < 0 
}

gen time = qg202 * (qg203*qg204 + qg205*qg206) / 2
bys fid12: egen hhtime = sum(time)
gen agri_ratio = time / hhtime
// replace agri_ratio = 0 if agri_ratio == .

merge m:1 fid12 using cfps2012famecon_201906, keepusing(fl3 fl7 fl8 fl4 fl9) keep(match) nogen 
foreach i in fl3 fl7 fl8 fl4 fl9 {
	replace `i' = 0 if `i' == -8
	replace `i' = . if `i' < 0 
}
gen net_agri = (fl3+fl7+fl8-fl4-fl9)
misstable sum net_agri
gen agri_inc = net_agri * agri_ratio
label var agri_inc "农业生产收入"
gen inc = wage + agri_inc
replace inc = wage if urban == 1
label var inc "总收入"
/* drop inc_1 */
drop inc 
rename inc_1 inc
local vars "pid cyear provcd urban gender age eduy inc employ"
keep pid `vars'
cd "$mydir\LIHK\1_LIHK"
save LIHK_12, replace

*------ 1.6: 处理2010年个人自答问卷，保留变量
cd "$rawdir\CFPS"
use cfps2010adult_201906, clear
replace cyear = 2010
local vars "qa1age cfps2010eduy_best"
keep pid fid cyear provcd gender qk10* qh1 qh2 qh3 urban qg3 qg301 qg303 `vars'
rename (`vars') (age eduy)
gen employ = 0
replace employ = 1 if qg3 == 1

// 城市收入计算
/// 工资性收入：职工工资、奖金、补贴、实物折合现金、第二职业收入和其他劳动收入
forvalues i = 1/6 {
	replace qk10`i' = 0 if qk10`i' == -8
	replace qk10`i' = . if qk10`i' < 0
	misstable sum qk10`i'
}
gen wage = 12 * (qk101 + qk102 + qk103 + qk104 + qk105 + qk106)
misstable sum wage 
label var wage "工资性收入"

// 农村收入计算：家庭收入按劳动时间比例分配到个人
forvalues i = 1/3 {
	replace qh`i' = 0 if qh`i' == -8
	replace qh`i' = . if qh`i' < 0
	misstable sum qh`i'
}
gen time = qh1 * qh2 * qh3
bys fid: egen hhtime = sum(time)
gen agri_ratio = time / hhtime 
replace agri_ratio = 0 if time == 0 & hhtime == 0
merge m:1 fid using cfps2010famecon_201906, keepusing(net_agri) keep(match) nogen 
replace net_agri = 0 if net_agri == -8 
replace net_agri = . if net_agri < 0 
gen agri_inc = net_agri * agri_ratio
label var agri_inc "农业生产收入"
misstable sum agri_inc 
gen inc = wage + agri_inc
replace inc = wage if urban == 1 
label var inc "总收入" 

local vars "pid cyear provcd gender urban age eduy inc employ"
keep pid `vars'
order pid `vars'
sor `vars'

cd "$mydir\LIHK\1_LIHK"
save LIHK_10, replace

*--- 2 合并所有年份收入数据
cd "$mydir\LIHK\1_LIHK"
use LIHK_10, clear
forvalues i = 12(2)20 {
	ap using LIHK_`i'
}

// 删除缺失值
drop if (age > 59 | age < 16) & gender == 1
drop if (age > 54 | age < 16) & gender == 0
keep if employ == 1 
bys cyear provcd: egen avinc = mean(inc)
bys cyear provcd: keep if inc >= avinc/20 & inc < 15*avinc
local vars "urban gender age eduy inc"
foreach i in `vars' {
	replace `i' = . if `i' < 0
	misstable sum `i'
	di("*--------------------------------------------------------*")
	di("Missing Values of Variable `j' is Deleted.")
	drop if `i' == .
}
keep pid cyear provcd `vars'
order pid cyear provcd `vars'
sor cyear provcd `vars'

gen exp = max(age-eduy-6, 0) // 定义工作经验
replace exp = max(eduy-16, 0) if eduy < 10
replace exp = 0 if exp < 0
gen exp2 = exp^2
gen Linc = ln(inc)
replace Linc = 0 if Linc == .

label var provcd "省份"
label var urban "城乡"
label var gender "性别"
label var age "年龄"
label var eduy "受教育年限"
label var inc "年收入（元）"
label var exp "工作经验"
label var exp2 "工作经验平方"
label var Linc "对数年收入"

save 1_LIHKSubj0, replace

*------ 2.2: 链接平均工资、劳均GDP，生成交互项
cd "$mydir\LIHK\1_LIHK"
use 1_LIHKSubj0, clear
cd "$mydir\macrodata\4_MacroData"
merge m:1 cyear provcd using 2_MacroData, nogen keep(match) keepusing(*wage wy indus)

gen avwage = uravwage
replace avwage = ruavwage if urban == 0
drop ruavwage uravwage
label var avwage "分省平均工资"
gen eduy_wy = eduy * wy
label var eduy_wy "受教育年限与省劳均GDP的交乘项"
gen eduy_indus = eduy * indus
label var eduy_indus "受教育年限与第三产业比重的交乘项"

cd "$mydir\LIHK\1_LIHK"
save 1_LIHKSubj0, replace

// 分省描述平均工资、对数平均工资的变化趋势
use 1_LIHKSubj0, clear
bys cyear provcd: egen avinc = mean(inc)
gen Lavinc = ln(avinc)
duplicates drop cyear provcd, force 
twoway line avinc cyear, by(provcd) legend(off)
cd "$mydir\LIHK\2_Description"
gr export "1_AvgIncome.png", as(png) replace
twoway line Lavinc cyear, by(provcd) legend(off)
gr export "2_LnAvgIncome.png", as(png) replace

*--- 2: 分年度，估计城市/农村、男性/女性4个Mincer方程
*------ 2.1: 估计原始方程
forvalues i = 2010(2)2020 {
	cd "$mydir\LIHK\1_LIHK"
	use 1_LIHKSubj0, clear
	keep if cyear == `i'

	foreach a in 1 0 {
		foreach b in 1 0 {
			di("*--------------------------------------------------------*")
			di("Coefficients of Variable eduy, exp, exp2 for Year `i' is Estimated.")
			di("Subgroup: Gender = `a' and Urban = `b'.")
			di("*--------------------------------------------------------*")
			local vars "Linc eduy exp exp2"
			reg `vars' if gender == `a' & urban == `b'
			sum `vars' if gender == `a' & urban == `b'
		}
	}

*------ 2.3: 对全样本回归
	local vars "cons eduy eduy_wy eduy_indus exp exp2 avwage"
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
	di "reg Linc avwage eduy eduy_wy eduy_indus exp exp2"	
	di("*--------------------------------------------------------*")
	reg Linc avwage eduy eduy_wy eduy_indus exp exp2

*------ 2.4: 对城乡、性别样本分别回归
*--------- 2.4.1: 教育、经验、认知
	di _newline(3)
	foreach a in 0 1 {     
		foreach b in 0 1 {
			di "urban = "`a'
			di "gender = "`b'
			reg Linc eduy exp exp2 if urban == `a' & gender == `b'
			sum Linc eduy exp exp2 if urban == `a' & gender == `b'
			predict ooo, xb    
			gen lyhat = exp(ooo) if urban == `a' & gender == `b'
			reg Linc lyhat, noconstant
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

*------ 2.5: 基于全国样本估计出的系数，在省级调整
	gen intercept = b_cons + b_avwage * avwage
	gen idx_eduy = b_eduy + b_eduy_wy * wy / 1000 + b_eduy_indus * indus
	gen idx_exp = b_exp
	gen idx_exp2 = b_exp2

	keep cyear provcd age urban gender eduy exp* idx* intercept
	cd "$mydir\LIHK\MincerParam"
	save `i'_param, replace	

}

forvalues i = 2010(2)2020 {
	foreach j in 0 1 {
		foreach k in 0 1 {
			use `i'_param, clear
			keep if urban == `j' * gender == `k'
			keep provcd cyear intercept 
			rename intercept int`j'`k'
			duplicates drop cyear provcd, force
			save `i'_int`j'`k', replace
		}
	}
	use `i'_param, clear
	merge m:1 provcd using `i'_int00, keep(match) nogen	// urban == 0 & gender == 0
	merge m:1 provcd using `i'_int01, keep(match) nogen	// urban == 0 & gender == 1
	merge m:1 provcd using `i'_int10, keep(match) nogen	// urban == 1 & gender == 0
	merge m:1 provcd using `i'_int11, keep(match) nogen	// urban == 1 & gender == 1
	save `i'_param, replace
	erase `i'_int00.dta
	erase `i'_int01.dta
	erase `i'_int10.dta
	erase `i'_int11.dta
}

*------ 2.6: 合并历年Mincer系数，保存个体层面数据
cd "$mydir\LIHK\MincerParam"
use 2010_param, clear
forvalues i = 2012(2)2020 {
	ap using `i'_param
}
keep cyear provcd urban gender age eduy exp* idx* int* 
save 1_ParamSubj0, replace

/* 
*------ 2.7: 计算人力资本指数
// 标准工人：农村女性
gen lnh = eduy*idx_eduy + cog*idx_cog + exp*idx_exp + exp2*idx_exp2
replace lnh = int2-int1 + eduy*idx_eduy + cog*idx_cog + exp*idx_exp + exp2*idx_exp2 if urban == 0 & gender == 1
replace lnh = int3-int1 + eduy*idx_eduy + cog*idx_cog + exp*idx_exp + exp2*idx_exp2 if urban == 1 & gender == 0
replace lnh = int4-int1 + eduy*idx_eduy + cog*idx_cog + exp*idx_exp + exp2*idx_exp2 if urban == 1 & gender == 1
			  
gen idx_h = exp(lnh)
label var idx_h "人力资本指数"
duplicates drop cyear provcd gender urban age eduy cog_group, force 
save 1020_LIHK, replace
*/

*------ 2.7: Mincer方程参数（截距、受教育年限、认知技能、工作经验、工作经验平方项）对时间回归，得到参数拟合值
cd "$mydir\LIHK\3_MincerParam"
use 1_ParamSubj0, clear
duplicates drop cyear provcd urban gender, force
egen id = group(provcd gender urban)
tab id 
cap gen cyear2=cyear^2

qui reg intercept cyear if id==1
gen tem1=_b[cyear]
gen tem3=_b[_cons]
gen tem4=tem1*cyear+tem3 if id==1
gen intercept_1 = . 
replace intercept_1=tem4 if id==1
drop tem*

qui reg idx_eduy cyear cyear2 if id==1
gen tem1=_b[cyear]
gen tem2=_b[cyear2]
gen tem3=_b[_cons]
gen tem4=tem1*cyear+tem2*cyear2+tem3 if id==1
gen idx_eduy_1 = .
replace idx_eduy_1 = tem4 if id == 1 
drop tem*

qui reg idx_exp cyear cyear2 if id==1
gen tem1=_b[cyear]
gen tem2=_b[cyear2]
gen tem3=_b[_cons]
gen tem4=tem1*cyear+tem2*cyear2+tem3 if id==1
gen idx_exp_1=.  
replace idx_exp_1 = tem4 if id==1
drop tem*

qui reg idx_exp2 cyear if id==1
gen tem1=_b[cyear]
gen tem3=_b[_cons]
gen tem4=tem1*cyear+tem3 if id==1
gen idx_exp2_1=.
replace idx_exp2_1 = tem4 if id==1
drop tem*

forvalues i = 2/100 {
	cap gen cyear2=cyear^2
	qui reg intercept cyear if id==`i'
	gen tem1=_b[cyear]
	gen tem3=_b[_cons]
	gen tem4=tem1*cyear+tem3 if id==`i'
	replace intercept_1=tem4 if id==`i'
	drop tem*
	
	qui reg idx_eduy cyear cyear2 if id==`i'
	gen tem1=_b[cyear]
	gen tem2=_b[cyear2]
	gen tem3=_b[_cons]
	gen tem4=tem1*cyear+tem2*cyear2+tem3 if id==`i'
	replace idx_eduy_1 = tem4 if id == `i' 
	drop tem*

	qui reg idx_exp cyear cyear2 if id==`i'
	gen tem1=_b[cyear]
	gen tem2=_b[cyear2]
	gen tem3=_b[_cons]
	gen tem4=tem1*cyear+tem2*cyear2+tem3 if id==`i'
	replace idx_exp_1 = tem4 if id==`i'
	drop tem*
	
	qui reg idx_exp2 cyear if id==`i'
	gen tem1=_b[cyear]
	gen tem3=_b[_cons]
	gen tem4=tem1*cyear+tem3 if id==`i'
	replace idx_exp2_1 = tem4 if id==`i'
	drop tem*
}

local vars "cyear provcd gender urban"
keep `vars' idx* int*
save 2_ParamGroup0, replace

local vars "cyear provcd gender urban"
merge 1:m `vars' using 1_ParamSubj0, nogen keep(match)
save 1_ParamSubj1, replace

*------ 2.8: 基于拟合参数，计算人力资本指数
// 标准工人：农村女性
cd "$mydir\LIHK\3_MincerParam"
use 1_ParamSubj1, clear
gen lnh = eduy*idx_eduy_1 + exp*idx_exp_1 + exp2*idx_exp2_1
replace lnh = int01-int00 + eduy*idx_eduy_1 + exp*idx_exp_1 + exp2*idx_exp2_1 ///
	if urban == 0 & gender == 1
replace lnh = int10-int00 + eduy*idx_eduy_1 + exp*idx_exp_1 + exp2*idx_exp2_1 ///
	if urban == 1 & gender == 0
replace lnh = int11-int00 + eduy*idx_eduy_1 + exp*idx_exp_1 + exp2*idx_exp2_1 ///
	if urban == 1 & gender == 1

gen idx_h = exp(lnh)
label var idx_h "人力资本指数"

// 分年份、分省份、分城乡、性别、年龄、受教育分组、认知分组，取人力资本指数的均值，作为4分人口的平均人力资本指数
gen sch = 0
replace sch = 6 if eduy < 9 & eduy >= 6
replace sch = 9 if eduy < 12 & eduy >= 9
replace sch = 12 if eduy < 15 & eduy >= 12
replace sch = 15 if eduy == 15
replace sch = 16 if eduy >= 16

local vars "cyear provcd urban gender age sch"
duplicates drop `vars', force 
order `vars'
sor `vars'
keep `vars' idx_h
save 2_ParamGroup1, replace

*--- 3: 分年份、分省份计算人力资本存量
*------3.1: 链接CHLR的4分人口
cd "$mydir\LIHK\3_MincerParam"
use 2_ParamGroup1, clear 
cd "$mydir\macrodata\1_PopData"
local vars "cyear provcd urban gender age sch"
merge 1:1 `vars' using 1_LongPop4, nogen keep(match) 
sor `vars'
order `vars'
gen h = idx_h * pop
label var h "4分人口LIHK存量"
cd "$mydir\LIHK\1_LIHK"
save 2_LIHKGroup1, replace

bys cyear provcd: egen H = total(h)
bys cyear provcd: egen Pop = total(pop)
gen avgH = H / Pop
duplicates drop cyear provcd, force
label var H "分省LIHK存量"
cd "$mydir\LIHK\1_LIHK"
save 2_LIHKGroup2, replace

*------ 3.3: 分省描述LIHK人力资本存量趋势
*--------- 3.3.1 LIHK总量
foreach i in $provcd {
	cd "$mydir\LIHK\1_LIHK"
	use 2_LIHKGroup2, clear
	keep if provcd == `i'
	twoway line H cyear, xlabel(2010(2)2020) ///
		title("Total LIHK human capital stock of province `i'") ///
		xtitle("Year", size(small)) ///
		ytitle("Total LIHK values", size(small)) ///
		subtitle("2010-2020") note("Method: LIHK") ///
		legend(ring(1) pos(6) cols(6) size(small)) 
	cd "$mydir\LIHK\2_Description"
	gr export "`i'_LIHK_H.png", as(png) replace
}

*--------- 3.3.2 LIHK人均
foreach i in $provcd {
	cd "$mydir\LIHK\1_LIHK"
	use 2_LIHKGroup2, clear
	keep if provcd == `i'
	twoway line avgH cyear, xlabel(2010(2)2020) ///
		title("Total LIHK human capital stock of province `i'") ///
		xtitle("Year", size(small)) ///
		ytitle("Total LIHK values", size(small)) ///
		subtitle("2010-2020") note("Method: LIHK") ///
		legend(ring(1) pos(6) cols(6) size(small)) 
	cd "$mydir\LIHK\2_Description"
	gr export "`i'_LIHK_h.png", as(png) replace
}
