# penalty: xxxxxxxxxxxx, mixture: xxxxx, train_rmse: xxxxxxxx, test_rmse: xxxxxxxx

# penalty: 3.162278e-03, mixture: 1.00,      train_rmse: 1.021679, test_rmse: 1.027312
# penalty: 0.0031622777, mixture: 0.750,     train_rmse: 1.021570, test_rmse: 1.026032 - strata 追加
# penalty: 0.001668101,  mixture: 0.8611111, train_rmse: 1.021235, test_rmse: 1.025976


library(tidyverse)
library(tidymodels)
library(furrr)

source("models/LR_01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)
#recipes::prep(recipe) %>% recipes::juice() %>% summary()


# Model Definition --------------------------------------------------------

model <- parsnip::linear_reg(
  mode = "regression",
  penalty = parsnip::varying(),
  mixture = parsnip::varying()
) %>%
  parsnip::set_engine(engine = "glmnet")


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- dials::grid_regular(
  dials::penalty(c(-3, -2)),
  dials::mixture(c(0.75, 1)),
  levels = 10
)
df.grid.params


# Parametr Fitting --------------------------------------------------------

# 並列処理
future::plan(future::multisession(workers = 8))

system.time({
  set.seed(1025)

  df.results <-

    # ハイパーパラメータをモデルに適用
    purrr::pmap(df.grid.params, function(penalty, mixture) {
      parsnip::set_args(
        model,
        penalty = penalty,
        mixture = mixture
      )
    }) %>%

    # ハイパーパラメータの組み合わせごとにループ
    furrr::future_map_dfr(function(model.applied) {

      # クロスバリデーションの分割ごとにモデル構築&評価
      purrr::map_dfr(df.cv$splits, train_and_eval, recipe = recipe, model = model.applied) %>%

        # CV 分割全体の平均値を評価スコアとする
        dplyr::summarise_all(mean)
    }) %>%

    # 評価結果とパラメータを結合
    dplyr::bind_cols(df.grid.params) %>%

    # 評価スコアの順にソート(昇順)
    dplyr::arrange(
      test_rmse
    ) %>%
    
    dplyr::select(
      penalty,
      mixture,
      
      train_rmse,
      test_rmse
    )
})
df.results
