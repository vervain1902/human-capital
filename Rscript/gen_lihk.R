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
years <- seq(2010, 2020, by = 2)
coefs_list00 <- tibble()
coefs_list01 <- tibble()
coefs_list10 <- tibble()
coefs_list11 <- tibble()

for (i in years) {
  df_lihk <- import(file.path(lihk_dir, "2_Macro_Pop0_pCog0_aEduy0_Cog_Inc.dta")) %>%
    distinct(cyear, pid, .keep_all = TRUE) %>%
    mutate(pwage = avwage / 10000, cyear2 = cyear^2)
  
  df_subset <- df_lihk %>%
    filter(cyear == i)
  
  if (nrow(df_subset) == 0) {
    next
  }
  
  # 1.1 full sample regression ----
  # reg without x-terms of full sample [model00]
  model_a <- lm(Linc ~ eduy + exp + exp2, data = df_subset)
  model_a_sum <- tidy(model_a) %>%
    mutate(cyear = i) %>%
    mutate(p.value = formatC(p.value, format = "f", digits = 3))
  
  mi <- exp(predict(model_a, newdata = df_subset))
  
  model_b <- lm(Linc ~ mi - 1, data = df_subset)
  model_b_sum <- tidy(model_b) %>%
    mutate(cyear = i) %>%
    mutate(p.value = formatC(p.value, format = "f", digits = 3))
  
  alpha_val <- exp(coef(model_b)) 
  model_b_sum <- model_b_sum %>%
    mutate(alpha = alpha_val)
  coefs_list00 <- bind_rows(coefs_list00, model_a_sum)
  
  # reg with x-terms of full sample [model01]
  model_a <- lm(Linc ~ eduy + eduy_wy + exp + exp2 + pwage, data = df_subset)
  model_a_sum <- tidy(model_a) %>%
    mutate(cyear = i) %>%
    mutate(p.value = formatC(p.value, format = "f", digits = 3))
  
  mi <- exp(predict(model_a, newdata = df_subset))
  
  model_b <- lm(Linc ~ mi - 1, data = df_subset)
  model_b_sum <- tidy(model_b) %>%
    mutate(cyear = i) %>%
    mutate(p.value = formatC(p.value, format = "f", digits = 3))
  
  alpha_val <- exp(coef(model_b))  
  model_b_sum <- model_b_sum %>%
    mutate(alpha = alpha_val)
  coefs_list01 <- bind_rows(coefs_list01, model_a_sum)
  
  # 1.1 by sample regression ----
  for (a in c(1, 0)) {
    for (b in c(1, 0)) {
      filtered_data <- df_subset %>% 
        filter(urban == a, gender == b)
      
      # reg without x-terms by urban and gender [model10]
      model_a <- lm(Linc ~ eduy + st_cog + exp + exp2, 
                    data = filtered_data)
      model_a_sum <- tidy(model_a) %>%
        mutate(cyear = i, gender = a, urban = b) %>%
        mutate(p.value = formatC(p.value, format = "f", digits = 3))
      
      mi <- exp(predict(model_a, newdata = filtered_data))
      
      model_b <- lm(Linc ~ mi - 1, data = filtered_data)
      model_b_sum <- tidy(model_b) %>%
        mutate(cyear = i, gender = a, urban = b) %>%
        mutate(p.value = formatC(p.value, format = "f", digits = 3))
      
      alpha_val <- exp(coef(model_b)) 
      model_b_sum <- model_b_sum %>%
        mutate(alpha = alpha_val)
      coefs_list10 <- bind_rows(coefs_list10, model_a_sum)
      
      # reg with x-terms by urban and gender [model11]
      model_a <- lm(Linc ~ eduy + eduy_wy + exp + exp2 + pwage, 
                    data = filtered_data)
      model_a_sum <- tidy(model_a) %>%
        mutate(cyear = i, gender = a, urban = b) %>%
        mutate(p.value = formatC(p.value, format = "f", digits = 3))
      
      mi <- exp(predict(model_a, newdata = filtered_data))
      
      model_b <- lm(Linc ~ mi - 1, data = filtered_data)
      model_b_sum <- tidy(model_b) %>%
        mutate(cyear = i, gender = a, urban = b) %>%
        mutate(p.value = formatC(p.value, format = "f", digits = 3))
      
      alpha_val <- exp(coef(model_b))  
      model_b_sum <- model_b_sum %>%
        mutate(alpha = alpha_val)
      coefs_list11 <- bind_rows(coefs_list11, model_a_sum)
    }
  }
}

# 1.3 export coefficients of 4 models ----
for (i in c("00", "01", "10", "11")) {
  file_name <- file.path(desdir, "3_LIHK", paste0("model", i, "_results.xlsx"))
  coefs_data <- get(paste0("coefs_list", i))  # 获取系数列表
  export(coefs_data, file = file_name)  # 确保传递文件名
  print(paste0("coefficients of model", i, " saved."))
}

# 1.4 merge micro data of lihk with coefficients of 4 models ----
coefs_list00_wide <- coefs_list00 %>%
  group_by(cyear) %>%
  select(-statistic, -p.value, -std.error) %>%
  pivot_wider(names_from = term, values_from = estimate) %>%
  ungroup() %>%
  rename(int_00 = `(Intercept)`, 
         eduy_00 = eduy, 
         exp_00 = exp, 
         exp2_00 = exp2)

coefs_list01_wide <- coefs_list01 %>%
  group_by(cyear) %>%
  select(-statistic, -p.value, -std.error) %>%
  pivot_wider(names_from = term, values_from = estimate) %>%
  ungroup() %>%
  rename(int_01 = `(Intercept)`, 
         eduy_01 = eduy, 
         exp_01 = exp, 
         exp2_01 = exp2,
         eduy_wy_01 = eduy_wy,
         pwage_01 = pwage)

coefs_list10_wide <- coefs_list10 %>%
  group_by(cyear, urban, gender) %>%
  select(-statistic, -p.value, -std.error) %>%
  pivot_wider(names_from = term, values_from = estimate) %>%
  ungroup() %>%
  rename(int_10 = `(Intercept)`,
         eduy_10 = eduy,
         exp_10 = exp,
         exp2_10 = exp2)

coefs_list11_wide <- coefs_list11 %>%
  group_by(cyear, urban, gender) %>%
  select(-statistic, -p.value, -std.error) %>%
  pivot_wider(names_from = term, values_from = estimate) %>%
  ungroup() %>%
  rename(int_11 = `(Intercept)`,
         eduy_11 = eduy,
         exp_11 = exp,
         exp2_11 = exp2,
         eduy_wy_11 = eduy_wy,
         pwage_11 = pwage)

df_lihk_index <- df_lihk %>%
  left_join(coefs_list00_wide, by = c("cyear")) %>%
  left_join(coefs_list01_wide, by = c("cyear")) %>%
  left_join(coefs_list10_wide, by = c("cyear", "urban", "gender")) %>%
  left_join(coefs_list11_wide, by = c("cyear", "urban", "gender")) %>%
  mutate(intercept = int_11 + pwage_11 * pwage, 
         b_eduy = eduy_11 + eduy_wy_11 * pgdp_w,
         b_exp = exp_11,
         b_exp2 = exp2_11) %>% 
  select(cyear, cyear2, provcd, urban, gender, age, age2, exp, exp2,
         intercept, b_eduy, b_exp, b_exp2) %>%
  distinct(cyear, provcd, urban, gender, .keep_all = TRUE) %>%
  filter(!is.na(intercept))

rm(list = ls(pattern = "^(coefs|model|df_subset)"))

# 2 estimate parameters ---- 
# fitted_values <- df_lihk_index %>%
#   group_by(provcd, urban, gender) %>%
#   reframe(
#     cyear = cyear,
#     intercept_fit = list(predict(lm(intercept ~ cyear, data = cur_data()))),
#     b_eduy_fit = list(predict(lm(b_eduy ~ cyear + cyear2, data = cur_data()))),
#     b_exp_fit = list(predict(lm(b_exp ~ cyear + cyear2, data = cur_data()))),
#     b_exp2_fit = list(predict(lm(b_exp2 ~ cyear, data = cur_data())))
#   ) %>%
#   unnest(cols = c(intercept_fit, b_eduy_fit, b_exp_fit, b_exp2_fit))

fitted_values_list <- df_lihk_index %>%
  split(list(.$provcd, .$urban, .$gender)) %>%
  map(~ {
    if (nrow(.x) < 2 || all(is.na(.x$cyear))) {
      return(tibble(cyear = NA, 
                    provcd = .x$provcd[1], 
                    urban = .x$urban[1], 
                    gender = .x$gender[1],
                    intercept_fit = NA, 
                    b_eduy_fit = NA, 
                    b_exp_fit = NA, 
                    b_exp2_fit = NA))
    }
    
    model_intercept <- lm(intercept ~ cyear, data = .x)
    model_b_eduy <- lm(b_eduy ~ cyear + cyear2, data = .x)
    model_b_exp <- lm(b_exp ~ cyear + cyear2, data = .x)
    model_b_exp2 <- lm(b_exp2 ~ cyear, data = .x)
    
    # 创建预测数据框
    tibble(
      cyear = .x$cyear,
      provcd = .x$provcd[1],
      urban = .x$urban[1],
      gender = .x$gender[1],
      intercept_fit = predict(model_intercept),
      b_eduy_fit = predict(model_b_eduy),
      b_exp_fit = predict(model_b_exp),
      b_exp2_fit = predict(model_b_exp2)
    )
  })

fitted_values <- bind_rows(fitted_values_list) %>%
  distinct(provcd, urban, gender, cyear, .keep_all = TRUE) %>%
  arrange(cyear, provcd, urban, gender)

file_name <- file.path(desdir, "3_LIHK", "fitted_val_nocog.xlsx")
export(fitted_values, file_name)
print("fitted values without cog saved.")

# generate lihk index using estimated params ----
df_lihk_index <- df_lihk %>%
  group_by(cyear, provcd) %>%
  left_join(fitted_values, by = c("cyear", "provcd", "urban", "gender")) %>%
  mutate(
    intercept00 = ifelse(urban == 0 & gender == 0, intercept_fit, NA),
    intercept01 = ifelse(urban == 0 & gender == 1, intercept_fit, NA),
    intercept10 = ifelse(urban == 1 & gender == 0, intercept_fit, NA),
    intercept11 = ifelse(urban == 1 & gender == 1, intercept_fit, NA)
) %>%
  mutate(lnh = case_when(
    urban == 0 & gender == 0 ~ 
      intercept00 + eduy * b_eduy_fit + exp * b_exp_fit + exp2 * b_exp2_fit,
    urban == 0 & gender == 1 ~ 
      intercept01 - intercept00 + eduy * b_eduy_fit + exp * b_exp_fit + exp2 * b_exp2_fit,
    urban == 1 & gender == 0 ~ 
      intercept10 - intercept00 + eduy * b_eduy_fit + exp * b_exp_fit + exp2 * b_exp2_fit,
    urban == 1 & gender == 1 ~ 
      intercept11 - intercept00 + eduy * b_eduy_fit + exp * b_exp_fit + exp2 * b_exp2_fit),
    h = exp(lnh),
    sch = case_when(
      eduy == 0 ~ 0,
      eduy < 9 & eduy >= 6 ~ 6,
      eduy < 12 & eduy >= 9 ~ 9,
      eduy < 15 & eduy >= 12 ~ 12,
      eduy == 15 ~ 15,
      eduy < 16 & eduy >= 16 ~ 16)
    ) %>%
  group_by(cyear, provcd, urban, gender, age, sch) %>%
  mutate(p_h = mean(h, na.rm = TRUE)) %>%
  ungroup() %>%
  distinct(cyear, provcd, urban, gender, age, sch, .keep_all = TRUE)



