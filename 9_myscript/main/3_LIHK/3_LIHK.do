cls
/*==================================================

Proiect: 劳动力人力资本数量、质量与经济增长 - 劳动力收入法测算人力资本
Author:  liuziyu
Created Date: 2023.12
Last Edited Date: 2024.10.28

--------------------------------------------------

This script is for:
	- 根据CFPS数据，整理调查的劳动年龄人口的四分人口数据（教育、年龄、性别、城乡）和工资；
		- 估计明瑟收入方程的系数；
	- 根据中国统计年鉴，整理分省份GDP和分省份、城乡的平均工资；
	- 根据人力资本中心估算数据，整理各省劳动年龄人口的四分人口数据
	- 链接微观数据与宏观数据（GDP、平均工资）
	- 链接微观数据与认知技能数据
	- 估计Mincer方程

==================================================*/

*---0 Program set up
cd "D:\# Library\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do

*---1 read micro income data of all years from CFPS database
cd "$scriptdir\function\read"
do read_income.do

*---2 merge micro income data and [micro cognitive skill], [macro data, 4-fold pop, average cognitive skill], to generate intercept term
cd "$mydir\3_LIHK"
use 1_Inc, clear
cd "$mydir\2_Cog\worker"
merge 1:1 cyear pid using 1_Cog, /* keep(match)  */nogen 
merge m:1 cyear provcd urban gender age eduy using 9_Macro_Pop4_Cog4, nogen /* keep(match) */

gen avwage = uravwage
replace avwage = ruavwage if urban == 0
drop ruavwage uravwage
label var avwage "分省平均工资"

gen eduy_wy = eduy * pgdp_w
label var eduy_wy "受教育年限与省劳均GDP的交乘项"
gen eduy_indus = eduy * indus
label var eduy_indus "受教育年限与第三产业比重的交乘项"
gen eduy_gov = eduy * gov
label var eduy_gov "受教育年限与公共预算支出交乘项"
gen eduy_trade = eduy * trade
label var eduy_trade "受教育年限与进出口比重的交乘项"

gen cog_wy = st_cog * pgdp_w
label var cog_wy "认知技能与省劳均GDP的交乘项"
gen cog_indus = st_cog * indus
label var cog_indus "认知技能与第三产业比重的交乘项"
gen cog_gov = st_cog * gov
label var cog_gov "认知技能与公共预算支出的交乘项"
gen cog_trade = st_cog * trade
label var cog_trade "认知技能与进出口比重的交乘项"

cd "$mydir\3_LIHK"
save 3_Macro_Pop4_Cog4_Inc, replace

/* // 分省描述平均工资、对数平均工资的变化趋势
cd "$mydir\3_LIHK"
use 3_Macro_Pop4_Cog_LIHK, clear
bys cyear provcd: egen pinc = mean(inc)
gen Lpinc = ln(pinc)
duplicates drop cyear provcd, force 
twoway line pinc cyear, by(provcd) legend(off)
cd "$desdir\3_LIHK"
gr export "1_Pincome.png", as(png) replace
twoway line Lpinc cyear, by(provcd) legend(off)
gr export "2_LnPincome.png", as(png) replace */

*---3 generate lihk index
cd "$funcdir\generate"
do gen_lihk.do 

*---4 describe lihk stock
cd "$funcdir\describe"
do des_lihk.do 

