cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 劳动年龄人口认知技能
Subproiect: Cog 
Author:   liuziyu
Create Date: 2023.12
Edit Date:  2024.10.29

--------------------------------------------------

This script is for: 
	1) describing cognitive skill and std_cog, 
	2) describing adjusting beta, 
	3) describing avg edu_year and avg adj_edu_year.

==================================================*/

*---1 describing cognitive skill and std_cog
// 创建一个局部宏，用于存储各年的图形名
forvalues i = 10(2)20 {
    cd "$mydir\2_Cog\worker"
    use cfps`i'_2, replace  // 读取指定年份的数据
    
    // 获取当前文件中的所有省份
    levelsof prov_hanzi, local(provs)
}

	local graphs ""  // 存储每个省份的图形

    // 循环处理每个省份
foreach j of local provs {
	local subgraphs ""  // 每个省份的子图形列表
	forvalues i = 10(2)20 {
		cd "$mydir\2_Cog\worker"
		use cfps`i'_2, replace  // 读取指定年份的数据
	    keep if prov_hanzi == "`j'" // 保留当前省份数据

	    // 绘制密度图	
	    kdensity st_cog, graphregion(color(white)) fcolor(ebg) lcolor(gs8) lwidth(medium) ///
	        title("20`i'年标准化认知技能的密度分布") subtitle("`j'") ytitle("密度", size(small)) ///
	        xtitle("标准化认知技能", size(small)) xscale(titlegap(2)) legend(off) name(Density_cog_`i'_`j', replace)

	        // 保存当前年份的图形
	        local subgraphs "`subgraphs' Density_cog_`i'_`j'"  // 将图形添加到局部图形列表

	        // 导出图形
	        cd "$desdir\2_Cog\worker\认知技能分布\Density"
	        gr export "Density-cog_`i'_`j'.png", replace
	    }

    // 将该省份的图形加入总图形列表
    graph combine `subgraphs', name(Combined_Density_`j', replace) title("`j'省 认知技能密度图 (2010-2020)")

	// 导出组合图
    cd "$desdir\2_Cog\worker\认知技能分布\Density\combined_density"
    gr export "Combined_Density_`j'.png", replace

    // 将该省份的组合图加入总图形列表
    local graphs "`graphs' Combined_Density_`j'"
}

// 将该省份所有年份的图形按行组合
graph combine `subgraphs', rows(2)  // 按行排列图形
gr export "Density_cog_`i'.png", replace  // 导出组合图形

forvalues j = 10(2)20 {
	cd "$mydir\2_Cog\worker"
	use cfps`j'_2, replace  // 保存删除样本的数据
	levelsof prov_hanzi, local(provs)

	foreach i in `provs' {
		local graphs ""
		keep if prov_hanzi == "`i'"		

		// 检查样本量是否为 0
        count
        if r(N) == 0 {
            continue  // 如果样本量为 0，则跳过当前循环
        }  

		// 对 st_cog 变量绘制密度图
		kdensity st_cog, ///
			graphregion(color(white)) fcolor(ebg) lcolor(gs8) lwidth(medium) ///
		    title("20`j'年标准化认知技能的密度分布") subtitle("`i'") ytitle("密度", size(small)) ///
		    xtitle("标准化认知技能", size(small)) xscale(titlegap(2)) ///
		    legend(off) name(Density_cog_`i'_`j', replace)

		local graphs "`graphs' Density_cog_`i'_`j'"  // 添加到图形列表
		// 导出每年的图形
		cd "$desdir\2_Cog\worker\认知技能分布"
		gr export "Density-cog_`i'_`j'.png", replace

	}
	graph combine `graphs', rows(2)  // 调整图形布局，按行排列
	gr export "Density_cog_`i'.png", replace
}

*---2 描述调整系数
cd "$mydir\2_Cog\worker"
use 4_Beta, clear
cd "$mydir\0_Macro"
mer m:1 provcd using 

* 创建一个局部宏用于存储所有省份代码的图形名
local graphs ""
foreach i of global provcd_4 {
    * 为每个省份生成散点图并保存到内存
    quietly {
        preserve  // 保留当前数据的完整状态
        keep if provcd == `i'  // 只保留当前省份的数据
        mscatter a_beta age_group, msymbol(oh) ///
            title("Province `i'") name(Scatter_aBeta_`i', replace)  // 保存在内存
            xlabel(, nogrid) ylabel(, nogrid)  // 去掉每个小图的坐标标签
        local graphs "`graphs' Scatter_aBeta_`i'"  // 将图形名加入组合列表
        restore  // 恢复数据集以供下一个省份使用
    }
}

* 组合所有省份的散点图
graph combine `graphs', rows(6)  // 按两行排列，可以根据需要调整布局
	xlabel(, grid) ylabel(, grid)  // 仅在组合图上显示坐标标签
cd "$desdir\2_Cog\worker\分样本估计"
gr export "Scatter-aBeta_Combined.png", replace

*--- 4.描述平均受教育年限调整值
// 二分人口平均教育年限调整值
/* foreach i in $provcd_4 {
	cd "$mydir\2_Cog\worker"
	use 6_Macro_Pop2_aEduy, clear
	keep if provcd == `i'
	twoway line a_peduy2 cyear, by(urban gender) xlabel(2010(2)2020) ///
		title("Adjusted Average education year of province `i'") ///
		xtitle("Year", size(small)) ///
		ytitle("Adjusted Average Education Year", size(small)) ///
		subtitle("2010-2020") ///
		legend(ring(1) pos(6) cols(6) size(small)) 
	cd "$desdir\1_Pop\worker\peduy2_beta"
	gr export "Line-aPeduy2-`i'.png", as(png) replace
} */

// 总人口平均教育年限调整值
foreach i in $provcd_4 {
	cd "$mydir\2_Cog\worker"
	use 7_Macro_Pop0_aEduy_Cog, clear
	duplicates drop cyear provcd, force
	keep if provcd == `i'
	twoway (line a_peduy0 cyear) (line peduy0 cyear), ///
		xlabel(2010(2)2020) ///
		title("劳动年龄人口平均受教育年限原始值与调整值 ") ///
		subtitle("`i'") ///
		xtitle("Year", size(small)) ///
		ytitle("平均受教育年限", size(small)) ///
		legend(ring(1) pos(6) cols(6) size(small)) 
	cd "$desdir\1_Pop\worker\peduy0_beta"
	gr export "Line-aPeduy0-`i'.png", as(png) replace
}


