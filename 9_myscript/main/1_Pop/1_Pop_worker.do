cls
/*==================================================

Proiect:		劳动力人力资本数量、质量与经济增长 - 劳动年龄人口
Author:			liuziyu
Create Date:	2023.12
Edit Date:		2024.10.13

--------------------------------------------------

This script is for
	- 生成4分人口（分城乡、性别、年龄、受教育年限）长数据
	- 生成2分人口（分城乡）长数据
	- 计算4分人口
	- 计算4分人口总数
	- 计算4分人口平均受教育年限

Note:数据来源
	CFPS 2010-2020
	CHLR 2010-2020
	Yearbook 2010-2020

==================================================*/

*--- 0.清空内存，定义路径
cd "D:\Library\OneDrive\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do

*--- 1.使用CHLR估算数据【2023-劳动年龄人口-四分】，生成分省份、分年度的四分人口长数据
cd "$scriptdir\function\generate"
do gen_pop4.do 

*--- 2.基于四分人口数据，计算三分人口、二分人口、一分人口
cd "$scriptdir\function\generate"
do gen_pop321.do

*--- 5.链接三分人口长数据与宏观数据
cd "$mydir\1_Pop\worker"
use 2_Pop3, clear 
cd "$mydir\0_Macro"
mer m:1 cyear provcd using 1_Macro, nogen 
cd "$mydir\1_Pop\worker"
save 6_Macro_Pop3, replace

*------ 5.2.链接四分人口长数据与宏观数据
cd "$mydir\1_Pop\worker"
use 1_Pop4, clear 
cd "$mydir\0_Macro"
mer m:1 cyear provcd using 1_Macro, nogen 
duplicates drop cyear provcd urban gender age sch, force 
gen eduy = sch
cd "$mydir\1_Pop\worker"
save 7_Macro_Pop4, replace
