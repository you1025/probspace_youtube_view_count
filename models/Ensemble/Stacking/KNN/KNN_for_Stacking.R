library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/KNN/functions_KNN.R", encoding = "utf-8")
source("models/Ensemble/Stacking/KNN/functions_Stacking_KNN.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean()

# for Cross-Validation
df.cv <- create_cv(df.train_data)


# 前処理レシピの作成
recipe <- create_recipe(df.train_data)

# 学習＆予測用データの生成
trained_recipe <- recipes::prep(recipe, training = df.train_data)
df.train <- recipes::juice(trained_recipe) %>%
  add_special_segment() %>%
  add_features_per_category(., .)
df.test  <- recipes::bake(trained_recipe, new_data = df.test_data) %>%
  add_special_segment() %>%
  add_features_per_category(df.train)


# Model Definition --------------------------------------------------------

model <- parsnip::nearest_neighbor(
  mode = "regression",
  neighbors = 20
) %>%
  parsnip::set_engine(engine = "kknn")


# 並列処理
future::plan(future::multisession(workers = 5))

system.time({
  set.seed(1025)

  # モデル構築用の説明変数を指定
  formula <- (
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
  )


  # 訓練データに対する予測値の算出
  df.predicted.train <- furrr::future_map_dfr(
    df.cv$splits,
    train_and_predict,
    recipe = recipe,
    model = model,
    formula = formula,
    .options = furrr::future_options(seed = 1025L)
  ) %>%
    dplyr::arrange(id)

  # テストデータに対する予測値の算出
  df.predicted.test <- parsnip::fit(model, formula, data = df.train) %>%
    {
      fit <- (.)
      df.test %>%
        dplyr::mutate(predicted = predict(fit, df.test,  type = "numeric")[[1]]) %>%
        dplyr::select(
          id,
          predicted
        )
    }

  # ファイルへの書き出し
  save_predicts("KNN", df.predicted.train, df.predicted.test)
})
