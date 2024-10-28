cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 劳动年龄人口认知技能
Subproiect: Cog 
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.10.28

--------------------------------------------------

This script is for: 
	1) generating micro cognitive skill data, 
		standardizing cog by year across all provinces, 
		generating avg_cog of 4-fold and 0-fold pop, 
	2) generating adjusted edu_year, 
		estimating adj_betas and standardizing them based on first age group, 
		merging standardized adjusting betas and 3-fold pop (with avg edu_year) to 
			calculate adjusted avg edu_year, 
		generating 2-fold pop and 0-fold pop (with adjusted avg edu_year) by 
			summarizing 3-fold pop (with avg edu_year and adjusted avg edu_year),

Data source:
	1) micro cognitive skills from CFPS 2010-2020, 
	2) 3-fold pop from 1_Pop_worker.do

更新：
	- 估计方式：分样本/交乘项
	- 回归思路：不分年度，分省的总体教育年限对认知回归
	- 增加认知比例的估计
		- 比例指标
	- 学生样本的认知，调整受教育年限，对经济增长的贡献
		- 比较调整前后的变化
		- 梳理基于微观调查数据的认知

==================================================*/

*---0 Program set up
cd "D:\# Library\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do

*---1 read micro cog data 
cd "$funcdir\read"
do read_cog.do // 运行从cfps读取认知技能的脚本

*---2 generate std micro cog data, clean data and construct secodary vars
cd "$funcdir\generate"
do gen_cog.do

*---3 generate 4-fold and 0-fold pop with std avg_cog
cd "$funcdir\generate"
do gen_pcog.do

*---4 generate 构建平均受教育年限调整值
cd "$funcdir\generate"
do gen_adjusted_eduy.do

*---5 describe distribution of avg std_cog of 0-fold pop, avg edu_year and avg adjusted edu_year 
cd "$funcdir\describe"
do des_cog.do


