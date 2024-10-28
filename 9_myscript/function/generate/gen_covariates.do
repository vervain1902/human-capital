cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 计算协变量
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.8.20

==================================================*/

*---1 使用统计年鉴 2010-2020 数据，保存总人口数、劳动年龄人口数、城镇化率、第三产业比重
cd "$rawdir\宏观数据"
import excel using 2010-2020_macrodata, firstrow clear // 来源：统计年鉴
drop if cyear == 2008
keep cyear provcd tpop wpop indus ratio

label var ratio "城镇化率"
label var wpop "劳动年龄人口数（人）"
label var tpop "总人口数（人）"
label var indus "第三产业比重"

cd "$mydir\0_Macro"
save tmp_tpop_indus, replace

*---2 物质资本存量
*------2.1 读取原始数据
cd "$rawdir\宏观数据"
import excel "2010-2020-固定资产投资-增长率-指数.xlsx", sh("固定资产投资") firstrow clear 
gather b11-b65, variable(provcd) value(fai)
gen provcd_new = real(substr(provcd, 2, 2))
drop provcd 
ren provcd_new provcd
destring(cyear), replace
label var fai "固定资产投资（亿元）"
cd "$mydir\0_Macro"
save tmp_fai, replace

cd "$rawdir\宏观数据"
import excel "2010-2020-固定资产投资-增长率-指数.xlsx", sh("增长率") firstrow clear 
gather a11-a65, variable(provcd) value(grow_rate)
gen provcd_new = real(substr(provcd, 2, 2))
drop provcd 
ren provcd_new provcd
destring(cyear), replace
label var grow_rate "固定资产投资增长率"
cd "$mydir\0_Macro"
save tmp_grow_rate, replace

cd "$rawdir\宏观数据"
import excel "2010-2020-固定资产投资-增长率-指数.xlsx", sh("指数") firstrow clear 
gather a11-a65, variable(provcd) value(idx_fai)
gen provcd_new = real(substr(provcd, 2, 2))
drop provcd 
ren provcd_new provcd
destring(cyear), replace
label var idx_fai "固定资产投资价格指数"
cd "$mydir\0_Macro"
mer 1:1 cyear provcd using tmp_fai, nogen
mer 1:1 cyear provcd using tmp_grow_rate, nogen
sor cyear provcd 

*------2.2 计算2018—2020年固定资产投资额
bys provcd (cyear): replace fai = fai[_n-1] * (1+grow_rate/100) if cyear > 2017
save tmp_fai, replace
erase tmp_grow_rate.dta

*------2.3 读取工业品出厂价格指数、建筑业增加值价格指数，使用平均值替换缺失值
// 2020年固定资产投资价格指数没有公布，使用工业品出厂价格指数、建筑业增加值价格指数的平均值替代
cd "$rawdir\宏观数据"
import excel "2010-2020-工业品出厂价格指数-建筑业增加值指数.xlsx", sh("工业品出厂") firstrow clear 
gather a11-a65, variable(provcd) value(idx_ppi)
gen provcd_new = real(substr(provcd, 2, 2))
drop provcd 
ren provcd_new provcd
destring(cyear), replace
label var idx_ppi "工业品出厂价格指数"
cd "$mydir\0_Macro"
save tmp_idx_ppi, replace

cd "$rawdir\宏观数据"
import excel "2010-2020-工业品出厂价格指数-建筑业增加值指数.xlsx", sh("建筑业增加值") firstrow clear 
gather a11-a65, variable(provcd) value(idx_ci)
gen provcd_new = real(substr(provcd, 2, 2))
drop provcd 
ren provcd_new provcd
destring(cyear), replace
label var idx_ci "建筑业增加值价格指数"
cd "$mydir\0_Macro"

mer 1:1 cyear provcd using tmp_idx_ppi, nogen 
gen idx_fai_new = (idx_ppi+idx_ci)/2
label var idx_fai_new "固定资产投资价格指数估算值"
mer 1:1 cyear provcd using tmp_fai, nogen
replace idx_fai_new = idx_ppi if idx_fai_new == .
replace idx_fai = idx_fai_new if idx_fai == .

gen idx_fai_base2010 = .
sor cyear provcd
bys provcd(cyear): replace idx_fai_base2010 = 100 if cyear == 2010
bys provcd(cyear): replace idx_fai_base2010 = idx_fai_base2010[_n-1] * (idx_fai / 100) if cyear > 2010
gen fai_base2010 = (fai / idx_fai_base2010) * 100
label var fai_base2010 "2010年不变价固定资产投资（亿元）"
order cyear provcd fai_base2010 fai
save tmp_fai, replace

use tmp_fai, clear 

gen K = .
bys provcd: gen fai_start = fai_base2010 if cyear == 2010
bys provcd: gen fai_end = fai_base2010 if cyear == 2020
bys provcd: egen fai_start_new = mean(fai_start)
bys provcd: egen fai_end_new = mean(fai_end)
gen p_grow_rate = ((fai_end_new / fai_start_new)^(1/10)) - 1
drop fai_start* fai_end*

save tmp_K, replace
erase tmp_idx_ppi.dta

*------2.4 永续盘存法估计物质资本
replace K = fai_base2010 / (0.05 + grow_rate) if cyear == 2010 // 估算基期物质资本存量
replace K = (1 - 0.05) * K[_n-1] + fai_base2010 if cyear > 2010 // 估算基期后物质资本存量

/* mscatter K cyear if provcd > 55, by(provcd)  */
save tmp_K, replace
erase tmp_fai.dta 

*---3 公共预算支出、进出口总额
*------3.1 读取公共预算支出、进出口总额与GDP
cd "$rawdir\宏观数据"
import excel "2010-2020-一般公共预算支出.xlsx", sh("一般公共预算支出") firstrow clear 
gather a11-a65, variable(provcd) value(invest)
gen provcd_new = real(substr(provcd, 2, 2))
drop provcd 
ren provcd_new provcd
destring(cyear), replace
label var invest "一般公共预算支出（亿元）"
cd "$mydir\0_Macro"
save tmp_invest, replace

cd "$rawdir\宏观数据"
import excel "2010-2020-进出口总额（美元）.xlsx", sh("进出口总额") firstrow clear 
gather a11-a65, variable(provcd) value(im_export)
gen provcd_new = real(substr(provcd, 2, 2))
drop provcd 
ren provcd_new provcd
destring(cyear), replace
label var im_export "进出口总额(万美元)"
cd "$mydir\0_Macro"
save tmp_im_export, replace

*------3.2 读取汇率数据，计算人民币为单位的进出口额
cd "$rawdir\宏观数据"
import excel using 2010-2020-美元对人民币汇率, sheet("美元对人民币汇率") firstrow clear // 来源：统计年鉴
keep if cyear == "2010" | cyear == "2012" | cyear == "2014" | ///
	cyear == "2016" | cyear == "2018" | cyear == "2020"
ren 人民币百美元 exchange
destring(cyear), replace
cd "$mydir\0_Macro"
save tmp_exchange, replace

cd "$mydir\0_Macro"
use tmp_exchange, clear 
mer 1:m cyear using tmp_im_export, nogen 
gen im_export_rmb = im_export*exchange/100
label var im_export_rmb "进出口总额（万元）"
drop im_export 
save tmp_im_export, replace
erase tmp_exchange.dta


