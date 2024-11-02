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

# 1 des micro income from cfps ---- 
file_name <- file.path(lihk_dir, "1_Inc.dta")
df_income <- import(file_name) %>%
  mutate(cyear = as.factor(cyear),
         linc = log(inc / 10000))

file_name <- file.path(lihk_dir, "tmp_inc.dta")
df_income_raw <- import(file_name) %>%
  mutate(cyear = as.factor(cyear))

provs <- unique(df_income$prov_hanzi)

# 1.1 national ----
median_2010 <- median(df_income$linc[df_income$cyear == 2010], na.rm = TRUE)

p <- ggplot(df_income, aes(x = cyear, y = linc, color = cyear)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, position = position_dodge(0.9)) +  # 箱线图
  geom_hline(yintercept = median_2010, linetype = "dashed", color = "red") +
  labs(x = "年份", y = "对数年收入（万元）") +
  colors_grey +
  ggtitle("全国") +
  coord_flip() +
  theme_minimal()
plot_name <- file.path(des_lihk_dir, "income", paste0("全国_income.jpg"))
ggsave(filename = plot_name, 
       plot = p, 
       dpi = 300, 
       width = 16, 
       height = 9, 
       units = "in")
print("全国 income saved.")

# 1.2 by province ----

for (i in provs) {
  df_subset <- df_income %>%
    subset(prov_hanzi == i)
  
    median_2010 <- median(df_subset$linc[df_subset$cyear == 2010], na.rm = TRUE)
    
    p <- ggplot(df_subset, aes(x = cyear, y = linc)) +
      geom_violin(trim = FALSE) +
      geom_boxplot(width = 0.1, position = position_dodge(0.9)) +  # 箱线图
      geom_hline(yintercept = median_2010, linetype = "dashed", color = "red") +
      labs(x = "年份", y = "对数年收入（万元）") +
      ggtitle(i) +
      coord_flip() +
      theme_minimal()
    plot_name <- file.path(des_lihk_dir, "income", paste0(i, "_income.jpg"))
    ggsave(filename = plot_name, 
           plot = p, 
           dpi = 300, 
           width = 16, 
           height = 9, 
           units = "in")
    print(paste0(i, " income saved."))
}

# 1.3 special provs ----
provs_west <- c("海南", "宁夏", "青海", "西藏", "新疆")
file_name <- file.path(lihk_dir, "tmp_inc.dta")
df_income_raw <- import(file_name) %>%
  mutate(cyear = as.factor(cyear),
         linc = log(inc / 10000))
for (i in provs_west) {
  df_subset <- df_income_raw %>%
    subset(prov_hanzi == i)
  
  median_2010 <- median(df_subset$linc[df_subset$cyear == 2010], na.rm = TRUE)
  
  p <- ggplot(df_subset, aes(x = as.factor(cyear), y = linc)) +
    geom_violin(trim = FALSE) +
    geom_boxplot(width = 0.1, position = position_dodge(0.9)) +  # 箱线图
    geom_hline(yintercept = median_2010, linetype = "dashed", color = "red") +
    labs(x = "年份", y = "对数年收入（万元）") +
    ggtitle(i) +
    coord_flip() +
    theme_minimal()
  plot_name <- file.path(des_lihk_dir, "income", paste0(i, "_income.jpg"))
  ggsave(filename = plot_name, 
         plot = p, 
         dpi = 300, 
         width = 16, 
         height = 9, 
         units = "in")
  print(paste0(i, " income saved."))
}

# 2 describe eduy, exp ----
# 2.1 national eduy ----
median_2010 <- median(df_income$peduy_micro[df_income$cyear == 2010], na.rm = TRUE)

p <- ggplot(df_income, aes(x = cyear, y = peduy_micro)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, position = position_dodge(0.9)) + 
  geom_hline(yintercept = median_2010, linetype = "dashed", color = "red") +
  labs(x = "年份", y = "受教育年限") +
  colors_grey +
  ggtitle("全国") +
  coord_flip() +
  theme_minimal()
plot_name <- file.path(des_lihk_dir, "age", paste0("全国_education year_new.jpg"))
ggsave(filename = plot_name, 
       plot = p, 
       dpi = 300, 
       width = 16, 
       height = 9, 
       units = "in")
print("全国 education year saved.")

# 2.2 by province eduy ----
for (i in provs) {
  df_subset <- df_income_raw %>%
    subset(prov_hanzi == i)
  
  median_2010 <- median(df_subset$eduy[df_subset$cyear == 2010], na.rm = TRUE)
  
  p <- ggplot(df_subset, aes(x = cyear, y = eduy)) +
    geom_violin(trim = FALSE) +
    geom_boxplot(width = 0.1, position = position_dodge(0.9)) +  # 箱线图
    geom_hline(yintercept = median_2010, linetype = "dashed", color = "red") +
    labs(x = "年份", y = "受教育年限") +
    ggtitle(i) +
    coord_flip() +
    theme_minimal()
  plot_name <- file.path(des_lihk_dir, "age", paste0(i, "_eduy.jpg"))
  ggsave(filename = plot_name, 
         plot = p, 
         dpi = 300, 
         width = 16, 
         height = 9, 
         units = "in")
  print(paste0(i, " eduy saved."))
}

# 1.3 national experience ----
median_2010 <- median(df_income$exp[df_income$cyear == 2010], na.rm = TRUE)

p <- ggplot(df_income, aes(x = cyear, y = exp)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, position = position_dodge(0.9)) + 
  geom_hline(yintercept = median_2010, linetype = "dashed", color = "red") +
  labs(x = "年份", y = "工作年限") +
  colors_grey +
  ggtitle("全国") +
  coord_flip() +
  theme_minimal()
plot_name <- file.path(des_lihk_dir, "age", paste0("全国_working experience.jpg"))
ggsave(filename = plot_name, 
       plot = p, 
       dpi = 300, 
       width = 16, 
       height = 9, 
       units = "in")
print("全国 working experience saved.")

# 3 describe lihk stocks ----
# 3.1 lihk stocks of 4-fold pop ----
file_name <- file.path(lihk_dir, "4_Macro_Pop4_pCog4_LIHK4_nocog.dta")
df_lihk4 <- import(file_name) %>%
  mutate(cyear = as.factor(cyear))

median_2010 <- median(df_lihk4$lihk4[df_lihk4$cyear == 2010], na.rm = TRUE)
p <- ggplot(df_lihk4, aes(x = cyear, y = lihk4)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, position = position_dodge(0.9)) + 
  geom_hline(yintercept = median_2010, linetype = "dashed", color = "red") +
  labs(x = "年份", y = "LIHK人力资本存量") +
  ggtitle("全国") +
  coord_flip() +
  theme_minimal()
plot_name <- file.path(des_lihk_dir, "lihk", paste0("全国_lihk4.jpg"))
ggsave(filename = plot_name, 
       plot = p, 
       dpi = 300, 
       width = 16, 
       height = 9, 
       units = "in")
print("全国 lihk stocks of 4-fold pop saved.")







file_name <- file.path(lihk_dir, "5_Macro_Pop0_pCog0_aEduy0_Cog_Inc_LIHK0_nocog.dta")
df_lihk <- import(file_name) %>%
  mutate(cyear = as.factor(cyear))

regions <- unique(df_lihk$region)
for (i in regions) {
  df_subset <- df_lihk %>%
    subset(region == i)
  
 p <- ggplot(df_subset, aes(x = cyear, 
                      y = lihk0, 
                      group = prov_hanzi, 
                      color = prov_hanzi)) +
    geom_line(size = 1.5) +  # 绘制折线
    geom_point(size = 3) +  # 添加点，设置点的大小
    labs(x = "年份", y = "LIHK人力资本存量") +
    ggtitle("") +
    theme_minimal() +
    colors_color +
    theme(legend.position = "right")  # 调整图例位置
 
   plot_name <- file.path(des_lihk_dir, "lihk", paste0(i, "_lihk stock.jpg"))
   ggsave(filename = plot_name, 
          plot = p, 
          dpi = 300, 
          width = 16, 
          height = 9, 
          units = "in")
   print(paste0(i, " lihk stock saved."))
}


# 

