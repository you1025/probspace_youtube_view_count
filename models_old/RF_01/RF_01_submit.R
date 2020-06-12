library(tidyverse)
library(tidymodels)

source("models/RF_01/functions.R", encoding = "utf-8")

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
  model <- parsnip::rand_forest(
    mode = "regression",
    # mtry  = 15,
    # trees = 1000,
    # min_n = 60
    mtry  = 13,
    trees = 1000,
    min_n = 3
  ) %>%
    parsnip::set_engine(
      engine = "ranger",
      # max.depth = 25,
      max.depth = 14,
      num.threads = 8,
      seed = 1234
    ) %>%
    parsnip::fit(
      y ~
        categoryId
      + likes
      + dislikes
      + comment_count
      + comments_disabled
      + ratings_disabled
      + title_length
      + published_year
      + flg_categoryId_high
      + tag_characters
      + description_length
      + days_from_published
      + diff_likes_dislikes
      + sum_likes_dislikes
      + flg_japanese
      + flg_official
      + categoryId_mean_y
      + categoryId_median_y
      + published_year_mean_y
      + flg_japanese_mean_y
      + flg_japanese_median_y
      + diff_categoryId_mean_comment_count
      + categoryId_max_comment_count
      + diff_comments_disabled_mean_dislikes
      + published_year_median_likes
      + ratio_published_year_median_likes
      + published_year_min_likes
      + published_year_sd_likes
      + diff_published_year_mean_dislikes
      + diff_flg_japanese_max_dislikes
      + diff_flg_japanese_max_comment_count
      + flg_japanese_sd_comment_count
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
      y = predict(fit, df.test, type = "numeric")[[1]] %>% exp() %>% { (.) - 1 } %>% as.integer()
    )
  } %>%

  {
    df.result <- (.)

    # ファイル名
    filename <- stringr::str_c(
      "RF",
      lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S"),
      sep = "_"
    ) %>%
      stringr::str_c("csv", sep = ".")

    # 出力ファイルパス
    filepath <- stringr::str_c("models/RF_01/output", filename, sep = "/")

    # 書き出し
    readr::write_csv(df.result, filepath, col_names = T)
  }
