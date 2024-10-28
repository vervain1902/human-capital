* ----------2.1: 分样本回归

 clear all

 foreach j in cfps10 cfps14 cfps18 {
 	use `j', clear
 	gen agroup1 = (age>=15&age<=24)
 	gen agroup2 = (age>=25&age<=34)
 	gen agroup3 = (age>=35&age<=44)
 	gen agroup4 = (age>=45&age<=54)
 	gen agroup5 = (age>=55&age<=64)
 	gen eduy1 = eduy*agroup1
 	gen eduy2 = eduy*agroup2
 	gen eduy3 = eduy*agroup3
 	gen eduy4 = eduy*agroup4
 	gen eduy5 = eduy*agroup5
	
 	gen age2 = age^2
 	gen cog = (st_math+st_word)/2
	
 	egen group = group(provcd)
 	sum group
 	forval i = 1/`r(max)'{
 		年龄组1
 		qui reg cog eduy1 age age2 i.gender if group==`i'
 		mat tmp = r(table) 储存结果的矩阵
 		scalar b1 = tmp[1,1] edu的系数
 		scalar p1 = tmp[4,1] edu的p-value
 		年龄组2
 		qui reg cog eduy2 age age2 i.gender if group==`i'
 		mat tmp = r(table)
 		scalar b2 = tmp[1,1]
 		scalar p2 = tmp[4,1]
 		年龄组3
 		qui reg cog eduy3 age age2 i.gender if group==`i'
 		mat tmp = r(table)
 		scalar b3 = tmp[1,1]
 		scalar p3 = tmp[4,1]
 		年龄组4
 		qui reg cog eduy4 age age2 i.gender if group==`i'
 		mat tmp = r(table)
 		scalar b4 = tmp[1,1]
 		scalar p4 = tmp[4,1]
 		年龄组5
 		qui reg cog eduy5 age age2 i.gender if group==`i'
 		mat tmp = r(table)
 		scalar b5 = tmp[1,1]
 		scalar p5 = tmp[4,1]
 		di `i' " " b1 " " p1 " " b2 " " p2 " " b3 " " p3 " " b4 " " p4 " " b5 " " p5
 	}
 }

 clear
 foreach j in cfps12 cfps16 cfps20 {
 	use `j', clear
 	gen agroup1 = (age>=15&age<=24)
 	gen agroup2 = (age>=25&age<=34)
 	gen agroup3 = (age>=35&age<=44)
 	gen agroup4 = (age>=45&age<=54)
 	gen agroup5 = (age>=55&age<=64)
 	gen eduy1 = eduy*agroup1
 	gen eduy2 = eduy*agroup2
 	gen eduy3 = eduy*agroup3
 	gen eduy4 = eduy*agroup4
 	gen eduy5 = eduy*agroup5
	
 	gen age2 = age^2
 	gen cog = (st_ns+st_wr)/2
	
 	egen group = group(provcd)
 	sum group
 	forval i = 1/`r(max)'{
 		年龄组1
 		qui reg cog eduy1 age age2 i.gender if group==`i'
 		mat tmp = r(table) 储存结果的矩阵
 		scalar b1 = tmp[1,1] edu的系数
 		scalar p1 = tmp[4,1] edu的p-value

 		年龄组2
 		qui reg cog eduy2 age age2 i.gender if group==`i'
 		mat tmp = r(table)
 		scalar b2 = tmp[1,1]
 		scalar p2 = tmp[4,1]

 		年龄组3
 		qui reg cog eduy3 age age2 i.gender if group==`i'
 		mat tmp = r(table)
 		scalar b3 = tmp[1,1]
 		scalar p3 = tmp[4,1]

 		年龄组4
 		qui reg cog eduy4 age age2 i.gender if group==`i'
 		mat tmp = r(table)
 		scalar b4 = tmp[1,1]
 		scalar p4 = tmp[4,1]

 		年龄组5
 		qui reg cog eduy5 age age2 i.gender if group==`i'
 		mat tmp = r(table)
 		scalar b5 = tmp[1,1]
 		scalar p5 = tmp[4,1]

 		di `i' " " b1 " " p1 " " b2 " " p2 " " b3 " " p3 " " b4 " " p4 " " b5 " " p5
 	}
 }
 
 
 gen a_teduy = teduy*a_beta
label var a_teduy "总受教育年限调整值"

bys cyear provcd: egen tteduy = total(teduy)
bys cyear provcd: egen a_tteduy = total(a_teduy)
bys cyear provcd: egen ttpop = total(tpop)
gen aveduy =  tteduy/ttpop
gen a_aveduy = a_tteduy/ttpop


bys cyear provcd: egen avg_icog = mean(int_cog)
bys cyear provcd: egen avg_bcog = mean(bsc_cog)
label var avg_icog "平均内在认知能力"
label var avg_bcog "平均基本认知能力"

// gen cog = (st_math+st_word+st_ns+st_wr)/4
// gen int_cog = (st_ns+st_wr)/2
// gen bsc_cog = (st_math+st_word)/2
// bys cyear provcd: egen avg_eduy = mean(eduy)
// label var cog "综合认知能力"
// label var int_cog "内在认知能力"
// label var bsc_cog "基本认知能力"
// label var avg_eduy "平均受教育年限"
