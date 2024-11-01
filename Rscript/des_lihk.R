# 0. Info ----

# Project: Human capital
# Author: LiuZiyu
# Created date: 2024/10
# Last edited date: 2024/10/29

# This script is for: 
#   1) describing lihk stocks

source("D:/# Library/1 Seminar/1_Publishs/1031-认知技能/data/Rscript/config.R")
lihk_dir <- file.path(mydir, "3_LIHK")
des_lihk_dir <- file.path(desdir, "3_LIHK")

# describe lihk stocks ----
df_lihk <- import(file.path(lihk_dir, "5_Macro_Pop0_pCog0_aEduy0_Cog_Inc_LIHK0_nocog.dta"))
median_2010 <- median(df_lihk$idx_h4[df_lihk$cyear == 2010], na.rm = TRUE)

ggplot(df_lihk, aes(x = as.factor(cyear), y = idx_h4)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, position = position_dodge(0.9)) +  # 箱线图
  geom_hline(yintercept = median_2010, linetype = "dashed", color = "red") +
  labs(x = "年份", y = "LIHK人力资本存量") +
  ggtitle("全国") +
  coord_flip() +
  theme_minimal()

median_2010 <- median(df_lihk$gdp_base2010[df_lihk$cyear == 2010], na.rm = TRUE)
ggplot(df_lihk, aes(x = as.factor(cyear), y = gdp_base2010)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, position = position_dodge(0.9)) +  # 箱线图
  geom_hline(yintercept = median_2010, linetype = "dashed", color = "red") +
  labs(x = "年份", y = "2010年不变价gdp") +
  ggtitle("全国") +
  coord_flip() +
  theme_minimal()


p <- ggplot(df_beta, aes(y = a_beta, x = age_group)) +
  geom_point() +
  scale_color_paletteer_d("ggsci::default_nejm") +
  facet_wrap(~ prov_hanzi, nrow = 5) +  # 按 prov_hanzi 分组，排列为 5 行
  labs(y = "调整系数", x = "年龄组")  # 设置坐标轴名称
plot_name <- file.path(desdir, "2_Cog/worker", "scatter_beta.png")
ggsave(filename = plot_name, 
       plot = p, 
       dpi = 300, 
       width = 16, 
       height = 9, 
       units = "in")
