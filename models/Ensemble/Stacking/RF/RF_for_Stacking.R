library(tidyverse)
library(tidymodels)
library(furrr)

source("models/RF/functions_RF.R", encoding = "utf-8")
source("models/Ensemble/Stacking/RF/functions_Stacking_RF.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean() %>%
  add_extra_features_train()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean() %>%
  add_extra_features_test()

# for Cross-Validation
df.cv <- create_cv(df.train_data)


# 前処理レシピの作成
recipe <- create_recipe(df.train_data)

# 学習＆予測用データの生成
trained_recipe <- recipes::prep(recipe, training = df.train_data)
df.train <- recipes::juice(trained_recipe) %>%
  add_features_per_category(., .)
df.test  <- recipes::bake(trained_recipe, new_data = df.test_data) %>%
  add_features_per_category(df.train)


# Model Definition --------------------------------------------------------

model <- parsnip::rand_forest(
  mode = "regression",
  mtry  = 10,
  trees = 1000,
  min_n = 3
) %>%
  parsnip::set_engine(
    engine = "ranger",
#    max.depth = 16,  # shallow
    max.depth = 26,  # deep
    num.threads = 8,
    seed = NULL
  )


# 並列処理
future::plan(future::multisession(workers = 5))

system.time({

  # モデル構築用の説明変数を指定
  formula <- (
    y ~
      categoryId
    + likes
    + dislikes
    + comment_count
    + comments_disabled
    + ratings_disabled
    + title_length
    + published_year
    + tag_count
    + tag_characters
    + description_length
    + days_from_published
    + flg_japanese
    + flg_official
    + flg_categoryId_high
    + published_month
    + channel_title_length
    + flg_url
    + url_count
    + comments_ratings_disabled_japanese
    + categoryId_max_y
    + categoryId_mean_likes
    + categoryId_median_likes
    + categoryId_min_likes
    + categoryId_max_likes
    + categoryId_mean_dislikes
    + categoryId_max_dislikes
    + categoryId_sd_dislikes
    + flg_japanese_mean_comment_count
    + comments_ratings_disabled_japanese_sd_y
    + comments_ratings_disabled_japanese_sd_likes
    + weighted_avg_recent_y
  )

  # seed の生成
  set.seed(1025)
  seeds <- sample(1:10000, size = 10, replace = F)

  # 訓練データに対する予測値の算出
  df.predicted.train <-

    # seed 毎に予測値を生成
    purrr::map_dfr(seeds, function(seed) {

      # seed 指定
      model.with_seed <- parsnip::set_args(model, seed = seed)
  
      furrr::future_map_dfr(
        df.cv$splits,
        train_and_predict,
        recipe = recipe,
        model = model.with_seed,
        formula = formula,
        .options = furrr::future_options(seed = 1025L)
      )
    }) %>%
    
    # seed averaging
    dplyr::group_by(id) %>%
    dplyr::summarise(predicted = mean(predicted)) %>%
    
    dplyr::arrange(id)


  # テストデータに対する予測値の算出
  df.predicted.test <-

    # seed 毎に予測値を生成
    purrr::map_dfr(seeds, function(seed) {

      # seed 指定
      model.with_seed <- parsnip::set_args(model, seed = seed)

      # 訓練データで学習
      model.fitted <- parsnip::fit(model.with_seed, formula, data = df.train)

      df.test %>%
        dplyr::mutate(predicted = predict(model.fitted, df.test, type = "numeric")[[1]]) %>%
        dplyr::select(
          id,
          predicted
        )
    }) %>%
    
    # seed averaging
    dplyr::group_by(id) %>%
    dplyr::summarise(predicted = mean(predicted)) %>%
    
    dplyr::arrange(id)


  # ファイルへの書き出し
  save_predicts("RF", df.predicted.train, df.predicted.test)
})
