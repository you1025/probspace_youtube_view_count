library(tidyverse)
library(tidymodels)

source("models/KNN/01/functions.R", encoding = "utf-8")

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
    add_special_segment() %>%
    add_features_per_category(., .)

  # 学習の実施
  model <- parsnip::nearest_neighbor(
    mode = "regression",
    neighbors = 20
  ) %>%
    parsnip::set_engine(engine = "kknn") %>%
    parsnip::fit(
      y ~
        likes
      + dislikes
      + title_length
      + tag_characters
      + description_length
      + url_count
      + comments_disabled
      + ratings_disabled
      + published_year
      + sum_likes_dislikes
      + diff_likes_dislikes
      + (special_segment_others + special_segment_ratings_disabled + special_segment_ratings_abled_low_comments)
      + (special_segment_others + special_segment_ratings_disabled + special_segment_ratings_abled_low_comments):(
        likes
        + dislikes
        + sum_likes_dislikes
        + sum_likes_dislikes_comments
        + flg_japanese
        + days_from_published
      )
      + categoryId_mean_y
      + categoryId_median_y
      + categoryId_min_y
      + categoryId_max_y
      + published_year_mean_y
      + flg_japanese_mean_y
      + flg_japanese_median_y
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
      add_special_segment() %>%
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
      "KNN",
      lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S"),
      sep = "_"
    ) %>%
      stringr::str_c("csv", sep = ".")
    
    # 出力ファイルパス
    filepath <- stringr::str_c("models/KNN/01/output", filename, sep = "/")
    
    # 書き出し
    readr::write_csv(df.result, filepath, col_names = T)
  }

