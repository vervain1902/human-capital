cls

/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 收入差距
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.10.13

--------------------------------------------------

This script is for: 
	- 读取城乡人均可支配收入；计算城乡收入比，作为地区经济发展差距指标
	- 读取劳动年龄人口收入；计算帕尔马比值，即测量收入最高的 10% 人口与最低的 40% 人口的总收入比值

Note:数据来源
	- 宏观数据
	- CFPS

==================================================*/

*---1 import micro income of labor total pop (include extremes)
cd "$mydir\3_LIHK"
use tmp_inc, clear 
drop if inc < 0 | inc == .
keep cyear provcd inc 

*---2 generate palma_ratio by cyear and province 
bys provcd cyear (inc): generate rank = _n
bys provcd cyear: egen total = total(inc)
bys provcd cyear: egen pop_total = count(inc)

gen high_10 = (rank >= 0.9 * pop_total)
gen low_40 = (rank <= 0.4 * pop_total)
bys provcd cyear: egen high_10_inc = total(inc * high_10)
bys provcd cyear: egen low_40_inc = total(inc * low_40)

gen palma_ratio = high_10_inc / low_40_inc

bys provcd cyear: keep if _n == 1
cd "$mydir/0_Macro"
save palma_ratio, replace
