# TODO
# - カテゴリ処理の有無(OK)

# max_depth: 11, num_leaves: 36, min_data_in_leaf: 25, feature_fraction: 0.5, bagging_freq: 2, bagging_fraction: 0.925, lambda_l1: 0.65, lambda_l2: 0.95, train_rmse: 0.55471,   test_rmse: 0.8061451 - Baseline

# lambda_l1: 0.65,  lambda_l1: 0.95,  train_rmse: 0.5836626, test_rmse: 0.8078496 - xxx
# lambda_l1: 1e-11, lambda_l1: 1e-06, train_rmse: 0.562915,  test_rmse: 0.8062154 - xxx
# lambda_l1: 0.725, lambda_l1: 0.925, train_rmse: 0.5526955, test_rmse: 0.8057299 - xxx

# learning_rate: 0.01, train_rmse: 0.51101,   test_rmse: 0.7937914 - # lambda_l1: 0.725, lambda_l1: 0.925
# learning_rate: 0.01, train_rmse: 0.5157549, test_rmse: 0.793986  - # lambda_l1: 1e-11, lambda_l1: 1e-06

# max_depth: xx, num_leaves: xx, min_data_in_leaf: xx, train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# max_depth: xx, num_leaves: xx, min_data_in_leaf: xx, train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# max_depth: xx, num_leaves: xx, min_data_in_leaf: xx, train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx



library(tidyverse)
library(tidymodels)
library(furrr)
library(lightgbm)

options(warn = -1)

source("models/LGBM_01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)
#recipes::prep(recipe) %>% recipes::juice() %>% summary()


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- tibble(
  learning_rate = 0.01,

  max_depth = 11,
  num_leaves = 36,
  min_data_in_leaf = 25,

  feature_fraction = 0.64,

  bagging_freq = 2,
  bagging_fraction = 0.91,

  lambda_l1 = 0.725,
  lambda_l2 = 0.925
)
# %>%
#   tidyr::crossing(
#     lambda_l1 = seq(0.7, 0.8, 0.025),
#     lambda_l2 = seq(0.925, 0.975, 0.025)
#   )
df.grid.params


# Parametr Fitting --------------------------------------------------------

# 並列処理
future::plan(future::multisession(workers = 8))

system.time({
  set.seed(1025)

  df.results <-

    # ハイパーパラメータの組み合わせごとにループ
#    furrr::future_pmap_dfr(df.grid.params, function(...) {
    purrr::pmap_dfr(df.grid.params, function(...) {

      # ハイパーパラメータ一覧
      hyper_params <- list(...)

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
        + published_month
        + published_dow
        + published_hour
        + channel_title_length
        + flg_categoryId_low
        + tag_characters
        + tag_count
        + description_length
        + url_count
        + days_from_published
        + diff_likes_dislikes
        + ratio_comments_likedis
        + flg_japanese
      )

      # クロスバリデーションの分割ごとにモデル構築&評価
#      purrr::map_dfr(
      furrr::future_map_dfr(
        df.cv$splits,
        train_and_eval_LGBM,
        recipe = recipe,
        formula = formula,
        hyper_params = hyper_params
        ,.options = furrr::future_options(seed = 1025L)
      ) %>%

        # CV 分割全体の平均値を評価スコアとする
        dplyr::summarise_all(mean)
#    }, .options = furrr::future_options(seed = 1025L)) %>%
    }) %>%

    # 評価結果とパラメータを結合
    dplyr::bind_cols(df.grid.params) %>%

    # 評価スコアの順にソート(昇順)
    dplyr::arrange(
      test_rmse
    ) %>%

    dplyr::select(
      colnames(df.grid.params),

      train_rmse,
      test_rmse
    )
})
df.results
