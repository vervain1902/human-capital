* 创建省份与代码的映射表

input str10 prov_hanzi str20 provcd_pinyin provcd
/* "全国" "quanguo" 0 */
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

* 保存映射表
cd "$mydir/0_Macro"
save province_codes, replace
