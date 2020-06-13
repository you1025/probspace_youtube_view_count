# TODO

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx

# train_rmse: 0.8051424, test_rmse: 0.8877055 - Baseline

# train_rmse: 0.7567539, test_rmse: 0.9098036 - published_hour2_x + published_hour2_y あかんか・・・
# train_rmse: 0.7993837, test_rmse: 0.8954024 - special_segment

# 以下 special_segment との交互作用
# train_rmse: 0.801866,  test_rmse: 0.8942387 - likes(なか)
# train_rmse: 0.792131,  test_rmse: 0.8906203 - likes(両方)
# train_rmse: 0.7987141, test_rmse: 0.8906473 - dislikes(なか)
# train_rmse: 0.794522,  test_rmse: 0.891198  - dislikes(両方)
# これはあかん

# train_rmse: 0.7787947, test_rmse: 0.8837981 - ↑categoryId_mean_y
# train_rmse: 0.7702758, test_rmse: 0.8855408 - categoryId_median_y
# train_rmse: 0.7558027, test_rmse: 0.8807845 - ↑categoryId_min_y
# train_rmse: 0.7394776, test_rmse: 0.8815971 - categoryId_max_y
# train_rmse: 0.7543211, test_rmse: 0.8821408 - published_year_mean_y
# train_rmse: 0.7543541, test_rmse: 0.8820101 - published_year_median_y
# train_rmse: 0.7547896, test_rmse: 0.8825453 - published_year_min_y
# train_rmse: 0.7549985, test_rmse: 0.8822973 - published_year_max_y
# train_rmse: 0.7544892, test_rmse: 0.8839957 - flg_japanese_mean_y
# train_rmse: 0.7542313, test_rmse: 0.8842495 - flg_japanese_median_y
# train_rmse: 0.7542625, test_rmse: 0.8830347 - flg_japanese_min_y
# train_rmse: 0.7529564, test_rmse: 0.8840291 - flg_japanese_max_y

# train_rmse: xxxxxxxxx, test_rmse: 0.8803982 - special_segment の閾値を 0.105 に変更

# train_rmse: 0.8010475, test_rmse: 0.8658069 - xxx
# train_rmse: 0.7961006, test_rmse: 0.8650331 - xxx
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx



library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/SVM/01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)


# Model Definition --------------------------------------------------------

model <- parsnip::svm_rbf(
  mode = "regression",
  cost = parsnip::varying(),
  rbf_sigma = parsnip::varying(),
  margin = parsnip::varying()
) %>%
  parsnip::set_engine(engine = "kernlab")


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- dials::grid_regular(
  # dials::cost(range = c(0.03562391, 0.03562391)),
  # dials::rbf_sigma(range = c(-0.95, -0.95)),
  # dials::margin(range = c(0.12714286, 0.12714286)),
  dials::cost(range = c(0.12, 0.12)),
  dials::rbf_sigma(range = c(-1.3, -1.3)),
  dials::margin(range = c(0.1233333, 0.1233333)),
  levels = 1
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

      # パラメータの適用
      model.applied <- parsnip::set_args(model, ...)

      # モデル構築用の説明変数を指定
      formula <- (
        y ~
          likes
        + dislikes
        + comment_count
        + tag_characters
        + flg_japanese
        + ratings_disabled
        + published_year
        + flg_categoryId_low
        + flg_categoryId_high
        + categoryId_mean_y
        + categoryId_min_y
      )

      # クロスバリデーションの分割ごとにモデル構築&評価
      purrr::map_dfr(
#      furrr::future_map_dfr(
        df.cv$splits,
        train_and_eval,
        recipe = recipe,
        model = model.applied,
        formula = formula
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
  