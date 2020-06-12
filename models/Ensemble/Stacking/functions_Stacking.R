
train_and_predict <- function(split, recipe, model, formula) {

  # 前処理済データの作成
  trained_recipe <- recipes::prep(recipe, training = rsample::training(split))
  df.train <- recipes::juice(trained_recipe) %>%
    add_features_per_category(., .)
  df.test  <- recipes::bake(trained_recipe, new_data = rsample::testing(split)) %>%
    add_features_per_category(df.train)

  # モデルの学習
  fit <- parsnip::fit(model, formula, data = df.train)


  df.test %>%

    # 予測の追加
    dplyr::mutate(predicted = predict(fit, df.test,  type = "numeric")[[1]]) %>%

    dplyr::select(
      id,
      predicted
    ) %>%
    dplyr::arrange(id)
}

save_predicts <- function(model_name, preds_train, preds_test) {

  # 対象時刻
  yyyymmddThhmmss <- lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S")

  # 格納先ディレクトリの作成
  dirpath <- stringr::str_c(
    "models/Ensemble/Stacking/",
    model_name,
    "output",
    yyyymmddThhmmss,
    sep = "/"
  )
  dir.create(dirpath)

  # 訓練データの書き出し
  write_file(preds_train, dirpath, yyyymmddThhmmss, "LR_train")

  # テストデータの書き出し
  write_file(preds_test, dirpath, yyyymmddThhmmss, "LR_test")
}

write_file <- function(data, dirpath, yyyymmddThhmmss, file_prefix) {

  # 出力ファイル名
  filename <- stringr::str_c(
    file_prefix,
    yyyymmddThhmmss,
    sep = "_"
  ) %>%
    stringr::str_c("csv", sep = ".")

  # 出力ファイルパス
  filepath <- stringr::str_c(dirpath, filename, sep = "/")
  
  # 書き出し
  readr::write_csv(data, filepath, col_names = T)
}
