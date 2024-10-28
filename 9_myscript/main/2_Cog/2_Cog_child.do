cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 10-15岁少儿人口认知技能
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.8.13

--------------------------------------------------

This script is for: 
	- 计算认知技能
		- 分年度在全国标准化
		- 计算三分人口、二分人口的平均认知技能
	- 调整受教育年限
		- 估算调整系数，并以第一个年龄组为基准标准化
		- 链接调整系数与三分人口的受教育年限数据，计算调整值
		- 合并得到二分人口、总人口的调整值

Note: database used 
	CFPS 2010-2020
	CHLR 2010-2020
	Yearbook 2010-2020

更新：
	- 估计方式：分样本/交乘项
	- 回归思路：不分年度，分省的总体教育年限对认知回归
	- 增加认知比例的估计
		- 比例指标
	- 学生样本的认知，调整受教育年限，对经济增长的贡献
		- 比较调整前后的变化
		- 梳理基于微观调查数据的认知

==================================================*/

*--- 0.清空内存，定义路径
cd "D:\Library\OneDrive\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript\config"
do config.do

*--- 1: 计算认知技能
*------ 1.1: 读取CFPS认知技能数据
*--------- 1.1.1: 2012、2016、2020年：数列测试、字词记忆测试
// 2020年
cd "$rawdir/2010-2020-CFPS"
use cfps2020person_202306, clear
local vars "provcd20 urban20 cfps2020eduy_im ns_w"
keep pid cyear gender age iwr dwr `vars'
rename (`vars') (provcd urban eduy ns)
cd "$mydir/2_Cog/child"
save cfps20_0, replace 

// 2016年
cd "$rawdir/2010-2020-CFPS"
use cfps2016child_201906, clear
replace self_cyear = 2016
local vars "self_cyear provcd16 cfps_gender cfps_age urban16 cfps2016eduy_im ns_w"
keep pid iwr dwr `vars'
rename (`vars') (cyear provcd gender age urban eduy ns)
cd "$mydir/2_Cog/child"
save cfps16_0, replace 

// 2012年
cd "$rawdir/2010-2020-CFPS"
use cfps2012child_201906, clear
replace cyear = 2012
local vars "cfps2012_gender_best cfps2012_age urban12 eduy2012 ns_w"
keep pid cyear provcd iwr dwr `vars'
rename (`vars') (gender age urban eduy ns)
cd "$mydir/2_Cog/child"
save cfps12_0, replace

// 删除缺失值，保留劳动年龄人口
forvalues i = 12(4)20 {
	cd "$mydir/2_Cog/child"
	use cfps`i'_0, clear
	foreach j in gender urban eduy iwr dwr ns {
		replace `j' = . if `j' < 0 
		misstable sum `j'
		drop if `j' == .
	}
	// 保留少儿人口
	drop if age > 15 | age < 10 // 10-15岁
	save cfps`i'_0, replace
}

*--------- 1.1.2: 2010、2014、2018年：字词测试、数学测试
// 2018年
cd "$rawdir/2010-2020-CFPS"
use cfps2018person_202012, clear
local vars "provcd18 urban18 cfps2018eduy_im mathtest18 wordtest18"
keep pid cyear gender age `vars'
replace cyear = 2018
rename (`vars') (provcd urban eduy math word)
cd "$mydir/2_Cog/child"
save cfps18_0, replace 

// 2014年
cd "$rawdir/2010-2020-CFPS"
use cfps2014child_201906, clear
replace cyear = 2014
local vars "provcd14 cfps_gender cfps2014_age urban14 cfps2014eduy_im mathtest14 wordtest14"
keep pid cyear `vars'	 
rename (`vars') (provcd gender age urban eduy math word)
cd "$mydir/2_Cog/child"
save cfps14_0, replace 

// 2010年
cd "$rawdir/2010-2020-CFPS"	
use cfps2010child_201906, clear
replace cyear = 2010
local vars "wa1age cfps2010eduy_best mathtest wordtest"
keep pid cyear provcd gender urban mathtest wordtest `vars'
rename (`vars') (age eduy math word)
cd "$mydir/2_Cog/child"
save cfps10_0, replace

// 删除缺失值，保留少儿人口
forvalues i = 10(4)18 {
	cd "$mydir/2_Cog/child"
	use cfps`i'_0, clear
	foreach j in gender urban eduy math word {
		replace `j' = . if `j' < 0 
		misstable sum `j'
		drop if `j' == .
	}
	// 保留少儿人口
	drop if age > 15 | age < 10 // 10-15岁
	save cfps`i'_0, replace
}

*------ 1.2.删除年龄组样本量不足的省份
forvalues i = 10(2)20 {
	cd "$mydir/2_Cog/child"
	use cfps`i'_0, clear

// 生成年龄平方项、年龄分组变量
	gen age2 = age^2

	// 以2岁为分组间隔，分为3个年龄组
	gen age_group = .
	replace age_group = 1 if age >= 10 & age <= 11
	replace age_group = 2 if age >= 12 & age <= 13
	replace age_group = 3 if age >= 14 & age <= 15
	save cfps`i'_0, replace

// 删除年龄组样本量不足的省份
	// 描述历年各省不同年龄组的样本量
 	qui tabplot provcd age_group, ///
 		title("Number of age_groups in 20`i'") ///
 		ytitle("Province", size(small)) ///
 		ylabel(, labsize(small)) 				///
 		showval(offset(0.6))					///
 		barw(0.8) 								///
 		horizontal 								
		cd "$desdir/2_Cog/child/年龄组"	
		gr export "Bar-AgeGroup_`i'_0.png", as(png) replace

	// 删除年龄组样本量不足的省份
	duplicates drop age_group provcd, force
	bys provcd: egen ngroup = count(age_group)
	keep cyear provcd age_group ngroup
	label var ngroup "历年各省年龄组数量"
	cd "$mydir/2_Cog/child"
	save ngroup_`i', replace

	use cfps`i'_0, clear
	merge m:1 provcd age_group using ngroup_`i', nogen keep(match)
	drop if ngroup < 3
	tab provcd
	
	// 重新描述不同年龄组的样本量
 	qui tabplot provcd age_group, ///
 		title("New number of age_groups in 20`i'") ///
 		ytitle("Province", size(small)) ///
 		ylabel(, labsize(small)) ///
 		showval(offset(0.6)) ///
 		barw(0.8) ///
 		horizontal
 	cd "$desdir/2_Cog/child/年龄组"	
 	gr export "Bar-AgeGroup_`i'_1.png", as(png) replace

*------ 1.4: 计算2010-2020认知技能综合变量
*--------- 1.4.1: 2012、2016、2020年：数列测试、字词记忆测试
	if `i' == 12 | `i' == 16 | `i' == 20 {
		// 基于全国样本标准化
		gen wr = (iwr+dwr)/2
		gen cog = (wr+ns)/2
		egen st_cog = std(cog)
		replace cog = st_cog
		drop st_cog
	}
*--------- 1.4.2: 2010、2014、2018年：字词测试、数学测试
	// 2010、2014、2018年：字词测试、数学测试
	else {
		// 基于全国样本标准化
		gen cog = (math + word)/2
		egen st_cog = std(cog)
		replace cog = st_cog
		drop st_cog
	}
	
	label var cog "标准化认知技能"

// 保存含认知技能、认知技能分组、年龄分组的劳动力样本
	cd "$mydir/2_Cog/child"
	save cfps`i'_1, replace // 保存删除样本的数据

*------ 1.5: 分年度描述全国样本认知技能
 	hist cog, ///
 		freq normal ///
 		graphregion(color(white)) ///
 		fcolor(ebg) lcolor(gs8)	 ///
 		lwidth(medium) normopts(lcolor(black)) ///
 		title("Histogram of cognitive skill in 20`i'") ///
 		subtitle("") ///
 		ytitle("Frequency", size(small)) ///
 		xtitle("Cognitive Skill", size(small)) xscale(titlegap(2)) 
 	cd "$desdir/2_Cog/child/认知技能分布"
 	gr export "Hist-Cog_`i'_1.png", replace
}

*------ 1.6: 合并历年认知技能
cd "$mydir/2_Cog/child"
use cfps20_1, clear
forvalues i = 10(2)18 {
	ap using cfps`i'_1
	erase cfps`i'_0.dta
	erase cfps`i'_1.dta
	erase ngroup_`i'.dta
}

gen sch = 0
replace sch = 6 if eduy < 9 & eduy >= 6
replace sch = 9 if eduy < 12 & eduy >= 9
replace sch = 12 if eduy < 15 & eduy >= 12
replace sch = 15 if eduy == 15
replace sch = 16 if eduy >= 16

local vars "cyear provcd gender urban age sch age_group"
keep pid cog eduy age2 `vars'
order `vars' 
sort `vars'

save 1_Cog, replace 
erase cfps20_0.dta 
erase cfps20_1.dta
erase ngroup_20.dta

*--- 2.计算四分人口认知技能均值
cd "$mydir/2_Cog/child"
use 1_Cog, clear
local vars "cyear provcd urban gender age sch"
bys `vars': egen pcog = mean(cog)
duplicates drop `vars', force 
label var pcog "四分人口认知技能均值"
keep `vars' age_group pcog 
order `vars'
sor `vars'
save 2_Cog4, replace

*--- 2.计算三分人口认知技能均值
cd "$mydir/2_Cog/child"
use 1_Cog, clear
local vars "cyear provcd urban gender age"
bys `vars': egen pcog3 = mean(cog)
duplicates drop `vars', force 
label var pcog3 "三分人口认知技能均值"
keep `vars' age_group pcog3
order `vars'
sor `vars'
save 3_Cog3, replace

*--- 3.计算受教育年限调整值
*------ 3.1.估计受教育年限对认知技能的系数（不分年度，不同省份分样本回归）
cd "$mydir/2_Cog/child"
use 1_Cog, clear
forval i = 1/3 {
	gen eduy`i' = 0
	replace eduy`i' = eduy if age_group == `i' 
}

// 定义年龄组大于等于3的省份代码
local provcd__ "11 12 13 14 21 22 23 31 32 33 34 35 36 37 41 42 43 44 45 50 51 52 53 61 62"

forval i = 1/3 {
	foreach j in `provcd__' {
		eststo m_beta`j': qui reg cog eduy`i' age age2 i.gender i.urban if age_group == `i' & provcd == `j'
	}

	esttab m_beta* using beta`i'.csv, ///
	 	keep(eduy`i') nonumbers not nostar noobs compress replace
}

forval i = 1/3 {
	import delimited using beta`i'.csv, varnames(1) stripquote(yes) clear
	gather cog-v26, value(beta_m)
	replace beta_m = subinstr(beta_m, "=", "", .)
	gen age_group = `i'
	drop v1
	destring(beta_m), replace
	gen provcd = .
	replace provcd = 11 if variable == "cog"
	replace provcd = 12 if variable == "v3"
	replace provcd = 13 if variable == "v4"
	replace provcd = 14 if variable == "v5"
	replace provcd = 21 if variable == "v6"
	replace provcd = 22 if variable == "v7"
	replace provcd = 23 if variable == "v8"
	replace provcd = 31 if variable == "v9"
	replace provcd = 32 if variable == "v10"
	replace provcd = 33 if variable == "v11"
	replace provcd = 34 if variable == "v12"
	replace provcd = 35 if variable == "v13"
	replace provcd = 36 if variable == "v14"
	replace provcd = 37 if variable == "v15"
	replace provcd = 41 if variable == "v16"
	replace provcd = 42 if variable == "v17"
	replace provcd = 43 if variable == "v18"
	replace provcd = 44 if variable == "v19"
	replace provcd = 45 if variable == "v20"
	replace provcd = 50 if variable == "v21"
	replace provcd = 51 if variable == "v22"
	replace provcd = 52 if variable == "v23"
	replace provcd = 53 if variable == "v24"
	replace provcd = 61 if variable == "v25"
	replace provcd = 62 if variable == "v26"
	drop variable
	order provcd age_group 
	save beta`i', replace
}

forval i = 1/2 {
	ap using beta`i'
	erase beta`i'.dta
	erase beta`i'.csv
}

bys provcd: egen base = total(beta_m * (age_group == 1)) 
gen a_beta = beta_m / base
label var a_beta "受教育年限调整系数"

order provcd age_group a_beta
sor provcd age_group

save 4_Beta, replace
erase beta3.dta
erase beta3.csv

*--------- 3.2: 作图描述调整系数
// 定义年龄组大于等于3的省份代码
local provcd__ "11 12 13 14 21 22 23 31 32 33 34 35 36 37 41 42 43 44 45 50 51 52 53 61 62"
foreach i in `provcd__' {
	cd "$mydir/2_Cog/child"
	use 4_Beta, clear
	keep if provcd == `i'
	mscatter a_beta age_group, fit(lfitci)
	cd "$desdir/2_Cog/child/分样本估计"
	gr export "Scatter-aBeta_`i'.png", replace	
}

*------ 3.3: 计算调整值
// 链接受教育年限调整系数与分城乡、性别和年龄的三分人口（含宏观数据）
cd "$mydir/1_Pop"
use 6_Macro_Pop3, clear
cd "$mydir/2_Cog/child"
merge m:1 provcd age_group using 4_Beta, keep(match) nogen
drop eduy 
gen a_peduy3 = peduy3 * a_beta // 调整后的三分人口平均受教育年限
local vars "cyear provcd urban gender age age_group a_peduy3 peduy3" 
order `vars'
sor `vars' 
label var a_peduy3 "三分人口人均受教育年限调整值"
cd "$mydir/2_Cog/child"
save 5_Macro_Pop3_aEduy, replace

// 计算调整后的平均受教育年限二分人口数据
cd "$mydir/2_Cog/child"
use 5_Macro_Pop3_aEduy, clear 
gen a_eduy3 = eduy3 * a_beta // 调整后的三分人口总受教育年限
local vars "cyear provcd urban gender"
bys `vars': egen a_eduy2 = total(a_eduy3) // 调整后的总人口受教育年限
bys `vars': egen pop2 = total(pop3) // 总人口
gen a_peduy2 = a_eduy2 / pop2 // 调整后的总人口平均受教育年限
duplicates drop `vars', force
drop *3
label var a_peduy2 "二分人口平均受教育年限调整值"
label var a_eduy2 "二分人口受教育年限调整值"
label var pop2 "二分人口数"
cd "$mydir/2_Cog/child"
save 6_Macro_Pop2_aEduy, replace // 保存二分人口平均受教育年限调整值

// 计算调整后的平均受教育年限总人口数据
cd "$mydir/2_Cog/child"
use 5_Macro_Pop3_aEduy, clear 
gen a_eduy3 = eduy3 * a_beta // 调整后的三分人口总受教育年限
local vars "cyear provcd"
bys `vars': egen a_eduy0 = total(a_eduy3) // 调整后的总人口受教育年限
bys `vars': egen pop0 = total(pop3) // 总人口
gen a_peduy0 = a_eduy0 / pop0 // 调整后的总人口平均受教育年限
duplicates drop `vars', force
drop *3 urban gender age age_group
label var a_peduy0 "总人口平均受教育年限调整值"
label var a_eduy0 "总人口受教育年限调整值"
label var pop0 "总人口数"
cd "$mydir/2_Cog/child"
save 7_Macro_Pop0_aEduy, replace // 保存二分人口平均受教育年限调整值

// 链接三分人口的平均认知技能、受教育年限调整值和人口数、宏观数据
cd "$mydir/2_Cog/child"
use 3_Cog3, clear 
mer 1:1 cyear provcd gender urban age using 5_Macro_Pop3_aEduy, nogen 

// 生成人均GDP、劳动力人均GDP、劳动年龄人口数、滞后2期劳动力人均GDP、2008年劳动力人均GDP
gen lnty = ln(ty)
gen lnwy = ln(wy)
gen lnwl = ln(wpop)
gen lndwy = ln(d2wy)
gen ln08wy = ln(wy08)

// 定义东、中、西部
gen region = 1
replace region = 3 if provcd == 15 | provcd == 45 | provcd == 50 | provcd == 51 | provcd == 52 | provcd == 53 | provcd == 54 | ///
	provcd == 61 | provcd == 62 | provcd == 63 | provcd == 64 | provcd == 65 
replace region = 2 if provcd == 14 | provcd == 22 | provcd == 23 | provcd == 34 | provcd == 36 | provcd == 41 | provcd == 42 | ///
	provcd == 43 
label define region 1 "east" 2 "center" 3 "west"
label value region region
label var region "区域"

save 8_Macro_Pop3_aEduy_Cog, replace

*--- 4.描述平均受教育年限调整值
// 二分人口平均教育年限调整值
local provcd__ "11 12 13 14 21 22 23 31 32 33 34 35 36 37 41 42 43 44 45 50 51 52 53 61 62"
foreach i in `provcd__' {
	cd "$mydir/2_Cog/child"
	use 6_Macro_Pop2_aEduy, clear
	keep if provcd == `i'
	twoway line a_peduy2 cyear, by(urban gender) xlabel(2010(2)2020) ///
		title("Adjusted Average education year of province `i'") ///
		xtitle("Year", size(small)) ///
		ytitle("Adjusted Average Education Year", size(small)) ///
		subtitle("2010-2020") ///
		legend(ring(1) pos(6) cols(6) size(small)) 
	cd "$desdir/4_Eduy/beta/二分人口"
	gr export "Line-aPeduy2-`i'.png", as(png) replace
}

// 总人口平均教育年限调整值
local provcd__ "11 12 13 14 21 22 23 31 32 33 34 35 36 37 41 42 43 44 45 50 51 52 53 61 62"
foreach i in `provcd__' {
	cd "$mydir/2_Cog/child"
	use 7_Macro_Pop0_aEduy, clear
	duplicates drop cyear provcd, force
	keep if provcd == `i'
	twoway line a_peduy0 cyear, xlabel(2010(2)2020) ///
		title("Adjusted Average Education year of province `i'") ///
		xtitle("Year", size(small)) ///
		ytitle("Adjusted Average Education Year", size(small)) ///
		subtitle("2010-2020") ///
		legend(ring(1) pos(6) cols(6) size(small)) 
	cd "$desdir/4_Eduy/beta/总人口"
	gr export "Line-aPeduy0-`i'.png", as(png) replace
}
