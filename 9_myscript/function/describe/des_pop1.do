*---1 描述历年各省分城乡的一分人口、人均受教育年限变化趋势
// 除上海
foreach i in $provcds {
	foreach j in 0 1 {
		cd "$mydir\1_Pop\worker"
		use 4_Pop1_Urban, clear
		keep if provcd == `i' & urban == `j'
		foreach k in pop1_ur peduy1_ur {
			twoway line `k' cyear, xlabel(2010(2)2020) ///
				title("`k' of province `i' and urban `j'") ///
				xtitle("Year", size(small)) ///
				ytitle("`k'", size(small)) ///
				subtitle("2010-2020") note("Data source: CHLR 2023") ///
				legend(ring(1) pos(6) cols(6) size(small)) 
			cd "$desdir\1_Pop\worker/`k'"
			gr export "Line-`i'_`j'_`k'.png", as(png) replace
		}
	}
}

// 描述历年各省分性别的一分人口、人均受教育年限变化趋势
foreach i in $provcds {
	foreach j in 0 1 {
		cd "$mydir\1_Pop\worker"
		use 4_Pop1_Gender, clear
		keep if provcd == `i' & gender == `j'
		foreach k in pop1_ge peduy1_ge {
			twoway line `k' cyear, xlabel(2010(2)2020) ///
				title("`k' of province `i' and gender `j'") ///
				xtitle("Year", size(small)) ///
				ytitle("`k'", size(small)) ///
				subtitle("2010-2020") note("Data source: CHLR 2023") ///
				legend(ring(1) pos(6) cols(6) size(small)) 
			cd "$desdir\1_Pop\worker/`k'"
			gr export "Line-`i'_`j'_`k'.png", as(png) replace
		}
	}
}

// 描述历年各省劳动年龄人口、人均受教育年限变化趋势
foreach i in $provcds {
	cd "$mydir\1_Pop\worker"
	use 5_Pop0, clear
	keep if provcd == `i'
	foreach j in pop0 peduy0 {
		twoway line `j' cyear, xlabel(2010(2)2020) ///
			title("`j' of province `i'") ///
			xtitle("Year", size(small)) ///
			ytitle("`j'", size(small)) ///
			subtitle("2010-2020") note("Data source: CHLR 2023") ///
			legend(ring(1) pos(6) cols(6) size(small)) 
		cd "$desdir\1_Pop\worker/`j'"
		gr export "Line-`i'_`j'.png", as(png) replace
	}
}
