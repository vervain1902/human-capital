cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 计算平均认知技能
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.10.28

==================================================*/

*---0 Program set up
cd "D:\# Library\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do

*---1 generate 4-fold pop (with macro data) with avg std_cog 
cd "$mydir\2_Cog\worker"
use 1_Cog, clear
local vars "cyear provcd urban gender age sch"
bys `vars': egen pcog = mean(st_cog)
duplicates drop `vars', force 
label var pcog "4-fold avg cog"
drop pid eduy st_cog 
order `vars'
sor `vars'
cd "$mydir\1_Pop\worker"
mer 1:1 cyear provcd urban gender age sch using 1_Macro_Pop4, nogen
cd "$mydir\2_Cog\worker"
save 2_Macro_Pop4_pCog4, replace

*---2 generate 3-fold pop [urban/gender/age] with avg std_cog 
cd "$mydir\2_Cog\worker"
use 1_Cog, clear
local vars "cyear provcd urban gender age"
bys `vars': egen pcog3 = mean(st_cog)
duplicates drop `vars', force 
label var pcog3 "3-fold avg cog"
keep `vars' age_group pcog3
order `vars'
sor `vars'
cd "$mydir\1_Pop\worker"
mer 1:1 cyear provcd urban gender age using 2_Macro_Pop3, nogen
cd "$mydir\2_Cog\worker"
save 3_Macro_Pop3_pCog3, replace

*---2 generate 2-fold pop [urban/gender] with avg std_cog 
cd "$mydir\2_Cog\worker"
use 1_Cog, clear
local vars "cyear provcd urban gender"
bys `vars': egen pcog2 = mean(st_cog)
duplicates drop `vars', force 
label var pcog2 "2-fold avg cog"
keep `vars' pcog2
order `vars'
sor `vars'
cd "$mydir\1_Pop\worker"
mer 1:1 cyear provcd urban gender using 3_Macro_Pop2, nogen
cd "$mydir\2_Cog\worker"
save 4_Macro_Pop2_pCog2, replace

*---3 generate 0-fold pop with avg std_cog 
use 1_Cog, clear
local vars "cyear provcd"
bys `vars': egen pcog0 = mean(st_cog)
bys `vars': egen n_high_cog = total(high_cog)
bys `vars': egen N = total(1)
gen high_cog_rt = n_high_cog / N
duplicates drop `vars', force 
label var pcog0 "0-fold avg cog"
label var high_cog_rt "ratio of higher cog pop"
keep `vars' pcog0 high_cog_rt
order `vars'
sor `vars'
cd "$mydir\1_Pop\worker"
mer 1:1 cyear provcd using 5_Macro_Pop0, nogen
cd "$mydir\2_Cog\worker"
save 5_Macro_Pop0_pCog0, replace
