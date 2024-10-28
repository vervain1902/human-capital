cls
/*==================================================

Proiect: 劳动力人力资本数量、质量与经济增长 - 10-15岁少儿人口
Author: liuziyu
Created Date: 2023.12
Last Edited Date: 2024.10.13

--------------------------------------------------

This script is for:
	- 生成4分人口（分城乡、性别、年龄、受教育年限）长数据
	- 生成2分人口（分城乡）长数据
	- 计算4分人口
	- 计算4分人口总数
	- 计算4分人口平均受教育年限

Data source:
	- CFPS 2010-2020
	- CHLR 2010-2020
	- Yearbook 2010-2020

==================================================*/

*--- 0.清空内存，定义路径
cd "D:\Library\OneDrive\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript\config"
do config.do

*--- 1.使用CHLR估算数据【2023-总人口-四分】，生成分省份、分年度的四分人口长数据
*------ 1.1.处理不含上海的省份
foreach i in $provcds_ {
    foreach j in rural urban {
		cd "$popdir"
		use Hcdata`i'/`j'/`j'_pop_1982_2021, clear
		keep if year == 2010 | year == 2012 | year == 2014 | ///
				year == 2016 | year == 2018 | year == 2020

		// 数据宽转长
		gather *male, value(pop)
		
		// 拆分 variable 变量为 sch 和 gender
		split variable, parse("_")
		rename (variable1 variable2) (sch_ gender_) 

		gen urban = .
		tostring urban, replace
		replace urban = "`j'"

		gen provcd = .
		replace provcd = `i'
		
		gen sch = 0 
		replace sch = 6 if sch_ == "primary"
		replace sch = 9 if sch_ == "junior"
		replace sch = 12 if sch_ == "senior"
		replace sch = 15 if sch_ == "college"
		replace sch = 16 if sch_ == "university"
		
		gen gender = 0 
		replace gender = 1 if gender_ == "male"
		
		drop variable *_
		gen urban_ = 0
		replace urban_ = 1 if urban == "urban"
		drop urban
		rename urban_ urban
		rename year cyear

		drop if age > 15 | age < 10 // 10-15岁
		
		local vars "cyear provcd age gender urban sch pop"
		sor `vars'
		order `vars'
		label var cyear "年份"
		cd "$mydir/1_Pop/child"
		save long_`i'_`j', replace
	}
}

*------ 1.2.处理上海（仅有城市数据）
cd "$popdir"
use Hcdata31/urban/urban_pop_1982_2021, clear
keep if year == 2010 | year == 2012 | year == 2014 | ///
		year == 2016 | year == 2018 | year == 2020
		
// 数据宽转长
gather *male, value(pop)

// 拆分 variable 变量为 sch 和 gender
split variable, parse("_")
rename (variable1 variable2) (sch_ gender_) 

gen urban = "urban"
gen provcd = 31

gen sch = 0 
replace sch = 6 if sch_ == "primary"
replace sch = 9 if sch_ == "junior"
replace sch = 12 if sch_ == "senior"
replace sch = 15 if sch_ == "college"
replace sch = 16 if sch_ == "university"

gen gender = 0 
replace gender = 1 if gender_ == "male"

drop variable *_
gen urban_ = 0
replace urban_ = 1 if urban == "urban"
drop urban
rename urban_ urban
rename year cyear

drop if age > 15 | age < 10 // 10-15岁

local vars "cyear provcd age gender urban sch pop"
sor `vars'
order `vars'
label var cyear "年份"
cd "$mydir/1_Pop/child"
save long_31_urban, replace

*------ 1.3.合并所有省份四分人口长数据
cd "$mydir/1_Pop/child"
use long_31_urban, clear
foreach i in $provcds_ {
	foreach j in urban rural {
		ap using long_`i'_`j'
		erase long_`i'_`j'.dta
	}
}
	
// 以2岁为分组间隔，分为3个年龄组
gen age_group = .
replace age_group = 1 if age >= 10 & age <= 11
replace age_group = 2 if age >= 12 & age <= 13
replace age_group = 3 if age >= 14 & age <= 15

replace pop = pop / 10000

label var provcd "省份代码"
label var sch "受教育年限"
label var pop "四分人口数（万人）"

cd "$mydir/1_Pop/child"
save 1_Pop4, replace
erase long_31_urban.dta

*--- 2.基于四分人口数据，计算三分人口总受教育年限、平均受教育年限
cd "$mydir/1_Pop/child"
use 1_Pop4, clear
gen eduy = sch * pop
local vars "cyear provcd urban gender age"
bys `vars': egen eduy3 = total(eduy)
bys `vars': egen pop3 = total(pop)
duplicates drop `vars', force 
gen peduy3 = eduy3 / pop3
drop sch pop 
label var eduy3 "三分人口总受教育年限"
label var pop3 "三分人口数（人）"
label var peduy3 "三分人口人均受教育年限"
save 2_Pop3, replace // 保存历年各省分城乡、性别、年龄的三分人口数据（含人均受教育年限信息）

*--- 2.基于三分人口数据，计算二分人口总受教育年限、平均受教育年限
cd "$mydir/1_Pop/child"
use 2_Pop3, clear
local vars "cyear provcd urban gender"
bys `vars': egen eduy2 = total(eduy3)
bys `vars': egen pop2 = total(pop3)
duplicates drop `vars', force 
gen peduy2 = eduy2 / pop2 
drop *3
label var eduy2 "二分人口总受教育年限"
label var pop2 "二分人口数（人）"
label var peduy2 "二分人口人均受教育年限"
save 3_Pop2, replace // 保存历年各省分城乡、性别的二分人口数据（含人均受教育年限信息）

*--- 3.基于二分人口数据，计算一分人口总受教育年限、平均受教育年限
*------ 3.1.分城乡的一分人口
cd "$mydir/1_Pop/child"
use 3_Pop2, clear 
local vars "cyear provcd urban"
bys `vars': egen eduy1_ur = total(eduy2)
bys `vars': egen pop1_ur = total(pop2)
duplicates drop `vars', force 
gen peduy1_ur = eduy2 / pop2
drop *2
label var eduy1_ur "分城乡的一分人口总受教育年限"
label var pop1_ur "分城乡的一分人口数（人）"
label var peduy1_ur "分城乡的一分人口人均受教育年限"
save 4_Pop1_Urban, replace

// 描述历年各省分城乡的一分人口、人均受教育年限变化趋势
foreach i in $provcds_ {
	foreach j in 0 1 {
		cd "$mydir/1_Pop/child"
		use 4_Pop1_Urban, clear
		keep if provcd == `i' & urban == `j'
		foreach k in pop1_ur peduy1_ur {
			twoway line `k' cyear, xlabel(2010(2)2020) ///
				title("`k' of province `i' and urban `j'") ///
				xtitle("Year", size(small)) ///
				ytitle("`k'", size(small)) ///
				subtitle("2010-2020") note("Data source: CHLR 2023") ///
				legend(ring(1) pos(6) cols(6) size(small)) 
			cd "$desdir/1_Pop/child/`k'"
			gr export "Line-`i'_`j'_`k'.png", as(png) replace
		}
	}
}

*------ 3.2.分性别的一分人口
cd "$mydir/1_Pop/child"
use 3_Pop2, clear 
local vars "cyear provcd gender"
bys `vars': egen eduy1_ge = total(eduy2)
bys `vars': egen pop1_ge = total(pop2)
duplicates drop `vars', force 
gen peduy1_ge = eduy2 / pop2
drop *2
label var eduy1_ge "分性别的一分人口总受教育年限"
label var pop1_ge "分性别的一分人口数（人）"
label var peduy1_ge "分性别的一分人口人均受教育年限"
save 4_Pop1_Gender, replace

// 描述历年各省分城乡的一分人口、人均受教育年限变化趋势
foreach i in $provcds_ 31 {
	foreach j in 0 1 {
		cd "$mydir/1_Pop/child"
		use 4_Pop1_Gender, clear
		keep if provcd == `i' & gender == `j'
		foreach k in pop1_ge peduy1_ge {
			twoway line `k' cyear, xlabel(2010(2)2020) ///
				title("`k' of province `i' and gender `j'") ///
				xtitle("Year", size(small)) ///
				ytitle("`k'", size(small)) ///
				subtitle("2010-2020") note("Data source: CHLR 2023") ///
				legend(ring(1) pos(6) cols(6) size(small)) 
			cd "$desdir/1_Pop/child/`k'"
			gr export "Line-`i'_`j'_`k'.png", as(png) replace
		}
	}
}

*--- 4.基于一分人口长数据，生成历年各省的总劳动人口长数据
cd "$mydir/1_Pop/child"
use 4_Pop1_Gender, clear
local vars "cyear provcd"
bys `vars': egen eduy0 = total(eduy1_ge)
bys `vars': egen pop0 = total(pop1_ge)
duplicates drop `vars', force 
gen peduy0 = eduy1_ge / pop1_ge
drop *_ge
label var eduy0 "少儿人口总受教育年限"
label var pop0 "少儿人口（人）"
label var peduy0 "少儿人口人均受教育年限"
save 5_Pop0, replace

// 描述历年各省劳动年龄人口、人均受教育年限变化趋势
foreach i in $provcds_ 31 {
	cd "$mydir/1_Pop/child"
	use 5_Pop0, clear
	keep if provcd == `i'
	foreach j in pop0 peduy0 {
		twoway line `j' cyear, xlabel(2010(2)2020) ///
			title("`j' of province `i'") ///
			xtitle("Year", size(small)) ///
			ytitle("`j'", size(small)) ///
			subtitle("2010-2020") note("Data source: CHLR 2023") ///
			legend(ring(1) pos(6) cols(6) size(small)) 
		cd "$desdir/1_Pop/child/`j'"
		gr export "Line-`i'_`j'.png", as(png) replace
	}
}

*--- 5.链接四分人口长数据与宏观数据
cd "$mydir/1_Pop/child"
use 2_Pop3, clear 
cd "$mydir/0_Macro"
mer m:1 cyear provcd using 1_Macro, nogen 
cd "$mydir/1_Pop/child"
save 6_Macro_Pop3, replace
