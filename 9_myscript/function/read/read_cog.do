cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 劳动年龄人口认知技能
Subproiect: Cog 
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.10.13

--------------------------------------------------

This script is for: 
	- 读取cfps认知技能数据
	- 保存为dta文件

==================================================*/

*---1 2012、2016、2020年：数列测试、字词记忆测试
// 2020年
cd "$rawdir\2010-2020-CFPS"
use cfps2020person_202306, clear
local vars "provcd20 urban20 cfps2020eduy_im ns_w"
keep pid cyear gender age iwr dwr `vars'
rename (`vars') (provcd urban eduy ns)
cd "$mydir\2_Cog\worker"
save cfps20_0, replace

// 2016年
cd "$rawdir\2010-2020-CFPS"
use cfps2016adult_201906, clear
replace cyear = 2016
local vars "provcd16 cfps_gender cfps_age urban16 cfps2016eduy_im ns_w"
keep pid cyear iwr dwr `vars'
rename (`vars') (provcd gender age urban eduy ns)
cd "$mydir\2_Cog\worker"
save cfps16_0, replace 

// 2012年
cd "$rawdir\2010-2020-CFPS"
use cfps2012adult_201906, clear
replace cyear = 2012
local vars "cfps2012_gender_best cfps2012_age urban12 eduy2012 ns_w"
keep pid cyear provcd iwr dwr `vars'
rename (`vars') (gender age urban eduy ns)
cd "$mydir\2_Cog\worker"
save cfps12_0, replace

*---2 2010、2014、2018年：字词测试、数学测试
// 2018年
cd "$rawdir\2010-2020-CFPS"
use cfps2018person_202012, clear
local vars "provcd18 urban18 cfps2018eduy_im mathtest18 wordtest18"
keep pid cyear gender age `vars'
replace cyear = 2018
rename (`vars') (provcd urban eduy math word)
cd "$mydir\2_Cog\worker"
save cfps18_0, replace 

// 2014年
cd "$rawdir\2010-2020-CFPS"
use cfps2014adult_201906, clear
replace cyear = 2014
local vars "provcd14 cfps_gender cfps2014_age urban14 cfps2014eduy_im mathtest14 wordtest14"
keep pid cyear `vars'	 
rename (`vars') (provcd gender age urban eduy math word)
cd "$mydir\2_Cog\worker"
save cfps14_0, replace 

// 2010年
cd "$rawdir\2010-2020-CFPS"	
use cfps2010adult_201906, clear
replace cyear = 2010
local vars "qa1age cfps2010eduy_best mathtest wordtest"
keep pid cyear provcd gender urban mathtest wordtest `vars'
rename (`vars') (age eduy math word)
cd "$mydir\2_Cog\worker"
save cfps10_0, replace
