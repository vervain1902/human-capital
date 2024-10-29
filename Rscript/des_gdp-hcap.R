# 0. Info ----

# Project: Human capital
# Author: LiuZiyu
# Created date: 2024/10
# Last edited date: 2024/10/29

# This script is for: 
#   1) describing gdp and human capital, 
#   2) describing adjusting beta, 
#   3) describing avg edu_year and avg adj_edu_year.

source("D:/# Library/1 Seminar/1_Publishs/1031-认知技能/data/Rscript/config.R")
lihk_dir <- file.path(mydir, "3_LIHK")

# 1 describe micro income ----
df_inc <- import(file.path(lihk_dir, "tmp_inc.dta"))

skim(df_inc)
setwd(file.path(desdir, "3_LIHK"))
dfSummary(df_inc) %>% stview()

p_missvar <- gg_miss_var(df_inc)
plot_name <- file.path(desdir, "3_LIHK", "miss_val.jpg")
ggsave(plot_name, plot = p_missvar, width = 10, height = 6, dpi = 300)


