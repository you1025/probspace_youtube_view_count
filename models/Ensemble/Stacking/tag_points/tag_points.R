library(tidyverse)

source("models/Ensemble/Stacking/tag_points/functions_Stacking_tag_points.R", encoding = "utf-8")

# load data
df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean()

# 辞書の読み込み
v.tag_dict <- load_tag_dict(df.train_data, df.test_data)

# データ生成
df.tag_points.train <- make_tag_points(df.train_data, v.tag_dict)
df.tag_points.test  <- make_tag_points(df.test_data,  v.tag_dict)

# 書き込み
save_tag_points(df.tag_points.train, df.tag_points.test)
