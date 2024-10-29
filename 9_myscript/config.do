cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - Config
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.10.28

------
This script is for:
	defining 1) working paths, 2) province codes and 3) plot style.

==================================================*/

clear all

*--- 1 define working paths
global dir "D:/# Library/1 Seminar/1_Publishs/1031-认知技能/data"
	global rawdir "$dir/0_rawdata"
		global wpopdir "$rawdir/1985-2021-劳动年龄人口-四分"
		global macrodir "$rawdir/宏观数据"
	global mydir "$dir/1_mydata"
	global desdir "$dir/2_description"
	global scriptdir "$dir/9_myscript"
		global funcdir "$scriptdir/function"

*--- 2 define province codes 
global provcd "11 12 13 14 15 21 22 23 31 32 33 34 35 36 37 41 42 43 44 45 46 50 51 52 53 54 61 62 63 64 65"
global provcds_ "11 12 13 14 15 21 22 23 32 33 34 35 36 37 41 42 43 44 45 46 50 51 52 53 54 61 62 63 64 65"

// define provinces whose number of age groups is more than 4
global provcd_4 "11 12 13 14 21 22 23 31 32 33 34 35 36 37 41 42 43 44 45 50 51 52 53 61 62"
global prov_4_pinyin "beijing tianjin hebei shanxi liaoning jilin heilongjiang shanghai jiangsu zhejiang anhui fujian jiangxi shandong henan hubei hunan guangdong guangxi chongqing sichuan guizhou yunnan xizang shanxi"
global prov_4_hanzi "北京 天津 河北 山西 辽宁 吉林 黑龙江 上海 江苏 浙江 安徽 福建 江西 山东 河南 湖北 湖南 广东 广西 重庆 四川 贵州 云南 西藏 陕西"

*--- 3 set plot style
set scheme plotplain, perm
