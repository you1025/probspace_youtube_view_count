source("models/functions_Global.R", encoding = "utf-8")

# 直近 n 回の平均を算出
add_average_y_from_recents <- function(target_data, train_data, n, flg_impute) {

  weight_ratio <- 1.5

  # 過去 n 回の平均を算出
  # 初回の場合は NA
  df.past_averages <- target_data %>%

    dplyr::left_join(
      (
        train_data %>%
          dplyr::select(
            channelId,
            recent_published_at = publishedAt,
            recent_y = y
          )
      ),
      by = "channelId"
    ) %>%

    # 過去のレコードのみを対象
    dplyr::filter(publishedAt >= recent_published_at) %>%
    dplyr::mutate(recent_y = ifelse(publishedAt == recent_published_at, NA, recent_y)) %>%

    # 直近 n 回の平均を算出
    dplyr::group_by(id) %>%
    dplyr::top_n(n + 1, wt = recent_published_at) %>%
    dplyr::arrange(id, desc(recent_published_at)) %>%
    dplyr::mutate(
      order = dplyr::row_number(desc(recent_published_at)) - 1,
      wt = weight_ratio^(-order) %>% ifelse(is.na(recent_y), NA, .),
      weighted_recent_y = recent_y * wt
    ) %>%
    dplyr::summarise(
      avg_recent_y = mean(recent_y, na.rm = T),
      weighted_avg_recent_y = sum(weighted_recent_y, na.rm = T) / sum(wt, na.rm = T)
    ) %>%
    dplyr::ungroup() %>%

    # NaN を NA に変換
    dplyr::mutate(
      avg_recent_y = ifelse(is.nan(avg_recent_y), NA, avg_recent_y),
      weighted_avg_recent_y = ifelse(is.nan(weighted_avg_recent_y), NA, weighted_avg_recent_y)
    )

  # 過去レコードが無い場合の NA を補完
  if(flg_impute) {

    df.past_averages <-

      (
        target_data %>%
          dplyr::select(id, categoryId) %>%
          dplyr::left_join(df.past_averages, by = "id")
      ) %>%

      # categoryId 毎の最初の y の平均値を結合
      dplyr::left_join(
        (
          train_data %>%

            # channelId 毎に初回のレコードのみを抽出
            dplyr::group_by(channelId) %>%
            dplyr::top_n(1, wt = desc(publishedAt)) %>%
            dplyr::ungroup() %>%

            # カテゴリ毎に平均値を算出
            dplyr::group_by(categoryId) %>%
            dplyr::summarise(avg_y_on_first_published = mean(y)) %>%
            dplyr::ungroup()
        ),
        by = "categoryId"
      ) %>%

      # categoryId 毎の初回レコードの平均値で補完
      dplyr::mutate(
        avg_recent_y          = ifelse(is.na(avg_recent_y),          avg_y_on_first_published, avg_recent_y),
        weighted_avg_recent_y = ifelse(is.na(weighted_avg_recent_y), avg_y_on_first_published, weighted_avg_recent_y)
      ) %>%
      dplyr::select(-avg_y_on_first_published)
  }


  target_data %>%

    dplyr::left_join(df.past_averages, by = "id")
}

get_average_y_from_recents <- function(target_data, train_data, n = 7, flg_impute = F) {

  # データの生成
  add_average_y_from_recents(target_data, train_data, n = n, flg_impute = flg_impute) %>%

    # 対数変換
    dplyr::mutate(
      avg_recent_y = log(avg_recent_y + 1),
      weighted_avg_recent_y = log(weighted_avg_recent_y + 1)
    ) %>%

    # 項目選択
    dplyr::select(
      id,
      avg_recent_y,
      weighted_avg_recent_y
    )
}

save_average_y_from_recents <- function(train_data, test_data) {

  # 対象時刻
  yyyymmddThhmmss <- lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S")

  # 格納先ディレクトリ
  dirpath <- stringr::str_c(
    "models/Ensemble/Stacking/use_y_histories/output",
    yyyymmddThhmmss,
    sep = "/"
  )
  dir.create(dirpath)

  # 訓練データの書き出し
  write_file(train_data, dirpath, yyyymmddThhmmss, stringr::str_c("avg_y_from_recents", "train", sep = "_"))

  # テストデータの書き出し
  write_file(test_data, dirpath, yyyymmddThhmmss, stringr::str_c("avg_y_from_recents", "test", sep = "_"))
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
