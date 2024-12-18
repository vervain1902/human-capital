cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 计算收入差距
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.10.28

==================================================*/

cd "$macrodir"
import excel "2010-2020-城乡居民人均可支配收入.xlsx", sh("urban") firstrow clear 
gather 全国-新疆, variable(provcd) value(inc_urban)
cd "$mydir/0_Macro"
save tmp_inc_urban, replace

cd "$macrodir"
import excel "2010-2020-城乡居民人均可支配收入.xlsx", sh("rural") firstrow clear 
gather 全国-新疆, variable(provcd) value(inc_rural)
cd "$mydir/0_Macro"
mer 1:1 cyear provcd using "tmp_inc_urban.dta", nogen
ren provcd prov_hanzi

cd "$mydir/0_Macro"
merge m:1 prov_hanzi using "province_codes.dta", nogen

*--- 2 计算人均可支配比值
gen inc_gap = inc_rural / inc_urban 

sor cyear provcd 
label var inc_urban "城镇人均可支配（元）"
label var inc_rural "农村人均可支配（元）"
label var inc_gap "农村/城镇人均可支配"

save 1_IncGap, replace
