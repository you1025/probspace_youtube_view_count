# TODO
# - collection_date の謎 これたぶんデータ取得日なので経過日数が算出可能(OK)
# - like + dislike (OK)
# - like / (like + dislike) (OK)
# - 月の中の日数は効くか？(OK)
# - URL が含まれると変わるか？ (OK)
# - 公式動画の推定(OK)
# - 絵文字(OK)
# - #xx(回数) (OK)
# - URL の個数 (OK)

# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: xxxxxxxx, test_rmse: xxxxxxxx - xxx

# penalty: 0.001668101, mixture: 0.8611111, train_rmse: 1.021235, test_rmse: 1.025976 - Baseline
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 1.021237, test_rmse: 1.025978 - 経過日数
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 1.02125,  test_rmse: 1.025985 - ↓経過日数(対数)
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 1.017706, test_rmse: 1.022861 - ↑likes + dislikes
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 1.000497, test_rmse: 1.005436 - ↑likes/(likes+dislikes)
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 1.000459, test_rmse: 1.005534 - published_term_in_month(3分割)
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 1.000388, test_rmse: 1.005651 - published_term_in_month(6分割)
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 0.9995683,test_rmse: 1.004556 - ↑flg_url
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 0.9994937,test_rmse: 1.004499 - ↑flg_emoji
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 0.9971707,test_rmse: 1.002209 - ↑flg_official
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 0.996676, test_rmse: 1.001768 - ↑url_count
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 0.9963537,test_rmse: 1.001409 - ↑url_count(対数)
# penalty: 0.0016681,   mixture: 0.8611111, train_rmse: 0.9959927,test_rmse: 1.001099 - ↑flg_count(factor)
# penalty: 0.001258925, mixture: 0.9111111, train_rmse: 0.9959191,test_rmse: 1.001099 - flg_count(数値)
# penalty: 0.001258925, mixture: 0.8888889, train_rmse: 0.9959519,test_rmse: 1.001085 - 何やかや色々直した


library(tidyverse)
library(tidymodels)
library(furrr)

source("models/LR_02/functions.R", encoding = "utf-8")

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
#  dials::penalty(c(-2.777778, -2.777778)),
#  dials::mixture(c(0.8611111, 0.8611111)),
  dials::penalty(c(-2.9, -2.5)),
  dials::mixture(c(0.8, 1.0)),
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
