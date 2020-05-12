library(tidyverse)


# Data Load ---------------------------------------------------------------

# Train Data
load_train_data <- function(path) {
  readr::read_csv(
    file = path,
    col_types = cols(
      id = col_integer(),
      video_id = col_character(),
      title = col_character(),
      publishedAt = col_datetime(format = ""),
      channelId = col_character(),
      channelTitle = col_character(),
      categoryId = readr::col_factor(levels = c(1:2, 10, 15, 17, 19:20, 22:30, 44)),
      collection_date = col_character(),
      tags = col_character(),
      likes = col_integer(),
      dislikes = col_integer(),
      comment_count = col_integer(),
      thumbnail_link = col_character(),
      comments_disabled = col_logical(),
      ratings_disabled = col_logical(),
      description = col_character(),
      y = col_integer()
    )
  )
}
#load_train_data("data/01.input/train_data.csv")

load_test_data <- function(path) {
  readr::read_csv(
    file = path,
    col_types = cols(
      id = col_integer(),
      video_id = col_character(),
      title = col_character(),
      publishedAt = col_datetime(format = ""),
      channelId = col_character(),
      channelTitle = col_character(),
      categoryId = readr::col_factor(levels = c(1:2, 10, 15, 17, 19:20, 22:30, 43:44)),
      collection_date = col_character(),
      tags = col_character(),
      likes = col_integer(),
      dislikes = col_integer(),
      comment_count = col_integer(),
      thumbnail_link = col_character(),
      comments_disabled = col_logical(),
      ratings_disabled = col_logical(),
      description = col_character()
    )
  )
}
#load_test_data("data/01.input/test_data.csv")


# データ変換 -------------------------------------------------------------------

# クレンジング
clean <- function(df) {
  df %>%

    dplyr::mutate(
      # CategoryId
      categoryId = forcats::fct_other(categoryId, drop = c(43, 44)),

      # Tags
      tags = ifelse(tags == "[none]", NA, tags)
    )
}
#load_train_data("data/01.input/train_data.csv") %>% clean()
#load_test_data("data/01.input/train_data.csv") %>% clean()
