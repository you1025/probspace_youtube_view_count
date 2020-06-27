# TODO

# train_rmse: 0.7961006, test_rmse: 0.8650331 - Baseline

# train_rmse: 0.787838 , test_rmse: 0.8659343 - tag_point

# train_rmse: 0.7660826, test_rmse: 0.8542474 - ↑avg_recent_y
# train_rmse: 0.7653286, test_rmse: 0.853294  - ↑weighted_avg_recent_y(☆)
# train_rmse: 0.759413 , test_rmse: 0.8549159 - ↑avg_recent_y + weighted_avg_recent_y

# train_rmse: 0.7501024, test_rmse: 0.8518138 - ↑flg_low_y_1000
# train_rmse: 0.7432065, test_rmse: 0.8446147 - ↑flg_low_y_5000
# train_rmse: 0.7388587, test_rmse: 0.8406223 - ↑flg_low_y_10000
# train_rmse: 0.7444148, test_rmse: 0.8432    - ↑flg_low_y_30000
# train_rmse: 0.7280374, test_rmse: 0.8381684 - ↑flg_low_y_10000 + flg_low_y_30000
# train_rmse: 0.7206949, test_rmse: 0.8395865 - flg_low_y_10000 + flg_low_y_30000 + flg_low_y_5000
# train_rmse: 0.7196573, test_rmse: 0.8405293 - flg_low_y_10000 + flg_low_y_30000 + flg_low_y_1000
# train_rmse: 0.7133436, test_rmse: 0.842859  - flg_low_y_10000 + flg_low_y_30000 + flg_low_y_1000 + flg_low_y_5000

# train_rmse: 0.7446848, test_rmse: 0.8273469 - ハイパラチューニング


library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/SVM/02/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean() %>%
  add_extra_features_train()

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
  dials::cost(range = c(1.36, 1.36)), # あとで
  dials::rbf_sigma(range = c(-1.6, -1.6)),
  dials::margin(range = c(0.137, 0.137)),
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
        + weighted_avg_recent_y
        + flg_low_y_10000
        + flg_low_y_30000
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
  