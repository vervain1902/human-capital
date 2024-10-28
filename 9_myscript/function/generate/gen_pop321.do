cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 计算三分、二分和一分人口
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.10.28

==================================================*/

*---1 generate 3-fold pop [urban/gender/age] based on 4-fold pop [urban/gender/age/edu_year]
cd "$mydir\1_Pop\worker"
use 1_Macro_Pop4, clear
gen eduy = sch * pop // 四分人口总受教育年限
local vars "cyear provcd urban gender age"
bys `vars': egen eduy3 = total(eduy)
bys `vars': egen pop3 = total(pop)
duplicates drop `vars', force 
gen peduy3 = eduy3 / pop3
drop sch pop eduy
label var eduy3 "total education years of 3-fold population"
label var pop3 "size of 3-fold population"
label var peduy3 "avg education years of 3-fold population"
local vars "cyear provcd prov_hanzi prov_pinyin"
order `vars'
save 2_Macro_Pop3, replace

*---2 generate 2-fold pop [urban/gender] based on 3-fold pop [urban/gender/age]
cd "$mydir\1_Pop\worker"
use 2_Macro_Pop3, clear
local vars "cyear provcd urban gender"
bys `vars': egen eduy2 = total(eduy3)
bys `vars': egen pop2 = total(pop3)
duplicates drop `vars', force 
gen peduy2 = eduy2 / pop2 
drop *3 age*
label var eduy2 "total education years of 2-fold population"
label var pop2 "size of 2-fold population"
label var peduy2 "avg education years of 2-fold population"
local vars "cyear provcd prov_hanzi prov_pinyin"
order `vars'
save 3_Macro_Pop2, replace

*---3 generate 1-fold pop [urban] and [gender] based on 2-fold pop [urban/gender]
*------3.1 one-fold pop [urban]
cd "$mydir\1_Pop\worker"
use 3_Macro_Pop2, clear 
local vars "cyear provcd urban"
bys `vars': egen eduy1_ur = total(eduy2)
bys `vars': egen pop1_ur = total(pop2)
duplicates drop `vars', force 
gen peduy1_ur = eduy2 / pop2
drop *2 gender 
label var eduy1_ur "total education years of 1-fold population (urban)"
label var pop1_ur "size of 1-fold population (urban)"
label var peduy1_ur "avg education years of 1-fold population (urban)"
local vars "cyear provcd prov_hanzi prov_pinyin"
order `vars'
save 4_Macro_Pop1_Urban, replace

*------3.1 one-fold pop [gender]
cd "$mydir\1_Pop\worker"
use 3_Macro_Pop2, clear 
local vars "cyear provcd gender"
bys `vars': egen eduy1_ge = total(eduy2)
bys `vars': egen pop1_ge = total(pop2)
duplicates drop `vars', force 
gen peduy1_ge = eduy2 / pop2
drop *2 urban
label var eduy1_ge "total education years of 1-fold population (gender)"
label var pop1_ge "size of 1-fold population (gender)"
label var peduy1_ge "avg education years of 1-fold population (gender)"
local vars "cyear provcd prov_hanzi prov_pinyin"
order `vars'
save 4_Macro_Pop1_Gender, replace

*---4 generate 0-fold pop based on 2-fold pop [urban/gender]
cd "$mydir\1_Pop\worker"
use 4_Macro_Pop1_Gender, clear
local vars "cyear provcd"
bys `vars': egen eduy0 = total(eduy1_ge)
bys `vars': egen pop0 = total(pop1_ge)
duplicates drop `vars', force 
gen peduy0 = eduy1_ge / pop1_ge
drop *_ge gender
label var eduy0 "total education years of 0-fold population"
label var pop0 "size of 0-fold population"
label var peduy0 "avg education years of 0-fold population"
local vars "cyear provcd prov_hanzi prov_pinyin"
order `vars'
save 5_Macro_Pop0, replace
