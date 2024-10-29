# Proiect:  劳动力人力资本数量、质量与经济增长 - Config
# Author:   liuziyu
# Created Date: 2023.12
# Last Edited Date:  2024.10.28
#
# ------
#   This script is for:
#   defining 1) working paths, 2) province codes and 3) plot style.

rm(list = ls())

library(tidyverse)
library(rio)
library(summarytools)
library(naniar)
library(skimr)
library(GGally)
library(paletteer)

# 设置全局路径变量 ----
dir <- "D:/# Library/1 Seminar/1_Publishs/1031-认知技能/data"
rawdir <- file.path(dir, "0_rawdata")
popdir <- file.path(rawdir, "1982-2021-人口-四分")
macrodir <- file.path(rawdir, "宏观数据")
mydir <- file.path(dir, "1_mydata")
desdir <- file.path(dir, "2_description")
scriptdir <- file.path(dir, "Rscript")

# 定义省份列表 ----
provcd <- c("11", "12", "13", "14", "15", "21", "22", "23", "31", "32", 
            "33", "34", "35", "36", "37", "41", "42", "43", "44", "45", 
            "46", "50", "51", "52", "53", "54", "61", "62", "63", "64", 
            "65")
provcds_ <- c("11", "12", "13", "14", "15", "21", "22", "23", "32", "33", 
              "34", "35", "36", "37", "41", "42", "43", "44", "45", "46", 
              "50", "51", "52", "53", "54", "61", "62", "63", "64", "65")

# 定义年龄组大于4的省份
provcd_4 <- c("11", "12", "13", "14", "21", "22", "23", "31", "32", "33", 
              "34", "35", "36", "37", "41", "42", "43", "44", "45", "50", 
              "51", "52", "53", "61", "62")
prov_4_pinyin <- c("beijing", "tianjin", "hebei", "shanxi", "liaoning", "jilin", 
                   "heilongjiang", "shanghai", "jiangsu", "zhejiang", "anhui", 
                   "fujian", "jiangxi", "shandong", "henan", "hubei", "hunan", 
                   "guangdong", "guangxi", "chongqing", "sichuan", "guizhou", 
                   "yunnan", "xizang", "shanxi")
prov_4_hanzi <- c("北京", "天津", "河北", "山西", "辽宁", "吉林", "黑龙江", 
                  "上海", "江苏", "浙江", "安徽", "福建", "江西", "山东", 
                  "河南", "湖北", "湖南", "广东", "广西", "重庆", "四川", 
                  "贵州", "云南", "西藏", "陕西")

colors <- scale_color_paletteer_d("palettetown::lairon")