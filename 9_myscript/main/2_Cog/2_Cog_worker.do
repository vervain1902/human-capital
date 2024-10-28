cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 劳动年龄人口认知技能
Subproiect: Cog 
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.10.13

--------------------------------------------------

This script is for: 
	- 计算认知技能
		- 分年度在全国标准化
		- 计算三分人口、二分人口的平均认知技能
	- 调整受教育年限
		- 估算调整系数，并以第一个年龄组为基准标准化
		- 链接调整系数与三分人口的受教育年限数据，计算调整值
		- 合并得到二分人口、总人口的调整值

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

*---0 清空内存，定义路径
cd "D:\Library\OneDrive\1 Seminar\1_Publishs\1031-认知技能\data\9_myscript"
do config.do

*---1 读取、计算认知技能原始值
cd "$funcdir\read"
do read_cog.do // 运行从cfps读取认知技能的脚本

*---2 构建认知技能
// 运行数据清洗脚本：计算认知技能指标、生成年龄平方项、转换受教育年限分类变量、
// 保留劳动年龄人口、删除缺失值、删除年龄组样本量不足的省份
cd "$funcdir\generate"
do gen_cog.do

*---3 构建认知技能均值
// 计算四分人口、三分人口、总人口认知技能均值
cd "$funcdir\generate"
do gen_pcog.do

*---4 构建平均受教育年限调整值
cd "$funcdir\generate"
do gen_adjusted_eduy.do

*---4 描述
// 描述总人口认知技能密度分布、描述平均受教育年限原始值与调整值
cd "$funcdir\describe"
do des_cog.do

// 链接四分人口、宏观数据与认知技能
cd "$mydir\2_Cog\worker"
use 2_Cog4, clear
cd "$mydir\1_Pop\worker"
mer 1:1 cyear provcd urban gender age sch using 7_Macro_Pop4, nogen
duplicates drop cyear provcd urban gender age sch, force 
cd "$mydir\2_Cog\worker"
save 9_Macro_Pop4_Cog4, replace

// 链接三分人口的平均认知技能、受教育年限调整值和人口数、宏观数据
cd "$mydir\2_Cog\worker"
use 3_Cog3, clear 
mer 1:1 cyear provcd gender urban age using 5_Macro_Pop3_aEduy, nogen 

// 定义东、中、西部
gen region = 1
replace region = 3 if provcd == 15 | provcd == 45 | provcd == 50 | provcd == 51 | provcd == 52 | provcd == 53 | provcd == 54 | ///
	provcd == 61 | provcd == 62 | provcd == 63 | provcd == 64 | provcd == 65 
replace region = 2 if provcd == 14 | provcd == 22 | provcd == 23 | provcd == 34 | provcd == 36 | provcd == 41 | provcd == 42 | ///
	provcd == 43 
label define region 1 "east" 2 "center" 3 "west"
label value region region
label var region "区域"

save 8_Macro_Pop3_aEduy_Cog3, replace

