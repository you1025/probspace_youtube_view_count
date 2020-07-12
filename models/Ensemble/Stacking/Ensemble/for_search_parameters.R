library(tidyverse)
library(tidymodels)

# train_mse: 0.7637331, test_rmse: 0.7840924 - XGB
# train_mse: 0.7565816, test_rmse: 0.7801578 - ↑LGBM
# train_mse: 0.7534993, test_rmse: 0.7785501 - ↑RF
# train_mse: 0.7504378, test_rmse: 0.7777353 - ↑SVM
# train_mse: 0.7492208, test_rmse: 0.7775731 - ↑KNN
# train_mse: 0.7481104, test_rmse: 0.7770977 - ↑NN
# train_mse: 0.7477699, test_rmse: 0.777681  - LR
# train_mse: 0.7482262, test_rmse: 0.7775796 - tag_point

# train_mse: 0.7482857, test_rmse: 0.7775183 - avg_recent_y
# train_mse: 0.7483303, test_rmse: 0.7777278 - weighted_avg_recent_y
# train_mse: 0.7484825, test_rmse: 0.7775041 - avg_recent_y + weighted_avg_recent_y

# train_mse: 0.7469812, test_rmse: 0.7778192 - low_y_1000
# train_mse: 0.7470922, test_rmse: 0.7779034 - low_y_5000
# train_mse: 0.7469218, test_rmse: 0.7777761 - low_y_10000
# train_mse: 0.7471571, test_rmse: 0.7780204 - low_y_30000

# train_mse: 0.7477173, test_rmse: 0.7782519 - Baseline
# train_mse: 0.7466045, test_rmse: 0.7774965 - ↑V1 + V2

# train_mse: 0.7472175, test_rmse: 0.7778517 - cluster.5
# train_mse: 0.7471588, test_rmse: 0.7778286 - cluster.10
# train_mse: 0.7470885, test_rmse: 0.7781813 - cluster.50
# train_mse: 0.7471754, test_rmse: 0.7778311 - cluster.100
# train_mse: 0.7469435, test_rmse: 0.7780033 - cluster.500
# train_mse: 0.7470441, test_rmse: 0.7771654 - ↑cluster.10 + cluster.100
# train_mse: 0.7476508, test_rmse: 0.7773694 - cluster.10 + cluster.100 + cluster.5
# train_mse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx


source("models/Ensemble/Stacking/Ensemble/functions_Stacking_Ensemble.R", encoding = "utf-8")

df.train_data <- load_stacking_train_data()

df.cv <- rsample::vfold_cv(df.train_data, v = 5, strata = "y")


# Model Definition --------------------------------------------------------

model <- parsnip::boost_tree(
  mode = "regression",
  learn_rate = 0.01,
  trees = 727,

  tree_depth = parsnip::varying(),
  mtry = parsnip::varying(),

  min_n = parsnip::varying(),
  sample_size = parsnip::varying(),

  loss_reduction = parsnip::varying()
) %>%
  parsnip::set_engine(
    engine = "xgboost",
    nthread = 1
  )


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- dials::grid_regular(
  dials::tree_depth(range = c(4, 4)),
  dials::mtry(range = c(5, 5)),
  dials::min_n(range = c(9, 9)),
  dials::loss_reduction(range = c(-0.2966667, -0.2966667)),
  levels = 12
) %>%
  tidyr::crossing(
    sample_size = 0.7217391
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
        KNN
        + SVM
        + NN.shallow
        + NN.deep
        + RF.shallow
        + RF.deep
        + XGB.shallow
        + XGB.middle
        + XGB.deep
        + LGBM.shallow
        + LGBM.deep
        + V1
        + V2
        + cluster.10
        + cluster.100
      )

      # クロスバリデーションの分割ごとにモデル構築&評価
      purrr::map_dfr(
#      furrr::future_map_dfr(
        df.cv$splits,
        train_and_eval,
        model = model.applied,
        formula = formula
#        ,.options = furrr::future_options(seed = 1025L)
      ) %>%
  
        # CV 分割全体の平均値を評価スコアとする
        dplyr::summarise_all(mean)
  }, .options = furrr::future_options(seed = 1025L)) %>%
#  }) %>%

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

