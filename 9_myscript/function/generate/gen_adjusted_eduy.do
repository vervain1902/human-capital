cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 计算受教育年限调整值
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.8.20

==================================================*/

*------ 3.1.估计受教育年限对认知技能的系数（不分年度，不同省份分样本回归）
cd "$mydir\2_Cog\worker"
use 1_Cog, clear
forval i = 1/4 {
	gen eduy`i' = 0
	replace eduy`i' = eduy if age_group == `i' 
}

forval i = 1/4 {
	foreach j in $provcd_4 {
		eststo m_beta`j': qui reg st_cog eduy`i' age age2 i.gender i.urban if age_group == `i' & provcd == `j'
	}

	esttab m_beta* using beta`i'.csv, ///
	 	keep(eduy`i') nonumbers not nostar noobs compress replace
}

forval i = 1/4 {
	import delimited using beta`i'.csv, varnames(1) stripquote(yes) clear
	gather st_cog-v26, value(beta_m)
	replace beta_m = subinstr(beta_m, "=", "", .)
	gen age_group = `i'
	drop v1
	destring(beta_m), replace
	gen provcd = .
	// 替换省份编号
	local vars "st_cog v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26"
	
	local j = 1
	foreach var of local vars {
	    local code: word `j' of $provcd_4
	    capture replace provcd = `code' if variable == "`var'"
	    if _rc != 0 {
	        di "No match found for variable: `var'"
	    }
	    local j = `j' + 1
	}

	drop variable
	order provcd age_group 
	save beta`i', replace
}

forval i = 1/3 {
	ap using beta`i'
	erase beta`i'.dta
	erase beta`i'.csv
}

bys provcd: egen base = total(beta_m * (age_group == 1)) 
gen a_beta = beta_m / base
label var a_beta "受教育年限调整系数"

order provcd age_group a_beta
sor provcd age_group

save 4_Beta, replace
erase beta4.dta
erase beta4.csv

// 链接受教育年限调整系数与分城乡、性别和年龄的三分人口（含宏观数据）
cd "$mydir\1_Pop\worker"
use 6_Macro_Pop3, clear
cd "$mydir\2_Cog\worker"
merge m:1 provcd age_group using 4_Beta, keep(match) nogen
gen a_peduy3 = peduy3 * a_beta // 调整后的三分人口平均受教育年限
local vars "cyear provcd urban gender age age_group a_peduy3 peduy3" 
order `vars'
sor `vars' 
label var a_peduy3 "三分人口人均受教育年限调整值"
cd "$mydir\2_Cog\worker"
save 5_Macro_Pop3_aEduy, replace

// 计算调整后的平均受教育年限二分人口数据
cd "$mydir\2_Cog\worker"
use 5_Macro_Pop3_aEduy, clear 
gen a_eduy3 = eduy3 * a_beta // 调整后的三分人口总受教育年限
local vars "cyear provcd urban gender"
bys `vars': egen a_eduy2 = total(a_eduy3) // 调整后的总人口受教育年限
bys `vars': egen pop2 = total(pop3) // 总人口
gen a_peduy2 = a_eduy2 / pop2 // 调整后的总人口平均受教育年限
duplicates drop `vars', force
drop *3
label var a_peduy2 "二分人口平均受教育年限调整值"
label var a_eduy2 "二分人口受教育年限调整值"
label var pop2 "二分人口数"
cd "$mydir\2_Cog\worker"
save 6_Macro_Pop2_aEduy, replace // 保存二分人口平均受教育年限调整值

// 计算调整后的平均受教育年限总人口数据
cd "$mydir\2_Cog\worker"
use 5_Macro_Pop3_aEduy, clear 
gen a_eduy3 = eduy3 * a_beta // 调整后的三分人口总受教育年限
local vars "cyear provcd"
bys `vars': egen a_eduy0 = total(a_eduy3) // 调整后的总人口受教育年限
bys `vars': egen pop0 = total(pop3) // 总人口
gen a_peduy0 = a_eduy0 / pop0 // 调整后的总人口平均受教育年限
duplicates drop `vars', force
drop *3 urban gender age age_group
label var a_peduy0 "劳动年龄人口平均受教育年限调整值"
label var a_eduy0 "劳动年龄人口受教育年限调整值"
label var pop0 "总人口数"
cd "$mydir\2_Cog\worker"
save 7_Macro_Pop0_aEduy, replace // 保存总人口平均受教育年限调整值

mer 1:1 cyear provcd using 4_Cog0, nogen
cd "$mydir\1_Pop\worker"
mer 1:1 cyear provcd using 5_Pop0, nogen

cd "$mydir\2_Cog\worker"
save 7_Macro_Pop0_aEduy_Cog, replace // 保存总人口平均受教育年限调整值
