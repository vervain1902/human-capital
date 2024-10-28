cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - read micro income data
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.10.28

==================================================*/

*---0 Program set up
cd "D:\# Library\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do

*---1 Read micro income data from CFPS database
*------1.1 处理2020年个人自答问卷，保留变量	
cd "$rawdir\2010-2020-CFPS"
use cfps2020person_202306, clear
replace cyear = 2020
local vars "provcd20 urban20 cfps2020eduy_im emp_income"
keep pid cyear gender age employ `vars'
rename (`vars') (provcd urban eduy inc)
cd "$mydir\3_LIHK"
save inc_20, replace

*------ 3.2 处理2018年个人自答问卷，保留变量
cd "$rawdir\2010-2020-CFPS"
use cfps2018person_202012, clear
replace cyear = 2018
local vars "provcd18 urban18 cfps2018eduy_im income"
keep pid cyear gender age employ `vars'
rename (`vars') (provcd urban eduy inc)
cd "$mydir\3_LIHK"
save inc_18, replace

*------ 1.3.处理2016年个人自答问卷，保留变量
cd "$rawdir\2010-2020-CFPS"
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
label var inc "total income"
drop income*
cd "$mydir\3_LIHK"
save inc_16, replace

*------ 1.4.处理2014年个人自答问卷，保留变量
cd "$rawdir\2010-2020-CFPS"
use cfps2014adult_201906, clear
replace cyear = 2014
local vars "provcd14 urban14 cfps_gender cfps2014_age cfps2014eduy_im p_wage employ2014"
keep pid cyear `vars'
rename (`vars') (provcd urban gender age eduy inc employ)
cd "$mydir\3_LIHK"
save inc_14, replace

*------ 1.5.处理2012年个人自答问卷，保留变量
cd "$rawdir\2010-2020-CFPS"
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
label var wage "salary income"

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
label var agri_inc "agricultural income"
gen inc = wage + agri_inc
replace inc = wage if urban == 1
label var inc "total income"
/* drop inc_1 */
drop inc 
rename inc_1 inc
local vars "pid cyear provcd urban gender age eduy inc employ"
keep pid `vars'
cd "$mydir\3_LIHK"
save inc_12, replace

*------ 1.6.处理2010年个人自答问卷，保留变量
cd "$rawdir\2010-2020-CFPS"
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
label var wage "salary income"

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
label var agri_inc "agricultural income"
misstable sum agri_inc 
gen inc = wage + agri_inc
replace inc = wage if urban == 1 
label var inc "total income" 

local vars "pid cyear provcd gender urban age eduy inc employ"
keep pid `vars'
order pid `vars'
sor `vars'

cd "$mydir\3_LIHK"
save inc_10, replace

*--- 2 合并所有年份收入数据
cd "$mydir\3_LIHK"
use inc_10, clear
forvalues i = 12(2)20 {
	ap using inc_`i'
	erase inc_`i'.dta // 删除文件
}
erase inc_10.dta // 删除文件

drop if (age > 59 | age < 16) & gender == 1
drop if (age > 54 | age < 16) & gender == 0
keep if employ == 1 // 保留劳动年龄人口

// 删除缺失值
bys cyear: egen pinc = mean(inc)
bys cyear: keep if inc >= pinc/20 & inc < 15*pinc // 删除收入的极端值
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

gen sch = 0 
replace sch = 6 if eduy > 0 & eduy <= 6
replace sch = 9 if eduy > 6 & eduy <= 9
replace sch = 12 if eduy > 9 & eduy <= 12
replace sch = 15 if eduy > 12 & eduy <= 15
replace sch = 16 if eduy > 15

label var provcd "province code"
label var urban "rural=0"
label var gender "female=0"
label var age "CFPS age"
label var eduy "CFPS edu_year"
label var inc "income per year (RMB)"
label var exp "working year"
label var exp2 "working year^2"
label var Linc "log income per year"

save 1_Inc, replace // 保存基于CFPS调查数据的微观数据
