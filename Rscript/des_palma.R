# 0 Info ----

# Project: Human capital - 
# Author: LiuZiyu
# Created date: 2024/10
# Last edited date: 2024/10/29

# This script is for: 
#   1) lihk without cog

source("D:/# Library/1 Seminar/1_Publishs/1031-认知技能/data/Rscript/config.R")
macro_dir <- file.path(mydir, "0_Macro")

df_palma <- import(file.path(macro_dir, "palma_ratio.dta"))

skim(df_palma)