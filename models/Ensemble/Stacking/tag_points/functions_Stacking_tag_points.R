source("models/functions_Global.R", encoding = "utf-8")

load_tag_dict <- function(train_data, test_data) {

  # 辞書のパス
  filepath <- "models/Ensemble/Stacking/tag_points/dictdata/tagdict.csv"

  if(file.exists(filepath)) {
    # 辞書の読み込み
    readr::read_csv(
      filepath,
      col_types = cols(
        tag = col_character(),
        count = col_integer()
      )
    ) %>%

      # ベクトルに変換
      tibble::deframe()
  } else {
    # 辞書の生成＆保存
    c(
      train_data$tags,
      test_data$tags
    ) %>%

      # "|" で分割
      stringr::str_split(pattern = "\\|") %>%
      base::unlist(use.names = F) %>%

      # カウントして tibble に変換
      table() %>%
      tibble::enframe(name = "tag", value = "count") %>%
      dplyr::arrange(desc(count)) %>%

      # ファイル書き込み
      readr::write_csv(path = filepath, append = F, col_names = T)
  }
}

make_tag_points <- function(data, tag_dict) {

  # タグポイントの算出
  v.tag_points <- data$tags %>%

    purrr::map_int(function(tags) {
      # タグを分割
      stringr::str_split(tags, pattern = "\\|")[[1]] %>%

        # カウントを集計
        purrr::map_int(~ tag_dict[.x]) %>%
        sum()
    })


  data %>%

    # タグポイント項目の追加
    dplyr::mutate(tag_point = ifelse(is.na(v.tag_points), 0, v.tag_points)) %>%

    dplyr::select(
      id,
      tag_point
    )
}


save_tag_points <- function(train_data, test_data) {

  # 対象時刻
  yyyymmddThhmmss <- lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S")

  # 格納先ディレクトリ
  dirpath <- stringr::str_c(
    "models/Ensemble/Stacking/tag_points/output",
    yyyymmddThhmmss,
    sep = "/"
  )
  dir.create(dirpath)

  # 訓練データの書き出し
  write_file(train_data, dirpath, yyyymmddThhmmss, stringr::str_c("tag_points", "train", sep = "_"))

  # テストデータの書き出し
  write_file(test_data, dirpath, yyyymmddThhmmss, stringr::str_c("tag_points", "test", sep = "_"))
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
