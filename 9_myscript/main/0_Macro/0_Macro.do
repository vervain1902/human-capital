cls

/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 宏观数据
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.10.13

--------------------------------------------------

This script is for: 
	- 读取保存城乡平均工资
	- 读取保存宏观数据（GDP、劳动力人均GDP、总人口、城镇化率、第三产业比重、一般公共预算支出比重、进出口总额比重）

Note:数据来源
	- CHLR整理的宏观数据
	- 中国统计年鉴的宏观数据

==================================================*/

*---0 清空内存，定义路径
cd "D:\Library\OneDrive\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do
 
*---1 计算被解释变量：2010年不变价GDP与人均GDP、劳动年龄人口人均gdp；城乡收入差距、Palma指数
cd "$scriptdir\function\generate"
do gen_gdp.do

*---2 计算城乡平均工资水平
cd "$scriptdir\function\generate"
do gen_pwage.do

*---3 计算其他控制变量：物质资本；人口、城镇化率、三产比重；政府支出、进出口总额
cd "$scriptdir\function\generate"
do gen_covariates.do

*---4 链接所有宏观变量
cd "$mydir\0_Macro"
use tmp_gdp, clear 
local files tmp_tpop_indus tmp_pwage tmp_K tmp_invest tmp_im_export
foreach file in `files' {
    merge 1:1 cyear provcd using `file'.dta
    drop _merge  // 删除merge标记变量
}

keep if cyear == 2010 | cyear == 2012 | cyear == 2014 | cyear == 2016 | cyear == 2018 | cyear == 2020

gen gov = invest/gdp
gen trade = im_export_rmb/gdp
gen pgdp_w = gdp_base2010 * 10000 / wpop 
gen pgdp_t = gdp_base2010 * 10000 / tpop 
label var gov "公共预算支出占GDP比重"
label var trade "进出口总额占GDP比重"
label var pgdp_t "人均GDP万元"
label var pgdp_w "劳动力人均GDP万元"
gen lnty = ln(pgdp_t)
gen lnwy = ln(pgdp_w)
gen lnwl = ln(wpop)
drop invest im_export* exchange idx* *rate 
mer m:1 provcd using province_codes, nogen
save 1_Macro, replace
local files tmp_gdp tmp_tpop_indus tmp_pwage tmp_K tmp_invest tmp_im_export
foreach file in `files' {
    erase `file'.dta
}
