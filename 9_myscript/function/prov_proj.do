cls
/*==================================================

Proiect:  劳动力人力资本数量、质量与经济增长 - 
Author:   liuziyu
Created Date: 2023.12
Last Edited Date:  2024.11.02

==================================================*/
clear 
input str10 prov_hanzi str20 prov_pinyin provcd
"北京" "beijing" 11
"天津" "tianjin" 12
"河北" "hebei" 13
"山西" "shanxi" 14
"内蒙古" "neimenggu" 15
"辽宁" "liaoning" 21
"吉林" "jilin" 22
"黑龙江" "heilongjiang" 23
"上海" "shanghai" 31
"江苏" "jiangsu" 32
"浙江" "zhejiang" 33
"安徽" "anhui" 34
"福建" "fujian" 35
"江西" "jiangxi" 36
"山东" "shandong" 37
"河南" "henan" 41
"湖北" "hubei" 42
"湖南" "hunan" 43
"广东" "guangdong" 44
"广西" "guangxi" 45
"海南" "hainan" 46
"重庆" "chongqing" 50
"四川" "sichuan" 51
"贵州" "guizhou" 52
"云南" "yunnan" 53
"西藏" "xizang" 54
"陕西" "shanxi" 61
"甘肃" "gansu" 62
"青海" "qinghai" 63
"宁夏" "ningxia" 64
"新疆" "xinjiang" 65
end

// define region of provs
gen region = "东部"
replace region = "西部" if inlist(provcd, 15, 45, 50, 51, 52, 53, 54, 61, 62, 63, 64, 65)
replace region = "中部" if inlist(provcd,  14 , 22 ,23, 34, 36, 41, 42 ,43)
label var region "区域"

cd "$mydir/0_Macro"
save province_codes, replace
