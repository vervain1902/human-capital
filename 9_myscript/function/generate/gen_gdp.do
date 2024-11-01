cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 计算受教育年限调整值
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.8.20

==================================================*/

*---1 读取原始数据
cd "$rawdir\宏观数据"
import excel "2010-2020-GDP-指数.xlsx", sh("GDP") firstrow clear 
gather a11-a65, variable(provcd) value(gdp)
gen provcd_new = real(substr(provcd, 2, 2))
drop provcd 
ren provcd_new provcd
destring(cyear), replace
label var gdp "nominal gdp (billion RMB)"
cd "$mydir\0_Macro"
save tmp_gdp, replace

cd "$rawdir\宏观数据"
import excel "2010-2020-GDP-指数.xlsx", sh("GDP指数") firstrow clear 
gather a11-a65, variable(provcd) value(idx_gdp)
gen provcd_new = real(substr(provcd, 2, 2))
drop provcd 
ren provcd_new provcd
destring(cyear), replace
label var idx_gdp "gdp idx (last year=100)"
cd "$mydir\0_Macro"
save tmp_idx_gdp, replace

mer 1:1 cyear provcd using tmp_gdp, nogen 
gen idx_gdp_base2010 = .
bys provcd(cyear): replace idx_gdp_base2010 = 100 if cyear == 2010
bys provcd(cyear): replace idx_gdp_base2010 = idx_gdp_base2010[_n-1] * (idx_gdp / 100) if cyear > 2010
gen gdp_base2010 = (gdp / idx_gdp_base2010) * 100
gen lny = ln(gdp_base2010)
label var lny "log 2010-based gdp (billion RMB)"
label var gdp_base2010 "2010 based gdp (billion RMB)"
order cyear provcd gdp_base2010 gdp 
save tmp_gdp, replace

erase tmp_idx_gdp.dta
