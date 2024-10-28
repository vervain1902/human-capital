cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 读取平均工资
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.10.28

==================================================*/

*---1 使用CHLR 2010-2020 数据，保存城镇和农村人均工资
foreach i in ruavwage uravwage {
    cd "$rawdir\宏观数据"
    use 1985-2021_macrodata, clear // 来源：CHLR整理的宏观数据集
	keep if wave == 2010 | wave == 2012 | wave == 2014 | ///
		wave == 2016 | wave == 2018 | wave == 2020
	keep wave *`i'
	rename wave cyear
	gather *`i', variable(provcd) value(`i') 
	replace provcd = substr(provcd, 2, 2)
	destring provcd, replace
	cd "$mydir\0_Macro"
	save `i', replace
}

merge 1:1 provcd cyear using ruavwage, nogen
drop if provcd == 0 
label var uravwage "城镇平均工资元/年"
label var ruavwage "农村平均工资元/年"
cd "$mydir\0_Macro"
save tmp_pwage, replace
erase ruavwage.dta
erase uravwage.dta
