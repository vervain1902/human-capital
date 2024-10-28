cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 计算三分、二分和一分人口
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.10.28

==================================================*/

*--- 1 基于四分人口计算三分人口
cd "$mydir\1_Pop\worker"
use 1_Pop4, clear
gen eduy = sch * pop // 四分人口总受教育年限
local vars "cyear provcd urban gender age"
bys `vars': egen eduy3 = total(eduy)
bys `vars': egen pop3 = total(pop)
duplicates drop `vars', force 
gen peduy3 = eduy3 / pop3
drop sch pop eduy
label var eduy3 "三分人口总受教育年限"
label var pop3 "三分人口数（人）"
label var peduy3 "三分人口人均受教育年限"
save 2_Pop3, replace // 保存历年各省分城乡、性别、年龄的三分人口数据（含人均受教育年限信息）

*--- 2.基于三分人口数据，计算二分人口总受教育年限、平均受教育年限
cd "$mydir\1_Pop\worker"
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
cd "$mydir\1_Pop\worker"
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

*------ 3.2.分性别的一分人口
cd "$mydir\1_Pop\worker"
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

*--- 4.基于一分人口长数据，生成历年各省的总劳动人口长数据
cd "$mydir\1_Pop\worker"
use 4_Pop1_Gender, clear
local vars "cyear provcd"
bys `vars': egen eduy0 = total(eduy1_ge)
bys `vars': egen pop0 = total(pop1_ge)
duplicates drop `vars', force 
gen peduy0 = eduy1_ge / pop1_ge
drop *_ge
label var eduy0 "劳动年龄人口总受教育年限"
label var pop0 "劳动年龄人口（人）"
label var peduy0 "劳动年龄人均受教育年限"
save 5_Pop0, replace

