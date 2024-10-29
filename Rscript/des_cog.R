cat("/014") # clear screen
# 0. Info ----

# Project: Human capital
# Author: LiuZiyu
# Created date: 2024/10
# Last edited date: 2024/10/29

# This script is for: 
#   1) describing cognitive skill and std_cog, 
#   2) describing adjusting beta, 
#   3) describing avg edu_year and avg adj_edu_year.

source("D:/# Library/1 Seminar/1_Publishs/1031-认知技能/data/Rscript/config.R")

# 1 describing cognitive skill and std_cog ----
cog_dir <- file.path(mydir, "2_Cog/worker")
df_cog <- import(file.path(cog_dir, "1_Cog.dta"))
df_cog_split <- split(df_cog, df_cog$prov_hanzif)
ggplot(df_cog, aes(x = as.factor(cyear), y = st_cog, fill = cyear)) +
  geom_violin(width=1.4) +
  geom_boxplot(width=0.1, color="grey", alpha=0.2) +
  scale_color_paletteer_d("ggsci::default_nejm") +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("A Violin wrapping a boxplot") +
  xlab("")


# 2 
df_beta <- import(file.path(cog_dir, "5_Beta.dta"))
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
