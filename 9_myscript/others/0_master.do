* =====================
*      Master file
* =====================
global scriptdir "D:\Onedrive\OneDrive - mail.bnu.edu.cn\1 Seminar\Publishs\1031-认知技能\data\myscript"
cd "$scriptdir"

* 宏观数据准备
run 1_macrodata.do

* 认知技能
run 2_cognitive.do

* LIHK人力资本测算
run 3_LIHK.do

* 经济增长贡献回归
run 4_regression.do
