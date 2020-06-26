library(tidyverse)

source("models/Ensemble/Stacking/use_y_histories/functions_Stacking_use_y_histories.R", encoding = "utf-8")

# load data
df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean()

# データ生成
df.avg_recent_y.train <- get_average_y_from_recents(df.train_data, df.train_data, flg_impute = T)
df.avg_recent_y.test  <- get_average_y_from_recents(df.test_data,  df.train_data, flg_impute = T)

# 書き込み
save_average_y_from_recents(df.avg_recent_y.train, df.avg_recent_y.test)
