cls
/*==================================================

Proiect:  human capital
Subproiect: Cog 
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.6.25

--------------------------------------------------

This script is for: 
	1. 基于CFPS数据，计算认知技能、认知技能人口比例
	2. 基于CFPS数据，计算受教育年限调整系数
	3. 基于CHLR数据，根据认知技能，计算四分人口组的平均认知技能
	4. 基于CHLR数据，根据调整系数对不同年龄组的受教育年限进行调整，加总得到四分人口组的总受教育年限
	5. 基于CHLR数据，计算四分人口组的平均受教育年限

Note: database used 
	CFPS 2010-2020
	CHLR 2010-2020
	Yearbook 2010-2020

更新：
	- 估计方式：分样本/交乘项
	- 回归思路：不分年度，分省的总体教育年限对认知回归
	- 增加认知比例的估计
		- 比例指标
	- 学生样本的认知，调整受教育年限，对经济增长的贡献
		- 比较调整前后的变化
		- 梳理基于微观调查数据的认知

==================================================*/

*--- 0.清空内存，定义路径
clear all

global dir "D:\Library\OneDrive\1 Seminar\1_Publishs\1031-认知技能\data"
	global mydir	"$dir\1_mydata"
	global rawdir	"$dir\0_rawdata"
	global desdir "$dir\2_description"
	global outdir "$dir\3_output"

global provcds_ "11 12 13 14 15 21 22 23 32 33 34 35 36 37 41 42 43 44 45 46 50 51 52 53 54 61 62 63 64 65"

set scheme plotplain, perm

mkdir "$desdir\2_Cog\beta_X"
mkdir "$desdir\4_Eduy\4-省份\beta_X"

*------ 2.2.不分年度，使用交乘项回归
cd "$mydir\2_Cog"
use 1_Cog, clear
di("--------- Estimate beta values of `i'. -----------")
eststo m_beta: reg cog i.provcd#i.age_group#c.eduy age age2 i.gender

cd "$mydir\2_Cog"
esttab m_beta using beta_X.csv, ///
	keep(*eduy) nonumbers not noobs nostar compress replace

*------ 2.3: 读取系数数据，转换为以年龄组1为基准的相对系数
*--------- 2.3.1: 读取系数数据，宽数据转长数据
import delimited using beta_X.csv, varnames(1) stripquote(yes) clear

// 使用 substr() 函数截取字符串的前三个字符
gen provcd = substr(v1, 2, 2)
gen age_group = substr(v1, 12, 1)
gen beta = substr(cog, 2, 5)
drop v1 cog

destring age_group provcd beta, replace
bys provcd: egen base = total(beta * (age_group == 1)) 
gen a_beta = beta / base
label var a_beta "受教育年限调整系数"

order provcd age_group a_beta
sor provcd age_group

cd "$mydir\2_Cog"
save 2_Beta_X, replace

*--------- 2.2.2: 作图描述调整系数
cd "$mydir\2_Cog"
use 2_Beta_X, clear
mscatter a_beta age_group, by(provcd, legend(off))
cd "$desdir\2_Cog\beta_X"
gr export "Scatter-a_beta_X.png", width(2400) replace

*--- 3.计算受教育年限调整值
*------ 3.1.链接受教育年限调整系数与四分人口
cd "$mydir\1_Pop"
use 1_Pop4, clear
cd "$mydir\2_Cog"
merge m:1 provcd age_group using 2_Beta_X, keep(match) keepusing(a_beta) nogen

*------ 3.2.计算调整后的平均受教育年限
gen a_aveduy4 = aveduy4 * a_beta // 调整后的四分人口平均受教育年限
gen a_eduy4 = eduy4 * a_beta // 调整后的四分人口受教育年限
bys cyear provcd: egen a_eduy0 = total(a_eduy4) // 调整后的总人口受教育年限
bys cyear provcd: egen pop0 = total(pop4) // 总人口
gen a_aveduy0 = a_eduy0 / pop0 // 调整后的总人口平均受教育年限
label var a_aveduy4 "四分人口平均受教育年限调整值"
label var a_eduy4 "四分人口受教育年限调整值"
label var pop0 "总人口数"
label var a_eduy0 "总人口受教育年限调整值"
label var a_aveduy0 "总人口平均受教育年限调整值"

local vars "cyear provcd urban gender age pop4 a_eduy4 a_aveduy4 pop0 a_eduy0 a_aveduy0 age_group"
keep `vars'
sor `vars'
order `vars'

save 3_Cog4_X, replace // 保存四分人口平均受教育年限调整值

*--- 4.描述平均受教育年限调整值
// 总人口平均教育年限调整值
foreach i in $provcds_ 31 {
	cd "$mydir\2_Cog"
	use 3_Cog4_X, clear
	duplicates drop cyear provcd, force
	keep if provcd == `i'
	twoway line a_aveduy0 cyear, xlabel(2010(2)2020) ///
		title("Education year of province `i'") ///
		xtitle("Year", size(small)) ///
		ytitle("Education Year", size(small)) ///
		subtitle("2010-2020") note("Data source: CHLR 2023") ///
		legend(ring(1) pos(6) cols(6) size(small)) 
	cd "$desdir\4_Eduy\4-省份\beta_X"
	gr export "Line-a_aveduy-`i'_X.png", as(png) replace
}
