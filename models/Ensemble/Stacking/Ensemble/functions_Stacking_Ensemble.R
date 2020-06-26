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
      readr::read_csv("models/Ensemble/Stacking/LR/output/20200613T002320/LR_train_20200613T002320.csv") %>%
        dplyr::rename(LR = predicted),
      by = "id"
    ) %>%

    # K-NearestNeighbor
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/KNN/output/20200613T001924/KNN_train_20200613T001924.csv") %>%
        dplyr::rename(KNN = predicted),
      by = "id"
    ) %>%

    # SupportVectorMachine
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/SVM/output/20200614T034817/SVM_train_20200614T034817.csv") %>%
        dplyr::rename(SVM = predicted),
      by = "id"
    ) %>%

    # NeuralNetwork
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/NN/output/20200617T235331_low/NN_train_20200617T235331.csv") %>%
        dplyr::rename(NN.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/NN/output/20200618T004346_high/NN_train_20200618T004346.csv") %>%
        dplyr::rename(NN.deep = predicted),
      by = "id"
    ) %>%

    # RandomForest
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/RF/output/20200619T035109_low/RF_train_20200619T035109.csv") %>%
        dplyr::rename(RF.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/RF/output/20200619T041537_high/RF_train_20200619T041537.csv") %>%
        dplyr::rename(RF.deep = predicted),
      by = "id"
    ) %>%

    # XGBoost
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200623T035104_shallow/XGB_train_20200623T035104.csv") %>%
        dplyr::rename(XGB.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200623T063233_middle/XGB_train_20200623T063233.csv") %>%
        dplyr::rename(XGB.middle = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200622T235813_deep/XGB_train_20200622T235813.csv") %>%
        dplyr::rename(XGB.deep = predicted),
      by = "id"
    ) %>%

    # LightGBM
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/LGBM/output/20200626T054221_shallow/LGBM_train_20200626T054221.csv") %>%
        dplyr::rename(LGBM.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/LGBM/output/20200626T033957_deep/LGBM_train_20200626T033957.csv") %>%
        dplyr::rename(LGBM.deep = predicted),
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
      readr::read_csv("models/Ensemble/Stacking/LR/output/20200613T002320/LR_test_20200613T002320.csv") %>%
        dplyr::rename(LR = predicted),
      by = "id"
    ) %>%

    # K-NearestNeighbor
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/KNN/output/20200613T001924/KNN_test_20200613T001924.csv") %>%
        dplyr::rename(KNN = predicted),
      by = "id"
    ) %>%

    # SupportVectorMachine
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/SVM/output/20200614T034817/SVM_test_20200614T034817.csv") %>%
        dplyr::rename(SVM = predicted),
      by = "id"
    ) %>%

    # NeuralNetwork
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/NN/output/20200617T235331_low/NN_test_20200617T235331.csv") %>%
        dplyr::rename(NN.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/NN/output/20200618T004346_high/NN_test_20200618T004346.csv") %>%
        dplyr::rename(NN.deep = predicted),
      by = "id"
    ) %>%

    # RandomForest
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/RF/output/20200619T035109_low/RF_test_20200619T035109.csv") %>%
        dplyr::rename(RF.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/RF/output/20200619T041537_high/RF_test_20200619T041537.csv") %>%
        dplyr::rename(RF.deep = predicted),
      by = "id"
    ) %>%

    # XGBoost
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200623T035104_shallow/XGB_test_20200623T035104.csv") %>%
        dplyr::rename(XGB.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200623T063233_middle/XGB_test_20200623T063233.csv") %>%
        dplyr::rename(XGB.middle = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/XGB/output/20200622T235813_deep/XGB_test_20200622T235813.csv") %>%
        dplyr::rename(XGB.deep = predicted),
      by = "id"
    ) %>%

    # LightGBM
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/LGBM/output/20200626T054221_shallow/LGBM_test_20200626T054221.csv") %>%
        dplyr::rename(LGBM.shallow = predicted),
      by = "id"
    ) %>%
    dplyr::left_join(
      readr::read_csv("models/Ensemble/Stacking/LGBM/output/20200626T033957_deep/LGBM_test_20200626T033957.csv") %>%
        dplyr::rename(LGBM.deep = predicted),
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
