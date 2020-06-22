library(tidyverse)
library(tidymodels)

source("models/XGB/01/functions.R", encoding = "utf-8")

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
  df.train <- recipes::juice(trained_recipe) %>%
    add_features_per_category(., .)

  # 学習の実施
  model <- parsnip::boost_tree(
    mode = "regression",
    learn_rate = 0.01,
    trees = 2774,

    tree_depth = 7,
    mtry = 35,
    min_n = 2,
    sample_size = 0.9,

    loss_reduction = 10^(-0.2706667)
  ) %>%
    parsnip::set_engine(
      engine = "xgboost",
      nthread = 1
    ) %>%

    parsnip::fit(
      y ~
        categoryId
      + likes
      + dislikes
      + comment_count
      + comments_disabled
      + ratings_disabled
      + published_year
      + published_month_x + published_month_y
      + channel_title_length
      + flg_no_tags
      + tag_characters
      + tag_count
      + description_length
      + flg_japanese
      + url_count
      + flg_url
      + flg_categoryId_high
      + comments_ratings_disabled_japanese
      + diff_published_year_mean_dislikes
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
    df.test <- recipes::bake(trained_recipe, df.test_data) %>%
      add_features_per_category(df.train)

    # 予測結果データセット
    tibble(
      id = 1:nrow(df.test),
      y = predict(fit, df.test, type = "numeric")[[1]] %>% exp() %>% { (.) - 1 } %>% as.integer() %>% ifelse(is.na(.), 2147483647, .)
    )
  } %>%

  {
    df.result <- (.)

    # ファイル名
    filename <- stringr::str_c(
      "XGB",
      lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S"),
      sep = "_"
    ) %>%
      stringr::str_c("csv", sep = ".")

    # 出力ファイルパス
    filepath <- stringr::str_c("models/XGB/01/output", filename, sep = "/")

    # 書き出し
    readr::write_csv(df.result, filepath, col_names = T)
  }

