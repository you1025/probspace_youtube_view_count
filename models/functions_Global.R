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
      collection_date = col_date(format = "%y.%d.%m"),
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
      collection_date = col_date(format = "%y.%d.%m"),
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


# データ変換 -------------------------------------------------------------------

# クレンジング
clean <- function(df) {
  df %>%
    
    dplyr::mutate(
      # CategoryId
      categoryId = forcats::fct_other(categoryId, drop = c(43, 44)),
      
      # Tags
      tags = dplyr::if_else(tags == "[none]", NA_character_, tags)
    )
}


# CV ----------------------------------------------------------------------

# CV 作成
create_cv <- function(df, v = 5, seed = 2851) {
  
  set.seed(seed)
  
  df %>%
    
    rsample::vfold_cv(v = v, strata = "categoryId")
}


# その他 ---------------------------------------------------------------------

get_dummies <- function(data) {
  recipes::recipe(y ~ ., data) %>%
    recipes::step_dummy(recipes::all_nominal(), one_hot = T) %>%
    recipes::prep() %>%
    recipes::juice()
}

add_interactions <- function(data, formula) {
  recipe <- recipes::recipe(y ~ ., data) %>%
    recipes::step_dummy(special_segment, one_hot = T) %>%
    recipes::step_dummy(recipes::all_nominal(), one_hot = T) %>%
    recipes::step_interact(terms = formula, sep = "__x__") %>%
    recipes::prep(training = data) %>%
    recipes::juice()
}

# タグの合計カウントを追加(bin counting の一種？)
add_tag_counts <- function(target_data, train_data) {
  # カウント辞書の作成
  tag_counts <- train_data$tags %>%
    stringr::str_split(pattern = "\\|", simplify = F) %>%
    purrr::map_dfr(tibble::as_tibble_col, column_name = "tag") %>%
    dplyr::count(tag, sort = T) %>%
    dplyr::filter(!is.na(tag)) %>%
    tibble::deframe()

  tag_sum_counts <- target_data$tags %>%
    stringr::str_split(pattern = "\\|") %>%
    purrr::map_int(~ sum(tag_counts[.]))

  tag_max_counts <- target_data$tags %>%
    stringr::str_split(pattern = "\\|") %>%
    purrr::map_int(~ max(tag_counts[.]))

  target_data %>%
    dplyr::mutate(
      tag_sum_counts = tag_sum_counts,
      tag_max_counts = tag_max_counts
    )
}