# TODO

# layers: x, units: xx, act: xxxx, l1: xxxxx, l2: xxxxx, train_mse: xxxxxxxxx, test_mse: xxxxxxxxx - xxx

# layers: 3, units: 32, act: relu, l1: 1e-04, l2: 1e-04, train_mse: 0.7604166, test_mse: 0.7867602 - xxx
# layers: 3, units: 64, act: relu, l1: 1e-05, l2: 1e-05, train_mse: 0.7641199, test_mse: 0.7922832 - xxx
# layers: 4, units: 64, act: relu, l1: 1e-05, l2: 1e-06, train_mse: 0.6306253, test_mse: 0.7066684 - xxx
# layers: 4, units:128, act: relu, l1: 1e-06, l2: 1e-05, train_mse: 0.4962074, test_mse: 0.7029339 - xxx
# layers: 3, units: 64, act: relu, l1: 1e-05, l2: 1e-04, train_mse: 0.6923259, test_mse: 0.7407603 - xxx
# layers: 3, units:128, act: relu, l1: 1e-05, l2: 1e-05, train_mse: 0.4493397, test_mse: 0.6392591 - xxx
# layers: x, units: xx, act: xxxx, l1: xxxxx, l2: xxxxx, train_mse: xxxxxxxxx, test_mse: xxxxxxxxx - xxx
# layers: x, units: xx, act: xxxx, l1: xxxxx, l2: xxxxx, train_mse: xxxxxxxxx, test_mse: xxxxxxxxx - xxx




library(tidyverse)
library(tidymodels)
library(furrr)
library(keras)
#keras::use_session_with_seed(1025)

source("models/NN_01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data) 
# %>%
#   recipes::step_rm(
#     
#   )
#recipes::prep(recipe) %>% recipes::juice() %>% colnames


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- tidyr::crossing(
  layers = c(3, 4),
  units = c(32, 64, 128),
  activation = c("relu"),
  l1 = c(1e-5, 1e-6),
  l2 = c(1e-4, 1e-5, 1e-6),
  dropout_rate = c(0.000),
  batch_size = c(64)
)
df.grid.params




# Parametr Fitting --------------------------------------------------------

# 並列処理
future::plan(future::multisession(workers = 8))

system.time({
  set.seed(1025)

  df.results <-

    # ハイパーパラメータの組み合わせごとにループ
    furrr::future_pmap_dfr(df.grid.params, function(..., cv, recipe) {

      # ハイパラ一覧
      params <- list(...)

      # モデル作成
      model <- create_model_applied_parameters(params)

      # クロスバリデーションの分割ごとにモデル構築&評価
      purrr::map_dfr(cv$splits, train_and_eval_nn, recipe = recipe, model = model, batch_size = params$batch_size) %>%

        # CV 分割全体の平均値を評価スコアとする
        dplyr::summarise_all(mean)

    }, cv = df.cv, recipe = recipe) %>%

    # 評価結果とパラメータを結合
    dplyr::bind_cols(df.grid.params) %>%

    # 評価スコアの順にソート(昇順)
    dplyr::arrange(
      test_mse
    ) %>%

    dplyr::select(
      colnames(df.grid.params),

      train_mse,
      test_mse
    )
})
df.results
