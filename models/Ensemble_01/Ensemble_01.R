library(tidyverse)

df.data <- dplyr::left_join(
  readr::read_csv("models/XGB_01/output/XGB_20200604T184410.csv")       %>% dplyr::rename(xgb = y),
  readr::read_csv("models/LGBM_01/output/LightGBM_20200609T215601.csv") %>% dplyr::rename(lgbm = y),
  by = "id"
)

df.data %>%
  dplyr::mutate(
    order = dplyr::row_number(lgbm)
  ) %>%
  tidyr::pivot_longer(cols = c(xgb, lgbm), names_to = "type", values_to = "pred") %>%
  ggplot(aes(order, pred)) +
    geom_line(aes(colour = type), alpha = 1/3) +
    scale_y_log10()

df.data %>%
  dplyr::mutate(y = as.integer(0.7 * xgb + 0.3 * lgbm)) %>%
  dplyr::select(id, y) %>%

  # ファイルに出力
  {
    df.submit <- (.)
    
    # ファイル名
    filename <- stringr::str_c(
      "Ensemble",
      lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S"),
      sep = "_"
    ) %>%
      stringr::str_c("csv", sep = ".")
    
    # 出力ファイルパス
    filepath <- stringr::str_c("models/Ensemble_01/output", filename, sep = "/")
    
    # 書き出し
    readr::write_csv(df.submit, filepath, col_names = T)
  }
