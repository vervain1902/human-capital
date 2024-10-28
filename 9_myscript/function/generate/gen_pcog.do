cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 计算平均认知技能
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.10.28

==================================================*/

*--- 0.清空内存，定义路径
cd "D:\# Library\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do

*--- 1.计算四分人口认知技能均值
cd "$mydir\2_Cog\worker"
use 1_Cog, clear
local vars "cyear provcd urban gender age sch"
bys `vars': egen pcog = mean(st_cog)
duplicates drop `vars', force 
label var pcog "四分人口认知技能均值"
keep `vars' age_group pcog 
order `vars'
sor `vars'
save 2_Cog4, replace

/* *--- 2.计算三分人口认知技能均值
cd "$mydir\2_Cog\worker"
use 1_Cog, clear
local vars "cyear provcd urban gender age"
bys `vars': egen pcog3 = mean(st_cog)
duplicates drop `vars', force 
label var pcog3 "三分人口认知技能均值"
keep `vars' age_group pcog3
order `vars'
sor `vars'
save 3_Cog3, replace */

*--- 3.计算总人口认知技能均值
use 1_Cog, clear
local vars "cyear provcd"
bys `vars': egen pcog0 = mean(st_cog)
duplicates drop `vars', force 
label var pcog "总人口认知技能均值"
keep `vars' age_group pcog
order `vars'
sor `vars'
save 4_Cog0, replace
