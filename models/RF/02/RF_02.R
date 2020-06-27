# TODO

# train_rmse: 0.3891919, test_rmse: 0.7958897 - Baseline

# train_rmse: 0.3857978, test_rmse: 0.795964  - tag_point

# train_rmse: 0.3888589, test_rmse: 0.7933313 - ↑avg_recent_y
# train_rmse: 0.3893465, test_rmse: 0.7931462 - ↑weighted_avg_recent_y
# train_rmse: 0.3908764, test_rmse: 0.7963324 - avg_recent_y + weighted_avg_recent_y

# train_rmse: 0.3912442, test_rmse: 0.800379  - flg_low_y_1000
# train_rmse: 0.3823915, test_rmse: 0.7958304 - flg_low_y_5000
# train_rmse: 0.3819381, test_rmse: 0.795666  - flg_low_y_10000
# train_rmse: 0.3871789, test_rmse: 0.794334  - flg_low_y_30000
# train_rmse: 0.3869245, test_rmse: 0.7954451 - flg_low_y_10000 + flg_low_y_30000
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_low_y_10000 + flg_low_y_30000 + flg_low_y_5000
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_low_y_10000 + flg_low_y_30000 + flg_low_y_1000
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_low_y_10000 + flg_low_y_30000 + flg_low_y_1000 + flg_low_y_5000

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - ハイパラチューニング

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx


library(tidyverse)
library(tidymodels)
library(furrr)

source("models/RF/02/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean() %>%
  add_extra_features_train()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)


# Model Definition --------------------------------------------------------

model <- parsnip::rand_forest(
  mode = "regression",
  mtry  = parsnip::varying(),
  trees = parsnip::varying(),
  min_n = parsnip::varying()
) %>%
  parsnip::set_engine(
    engine = "ranger",
    num.threads = 1,
    seed = 1025
  )


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- dials::grid_regular(
  dials::mtry(range = c(10, 10)),
  dials::trees(range = c(1000, 1000)),
  dials::min_n(range = c(3, 3)),
  levels = 1
) %>%
  tidyr::crossing(
    max.depth = seq(16, 16)
  )
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

      # パラメータの適用
      model.applied <- parsnip::set_args(model, ...)

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

      # クロスバリデーションの分割ごとにモデル構築&評価
#      purrr::map_dfr(
      furrr::future_map_dfr(
        df.cv$splits,
        train_and_eval,
        recipe = recipe,
        model = model.applied,
        formula = formula
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
