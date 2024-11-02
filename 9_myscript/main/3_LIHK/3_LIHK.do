cls
/*==================================================

Proiect: 劳动力人力资本数量、质量与经济增长 - 劳动力收入法测算人力资本
Author:  liuziyu
Created Date: 2023.12
Last Edited Date: 2024.11.02

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

*---1 read micro income data of all years from CFPS database
cd "$funcdir\read"
do read_income.do

*---2 merge micro income data and [micro cognitive skill], [macro data, 4-fold pop, average cognitive skill], to generate intercept term
cd "$funcdir\generate"
do gen_income.do

*---3 generate lihk index
cd "$funcdir\generate"
do gen_lihk_nocog.do 

cd "$funcdir\generate"
do gen_lihk_cog.do 


