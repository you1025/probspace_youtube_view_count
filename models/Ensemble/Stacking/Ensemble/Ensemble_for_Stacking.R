library(tidyverse)
library(tidymodels)

source("models/Ensemble/Stacking/Ensemble/functions_Stacking_Ensemble.R", encoding = "utf-8")

df.train_data <- load_stacking_train_data()
df.test_data  <- load_stacking_test_data()


# Model Definition --------------------------------------------------------

model <- parsnip::boost_tree(
  mode = "regression",
  learn_rate = 0.01,
  trees = 727,

  tree_depth = 4,
  mtry = 5,

  min_n = 9,
  sample_size = 0.7217391,

  loss_reduction = 10^(-0.2966667)
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
    KNN
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
  + V1
  + V2
  + cluster.10
  + cluster.100
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

