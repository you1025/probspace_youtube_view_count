library(tidyverse)
library(tidymodels)

source("models/SVM_01/functions.R", encoding = "utf-8")

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
  trained_recipe <- recipes::prep(recipe, training = df.train_data)
  df.train <- recipes::juice(trained_recipe)

  # 学習の実施
  model <- parsnip::svm_rbf(
    mode = "regression",
    cost = 1.025,
    rbf_sigma = 0.1122018,
    margin = 0.12714286
  ) %>%
    parsnip::set_engine(engine = "kernlab") %>%
    parsnip::fit(
      y ~
        likes
        + dislikes
        + comment_count
        + tag_characters
        + flg_japanese
        + ratings_disabled
        + published_year
        + flg_categoryId_low
        + flg_categoryId_high
        ,
      df.train
    )

  list(
    train_data = df.train,
    model = model
  )
} %>%

  # テストデータを用いた予測
  {
    lst.results <- (.)

    # 学習済みモデル
    fit <- lst.results$model

    # 前処理済データの作成
    trained_recipe <- recipes::prep(recipe, training = df.train_data)
    df.test <- recipes::bake(trained_recipe, df.test_data)

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
      "SVM",
      lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S"),
      sep = "_"
    ) %>%
      stringr::str_c("csv", sep = ".")

    # 出力ファイルパス
    filepath <- stringr::str_c("models/SVM_01/output", filename, sep = "/")

    # 書き出し
    readr::write_csv(df.result, filepath, col_names = T)
  }
