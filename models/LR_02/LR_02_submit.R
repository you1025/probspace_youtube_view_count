library(tidyverse)
library(tidymodels)

source("models/LR_02/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

# 訓練データ
df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean()

# 前処理レシピの作成
recipe <- create_recipe(df.train_data)


# Predict by Test Data ----------------------------------------------------

# モデルの学習
{
  # 前処理済データの作成
  df.train <- recipes::prep(recipe, training = df.train_data) %>%
    recipes::juice()

  # 学習の実施
  model.fitted <- parsnip::linear_reg(
    mode = "regression",
    penalty = 0.001258925,
    mixture = 0.8888889
  ) %>%
    parsnip::set_engine(engine = "glmnet") %>%
    parsnip::fit(y ~ ., df.train)
  
  list(
    train_data = df.train,
    model = model.fitted
  )
} %>%
  
  # テストデータを用いた予測
  {
    lst.results <- (.)
    
    # 学習済みモデル
    fit <- lst.results$model
    
    # 前処理済データの作成
    df.test <- recipes::prep(recipe, training = df.train_data) %>%
      recipes::bake(df.test_data)

    # 予測結果データセット
    tibble(
      id = 1:nrow(df.test),
      y = predict(fit, df.test, type = "numeric")[[1]] %>% exp() %>% { (.) - 1 } %>% as.integer()
    )
  } %>%
  
  {
    df.result <- (.)
    
    # ファイル名
    filename <- stringr::str_c(
      "LR",
      lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S"),
      sep = "_"
    ) %>%
      stringr::str_c("csv", sep = ".")
    
    # 出力ファイルパス
    filepath <- stringr::str_c("models/LR_02/output", filename, sep = "/")
    
    # 書き出し
    readr::write_csv(df.result, filepath, col_names = T)
  }
