cls
/*==================================================

Proiect: 劳动力人力资本数量、质量与经济增长 - reg ln_gdp ~ peduy0, a_peduy0, pcog0, and lihk0 
Author:  liuziyu
Created Date: 2023.12
Last Edited Date: 2024.11.01

--------------------------------------------------

This script is for:
	1) reading micro income data from CFPS database, 
	2) merge micro income data and [micro cognitive skill], [macro data, 4-fold pop, average cognitive skill], 
	3) generate lihk index， 
	4) describe lihk stock.

==================================================*/

*---0 Program set up
cd "D:\# Library\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do

*---1 import 0-fold pop data with macro vars, pcog0, peduy0, a_peduy0, and lihk0
cd "$mydir\3_LIHK"
use 5_Macro_Pop0_pCog0_aEduy0_Cog_Inc_LIHK0_cog, clear 
duplicates drop cyear provcd, force
xtset provcd cyear 
xtdescribe

*---2 modeling
*------2.1 reg lny peduy0 and covariates [K]
local vars "lny peduy0 K"
xtreg `vars', fe
estimates store model_fe
xtreg `vars', re
estimates store model_re

local vars "lny a_peduy0 K"
xtreg `vars', fe
estimates store model_fe
xtreg `vars', re
estimates store model_re

local vars "lny a_peduy pcog0 K"
xtreg `vars', fe
estimates store model_fe1
xtreg `vars', re
estimates store model_re1

local vars "lny a_peduy0 pcog0 K"
xtreg `vars', fe
estimates store model_fe2
xtreg `vars', re
estimates store model_re2

cd "$desdir\3_LIHK"
esttab model_fe model_re model_fe1 model_re1 model_fe2 model_re2 using "model_results.csv", ///
    cells(b(fmt(3)) se(fmt(3)) p(fmt(3) star)) ///
    stats(N ar2) ///
    title("Panel Regression Results") ///
    replace




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
