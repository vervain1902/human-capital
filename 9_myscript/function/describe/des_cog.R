# 加载必要的包
library(haven)   # 用于读取 .dta 文件
library(ggplot2) # 用于绘图
library(gridExtra) # 用于组合图形

# 设置文件路径和文件名
setwd("D:/Library/OneDrive/1 Seminar/1_Publishs/1031-认知技能/data/1_mydata/2_Cog/worker")
file_paths <- c("cfps10_2.dta", "cfps12_2.dta", "cfps14_2.dta", "cfps16_2.dta", "cfps18_2.dta", "cfps20_2.dta")

# 创建一个空的列表来存储图形
all_plots <- list()

# 循环读取每个文件并生成图形
for (file_path in file_paths) {
  
  # 读取 .dta 文件
  data <- read_dta(file_path)
  
  # 获取所有独特的省份
  provinces <- unique(data$prov_hanzi)
  
  # 循环处理每个省份
  for (prov in provinces) {
    
    # 获取当前省份的数据
    prov_data <- subset(data, prov_hanzi == prov)
    
    # 获取每个年份的独特值
    years <- unique(prov_data$cyear)
    
    # 为当前省份创建一个空的列表来存储每年的图像
    year_plots <- list()
    
    # 循环处理每个年份
    for (year in years) {
      
      # 获取当前年份的数据
      year_data <- subset(prov_data, cyear == year)
      
      # 绘制密度图
      p <- ggplot(year_data, aes(x = st_cog)) +
        geom_density(fill = "blue", alpha = 0.5) +
        labs(title = paste("Density of st_cog in", prov, "for", year),
             x = "st_cog", y = "Density") +
        theme_minimal()
      
      # 将图形存储到列表
      year_plots[[as.character(year)]] <- p
    }
    
    # 将多个年份的图形组合成一个
    combined_plot <- grid.arrange(grobs = year_plots, ncol = length(years))
    
    # 将组合的图形保存到本地
    output_path <- paste0(prov, "_st_cog_density.png")
    ggsave(output_path, combined_plot, width = 10, height = 6)
    
    # 将组合图形存储到主图列表
    all_plots[[prov]] <- combined_plot
  }
}
