source("models/functions_Global.R", encoding = "utf-8")


save_UMAP <- function(train_data, test_data) {

  # 対象時刻
  yyyymmddThhmmss <- lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S")

  # 格納先ディレクトリ
  dirpath <- stringr::str_c(
    "models/Ensemble/Stacking/UMAP/output",
    yyyymmddThhmmss,
    sep = "/"
  )
  dir.create(dirpath)

  # 訓練データの書き出し
  write_file(train_data, dirpath, yyyymmddThhmmss, stringr::str_c("UMAP", "train", sep = "_"))

  # テストデータの書き出し
  write_file(test_data, dirpath, yyyymmddThhmmss, stringr::str_c("UMAP", "test", sep = "_"))
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
