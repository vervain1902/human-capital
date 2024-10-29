cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 劳动年龄人口认知技能
Subproiect: Cog 
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.10.28

==================================================*/

*---1 Generate micro cog and standardize cog by year across all provinces 
// 2012, 2016, 2020 - test of [number serial] and [word memory]
forvalues i = 10(2)20 {
	cd "$mydir\2_Cog\worker"
	use cfps`i'_0, clear
	gen 

	if `i' == 12 | `i' == 16 | `i' == 20 {
		// standardize cog by year across all provinces
		gen wr = (iwr + dwr) / 2
		gen cog = (wr + ns) / 2
		egen st_cog = std(cog)
	}

// 2010, 2014, 2018 - test of [word] and [math]
	else {
		// standardize cog by year across all provinces
		gen cog = (math + word)/2
		egen st_cog = std(cog)
	}
	
	label var cog "raw value of cognitive skill"
	label var st_cog "standardized value of cognitive skill"

	save cfps`i'_0, replace
}

*---2 Clean data 
*------2.1 Keep work_aged pop and delete missing vals
forvalues i = 10(2)20 {
	cd "$mydir\2_Cog\worker"
	use cfps`i'_0, clear

	// 保留劳动年龄人口
	drop if (age > 59 | age < 16) & gender == 1 // 男性：16-59岁
	drop if (age > 54 | age < 16) & gender == 0 // 女性：16-54岁

	// 删除缺失值
	foreach j in gender urban eduy cog {
		replace `j' = . if `j' < 0 
		misstable sum `j'
		drop if `j' == .
	}

	// 以11岁为分组间隔，分为4个年龄组
	gen age_group = .
	replace age_group = 1 if age >= 16 & age <= 26
	replace age_group = 2 if age >= 27 & age <= 37
	replace age_group = 3 if age >= 38 & age <= 48
	replace age_group = 4 if age >= 49 & age <= 59

	save cfps`i'_1, replace // 劳动年龄人口
}

*------2.2 Delete provinces whose number of age_groups is less than 4
forvalues i = 10(2)20 {
	cd "$mydir\2_Cog\worker"
	use cfps`i'_1, clear

/* 	// 描述历年各省不同年龄组的样本量
 	tabplot provcd age_group, title("Number of age_groups in 20`i'") ytitle("Province", size(small)) ///
 		ylabel(, labsize(small)) showval(offset(0.6)) barw(0.8) horizontal 								
	cd "$desdir\2_Cog\worker\年龄组"	
	gr export "Bar-AgeGroup_`i'_0.png", as(png) replace */

/* 	// 分年度描述全国样本认知技能
	foreach j in cog st_cog {
	 	hist `j', freq normal graphregion(color(white)) fcolor(ebg) lcolor(gs8)	lwidth(medium) ///
	 		normopts(lcolor(black)) title("Histogram of `j' in 20`i'") subtitle("") ytitle("Frequency", size(small)) ///
	 		xtitle("Cognitive Skill", size(small)) xscale(titlegap(2)) 
	 	cd "$desdir\2_Cog\worker\认知技能分布"
	 	gr export "Hist-`j'_`i'_0.png", replace
	} */

	// 删除年龄组样本量不足的省份
	duplicates drop age_group provcd, force
	bys provcd: egen ngroup = count(age_group)
	keep cyear provcd age_group ngroup
	label var ngroup "number of age groups by year"
	cd "$mydir\2_Cog\worker"
	save ngroup`i', replace

	use cfps`i'_1, clear
	merge m:1 provcd age_group using ngroup`i', nogen keep(match)
	drop if ngroup < 4
	
*------2.3 Construct secondary vars 
	gen age2 = age^2

	gen sch = 0
	replace sch = 6 if eduy < 9 & eduy >= 6
	replace sch = 9 if eduy < 12 & eduy >= 9
	replace sch = 12 if eduy < 15 & eduy >= 12
	replace sch = 15 if eduy == 15
	replace sch = 16 if eduy >= 16

	local vars "cyear provcd gender urban age sch age_group"
	keep pid st_cog eduy age2 `vars'
	order `vars' 
	sort `vars'

	// 链接省份汉字、拼音与代码
	cd "$mydir\0_Macro"
	mer m:1 provcd using province_codes, nogen keep(match)

	// 将年龄组数量大于4的省份代码存储到全局变量 prov_4_code
    global prov_4_code
    levelsof provcd, local(provs)
    foreach prov of local provs {
        global prov_4_code "`prov_4_code' `prov'"
    }

    // 输出全局变量 prov_4_code
    display "`prov_4_code'"

	cd "$mydir\2_Cog\worker"
	save cfps`i'_2, replace // 保存删除样本的数据

/* 	// 重新描述不同年龄组的样本量
 	tabplot provcd age_group, title("New number of age_groups in 20`i'") ytitle("Province", size(small)) ///
		ylabel(, labsize(small)) showval(offset(0.6)) barw(0.8) horizontal
 	cd "$desdir\2_Cog\worker\年龄组"	
 	gr export "Bar-AgeGroup_`i'_1.png", as(png) replace */

}

*---3 Merge micro cog data each year 
cd "$mydir\2_Cog\worker"
use cfps20_2, clear
forvalues i = 10(2)18 {
	ap using cfps`i'_2
	erase cfps`i'_0.dta
	erase cfps`i'_1.dta
	erase ngroup`i'.dta
}

save 1_Cog, replace 

erase cfps20_0.dta 
erase cfps20_1.dta
erase ngroup20.dta


