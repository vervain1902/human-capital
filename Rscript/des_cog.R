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
cog_dir <- file.path(mydir, "2_Cog/worker")

# 1 describe adjusting beta ----
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

# 2 describe cognitive skill and std_cog ----
df_cog <- import(file.path(cog_dir, "1_Cog.dta"))
df_cog_split <- split(df_cog, df_cog$prov_hanzi)

df_cog_filtered1 <- df_cog %>% 
  filter(cyear %in% c(2010, 2014, 2018))
df_cog_filtered1_split <- split(df_cog_filtered1, df_cog_filtered1$prov_hanzi)

df_cog_filtered2 <- df_cog %>% 
  filter(cyear %in% c(2012, 2016, 2020))
df_cog_filtered2_split <- split(df_cog_filtered2, df_cog_filtered2$prov_hanzi)

# 2.1 distribution of st_cog [national, violin plot] ----
median1_2010 <- median(df_cog_filtered1$st_cog[df_cog_filtered1$cyear == 2010], na.rm = TRUE)

p <- ggplot(df_cog_filtered1, aes(x = as.factor(cyear), y = st_cog)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, position = position_dodge(0.9)) +  # 箱线图
  geom_hline(yintercept = median1_2010, linetype = "dashed", color = "red") +
  labs(x = "年份", y = "标准化认知技能得分") +
  ggtitle("全国") +
  coord_flip() +
  theme_minimal()

plot_name <- file.path(desdir, "2_Cog/worker/cog_distri/Violin", "violin_plot1_全国.jpg")
ggsave(plot = p, filename = plot_name)  # 保存图形为 PNG 文件
print("2010, 2014 and 2018 national distribution of standardized cog saved.")

median2_2012 <- median(df_cog_filtered2$st_cog[df_cog_filtered2$cyear == 2012], na.rm = TRUE)

p <- ggplot(df_cog_filtered2, aes(x = as.factor(cyear), y = st_cog)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, position = position_dodge(0.9)) +  # 箱线图
  geom_hline(yintercept = median2_2012, linetype = "dashed", color = "red") +
  labs(x = "年份", y = "标准化认知技能得分") +
  ggtitle("全国") +
  coord_flip() +
  theme_minimal()

plot_name <- file.path(desdir, "2_Cog/worker/cog_distri/Violin", "violin_plot2_全国.jpg")
ggsave(plot = p, filename = plot_name)  # 保存图形为 PNG 文件
print("2012, 2016 and 2020 national distribution of standardized cog saved.")

# 2.2 distribution of st_cog [by province, violin plot] ---- 
for (prov in names(df_cog_filtered1_split)) {
  df_subset <- df_cog_filtered1_split[[prov]]
  median1_2010 <- median(df_subset$st_cog[df_subset$cyear == 2010], na.rm = TRUE)  
  p <- ggplot(df_subset, aes(x = as.factor(cyear), y = st_cog)) +
    geom_violin(trim = FALSE) +
    geom_boxplot(width = 0.1, position = position_dodge(0.9)) +  # 箱线图
    geom_hline(yintercept = median1_2010, linetype = "dashed", color = "red") +
    labs(x = "年份", y = "标准化认知技能得分") +
    ggtitle(as.character(df_subset$prov_hanzi)) +
    coord_flip() +
    theme_minimal()
    
    plot_name <- file.path(desdir, "2_Cog/worker/cog_distri/Violin", paste0("violin_plot1_", prov, ".jpg"))
    ggsave(plot = p, filename = plot_name)  
    print(paste0("2010, 2014 and 2018 ", prov, " distribution of standardized cog saved."))
}

for (prov in names(df_cog_filtered2_split)) {
  df_subset <- df_cog_filtered2_split[[prov]]
  median2_2012 <- median(df_subset$st_cog[df_subset$cyear == 2012], na.rm = TRUE)
  p <- ggplot(df_subset, aes(x = as.factor(cyear), y = st_cog)) +
    geom_violin(trim = FALSE) +
    geom_boxplot(width = 0.1, position = position_dodge(0.9)) +  # 箱线图
    geom_hline(yintercept = median2_2012, linetype = "dashed", color = "red") +
    labs(x = "年份", y = "标准化认知技能得分") +
    ggtitle(as.character(df_subset$prov_hanzi)) +
    coord_flip() +
    theme_minimal()
  
  plot_name <- file.path(desdir, "2_Cog/worker/cog_distri/Violin", paste0("violin_plot2_", prov, ".jpg"))
  ggsave(plot = p, filename = plot_name)  
  print(paste0("2012, 2016 and 2020 ", prov, " distribution of standardized cog saved."))
}

# 3 describe raw vals and adjusted vals of avg edu_year ----
# 3.1 change of [national] ----
file_name <- file.path(cog_dir, "8_Macro_Pop0_pCog0_aEduy0.dta")
df_eduy <- import(file_name)

df_sum <- df_eduy %>%
  group_by(cyear) %>%
  summarise(
    t_pop0 = sum(pop0, na.rm = TRUE),
    t_eduy0 = sum(eduy0, na.rm = TRUE),
    t_a_eduy0 = sum(a_eduy0, na.rm = TRUE)
  ) %>%
  mutate(
    avg_eduy0 = t_eduy0 / t_pop0,
    avg_a_eduy0 = t_a_eduy0 / t_pop0,
    fill_color = ifelse(avg_a_eduy0 > avg_eduy0, "lightgray", "darkgray")
  )

p <- ggplot(df_sum, aes(x = cyear)) +
  geom_ribbon(aes(ymin = pmin(avg_eduy0, avg_a_eduy0), ymax = pmax(avg_eduy0, avg_a_eduy0), fill = fill_color), alpha = 0.5) +
  geom_line(aes(y = avg_a_eduy0, color = "平均受教育年限调整值", group = 1), size = 1) +
  geom_point(aes(y = avg_a_eduy0, color = "平均受教育年限调整值", shape = "平均受教育年限调整值"), size = 4) +
  geom_line(aes(y = avg_eduy0, color = "平均受教育年限", group = 2), size = 1) +
  geom_point(aes(y = avg_eduy0, color = "平均受教育年限", shape = "平均受教育年限"), size = 4) +
  labs(x = "年份", y = "平均受教育年限（年）", color = NULL, shape = NULL) +
  scale_y_continuous(limits = c(5, NA)) +
  scale_x_continuous(breaks = unique(df_sum$cyear)) +  # 确保显示为整数
  scale_fill_identity() +  # 直接使用填充颜色
  colors +
  theme_minimal(base_size = 14) +
  theme(
    legend.title = element_text(size = 16),  # 图例标题字体大小
    legend.text = element_text(size = 14)    # 图例文本字体大小
  ) +
  ggtitle("全国")

plot_name <- file.path(desdir, "2_Cog/worker/edu_year", "edu_year_全国.jpg")
ggsave(plot = p, filename = plot_name, 
       dpi = 300, 
       width = 16, 
       height = 9, 
       units = "in")

# 3.2 change of [by prov] ----
df_eduy_split <- split(df_eduy, df_eduy$prov_hanzi)
for (prov in names(df_eduy_split)) {
  df_subset <- df_eduy_split[[prov]]
  
  df_subset <- df_subset %>%
    mutate(fill_color = ifelse(peduy0 > a_peduy0, "lightgray", "darkgray"))
  
  p <- ggplot(df_subset, aes(x = cyear)) +
    geom_ribbon(aes(ymin = pmin(peduy0, a_peduy0), ymax = pmax(peduy0, a_peduy0), fill = fill_color), alpha = 0.5) +
    geom_line(aes(y = a_peduy0, color = "平均受教育年限调整值", group = 1), size = 1) +
    geom_point(aes(y = a_peduy0, color = "平均受教育年限调整值", shape = "平均受教育年限调整值"), size = 4) +
    geom_line(aes(y = peduy0, color = "平均受教育年限", group = 2), size = 1) +
    geom_point(aes(y = peduy0, color = "平均受教育年限", shape = "平均受教育年限"), size = 4) +
    labs(x = "年份", y = "平均受教育年限（年）", color = NULL, shape = NULL) +
    scale_y_continuous(limits = c(5, NA)) +
    scale_x_continuous(breaks = unique(df_subset$cyear)) +  # 确保显示为整数
    scale_fill_identity() +  # 使用指定的填充颜色
    colors +
    theme_minimal(base_size = 14) +
    theme(
      legend.title = element_text(size = 16),  # 图例标题字体大小
      legend.text = element_text(size = 14)    # 图例文本字体大小
    ) +
    ggtitle(as.character(df_subset$prov_hanzi))
  
  plot_name <- file.path(desdir, "2_Cog/worker/edu_year", paste0("edu_year_", prov, ".jpg"))
  ggsave(plot = p, filename = plot_name, 
         dpi = 300, 
         width = 16, 
         height = 9, 
         units = "in")
}