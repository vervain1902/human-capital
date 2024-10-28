cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 估计回归方程
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.10.28

--------------------------------------------------

This script is for: 
	- 估计人力资本对经济增长的贡献
		- 数量指标：平均受教育年限/调整值
		- 质量指标：认知技能、LIHK方法测算的人力资本

- 更新：
		- 北京LIHK样本量不足的问题
		- 6年LIHK部分省份缺失的问题
		- 回归部分

Note: database used 
	CFPS 2010-2020
	CHLR 2010-2020
	Yearbook 2010-2020

==================================================*/

*--- 0.清空内存，定义路径
cd "D:\# Library\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do

*--- 1.读取宏观、三分人口、平均受教育年限、认知技能数据
cd "$mydir\2_Cog\worker"
use 7_Macro_Pop0_aEduy_Cog, clear
drop if provcd == 0
xtset provcd cyear

gen lpcog0 = ln(pcog0)
gen la_peduy0 = ln(a_peduy0)

egen st_pcog0 = std(pcog0)
egen st_a_peduy0 = std(a_peduy0)

egen st_lpcog0 = std(lpcog0)
egen st_la_peduy0 = std(la_peduy0)
egen st_lnty = std(lnty)

*--- 2. 建模
*------ 2.1.平均受教育年限、平均受教育年限的调整值
// 基准回归
/* eststo m11: areg lnty peduy0, absorb(provcd) beta 
eststo m12: areg lnty a_peduy0, absorb(provcd) beta 
eststo m23: areg lnty pcog0, absorb(provcd) beta 
eststo m31: areg lnty pcog0 peduy0, absorb(provcd) beta  */
/* eststo m31: xtreg st_lnty st_pcog0 st_a_peduy0, fe
eststo m32: xtreg st_lnty st_pcog0 st_a_peduy0
eststo m33: xtreg st_lnty st_lpcog0 st_la_peduy0, fe
eststo m34: xtreg st_lnty st_lpcog0 st_la_peduy0 */

/* eststo m35: xtreg st_lnty lpcog0 la_peduy0, fe
eststo m36: xtreg st_lnty lpcog0 la_peduy0 */
cd "$outdir\4_Reg"
esttab /* m1* m2* */ m3* using reg2.csv, ar2 t p pa replace

// 加入控制变量：劳动力人口数、滞后GDP、产业结构、外贸依存度、政府支持、城镇化率
local vars "ratio"
eststo m21: reg lnty peduy0 `vars', r
eststo m22: reg lnty a_peduy0 `vars', r

cd "$outdir\4_Reg"
esttab m1* m2* m3* using reg_peduy_dy.csv, ar2 t p pa replace
esttab m1* m3* using reg_peduy_08y.csv, ar2 t p pa replace

// 加入产业结构
local vars "ratio gov"
eststo m21: reg lnty peduy0 `vars', r
eststo m22: reg lnty a_peduy0 `vars', r

eststo m31: reg lnty peduy0 `vars'
eststo m32: reg lnty a_peduy0 `vars'

cd "$outdir\4_Reg"
esttab m1* m2* using reg_peduy_dy1.csv, ar2 t p pa replace
esttab m1* m3* using reg_peduy_08y.csv, ar2 t p pa replace

*------ 2.2.平均受教育年限、平均受教育年限的调整值+劳动力认知技能
// 基准回归
eststo d11: reg lnty pcog peduy0, r
eststo d12: reg lnty pcog a_peduy0, r



// 加入控制变量：劳动力人口数、滞后GDP、产业结构、外贸依存度、政府支持、城镇化率
local vars "ratio"
eststo d21: reg lnty pcog peduy0 `vars', r
eststo d22: reg lnty pcog a_peduy0 `vars', r

// eststo d31: reg lnty pcog peduy0 `vars'
// eststo d32: reg lnty pcog a_peduy0 `vars'

cd "$outdir\4_Reg"
esttab d1* d2* using reg_peduy_pcog_dy.csv, ar2 t p pa replace
// esttab d1* d3* using reg_peduy_pcog_08y.csv, ar2 t p pa replace

*------ 2.3.
** full model
eststo fm0: reg lnty pcog lnH a_peduy0
eststo fm1: reg lnty pcog lnH a_peduy0 ln08wy lnwl
eststo fm2: reg lnty pcog lnH a_peduy0 lndwy lnwl
eststo fm00: reg lnty pcog lnH peduy0
eststo fm10: reg lnty pcog lnH peduy0 ln08wy lnwl
eststo fm20: reg lnty pcog lnH peduy0 lndwy lnwl
esttab f* using reg_fullvar.csv, ar2 t p pa replace
** robust test
