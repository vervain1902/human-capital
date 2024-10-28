cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 宏观数据
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.8.13

--------------------------------------------------

This script is for: 
	- 读取保存城乡平均工资
	- 读取保存宏观数据（GDP、劳动力人均GDP、总人口、城镇化率、第三产业比重、一般公共预算支出比重、进出口总额比重）

Note:数据来源
	- CHLR整理的宏观数据
	- 中国统计年鉴的宏观数据

==================================================*/

*--- 0: 清空内存，定义路径
cd "D:\Library\OneDrive\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do
 
*--- 1: 计算宏观变量


*------ 1.2: 使用统计年鉴 2010-2020 数据，保存分省份的GDP、劳均GDP、总人口、城镇人口比重、第三产业比重
// 增加开放指数、政府财政支出比重
cd "$rawdir\宏观数据"
import excel using 2010-2020_macrodata, firstrow clear // 来源：统计年鉴
drop if cyear == 2008

label var ratio "城镇人口比重"
label var Y "GDP万元"
label var wy "劳动力人均GDP元"
label var wpop "劳动力人口"
label var ty "人均GDP元"
label var tpop "总人口"
label var d2ty "滞后2期人均GDP元"
label var d2wy "滞后2期劳动力人均GDP元"
label var ty08 "08年人均GDP元"
label var wy08 "08年劳均GDP元"
label var indus "第三产业比重"

cd "$mydir\0_Macro"
mer 1:1 cyear provcd using tmp_wage, nogen
save 1_Macro, replace
erase tmp_wage.dta

*------ 1.3: 使用统计年鉴 2010-2020 数据，链接一般公共预算支出、进出口总额与GDP
// 读取一般公共预算支出数据
cd "$rawdir\宏观数据"
import excel using 2010-2020-一般公共预算支出, sheet("一般公共预算支出") firstrow clear // 来源：统计年鉴
drop C E G I K
gather B-L, variable(cyear_) value(invest)
replace invest = invest*10000
label var invest "一般公共预算支出(万元)"
gen cyear = 2010
replace cyear = 2012 if cyear_ == "D"
replace cyear = 2014 if cyear_ == "F"
replace cyear = 2016 if cyear_ == "H"
replace cyear = 2018 if cyear_ == "J"
replace cyear = 2020 if cyear_ == "L"
drop cyear_
cd "$mydir\0_Macro"
save tmp_invest, replace

// 读取进出口额数据
cd "$rawdir\宏观数据"
import excel using 2010-2020-进出口总额（美元）, sheet("进出口总额") firstrow clear // 来源：统计年鉴
drop C E G I K
gather B-L, variable(cyear_) value(imex)
label var imex "进出口总额(万美元)"
gen cyear = 2010
replace cyear = 2012 if cyear_ == "D"
replace cyear = 2014 if cyear_ == "F"
replace cyear = 2016 if cyear_ == "H"
replace cyear = 2018 if cyear_ == "J"
replace cyear = 2020 if cyear_ == "L"
drop cyear_
cd "$mydir\0_Macro"
save tmp_imex, replace

// 读取汇率数据，计算人民币为单位的进出口额
cd "$rawdir\宏观数据"
import excel using 2010-2020-美元对人民币汇率, sheet("美元对人民币汇率") firstrow clear // 来源：统计年鉴
keep if cyear == "2010" | cyear == "2012" | cyear == "2014" | ///
	cyear == "2016" | cyear == "2018" | cyear == "2020"
ren 人民币百美元 exrate
destring cyear, replace
cd "$mydir\0_Macro"
save tmp_exrate, replace

cd "$mydir\0_Macro"
use tmp_exrate, clear 
mer 1:m cyear using tmp_imex, nogen 
gen imex_RMB = imex*exrate/100
label var imex_RMB "进出口总额（万元）"
drop imex 
save tmp_imex, replace

// 链接一般公共预算支出、进出口总额与GDP，计算占GDP比例
cd "$mydir\0_Macro"
use tmp_imex, clear 
mer 1:1 cyear provcd using tmp_invest, nogen // 链接公共预算支出、进出口总额
mer 1:1 cyear provcd using 1_Macro, nogen // 链接GDP

gen gov = invest/Y
gen trade = imex_RMB/Y
label var gov "公共预算支出占GDP比重"
label var trade "进出口总额占GDP比重"

drop invest imex* 

save 1_Macro, replace
