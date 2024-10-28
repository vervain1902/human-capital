/*

Project:			human capital
Author:				liuziyu
Create Date:		2023.12

database used: 
	CFPS 2010-2020
	CHLR 2010-2020
	Yearbook 2010-2020
 
This script is for: 
	Calculating long-form data of 4-fold population;
	Acquiring total size of 4-fold population;
	Calculating average edu year of 4-fold population;

Note:
	[4-fold population] meaning province/urban/gen
	r/age group each year；
	[2-fold population] meaning province/age group each year.

*/

*--- 0: Program set up
clear all
cls

global dir "D:\Onedrive\OneDrive - mail.bnu.edu.cn\1 Seminar\Publishs\1031-认知技能\data"
global mydir	"$dir\mydata"
global rawdir	"$dir\rawdata"
global popdir  	"$rawdir\CHLR\2023_CHLR\2.2项目估算数据-2023\总人口\人口四分数据和代码\人口四分数据"
global macrodir "$rawdir\CHLR\2023_CHLR\3.mincer微观数据库以及宏观数据库-2023\2023宏观数据库"

global provcds_ "11 12 13 14 15 21 22 23 32 33 34 35 36 37 41 42 43 44 45 46 50 51 52 53 54 61 62 63 64 65"

set scheme plotplain, perm

*--- 1: 生成分省份、分年度的四分人口长数据
*------ 1.1: 处理不含上海的省份
foreach i in $provcds_ {
    foreach j in rural urban {
		cd "$popdir"
		use Hcdata`i'/`j'/`j'_pop_1982_2021, clear
		keep if year == 2010 | year == 2012 | year == 2014 | year == 2016 | year == 2018 | year == 2020

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

		drop if (age > 59 | age < 16) & gender == 1 // 男性：16-59岁
		drop if (age > 54 | age < 16) & gender == 0 // 女性：16-54
		cd "$mydir\macrodata_1\1_PopData"

		local vars "cyear provcd age gender urban sch pop"
		sor `vars'
		order `vars'
		label var cyear "年份"
		save long_`i'_`j', replace
	}
}

*------ 1.2: 处理上海（仅有城市数据）
cd "$popdir"
use Hcdata31/urban/urban_pop_1982_2021, clear
keep if year == 2010 | year == 2012 | year == 2014 | year == 2016 | year == 2018 | year == 2020

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

drop if (age > 59 | age < 16) & gender == 1 // 男性：16-59岁
drop if (age > 54 | age < 16) & gender == 0 // 女性：16-54岁

drop variable *_
gen urban_ = 0
replace urban_ = 1 if urban == "urban"
drop urban
rename urban_ urban
rename year cyear

local vars "cyear provcd age gender urban sch pop"
sor `vars'
order `vars'
label var cyear "年份"
cd "$mydir\macrodata_1\1_PopData"
save long_31_urban, replace

*------ 1.3: 合并所有省份四分人口长数据
cd "$mydir\macrodata_1\1_PopData"
use long_31_urban, clear
foreach i in $provcds_ {
	foreach j in urban rural {
		ap using long_`i'_`j'
		erase long_`i'_`j'.dta
	}
}

cd "$mydir\macrodata_1\1_PopData"
save 1_LongPop4, replace
erase long_31_urban.dta

*------ 1.4: 分省份、分城乡、分性别描述劳动年龄人口变化趋势
*--------- 1.4.1 不含上海的省份
foreach i in $provcds_ {
	foreach j in 0 1 {
		foreach k in 0 1 {
			cd "$mydir\macrodata_1\1_PopData"
			use 1_LongPop4, clear
			bys cyear provcd gender urban: egen tpop = total(pop)
			replace tpop = tpop / 10000
			label var tpop "劳动年龄人口（万人）"
			keep if provcd == `i' & urban == `j' & gender == `k'
			twoway line tpop cyear, xlabel(2010(2)2020) ///
				title("Population size of province `i' of urban `j' and gender `k'") ///
				xtitle("Year", size(small)) ///
				ytitle("Population size", size(small)) ///
				subtitle("2010-2020") note("Data source: CHLR 2023") ///
				legend(ring(1) pos(6) cols(6) size(small)) 
			cd "$mydir\macrodata_1\3_Description\5_Pop4"
			gr export "`i'_urban`j'_gender`k'.png", as(png) replace
		}
	}
}

*--------- 1.5.2: 描述上海城镇人口变化趋势
foreach i in 0 1 {
	cd "$mydir\macrodata_1\1_PopData"
	use 1_LongPop4, clear
	keep if provcd == 31 & gender == `i'
	bys cyear provcd gender: egen tpop = total(pop)
	replace tpop = tpop / 10000
	label var tpop "劳动年龄人口（万人）"
	twoway line tpop cyear, xlabel(2010(2)2020) ///
		title("Population size of province 31 of urban 1 and gender `i'") ///
		xtitle("Year", size(small)) ///
		ytitle("Population size", size(small)) ///
		subtitle("2010-2020") note("Data source: CHLR 2023") ///
		legend(ring(1) pos(6) cols(6) size(small)) 
	cd "$mydir\macrodata_1\3_Description\5_Pop4"
	gr export "31_urban1_gender`i'.png", as(png) replace
}

*------ 1.5: 分省份、分城乡描述劳动年龄人口变化趋势
*--------- 1.5.1: 不含上海的省份
foreach i in $provcds_ {
	foreach j in 0 1 {
		cd "$mydir\macrodata_1\1_PopData"
		use 1_LongPop4, clear
		bys cyear urban provcd: egen tpop = total(pop)
		replace tpop = tpop / 10000
		label var tpop "劳动年龄人口（万人）"
		keep if provcd == `i' & urban == `j'
		twoway line tpop cyear, xlabel(2010(2)2020) ///
			title("Population size of province `i' of urban `j'") ///
			xtitle("Year", size(small)) ///
			ytitle("Population size", size(small)) ///
			subtitle("2010-2020") note("Data source: CHLR 2023") ///
			legend(ring(1) pos(6) cols(6) size(small)) 
		cd "$mydir\macrodata_1\3_Description\1_Pop2\1_Urban"
		gr export "`i'_urban`j'.png", as(png) replace
	}
}

*--------- 1.5.2: 描述上海城镇人口变化趋势
cd "$mydir\macrodata_1\1_PopData"
use 1_LongPop4, clear
keep if provcd == 31 
bys cyear provcd urban: egen tpop = total(pop)
replace tpop = tpop / 10000
label var tpop "劳动年龄人口（万人）"
twoway line tpop cyear, xlabel(2010(2)2020) ///
	title("Population size of province 31 of urban 1") ///
	xtitle("Year", size(small)) ///
	ytitle("Population size", size(small)) ///
	subtitle("2010-2020") note("Data source: CHLR 2023") ///
	legend(ring(1) pos(6) cols(6) size(small)) 
cd "$mydir\macrodata_1\3_Description\1_Pop2\1_Urban"
gr export "31_urban1.png", as(png) replace

*------ 1.6: 分省份、分性别描述劳动年龄人口变化趋势
foreach i in $provcds_ 31 {
	foreach j in 0 1 {
		cd "$mydir\macrodata_1\1_PopData"
		use 1_LongPop4, clear
		bys cyear gender provcd: egen tpop = total(pop)
		replace tpop = tpop / 10000
		label var tpop "劳动年龄人口（万人）"
		keep if provcd == `i' & gender == `j'
		twoway line tpop cyear, xlabel(2010(2)2020) ///
			title("Population size of province `i' of gender `j'") ///
			xtitle("Year", size(small)) ///
			ytitle("Population size", size(small)) ///
			subtitle("2010-2020") note("Data source: CHLR 2023") ///
			legend(ring(1) pos(6) cols(6) size(small)) 
		cd "$mydir\macrodata_1\3_Description\1_Pop2\2_Gender"
		gr export "`i'_gender`j'.png", as(png) replace
	}
}

*--- 2: 生成分省份、分年度的二分人口（分年龄、受教育程度）长数据
cd "$mydir\macrodata_1\1_PopData"
use 1_LongPop4, clear
local vars "cyear provcd age sch"
bys `vars': egen pop2 = total(pop)
duplicates drop `vars', force 
keep pop2 `vars'

// 以11岁为分组间隔，分为4个年龄组
gen age_group = .
replace age_group = 1 if age >= 16 & age <= 26
replace age_group = 2 if age >= 27 & age <= 37
replace age_group = 3 if age >= 38 & age <= 48
replace age_group = 4 if age >= 49 & age <= 59
save 2_LongPop2, replace

*--- 3: 生成分省份、分年度的总劳动人口数据
cd "$mydir\macrodata_1\1_PopData"
use 1_LongPop4, clear
bys cyear: egen Pop0 = total(pop)
duplicates drop cyear, force
gen Pop0_ = Pop0/10000
drop Pop0
rename Pop0_ Pop0
label var Pop0 "劳动年龄人口（万人）"
save 4_LongPop0, replace

// 描述全国劳动年龄人口变化趋势
cd "$mydir\macrodata_1\1_PopData"
use 4_LongPop0, clear
twoway line Pop0 cyear, xlabel(2010(2)2020) ///
	title("Nationwide labor population size") ///
	xtitle("Year", size(small)) ///
	ytitle("Population size", size(small)) ///
	subtitle("2010-2020") note("Data source: CHLR 2023") ///
	legend(ring(1) pos(6) cols(6) size(small)) 
cd "$mydir\macrodata_1\3_Description\2_Pop0"
gr export Pop0.png, as(png) replace

cd "$mydir\macrodata_1\1_PopData"
use 1_LongPop4, clear
local vars "cyear provcd"
bys `vars': egen pop0 = total(pop)
duplicates drop `vars', force 
keep pop0 `vars'
gen pop0_ = pop0/10000
drop pop0
rename pop0_ pop0
label var pop0 "劳动年龄人口（万人）"
save 3_LongPop0, replace

// 分省份描述劳动年龄人口变化趋势
foreach i in $provcds_ 31 {
	cd "$mydir\macrodata_1\1_PopData"
	use 3_LongPop0, clear
	keep if provcd == `i'
	twoway line pop0 cyear, xlabel(2010(2)2020) ///
		title("Population size of province `i'") ///
		xtitle("Year", size(small)) ///
		ytitle("Population size", size(small)) ///
		subtitle("2010-2020") note("Data source: CHLR 2023") ///
		legend(ring(1) pos(6) cols(6) size(small)) 
	cd "$mydir\macrodata_1\3_Description\2_Pop0"
	gr export `i'_Pop0.png, as(png) replace
}

*--- 4: 基于宽数据，计算四分人口总受教育年限、平均受教育年限
*------ 4.1: 处理不含上海的省份
foreach i in $provcds_ {
    foreach j in rural urban {
		foreach k in male female {
			cd "$popdir"
			use Hcdata`i'/`j'/`j'_pop_1982_2021, clear
			keep if year == 2010 | year == 2012 | year == 2014 | year == 2016 | year == 2018 | year == 2020		
			keep year age *_`k'
			gen pop4 = nosch_`k' + primary_`k' + junior_`k' + senior_`k' + college_`k' + university_`k'
			label var pop4 "四分人口数"
			gen eduy4 = primary_`k'*6 + junior_`k'*9 + senior_`k'*12 + college_`k'*15 + university_`k'*16
			label var eduy4 "四分人口总受教育年限"
			gen aveduy4 = eduy4 / pop4
			label var aveduy4 "四分人口平均受教育年限"
			gen gender = .
			tostring gender, replace
			replace gender = "`k'"
			gen urban = .
			tostring urban, replace
			replace urban = "`j'"
			gen provcd = .
			replace provcd = `i'
			drop *_`k'
			cd "$mydir\macrodata_1\1_PopData"
			save `i'_`j'_`k', replace // 分省份、城乡、性别保存人口数据
			misstable sum aveduy4

		}			
	}
}

*------ 4.2: 处理上海数据（无农村人口）
foreach k in male female {
	cd "$popdir"
	use Hcdata31/urban/urban_pop_1982_2021, clear
	keep if year == 2010 | year == 2012 | year == 2014 | year == 2016 | year == 2018 | year == 2020
	keep year age *_`k'
	gen pop4 = nosch_`k' + primary_`k' + junior_`k' + senior_`k' + college_`k' + university_`k'
	label var pop4 "四分人口数"
	gen eduy4 = primary_`k' * 6 + junior_`k' * 9 + senior_`k' * 12 + college_`k' * 15 + university_`k' * 16
	label var eduy4 "四分人口总受教育年限"
	gen aveduy4 = eduy4 / pop4
	label var aveduy4 "四分人口平均受教育年限"
	gen urban = .
	tostring urban, replace
	replace urban = "urban"
	gen provcd = .
	replace provcd = 31
	gen gender = .
	tostring gender, replace
	replace gender = "`k'"
	drop *_`k'
	cd "$mydir\macrodata_1\1_PopData"
	save 31_urban_`k', replace
	misstable sum aveduy4
}
ap using 31_urban_male

*------ 4.3 合并全国数据
foreach i in $provcds_ {
	foreach j in urban rural {
		foreach k in male female {
			ap using `i'_`j'_`k'
			erase `i'_`j'_`k'.dta
		}
	}
}

gen urban_ = 0
replace urban_ = 1 if urban == "urban"
drop urban
rename urban_ urban

gen gender_ = 0
replace gender_ = 1 if gender == "male"
drop gender
rename gender_ gender
rename year cyear

drop if (age > 59 | age < 16) & gender == 1 // 男性：16-59岁
drop if (age > 54 | age < 16) & gender == 0 // 女性：16-54岁

sor cyear provcd age urban gender pop4 eduy4 aveduy4
order cyear provcd age urban gender
cd "$mydir\macrodata_1\1_PopData"
save 1_Pop4, replace
erase 31_urban_male.dta
erase 31_urban_female.dta

*--- 5: 分年度、分省份计算二分人口（分城乡、性别）受教育年限
*------ 5.1: 计算二分人口总人口数、总受教育年限、平均受教育年限
cd "$mydir\macrodata_1\1_PopData"

local vars "cyear provcd gender urban"
bys `vars': egen pop2 = total(pop4)
bys `vars': egen eduy2 = total(eduy4)
gen aveduy2 = eduy2 / pop2
duplicates drop `vars', force 
keep `vars' *2
label var pop2 "二分人口数"
label var eduy2 "二分人口总受教育年限"
label var aveduy2 "二分人口平均受教育年限"
save 2_Pop2, replace

*------ 5.2: 分省份、分城乡描述总受教育年限、平均受教育年限的变化趋势
*---------- 5.2.1: 不含上海的省份
foreach i in $provcds_ {
	foreach j in 0 1 {
		foreach k in eduy2 aveduy2 {
			cd "$mydir\macrodata_1\1_PopData"
			use 1_Pop4, clear
			keep if provcd == `i' & urban == `j'
			local vars "cyear provcd urban"
			bys `vars': egen pop2 = total(pop4)
			bys `vars': egen eduy2 = total(eduy4)
			gen aveduy2 = eduy2 / pop2
			duplicates drop `vars', force
			twoway line `k' cyear, xlabel(2010(2)2020) ///
				title("Education year of urban `j' of province `i'") ///
				xtitle("Year", size(small)) ///
				ytitle("Education Year", size(small)) ///
				subtitle("2010-2020") note("Data source: CHLR 2023") ///
				legend(ring(1) pos(6) cols(6) size(small)) 
			cd "$mydir\macrodata_1\3_Description\3_EduYear2\1_Urban"
			gr export "`k'_`i'_urban`j'.png", as(png) replace
		}
	}
}

*--------- 5.2.2: 描述上海城镇人口变化趋势
cd "$mydir\macrodata_1\1_PopData"
foreach i in eduy2 aveduy2 {
	cd "$mydir\macrodata_1\1_PopData"
	use 1_Pop4, clear
	keep if provcd == 31
	local vars "cyear provcd urban"
	bys `vars': egen pop2 = total(pop4)
	bys `vars': egen eduy2 = total(eduy4)
	gen aveduy2 = eduy2 / pop2
	duplicates drop `vars', force
	twoway line `i' cyear, xlabel(2010(2)2020) ///
		title("Education year of urban 1 of province 31") ///
		xtitle("Year", size(small)) ///
		ytitle("Population size", size(small)) ///
		subtitle("2010-2020") note("Data source: CHLR 2023") ///
		legend(ring(1) pos(6) cols(6) size(small)) 
	cd "$mydir\macrodata_1\3_Description\3_EduYear2\1_Urban"
	gr export "`i'_31_urban1.png", as(png) replace
}

*------ 5.3: 分省份、分性别描述总受教育年限、平均受教育年限的变化趋势
foreach i in $provcds_ 31 {
	foreach j in 0 1 {
		foreach k in eduy2 aveduy2 {
			cd "$mydir\macrodata_1\1_PopData"
			use 1_Pop4, clear
			keep if provcd == `i' & gender == `j'
			local vars "cyear provcd gender"
			bys `vars': egen pop2 = total(pop4)
			bys `vars': egen eduy2 = total(eduy4)
			gen aveduy2 = eduy2 / pop2
			duplicates drop `vars', force
			twoway line `k' cyear, xlabel(2010(2)2020) ///
				title("Education year of gender `j' of province `i'") ///
				xtitle("Year", size(small)) ///
				ytitle("Education Year", size(small)) ///
				subtitle("2010-2020") note("Data source: CHLR 2023") ///
				legend(ring(1) pos(6) cols(6) size(small)) 
			cd "$mydir\macrodata_1\3_Description\3_EduYear2\2_Gender"
			gr export "`k'_`i'_gender`j'.png", as(png) replace
		}
	}
}

*--- 4: 计算宏观变量
*------ 4.1: 使用CHLR 2010-2020 数据，保存城镇和农村人均工资
foreach i in ruavwage uravwage {
    cd "$macrodir"
    use macro_data, clear
	keep if wave == 2010 | wave == 2012 | wave == 2014 | wave == 2016 | wave == 2018 | wave == 2020
	keep wave *`i'
	rename wave cyear
	gather *`i', variable(provcd) value(`i') 
	replace provcd = substr(provcd, 2, 2)
	destring provcd, replace
	cd "$mydir\macrodata_1\4_MacroData"
	save `i', replace
}

merge 1:1 provcd cyear using ruavwage, nogen
drop if provcd == 0
label var uravwage "城镇平均工资元"
label var ruavwage "农村平均工资元"
cd "$mydir\macrodata_1\4_MacroData"
save 1_AvgWage, replace

*------ 4.2: 使用统计年鉴 2010-2020 数据，保存GDP、劳均GDP、总人口、城镇人口比重、第三产业比重
cd "$rawdir\MacroData"
import excel using 2010-2020_macrodata, firstrow clear
drop if cyear == 2008

label var ratio "城镇人口比重"
label var Y "GDP万元"
label var wy "劳动力人均GDP元"
label var wpop "劳动力人口"
label var ty "人均GDP元"
label var tpop "总人口"
label var d2ty "滞后2期人均GDP元"
label var d2wy "滞后2期劳动力人均GDP元"
label var ty08 "08年人均GDP元"
label var wy08 "08年劳均GDP元"
label var indus "第三产业比重"

*------ 4.3: 链接CHLR和统计年鉴的宏观数据
cd "$mydir\macrodata_1\4_MacroData"
merge 1:m provcd cyear using 1_AvgWage, nogen keep(match)
save 2_MacroData, replace
