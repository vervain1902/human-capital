*------ 3.2.绘制名义 GDP 和 不变价格 GDP 的折线图
foreach i of global $provcd {
       cd "$mydir\0_Macro"
       use 
}
       twoway (line gdp cyear, lcolor(blue) lwidth(medium) lpattern(solid)) ///
              (line gdp_base2010 cyear, lcolor(red) lwidth(medium) lpattern(dash)), ///
              title("名义GDP与2010年不变价格GDP") ///
              legend(order(1 "名义GDP" 2 "2010年不变价格GDP") position(6)) ///
              xlabel(2010(1)2020) ///
              ylabel(, format(%10.0f)) ///
              xtitle("年份") ytitle("GDP")
       cd "$desdir\0_Macro\GDP"
       gr export "11-GDP.png", as(png) replace
