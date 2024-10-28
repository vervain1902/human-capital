

*------ 3.3.分省描述LIHK人力资本存量趋势
foreach i in $provcd {
	cd "$mydir\3_LIHK"
	use 2_LIHKGroup2, clear
	keep if provcd == `i'
	twoway line H cyear, xlabel(2010(2)2020) ///
		title("Total LIHK human capital stock of province `i'") ///
		xtitle("Year", size(small)) ///
		ytitle("Total LIHK values", size(small)) ///
		subtitle("2010-2020") note("Method.LIHK") ///
		legend(ring(1) pos(6) cols(6) size(small)) 
	cd "$desdir\3_LIHK"
	gr export "`i'_LIHK.png", as(png) replace
}
