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

*--- 0 清空内存，定义路径
cd "D:\# Library\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do

*--- 1 读取城乡收入
cd "$scriptdir/function/generate"
do gen_income_gap.do // 运行从宏观数据生成城乡收入差距的脚本
cd "$scriptdir/function/read"
do read_income.do // 运行从cfps读取收入的脚本

keep cyear provcd inc 
drop if missing(cyear) | missing(provcd) | missing(inc) 
drop if cyear < 0 | provcd < 0 | inc < 0 // 删除无效样本

// 分省计算palma比值
* 按省份、年份、个人收入排序
bys provcd cyear (inc): generate rank = _n
bys provcd cyear: egen total = total(inc)  // 计算总收入

* 计算每个省份每年的总人口数
bys provcd cyear: egen pop_total = count(inc)

* 标记最高10%的收入
gen high_10 = (rank >= 0.9 * pop_total)

* 标记最低40%的收入
gen low_40 = (rank <= 0.4 * pop_total)
* 计算最高10%人口的总收入
bysort provcd cyear: egen high_10_inc = total(inc * high_10)

* 计算最低40%人口的总收入
bysort provcd cyear: egen low_40_inc = total(inc * low_40)
* 计算帕尔马比值
gen palma_ratio = high_10_inc / low_40_inc

* 删除按省份、年份的重复值，只保留计算过帕尔马比值的数据
bysort provcd cyear: keep if _n == 1
cd "$mydir/0_Macro"
save palma_ratio, replace
