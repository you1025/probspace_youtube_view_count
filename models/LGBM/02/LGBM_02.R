# TODO

# train_rmse: 0.6096198, test_rmse: 0.8082154 - Baseline

# train_rmse: 0.6035131, test_rmse: 0.8053323 - ↑tag_point

# train_rmse: 0.6303428, test_rmse: 0.7981841 - ↑avg_recent_y
# train_rmse: 0.6110836, test_rmse: 0.7966263 - ↑weighted_avg_recent_y
# train_rmse: 0.6306855, test_rmse: 0.796887  - avg_recent_y + weighted_avg_recent_y

# train_rmse: 0.6249948, test_rmse: 0.8051897 - flg_low_y_1000
# train_rmse: 0.6298613, test_rmse: 0.8019657 - flg_low_y_5000
# train_rmse: 0.6468505, test_rmse: 0.8040411 - flg_low_y_10000
# train_rmse: 0.6448286, test_rmse: 0.8104284 - flg_low_y_30000
# train_rmse: 0.6509707, test_rmse: 0.8039612 - flg_low_y_5000 + flg_low_y_10000
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_low_y_10000 + flg_low_y_30000 + flg_low_y_5000
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_low_y_10000 + flg_low_y_30000 + flg_low_y_1000
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_low_y_10000 + flg_low_y_30000 + flg_low_y_1000 + flg_low_y_5000

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - ハイパラチューニング

# train_rmse: 0.5596695, test_rmse: 0.7911912 - xxx


library(tidyverse)
library(tidymodels)
library(furrr)
library(lightgbm)

options(warn = -1)

source("models/LGBM/02/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean() %>%
  add_extra_features_train()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- tidyr::crossing(
  learning_rate = 0.01,

  max_depth = 12,
  num_leaves = 39,
  min_data_in_leaf = 23,

  feature_fraction = 0.9652174,

  bagging_freq = 1,
  bagging_fraction = 0.7956522,

  lambda_l1 = 0.735,
  lambda_l2 = 0.825
)
df.grid.params


# Parametr Fitting --------------------------------------------------------

# 並列処理
future::plan(future::multisession(workers = 8))

system.time({
  set.seed(1025)

  df.results <-

    # ハイパーパラメータの組み合わせごとにループ
    furrr::future_pmap_dfr(df.grid.params, function(...) {
#    purrr::pmap_dfr(df.grid.params, function(...) {

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
        + channel_title_length
        + tag_characters
        + tag_count
        + description_length
        + days_from_published
        + diff_likes_dislikes
        + ratio_likes
        + ratio_comments_likedis
        + flg_japanese
        + published_year
        + flg_url
        + url_count
        + flg_movie_number
        + flg_comments_ratings_disabled_japanese_low
        + categoryId_max_y
        + published_year_max_y
        + tag_point
        + weighted_avg_recent_y
      )

      # クロスバリデーションの分割ごとにモデル構築&評価
      purrr::map_dfr(
#      furrr::future_map_dfr(
        df.cv$splits,
        train_and_eval_LGBM,
        recipe = recipe,
        formula = formula,
        hyper_params = hyper_params
#        ,.options = furrr::future_options(seed = 1025L)
      ) %>%

        # CV 分割全体の平均値を評価スコアとする
        dplyr::summarise_all(mean)
    }, .options = furrr::future_options(seed = 1025L)) %>%
#    }) %>%

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
