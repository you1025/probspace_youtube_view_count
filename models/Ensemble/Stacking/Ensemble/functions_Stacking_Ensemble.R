source("models/functions_Global.R", encoding = "utf-8")

load_stacking_train_data <- function() {

  # 訓練データ(オリジナル)
  df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

  (
    df.train_data %>%
      dplyr::select(id, y) %>%

      # 対数変換
      dplyr::mutate(
        y = log(y + 1)
      )
  ) %>%

    # LinearRegression
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/LR/output/20200628T015943/LR_train_20200628T015943.csv") %>%
        dplyr::rename(LR = predicted),
      by = "id"
    ) %>%

    # K-NearestNeighbor
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/KNN/output/20200628T025407/KNN_train_20200628T025407.csv") %>%
        dplyr::rename(KNN = predicted),
      by = "id"
    ) %>%

    # SupportVectorMachine
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/SVM/output/20200628T052909/SVM_train_20200628T052909.csv") %>%
        dplyr::rename(SVM = predicted),
      by = "id"
    ) %>%

    # NeuralNetwork
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/NN/output/20200628T061331_shallow/NN_train_20200628T061331.csv") %>%
        dplyr::rename(NN.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/NN/output/20200628T064248_deep/NN_train_20200628T064248.csv") %>%
        dplyr::rename(NN.deep = predicted),
      by = "id"
    ) %>%

    # RandomForest
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/RF/output/20200628T073152_shallow/RF_train_20200628T073152.csv") %>%
        dplyr::rename(RF.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/RF/output/20200628T075159_deep/RF_train_20200628T075159.csv") %>%
        dplyr::rename(RF.deep = predicted),
      by = "id"
    ) %>%

    # XGBoost
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200628T100320_shallow/XGB_train_20200628T100320.csv") %>%
        dplyr::rename(XGB.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200628T103825_middle/XGB_train_20200628T103825.csv") %>%
        dplyr::rename(XGB.middle = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200628T110513_deep/XGB_train_20200628T110513.csv") %>%
        dplyr::rename(XGB.deep = predicted),
      by = "id"
    ) %>%

    # LightGBM
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/LGBM/output/20200628T121442_shallow/LGBM_train_20200628T121442.csv") %>%
        dplyr::rename(LGBM.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/LGBM/output/20200628T124930_deep/LGBM_train_20200628T124930.csv") %>%
        dplyr::rename(LGBM.deep = predicted),
      by = "id"
    ) %>%

    # 直近の平均値(y)
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/use_y_histories/output/20200627T025207_with_impute/avg_y_from_recents_train_20200627T025207.csv"),
      by = "id"
    ) %>%

    # タグポイント
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/tag_points/output/20200627T061040/tag_points_train_20200627T061040.csv"),
      by = "id"
    ) %>%

    # 低視聴フラグ
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/low_y_flag/output/20200627T230808_1000/low_y_flags_train_20200627T230808.csv") %>%
        dplyr::rename(low_y_1000 = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/low_y_flag/output/20200627T235238_5000/low_y_flags_train_20200627T235238.csv") %>%
        dplyr::rename(low_y_5000 = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/low_y_flag/output/20200628T002124_10000/low_y_flags_train_20200628T002124.csv") %>%
        dplyr::rename(low_y_10000 = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/low_y_flag/output/20200628T005739_30000/low_y_flags_train_20200628T005739.csv") %>%
        dplyr::rename(low_y_30000 = predicted),
      by = "id"
    ) %>%

    # UMAP
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/UMAP/output/20200628T145746/UMAP_train_20200628T145746.csv"),
      by = "id"
    )
}

load_stacking_test_data <- function() {

  # テストデータ(オリジナル)
  df.test_data <- load_test_data("data/01.input/test_data.csv") %>% clean()

  (
    df.test_data %>%
      dplyr::select(id)
  ) %>%

    # LinearRegression
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/LR/output/20200628T015943/LR_test_20200628T015943.csv") %>%
        dplyr::rename(LR = predicted),
      by = "id"
    ) %>%

    # K-NearestNeighbor
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/KNN/output/20200628T025407/KNN_test_20200628T025407.csv") %>%
        dplyr::rename(KNN = predicted),
      by = "id"
    ) %>%

    # SupportVectorMachine
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/SVM/output/20200628T052909/SVM_test_20200628T052909.csv") %>%
        dplyr::rename(SVM = predicted),
      by = "id"
    ) %>%

    # NeuralNetwork
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/NN/output/20200628T061331_shallow/NN_test_20200628T061331.csv") %>%
        dplyr::rename(NN.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/NN/output/20200628T064248_deep/NN_test_20200628T064248.csv") %>%
        dplyr::rename(NN.deep = predicted),
      by = "id"
    ) %>%

    # RandomForest
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/RF/output/20200628T073152_shallow/RF_test_20200628T073152.csv") %>%
        dplyr::rename(RF.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/RF/output/20200628T075159_deep/RF_test_20200628T075159.csv") %>%
        dplyr::rename(RF.deep = predicted),
      by = "id"
    ) %>%

    # XGBoost
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200628T100320_shallow/XGB_test_20200628T100320.csv") %>%
        dplyr::rename(XGB.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200628T103825_middle/XGB_test_20200628T103825.csv") %>%
        dplyr::rename(XGB.middle = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200628T110513_deep/XGB_test_20200628T110513.csv") %>%
        dplyr::rename(XGB.deep = predicted),
      by = "id"
    ) %>%

    # LightGBM
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/LGBM/output/20200628T121442_shallow/LGBM_test_20200628T121442.csv") %>%
        dplyr::rename(LGBM.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/LGBM/output/20200628T124930_deep/LGBM_test_20200628T124930.csv") %>%
        dplyr::rename(LGBM.deep = predicted),
      by = "id"
    ) %>%

    # 直近の平均値(y)
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/use_y_histories/output/20200627T025207_with_impute/avg_y_from_recents_test_20200627T025207.csv"),
      by = "id"
    ) %>%

    # タグポイント
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/tag_points/output/20200627T061040/tag_points_test_20200627T061040.csv"),
      by = "id"
    ) %>%

    # 低視聴フラグ
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/low_y_flag/output/20200627T230808_1000/low_y_flags_test_20200627T230808.csv") %>%
        dplyr::rename(low_y_1000 = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/low_y_flag/output/20200627T235238_5000/low_y_flags_test_20200627T235238.csv") %>%
        dplyr::rename(low_y_5000 = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/low_y_flag/output/20200628T002124_10000/low_y_flags_test_20200628T002124.csv") %>%
        dplyr::rename(low_y_10000 = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/low_y_flag/output/20200628T005739_30000/low_y_flags_test_20200628T005739.csv") %>%
        dplyr::rename(low_y_30000 = predicted),
      by = "id"
    ) %>%

    # UMAP
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/UMAP/output/20200628T145746/UMAP_test_20200628T145746.csv"),
      by = "id"
    )
}


# モデルの構築と評価
train_and_eval <- function(split, recipe, model, formula) {

  # 前処理済データの作成
  df.train <- rsample::training(split)
  df.test  <- rsample::testing(split)

  # モデルの学習
  fit <- parsnip::fit(model, formula, data = df.train)


  # 評価指標の一覧を定義
  metrics <- yardstick::metric_set(
    yardstick::rmse
  )

  # train データでモデルを評価
  df.result.train <- df.train %>%
    dplyr::mutate(
      predicted = predict(fit, df.train, type = "numeric")[[1]]
    ) %>%
    metrics(
      truth    = y,
      estimate = predicted
    ) %>%
    dplyr::select(-.estimator) %>%
    dplyr::mutate(
      .metric = stringr::str_c("train", .metric, sep = "_")
    ) %>%
    tidyr::spread(key = .metric, value = .estimate)

  # test データでモデルを評価
  df.result.test <- df.test %>%
    dplyr::mutate(
      predicted = predict(fit, df.test,  type = "numeric")[[1]]
    ) %>%
    metrics(
      truth    = y,
      estimate = predicted
    ) %>%
    dplyr::select(-.estimator) %>%
    dplyr::mutate(
      .metric = stringr::str_c("test", .metric, sep = "_")
    ) %>%
    tidyr::spread(key = .metric, value = .estimate)


  dplyr::bind_cols(
    df.result.train,
    df.result.test
  )
}
