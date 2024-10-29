cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 计算lihk指数（不含认知技能）
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.10.29

==================================================*/

*---1 merge micro income data and 
*		[micro cognitive skill] and 
*		[macro data, 0-fold pop, average cognitive skill, adjusted edu_year]
cd "$mydir\3_LIHK"
use 1_Inc, clear
cd "$mydir\2_Cog\worker"
merge 1:1 cyear pid using 1_Cog, nogen 
merge m:1 cyear provcd using 8_Macro_Pop0_pCog0_aEduy0, nogen 
gen avwage = uravwage
replace avwage = ruavwage if urban == 0
drop ruavwage uravwage
label var avwage "分省平均工资"

*---2 generate x-terms
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
save 2_Macro_Pop0_pCog0_aEduy0_Cog_Inc, replace
