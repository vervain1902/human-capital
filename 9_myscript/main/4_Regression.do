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

replace K = K / 10000
label var K "material capital (billion yuan)"
/* replace wpop = wpop / 10000
label var wpop "size of labor pop (10,000)"
replace tpop = tpop / 10000
label var tpop "size of total pop (10,000)" */

estpost summarize lny tpop wpop K lihk0 peduy0 a_peduy0 pcog0

*---2 modeling
*------2.1 reg lny peduy0 pcog0 and covariates [K]
local vars "lny peduy0 wpop K"
eststo fe0: xtreg `vars', fe
eststo re0: xtreg `vars', re

local vars "lny peduy0 pcog0 wpop K"
eststo fe1: xtreg `vars', fe
eststo re1: xtreg `vars', re

local vars "lny a_peduy0 wpop K"
eststo fe2: xtreg `vars', fe
eststo re2: xtreg `vars', re

local vars "lny a_peduy0 pcog0 wpop K"
eststo fe3: xtreg `vars', fe
eststo re3: xtreg `vars', re

cd "$outdir"
esttab *0 *1 *2 *3 using model_results_eduy_cog.csv, ///
	star b(%9.3f) ar2(%9.3f) p(%9.3f) obslast pa nogap compress mtitle replace

*------2.2 reg lny peduy0 pcog0 and covariates [K]
local vars "lny lihk0 K"
eststo m41: xtreg `vars', fe
eststo m42: xtreg `vars', re

cd "$outdir"
esttab m4* using model_results_lihk.csv, ///
	b(%9.3f) ar2(%9.3f) p(%9.3f) pa obslast star nogap compress replace
