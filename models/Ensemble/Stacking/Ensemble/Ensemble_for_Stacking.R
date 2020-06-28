library(tidyverse)
library(tidymodels)

source("models/Ensemble/Stacking/Ensemble/functions_Stacking_Ensemble.R", encoding = "utf-8")

df.train_data <- load_stacking_train_data()
df.test_data  <- load_stacking_test_data()


# Model Definition --------------------------------------------------------

model <- parsnip::boost_tree(
  mode = "regression",
  learn_rate = 0.01,
  trees = 700,

  tree_depth = 3,
  mtry = 8,

  min_n = 11,
  sample_size = 0.7375,

  loss_reduction = 10^(-0.2895833)
) %>%
  parsnip::set_engine(
    engine = "xgboost",
    nthread = 1
  )


# Predict by Test Data ----------------------------------------------------

# モデルの学習
# 学習の実施
model <- parsnip::fit(
  model,
  y ~
    LR
  + KNN
  + SVM
  + NN.shallow
  + NN.deep
  + RF.shallow
  + RF.deep
  + XGB.shallow
  + XGB.middle
  + XGB.deep
  + LGBM.shallow
  + LGBM.deep
  + tag_point
  + avg_recent_y
  + weighted_avg_recent_y
  + low_y_1000
  + low_y_5000
  + low_y_10000
  + low_y_30000
  ,
  df.train_data
)

# 予測結果データセット
df.predicted <- df.test_data %>%

  # 予測の追加
  dplyr::mutate(
    y = predict(model, df.test_data, type = "numeric")[[1]] %>% { exp(.) - 1 } %>% as.integer()
  ) %>%

  dplyr::select(
    id,
    y
  )

# ファイル出力
df.predicted %>%
  {
    df.result <- (.)
    
    # ファイル名
    filename <- stringr::str_c(
      "Stacking",
      lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S"),
      sep = "_"
    ) %>%
      stringr::str_c("csv", sep = ".")
    
    # 出力ファイルパス
    filepath <- stringr::str_c("models/Ensemble/Stacking/Ensemble/output", filename, sep = "/")
    
    # 書き出し
    readr::write_csv(df.result, filepath, col_names = T)
  }

