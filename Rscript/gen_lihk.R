# 0 Info ----

# Project: Human capital - 
# Author: LiuZiyu
# Created date: 2024/10
# Last edited date: 2024/10/29

# This script is for: 
#   1) lihk without cog

source("D:/# Library/1 Seminar/1_Publishs/1031-认知技能/data/Rscript/config.R")
lihk_dir <- file.path(mydir, "3_LIHK")

# 1 estimate 4 Mincer equations [urban*gender] by year ----
# 1.1 by sample regression ----
years <- seq(2010, 2020, by = 2)
coefs_list00 <- data.frame()
coefs_list01 <- data.frame()
coefs_list10 <- data.frame()
coefs_list11 <- data.frame()

for (i in years) {
  df_lihk <- import(file.path(lihk_dir, "2_Macro_Pop0_pCog0_aEduy0_Cog_Inc.dta")) %>%
    distinct(cyear, pid, .keep_all = TRUE) %>%
    mutate(pwage = avwage / 10000) %>%
    filter(cyear == i)
  
  for (a in c(1, 0)) {
    for (b in c(1, 0)) {
      filtered_data <- df_lihk %>% 
        filter(urban == a, gender == b)
      
      # reg without x-terms by year, urban and gender 
      model_a <- lm(Linc ~ eduy + exp + exp2, data = filtered_data)
      model_a_sum <- tidy(model_a) %>%
        mutate(cyear = i, gender = a, urban = b) %>%
        mutate(p.value = formatC(p.value, format = "f", digits = 3))
      
      mi <- exp(predict(model_a, newdata = filtered_data))
      
      model_b <- lm(Linc ~ mi - 1, data = filtered_data)
      model_b_sum <- tidy(model_b) %>%
        mutate(cyear = i, gender = a, urban = b) %>%
        mutate(p.value = formatC(p.value, format = "f", digits = 3))
      
      alpha_val <- exp(coef(model_b))  # 使用模型系数
      model_b_sum <- model_b_sum %>%
        mutate(alpha = alpha_val)
      coefs_list00 <- bind_rows(coefs_list00, model_a_sum)
      
      # reg with x-terms by year, urban and gender 
      model_a <- lm(Linc ~ eduy + eduy_wy + exp + exp2 + pwage, data = filtered_data)
      model_a_sum <- tidy(model_a) %>%
        mutate(cyear = i, gender = a, urban = b) %>%
        mutate(p.value = formatC(p.value, format = "f", digits = 3))
      
      mi <- exp(predict(model_a, newdata = filtered_data))
      
      model_b <- lm(Linc ~ mi - 1, data = filtered_data)
      model_b_sum <- tidy(model_b) %>%
        mutate(cyear = i, gender = a, urban = b) %>%
        mutate(p.value = formatC(p.value, format = "f", digits = 3))
      
      alpha_val <- exp(coef(model_b))  # 使用模型系数
      model_b_sum <- model_b_sum %>%
        mutate(alpha = alpha_val)
      coefs_list01 <- bind_rows(coefs_list01, model_a_sum)
    }
  }
  
  # 1.2 full sample regression ----
  # reg without x-terms of full sample
  # model <- lm(Linc ~ eduy + exp + exp2, data = df_lihk)
  # model_sum <- tidy(model)
  # model_sum$p.value <- formatC(model_sum$p.value, format = "f", digits = 3)
  # model_sum <- model_sum %>%
  #   mutate(cyear = i)
  # coefs_list10 <- bind_rows(coefs_list10, model_sum)
  # 
  # # reg with x-terms of full sample
  # model <- lm(Linc ~ eduy + eduy_wy + exp + exp2 + avwage, data = df_lihk)
  # model_sum <- tidy(model)
  # model_sum$p.value <- formatC(model_sum$p.value, format = "f", digits = 3)
  # model_sum <- model_sum %>%
  #   mutate(cyear = i)
  # coefs_list11 <- bind_rows(coefs_list11, model_sum)
}

# 1.3 export coefficients of 4 models ----
coefs_list00_wide <- coefs_list00 %>%
  group_by(cyear, gender, urban) %>%
  select(-statistic, -p.value, -std.error) %>%
  pivot_wider(names_from = term, values_from = estimate) %>%
  ungroup() %>%
  rename(int_00 = `(Intercept)`, 
         eduy_00 = eduy, 
         exp_00 = exp, 
         exp2_00 = exp2)
file_name <- file.path(desdir, "3_LIHK", paste0("model00_results.xlsx"))
export(coefs_list00_wide, file_name)

coefs_list01_wide <- coefs_list01 %>%
  group_by(cyear, gender, urban) %>%
  select(-statistic, -p.value, -std.error) %>%
  pivot_wider(names_from = term, values_from = estimate) %>%
  ungroup() %>%
  rename(int_01 = `(Intercept)`, 
         eduy_01 = eduy, 
         exp_01 = exp, 
         exp2_01 = exp2,
         eduy_wy_01 = eduy_wy,
         pwage_01 = pwage)
file_name <- file.path(desdir, "3_LIHK", paste0("model01_results.xlsx"))
export(coefs_list01_wide, file_name)

# coefs_list10_wide <- coefs_list10 %>%
#   group_by(cyear) %>%
#   select(-statistic, -p.value, -std.error) %>%
#   pivot_wider(names_from = term, values_from = estimate) %>%
#   ungroup() %>%
#   rename(int_10 = `(Intercept)`, 
#          eduy_10 = eduy, 
#          exp_10 = exp, 
#          exp2_10 = exp2)
# file_name <- file.path(desdir, "3_LIHK", paste0("model10_results.xlsx"))
# export(coefs_list10_wide, file_name)
# 
# coefs_list11_wide <- coefs_list11 %>%
#   group_by(cyear) %>%
#   select(-statistic, -p.value, -std.error) %>%
#   pivot_wider(names_from = term, values_from = estimate) %>%
#   ungroup() %>%
#   rename(int_11 = `(Intercept)`, 
#          eduy_11 = eduy, 
#          exp_11 = exp, 
#          exp2_11 = exp2, 
#          eduy_wy_11 = eduy_wy)
# file_name <- file.path(desdir, "3_LIHK", paste0("model11_results.xlsx"))
# export(coefs_list11_wide, file_name)

# 1.4 merge micro data of lihk with coefficients of 4 models 
df_lihk <- df_lihk %>%
  left_join(coefs_list00_wide, by = c("cyear", "gender", "urban")) %>%
  left_join(coefs_list01_wide, by = c("cyear", "gender", "urban")) %>%
  # left_join(coefs_list10_wide, by = c("cyear")) %>% 
  # left_join(coefs_list11_wide, by = c("cyear")) %>%
  mutate(intercept_01 = int_01 + pwage_01 * pwage, 
         b_eduy_01 = eduy_01 + eduy_wy_01 * gdp / 10000,
         b_exp_01 = exp_01,
         b_exp2_01 = exp2_01)

