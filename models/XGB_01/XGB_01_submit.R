library(tidyverse)
library(tidymodels)

source("models/XGB_01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

# 訓練データ
df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean()

# 前処理レシピの作成
recipe <- create_recipe(df.train_data)


# Predict by Test Data ----------------------------------------------------

# モデルの学習
{
  set.seed(1025)

  # 前処理済データの作成
  trained_recipe <- recipes::prep(recipe, training = df.train_data)
  df.train <- recipes::juice(trained_recipe) %>%
    add_features_per_category(., .)

  # 学習の実施
  model <- parsnip::boost_tree(
    mode = "regression",
    learn_rate = 0.01,
    trees = 774,

    tree_depth = 11,
    mtry = 29,
    min_n = 7,
    loss_reduction = 0.7340308,
    sample_size = 0.8
  ) %>%
    parsnip::set_engine(
      engine = "xgboost"
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
      + flg_categoryId_low
      + flg_categoryId_high
      + flg_no_tags
      + tag_characters
      + url_count
      + days_from_published
      + sum_likes_dislikes
      + ratio_comments_likedis
      + flg_japanese
      
      + categoryId_median_y
      + categoryId_min_y
      + categoryId_max_comment_count
      + diff_categoryId_max_comment_count
      + ratio_published_year_median_dislikes
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
      add_features_per_category(lst.results$train_data)

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
      "XGB",
      lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S"),
      sep = "_"
    ) %>%
      stringr::str_c("csv", sep = ".")

    # 出力ファイルパス
    filepath <- stringr::str_c("models/XGB_01/output", filename, sep = "/")

    # 書き出し
    readr::write_csv(df.result, filepath, col_names = T)
  }
