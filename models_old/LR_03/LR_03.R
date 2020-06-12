# TODO
# - CV 構築 (OK)
# - 空フラグ(文字列) (OK)
# - comment_count と likes+dislikes との比 (OK)
# - 年末年始 (NO)
# - binning(No)
# - テストデータの範囲を確認 - 過去のデータを対象外にする？
#  - 同じ時間範囲でランダムサンプリングしている模様(channelId の重複も確認) (OK)
# - flg_japanese と hour の関係: いい感じだけど線形モデルでは悪影響 (OK)


# penalty: 0.0006309573, mixture: 0.8566667, train_rmse: xxxxxxxxx, test_rmse: xxxxxxxx - xxx

# penalty: 0.001258925, mixture: 0.8888889, train_rmse: 0.9959519, test_rmse: 1.001085 - LR_02
# penalty: 0.001258925, mixture: 0.8888889, train_rmse: 0.9958207, test_rmse: 1.00232  - CV 変更
# penalty: 0.0006309573,mixture: 0.8566667, train_rmse: 0.9957696, test_rmse: 1.002278 - Baseline

# penalty: 0.0006309573, mixture: 0.8566667, train_rmse: 0.9951655, test_rmse: 1.001744 - ↑空フラグ
# penalty: 0.0006309573, mixture: 0.8566667, train_rmse: 0.9950708, test_rmse: 1.001699 - ↑(kikes+dislikes)/comment_count
# penalty: 0.0006309573, mixture: 0.8566667, train_rmse: 0.9950375, test_rmse: 1.001756 - comment_count + likes + dislikes(棄却)
# penalty: 0.0006309573, mixture: 0.8566667, train_rmse: 0.9947834, test_rmse: 1.001893 - bin_comment_count(棄却)
# penalty: 0.0006309573, mixture: 0.8566667, train_rmse: 0.9951961, test_rmse: 1.001777 - published_houe を JST/UTC に分離(棄却)
# penalty: 0.0006309573, mixture: 0.8566667, train_rmse: 0.996428,  test_rmse: 1.001408 - ↑published_hour を除去

# penalty: 0.0001000000, mixture: 0.9500000, train_rmse: 0.9963423, test_rmse: 1.001331 - xxx




library(tidyverse)
library(tidymodels)
library(furrr)

source("models/LR_03/functions.R", encoding = "utf-8")

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
  # dials::penalty(c(-3.2, -3.2)),
  # dials::mixture(c(0.8566667, 0.8566667)),
  dials::penalty(c(-10, -4)),
  dials::mixture(c(0.75, 1.0)),
  levels = 5
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
