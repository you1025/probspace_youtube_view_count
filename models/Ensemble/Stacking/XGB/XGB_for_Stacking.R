library(tidyverse)
library(tidymodels)
library(furrr)

source("models/XGB/functions_XGB.R", encoding = "utf-8")
source("models/Ensemble/Stacking/XGB/functions_Stacking_XGB.R", encoding = "utf-8")

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

# model.shallow <- parsnip::boost_tree(
#   mode = "regression",
#   learn_rate = 0.01,
#   trees = 2774,
#   tree_depth = 7,
#   mtry = 35,
#   min_n = 2,
#   sample_size = 0.9,
#   loss_reduction = 10^(-0.2706667)
# ) %>%
#   parsnip::set_engine(
#     engine = "xgboost",
#     nthread = 1
#   )
# model.middle <- parsnip::boost_tree(
#   mode = "regression",
#   learn_rate = 0.01,
#   trees = 1423,
#   tree_depth = 12,
#   mtry = 34,
#   min_n = 2,
#   sample_size = 0.9,
#   loss_reduction = 10^(-0.2633333)
# ) %>%
#   parsnip::set_engine(
#     engine = "xgboost",
#     nthread = 1
#   )
model.deep <- parsnip::boost_tree(
  mode = "regression",
  learn_rate = 0.01,
  trees = 988,
  tree_depth = 17,
  mtry = 25,
  min_n = 5,
  sample_size = 0.9,
  loss_reduction = 10^(-0.3071429)
) %>%
  parsnip::set_engine(
    engine = "xgboost",
    nthread = 1
  )
model <- model.deep


# 並列処理
future::plan(future::multisession(workers = 8))

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
    + tag_point
    + weighted_avg_recent_y
  )

  # seed の生成
  set.seed(1025)
  seeds <- sample(1:10000, size = 10, replace = F)

  # 訓練データに対する予測値の算出
  df.predicted.train <-

    # seed 毎に予測値を生成
    purrr::map_dfr(seeds, function(seed) {

      furrr::future_map_dfr(
        df.cv$splits,
        train_and_predict,
        recipe = recipe,
        model = model,
        formula = formula,
        seed,
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
    furrr::future_map_dfr(seeds, function(seed) {

      set.seed(seed)

      # 訓練データで学習
      model.fitted <- parsnip::fit(model, formula, data = df.train)

      df.test %>%
        dplyr::mutate(predicted = predict(model.fitted, df.test, type = "numeric")[[1]]) %>%
        dplyr::select(
          id,
          predicted
        )
    }, .options = furrr::future_options(seed = 1025L)) %>%
    
    # seed averaging
    dplyr::group_by(id) %>%
    dplyr::summarise(predicted = mean(predicted)) %>%
    
    dplyr::arrange(id)


  # ファイルへの書き出し
  save_predicts("XGB", df.predicted.train, df.predicted.test)
})
