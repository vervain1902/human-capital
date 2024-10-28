cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 计算四分人口
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.10.28

==================================================*/

*---1 generate long data of 4-fold population [urban/gender/age/edu_year]
// note: rural pop of Shanghai was manually created already (Hcdata31/...), with 0 values in each cell.
foreach i in $provcd {
    foreach j in rural urban {
		cd "$wpopdir"
		use Hcdata`i'/`j'/`j'_outschool_1985_2021, clear
		keep if year == 2010 | year == 2012 | year == 2014 | year == 2016 | year == 2018 | year == 2020
		gather *male, value(pop)
		split variable, parse("_")
		ren (variable1 variable2) (sch_ gender_) 

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

		drop if age > 54 & gender == 0 // male: 16-59 years old, female: 16-54 years old
		
		local vars "cyear provcd age gender urban sch pop"
		sor `vars'
		order `vars'
		label var cyear "year"
		cd "$mydir\1_Pop\worker"
		save long_`i'_`j', replace
	}
}

/* *------ 1.2.处理上海（仅有城市数据）
cd "$wpopdir"
use Hcdata31/urban/urban_outschool_1985_2021, clear
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

drop variable *_
gen urban_ = 0
replace urban_ = 1 if urban == "urban"
drop urban
rename urban_ urban
rename year cyear

drop if age > 54 & gender == 0

local vars "cyear provcd age gender urban sch pop"
sor `vars'
order `vars'
label var cyear "年份"
cd "$mydir\1_Pop\worker"
save long_31_urban, replace */

*---2 merge long data of pop of all provinces.
cd "$mydir\1_Pop\worker"
use long_31_urban, clear
ap using long_31_rural
foreach i in $provcds_ {
	foreach j in urban rural {
		ap using long_`i'_`j'
		erase long_`i'_`j'.dta
	}
}

// divide pop into 4 groups, with an 11-years interval
gen age_group = 1
replace age_group = 2 if age >= 27 & age <= 37
replace age_group = 3 if age >= 38 & age <= 48
replace age_group = 4 if age >= 49 & age <= 59

replace pop = pop/10000

label var provcd "province code"
label var sch "year of education"
label var pop "4-fold population (10,000)"
cd "$mydir\0_Macro"
mer m:1 cyear provcd using 1_Macro, nogen 
local vars "cyear provcd prov_hanzi prov_pinyin"
order `vars'
cd "$mydir\1_Pop\worker"
save 1_Macro_Pop4, replace

erase long_31_urban.dta
erase long_31_rural.dta
