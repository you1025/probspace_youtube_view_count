# TODO

# train_rmse: 0.8817789, test_rmse: 0.9531775 - Baseline

# train_rmse: 0.872091, test_rmse: 0.9522686 - ↑tag_point

# train_rmse: 0.8446193, test_rmse: 0.9251629 - ↑avg_recent_y
# train_rmse: 0.8396679, test_rmse: 0.9149037 - ↑weighted_avg_recent_y
# train_rmse: 0.8507405, test_rmse: 0.9300287 - avg_recent_y + weighted_avg_recent_y

# train_rmse: 0.8941324, test_rmse: 0.959939  - flg_low_y_1000
# train_rmse: 0.8607252, test_rmse: 0.9266668 - flg_low_y_5000
# train_rmse: 0.8445265, test_rmse: 0.9067375 - ↑flg_low_y_10000
# train_rmse: 0.8615729, test_rmse: 0.924614  - flg_low_y_30000
# train_rmse: 0.8331444, test_rmse: 0.8965569 - ↑flg_low_y_10000 + flg_low_y_30000
# train_rmse: 0.834527 , test_rmse: 0.900925  - flg_low_y_10000 + flg_low_y_30000 + flg_low_y_5000
# train_rmse: 0.8354684, test_rmse: 0.901307  - flg_low_y_10000 + flg_low_y_30000 + flg_low_y_1000

# test_rmse: xxxxxxxxx, train_rmse: xxxxxxxxx - xxx
# test_rmse: xxxxxxxxx, train_rmse: xxxxxxxxx - xxx
# test_rmse: xxxxxxxxx, train_rmse: xxxxxxxxx - xxx
# test_rmse: xxxxxxxxx, train_rmse: xxxxxxxxx - xxx


library(tidyverse)
library(tidymodels)
library(furrr)
library(keras)
library(tensorflow)

source("models/NN/02/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean() %>%
  add_extra_features_train()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- tidyr::crossing(
  layers = c(2),
  units = c(512),
  activation = c("relu"),
  l1 = c(1e-4),
  l2 = c(1e-4),
  dropout_rate = c(0.06),
  batch_size = c(64)
)
# df.grid.params <- tibble(
#   layers = c(2),
#   units = c(512),
#   activation = c("relu"),
#   l1 = c(1e-4),
#   l2 = c(1e-4),
#   dropout_rate = c(0.06),
#   batch_size = c(64)
# )
# df.grid.params <- tibble(
#   layers = c(7),
#   units = c(512),
#   activation = c("relu"),
#   l1 = c(1e-3),
#   l2 = c(1e-4),
#   dropout_rate = c(0.027),
#   batch_size = c(64)
# )
df.grid.params


# Parametr Fitting --------------------------------------------------------

# 並列処理
future::plan(future::multisession(workers = 5))

system.time({

  df.results <-

    # ハイパーパラメータの組み合わせごとにループ
#    furrr::future_pmap_dfr(df.grid.params, function(...) {
    purrr::pmap_dfr(df.grid.params, function(...) {

      # ハイパラ一覧
      params <- list(...)

      # クロスバリデーションの分割ごとにモデル構築&評価
#      purrr::map_dfr(
      furrr::future_map_dfr(
        df.cv$splits,
        train_and_eval,
        recipe = recipe,
        params = params,
        batch_size = params$batch_size
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
