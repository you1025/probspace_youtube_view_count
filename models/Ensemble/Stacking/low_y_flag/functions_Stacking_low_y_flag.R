source("models/functions_Global.R", encoding = "utf-8")

train_and_predict <- function(split, recipe, model, formula, seed) {

  set.seed(seed)
  options("dplyr.summarise.inform" = F)

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
    dplyr::mutate(predicted = predict(fit, df.test,  type = "prob") %>% dplyr::pull(.pred_TRUE)) %>%
    
    dplyr::select(
      id,
      predicted
    ) %>%
    dplyr::arrange(id)
}

save_low_y_flags <- function(train_data, test_data) {

  # 対象時刻
  yyyymmddThhmmss <- lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S")

  # 格納先ディレクトリ
  dirpath <- stringr::str_c(
    "models/Ensemble/Stacking/low_y_flag/output",
    yyyymmddThhmmss,
    sep = "/"
  )
  dir.create(dirpath)

  # 訓練データの書き出し
  write_file(train_data, dirpath, yyyymmddThhmmss, stringr::str_c("low_y_flags", "train", sep = "_"))

  # テストデータの書き出し
  write_file(test_data, dirpath, yyyymmddThhmmss, stringr::str_c("low_y_flags", "test", sep = "_"))
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
