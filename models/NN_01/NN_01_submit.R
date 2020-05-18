library(tidyverse)
library(tidymodels)
library(keras)

source("models/NN_01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

# 訓練データ
df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean()

# 前処理レシピの作成
recipe <- create_recipe(df.train_data)


# Predict by Test Data ----------------------------------------------------

# モデルの学習と評価
{
  # 訓練/検証 データの作成
  lst.train_valid <- create_train_valid_data(df.train_data, recipe, 5000)

  # モデル作成
  params <- list(
    layers = 3,
    units = 32,
    activation = "relu",
    l1 = 1e-03,
    l2 = 1e-03,
    dropout_rate = 0.0,
    batch_size = 64
  )
  n <- lst.train_valid$x_train_train %>% ncol()
  model <- create_model_applied_parameters(params, n)

  # Compile
  model %>% keras::compile(
    optimizer = "rmsprop",
    loss = "mse",
    metrics = c("mse")
  )

  # 学習
  history <- model %>% keras::fit(
    # 訓練データ
    lst.train_valid$x_train_train,
    lst.train_valid$y_train_train,
    
    # 検証用データ(for Early Stopping)
    validation_data = list(
      lst.train_valid$x_train_valid,
      lst.train_valid$y_train_valid
    ),
    callbacks = list(
      keras::callback_early_stopping(
        monitor = "mse",
        patience = 2
      )
    ),
    
    epoch = 200,
    batch_size = params$batch_size,
    verbose = 1
  )


  # Test
  trained_recipe <- recipes::prep(recipe, training = df.train_data)
  baked_test <- recipes::bake(trained_recipe, new_data = df.test_data)
  x_test <- baked_test %>% as.matrix()

  # 予測結果データセット
  tibble(
    id = 1:nrow(df.test_data),
    y = predict(model, x_test) %>% exp() %>% { (.) - 1 } %>% as.integer()
  )
} %>%

  {
    df.result <- (.)

    # ファイル名
    filename <- stringr::str_c(
      "NN",
      lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S"),
      sep = "_"
    ) %>%
      stringr::str_c("csv", sep = ".")

    # 出力ファイルパス
    filepath <- stringr::str_c("models/NN_01/output", filename, sep = "/")

    # 書き出し
    readr::write_csv(df.result, filepath, col_names = T)
  }
