library(tidyverse)
library(tidymodels)

source("models/LR/01/functions.R", encoding = "utf-8")

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
  model <- parsnip::linear_reg(
    mode = "regression",
    penalty = 0.0001,
    mixture = 0.975
  ) %>%
    parsnip::set_engine(
      engine = "glmnet"
    ) %>%
    parsnip::fit(
      y ~
        special_segment
      + special_segment:(
        categoryId
        + pc1
        + likes
        + dislikes
        + comment_count
        + title_length
        + tag_characters
        + tag_count
        + description_length
        + diff_likes_dislikes
        + sum_likes_dislikes
        + days_from_published
        + flg_japanese
        + published_dow
        + published_month
        + published_year
        + flg_no_tags
        + ratio_likes
        + ratio_comments_likedis
        + flg_no_description
        + description_length
        + flg_url
        + url_count
        + flg_emoji
        + flg_official
        + flg_movie_number
        + flg_categoryId_low
        + categoryId_mean_y
        + categoryId_min_y
        + published_year_mean_y
        + flg_japanese_mean_y
        + categoryId_max_comment_count
        + published_year_mean_pc1
        + comments_disabled_mean_pc1
        + diff_comments_disabled_mean_dislikes
        + published_year_median_likes
        + diff_published_year_mean_dislikes
      )
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
      "LR",
      lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S"),
      sep = "_"
    ) %>%
      stringr::str_c("csv", sep = ".")

    # 出力ファイルパス
    filepath <- stringr::str_c("models/LR/01/output", filename, sep = "/")

    # 書き出し
    readr::write_csv(df.result, filepath, col_names = T)
  }

