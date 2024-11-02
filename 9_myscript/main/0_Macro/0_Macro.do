cls

/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - Macro Data
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.10.28

--------------------------------------------------

This script is for: 
	1) generate dependent vars, 
	2) generate average urban and rural wage,
	3) generate covariates, 
	4) merge all macro vars, 
	5) gen secondary covariates.

Data source: 
	1) macro data from CHLR, 
	2) macro data from Chinese Yearbook

==================================================*/

*---0 Program set up
cd "D:\# Library\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do
 
*---1 generate dependent vars: 2010_based GDP, average GDP, work_aged average gdp, urban_rural income gap and Palma index
cd "$scriptdir\function\generate"
do gen_gdp.do
cd "$scriptdir\function\generate"
do gen_palma.do
cd "$scriptdir\function\generate"
do gen_income_gap.do

*---2 generate average urban and rural wage 
cd "$scriptdir\function\generate"
do gen_pwage.do

*---3 generate covariates: 
*		K, pop, urbanization_ratio, third_indus_ratio, gov_invest, import and export trade
cd "$scriptdir\function\generate"
do gen_covariates.do

*---4 merge all macro vars
cd "$mydir\0_Macro"
use tmp_gdp, clear 
local files tmp_tpop_indus tmp_pwage tmp_K tmp_invest tmp_im_export
foreach file in `files' {
    merge 1:1 cyear provcd using `file'.dta
    drop _merge 
}

keep if inlist(cyear, 2010, 2012, 2014, 2016, 2018, 2020)

gen gov = invest/gdp
gen trade = im_export_rmb/gdp
gen pgdp_w = gdp_base2010 * 10000 / wpop 
gen pgdp_t = gdp_base2010 * 10000 / tpop 
label var gov "budget/gdp"
label var trade "imports and exports/gdp"
label var pgdp_t "GDP per capita (10,000 RMB)"
label var pgdp_w "GDP per labor (10,000 RMB)"
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
