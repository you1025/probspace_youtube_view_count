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


# CV ----------------------------------------------------------------------

# CV 作成
create_cv <- function(df, v = 5, seed = 2851) {
  
  set.seed(seed)
  
  df %>%
    
    rsample::vfold_cv(v = v, strata = "categoryId")
}


# Recipe ------------------------------------------------------------------

create_feature_engineerging_recipe <- function(data) {

  recipes::recipe(y ~ ., data) %>%

    recipes::step_mutate(

      ### 単体指標 ###

      # タイトル
      title_length = stringr::str_length(title),

      # 投稿: 年
      published_year  = lubridate::year(publishedAt),

      # 投稿: 月
      published_month = lubridate::month(publishedAt) %>% forcats::as_factor(),
      published_month_x = lubridate::month(publishedAt) %>% {
        month <- (.)
        theta <- ((month - 1) / ((12 + 1) - 1)) * 2 * pi
        cos(theta)
      },
      published_month_y = lubridate::month(publishedAt) %>% {
        month <- (.)
        theta <- ((month - 1) / ((12 + 1) - 1)) * 2 * pi
        sin(theta)
      },

      # 投稿: 日
      published_day = lubridate::day(publishedAt) %>% forcats::as_factor(),
      published_day_x = lubridate::day(publishedAt) %>% {
        day <- (.)
        theta <- ((day - 1) / ((31 + 1) - 1)) * 2 * pi
        cos(theta)
      },
      published_day_y = lubridate::day(publishedAt) %>% {
        day <- (.)
        theta <- ((day - 1) / ((31 + 1) - 1)) * 2 * pi
        sin(theta)
      },
      published_term_in_month = dplyr::case_when(
        dplyr::between(lubridate::day(publishedAt),  1,  5) ~ "term_01_05",
        dplyr::between(lubridate::day(publishedAt),  6, 10) ~ "term_06_10",
        dplyr::between(lubridate::day(publishedAt), 11, 15) ~ "term_11_15",
        dplyr::between(lubridate::day(publishedAt), 16, 20) ~ "term_16_20",
        dplyr::between(lubridate::day(publishedAt), 21, 25) ~ "term_21_25",
        dplyr::between(lubridate::day(publishedAt), 26, 31) ~ "term_26_31"
      ) %>% forcats::as_factor(),

      # 投稿: 週
      published_dow   = lubridate::wday(publishedAt, , label = T, abbr = T, locale = "C"), # これなんとかする！
      published_dow_x = lubridate::wday(publishedAt) %>% {
        dow <- (.)
        theta <- ((dow - 1) / ((7 + 1) - 1)) * 2 * pi
        cos(theta)
      },
      published_dow_y = lubridate::wday(publishedAt) %>% {
        dow <- (.)
        theta <- ((dow - 1) / ((7 + 1) - 1)) * 2 * pi
        sin(theta)
      },

      # 投稿: 時間
      published_hour  = lubridate::hour(publishedAt)  %>% forcats::as_factor(),
      published_hour_x = lubridate::hour(publishedAt) %>% {
        hour <- (.)
        theta <- ((hour - 1) / ((12 + 1) - 1)) * 2 * pi
        cos(theta)
      },
      published_hour_y = lubridate::hour(publishedAt) %>% {
        hour <- (.)
        theta <- ((hour - 1) / ((12 + 1) - 1)) * 2 * pi
        sin(theta)
      },

      # チャンネルタイトル
      channel_title_length = stringr::str_length(channelTitle),

      # カテゴリ
      flg_categoryId_low  = (categoryId %in% c("19", "28", "29", "30")),
      flg_categoryId_high = (categoryId %in% c("1", "10", "20", "23", "24")),

      # タグ
      flg_no_tags = is.na(tags),
      tag_characters = dplyr::if_else(is.na(tags), 0L, stringr::str_length(tags)),
      tag_count      = dplyr::if_else(is.na(tags), 0L, stringr::str_count(tags, pattern = "\\|") + 1L),

      # 説明文
      flg_no_description = is.na(description),
      description_length = dplyr::if_else(is.na(description), 0L, stringr::str_length(description)),
      flg_url   = ifelse(is.na(description), F, stringr::str_detect(description, pattern = "http(|s)://")),
      url_count = ifelse(is.na(description), 0L, stringr::str_count(description, patter = "http(|s)://")),


      ### 複合指標 ###

      # 公開からの経過日数
      days_from_published = as.integer(collection_date - lubridate::as_date(publishedAt)),

      # likes / dislikes
      diff_likes_dislikes = likes - dislikes,
      sum_likes_dislikes  = likes + dislikes,
      ratio_likes = ifelse(likes+dislikes == 0, 0, likes / (likes + dislikes)),

      # comment_count / likes / dislikes
      sum_likes_dislikes_comments = likes + dislikes + comment_count,
      ratio_comments_likedis = ifelse(comment_count == 0, 0, (likes + dislikes) / comment_count),

      # 日本語フラグ
      flg_japanese = stringr::str_c(
        title,
        channelTitle,
        ifelse(is.na(tags), "", tags),
        ifelse(is.na(description), "", description),
        sep = ""
      ) %>%
        stringr::str_detect(pattern = "\\p{Hiragana}|\\p{Katakana}|\\p{Han}"),

      # 絵文字フラグ
      flg_emoji = stringr::str_c(
        title,
        channelTitle,
        ifelse(is.na(tags), "", tags),
        ifelse(is.na(description), "", description),
        sep = ""
      ) %>%
        stringr::str_detect(pattern = "/\\p{Emoji_Modifier_Base}\\p{Emoji_Modifier}?|\\p{Emoji_Presentation}|\\p{Emoji}\uFE0F/gu"),

      # 公式フラグ
      flg_official = stringr::str_c(
        title,
        channelTitle,
        ifelse(is.na(description), "", description),
        sep = ""
      ) %>%
        stringr::str_detect(pattern = stringr::regex("(公式|official)", ignore_case = T)),

      # 動画番号フラグ
      flg_movie_number = stringr::str_c(
        title,
        ifelse(is.na(description), "", description),
        sep = ""
      ) %>%
        stringr::str_detect(pattern = stringr::regex("(#|＃|No(|.))\\d{1,3}", ignore_case = T)),

      # 投稿時間
      # flg_japanese を考慮
      published_hour2  = ifelse(flg_japanese, (lubridate::hour(publishedAt) + 9) %% 24, (lubridate::hour(publishedAt) - 0) %% 24),
      published_hour2_x = published_hour2 %>% {
        hour <- (.)
        theta <- ((hour - 1) / ((12 + 1) - 1)) * 2 * pi
        cos(theta)
      },
      published_hour2_y = published_hour2 %>% {
        hour <- (.)
        theta <- ((hour - 1) / ((12 + 1) - 1)) * 2 * pi
        sin(theta)
      },
      published_hour2 = forcats::as_factor(published_hour2),

      # comments_disabled x ratings_disabled x flg_japanese
      comments_ratings_disabled_japanese = stringr::str_c(
        stringr::str_extract(comments_disabled, pattern = "^."),
        stringr::str_extract(ratings_disabled,  pattern = "^."),
        stringr::str_extract(flg_japanese,      pattern = "^."),
        sep = "_"
      ),
      flg_comments_ratings_disabled_japanese_high      = (comments_ratings_disabled_japanese == "F_T_T"),
      flg_comments_ratings_disabled_japanese_very_high = (comments_ratings_disabled_japanese == "F_T_F"),
      flg_comments_ratings_disabled_japanese_low       = (comments_ratings_disabled_japanese %in% c("T_F_F", "T_T_T")),
      flg_comments_ratings_disabled_japanese_very_low  = (comments_ratings_disabled_japanese == "T_T_F")
    )
}


# Target Encoding ---------------------------------------------------------

# カテゴリ毎に target の代表値を算出
# カウントの極端に少ないカテゴリには補正あり
smoothed_categorical_value <- function(data, category, target, fun = mean) {

  # smoothing parameters
  k <- 5
  f <- 1

  # for NSE
  category = dplyr::enquo(category)
  target   = dplyr::enquo(target)

  # 全体の集約値
  # 補正のために使用
  outer_stat <- data %>%
    dplyr::summarise(outer_stat = fun(!!target, na.rm = T)) %>%
    dplyr::pull(outer_stat)

  # 指定 category 単位の集約値
  df.inner_stats <- data %>%
    dplyr::group_by(!!category) %>%
    dplyr::summarise(
      n = n(),
      inner_stat = fun(!!target, na.rm = T)
    ) %>%
    dplyr::ungroup()


  # category 毎の代表値を補正付きに変換
  df.inner_stats %>%

    # 補正の実施
    dplyr::mutate(
      lambda = 1 / (1 + exp(-(n - k) / f)),
      smoothed_stat = lambda * inner_stat + (1 - lambda) * outer_stat,
      total_stat = outer_stat
    ) %>%

    dplyr::select(
      !!category,

      stat = smoothed_stat, # カテゴリ毎の統計量
      total_stat            # レコード全体での統計量
    )
}

add_feature_per_category <- function(target_data, train_data, category, target, fun) {

  # for NSE
  category = dplyr::enquo(category)
  target   = dplyr::enquo(target)

  # 新規に生成される項目名
  # ex. "categoryId_mean_y"
  new_col_name <- stringr::str_c(
    dplyr::quo_name(category),
    substitute(fun),
    dplyr::quo_name(target),
    sep = "_"
  )

  # category 毎の代表値を取得
  df.category_average <- smoothed_categorical_value(train_data, !!category, !!target, fun)

  # レコード全体での統計量
  # 補完に用いる
  total_summary <- unique(df.category_average$total_stat)

  # target_data に算出した代表値を結合
  target_data %>%

    dplyr::left_join(df.category_average, by = dplyr::quo_name(category)) %>%

    # train_data 側に存在しないカテゴリの場合はレコード全体での統計量で補完
    dplyr::mutate(
      !!new_col_name := ifelse(!is.na(stat), stat, total_summary)
    ) %>%

    # 不要項目の削除
    dplyr::select(-stat, -total_stat)
}

add_features_per_category <- function(target_data, train_data) {

  target_data %>%

    # categoryId
    add_feature_per_category(train_data, categoryId, y, mean) %>%
    add_feature_per_category(train_data, categoryId, y, median) %>%
    add_feature_per_category(train_data, categoryId, y, min) %>%
    add_feature_per_category(train_data, categoryId, y, max) %>%
    add_feature_per_category(train_data, categoryId, y, sd) %>%

    # published_year
    add_feature_per_category(train_data, published_year, y, mean) %>%
    add_feature_per_category(train_data, published_year, y, median) %>%
    add_feature_per_category(train_data, published_year, y, min) %>%
    add_feature_per_category(train_data, published_year, y, max) %>%
    add_feature_per_category(train_data, published_year, y, sd) %>%

    # published_month
    add_feature_per_category(train_data, published_month, y, mean) %>%
    add_feature_per_category(train_data, published_month, y, median) %>%
    add_feature_per_category(train_data, published_month, y, min) %>%
    add_feature_per_category(train_data, published_month, y, max) %>%
    add_feature_per_category(train_data, published_month, y, sd) %>%

    # published_dow
    add_feature_per_category(train_data, published_dow, y, mean) %>%
    add_feature_per_category(train_data, published_dow, y, median) %>%
    add_feature_per_category(train_data, published_dow, y, min) %>%
    add_feature_per_category(train_data, published_dow, y, max) %>%
    add_feature_per_category(train_data, published_dow, y, sd) %>%

    # comments_disabled
    add_feature_per_category(train_data, comments_disabled, y, mean) %>%
    add_feature_per_category(train_data, comments_disabled, y, median) %>%
    add_feature_per_category(train_data, comments_disabled, y, min) %>%
    add_feature_per_category(train_data, comments_disabled, y, max) %>%
    add_feature_per_category(train_data, comments_disabled, y, sd) %>%

    # ratings_disabled
    add_feature_per_category(train_data, ratings_disabled, y, mean) %>%
    add_feature_per_category(train_data, ratings_disabled, y, median) %>%
    add_feature_per_category(train_data, ratings_disabled, y, min) %>%
    add_feature_per_category(train_data, ratings_disabled, y, max) %>%
    add_feature_per_category(train_data, ratings_disabled, y, sd) %>%

    # flg_categoryId_low
    add_feature_per_category(train_data, flg_categoryId_low, y, mean) %>%
    add_feature_per_category(train_data, flg_categoryId_low, y, median) %>%
    add_feature_per_category(train_data, flg_categoryId_low, y, min) %>%
    add_feature_per_category(train_data, flg_categoryId_low, y, max) %>%
    add_feature_per_category(train_data, flg_categoryId_low, y, sd) %>%

    # flg_category_high
    add_feature_per_category(train_data, flg_categoryId_high, y, mean) %>%
    add_feature_per_category(train_data, flg_categoryId_high, y, median) %>%
    add_feature_per_category(train_data, flg_categoryId_high, y, min) %>%
    add_feature_per_category(train_data, flg_categoryId_high, y, max) %>%
    add_feature_per_category(train_data, flg_categoryId_high, y, sd) %>%

    # flg_no_tags
    add_feature_per_category(train_data, flg_no_tags, y, mean) %>%
    add_feature_per_category(train_data, flg_no_tags, y, median) %>%
    add_feature_per_category(train_data, flg_no_tags, y, min) %>%
    add_feature_per_category(train_data, flg_no_tags, y, max) %>%
    add_feature_per_category(train_data, flg_no_tags, y, sd) %>%

    # flg_no_description
    add_feature_per_category(train_data, flg_no_description, y, mean) %>%
    add_feature_per_category(train_data, flg_no_description, y, median) %>%
    add_feature_per_category(train_data, flg_no_description, y, min) %>%
    add_feature_per_category(train_data, flg_no_description, y, max) %>%
    add_feature_per_category(train_data, flg_no_description, y, sd) %>%

    # flg_url
    add_feature_per_category(train_data, flg_url, y, mean) %>%
    add_feature_per_category(train_data, flg_url, y, median) %>%
    add_feature_per_category(train_data, flg_url, y, min) %>%
    add_feature_per_category(train_data, flg_url, y, max) %>%
    add_feature_per_category(train_data, flg_url, y, sd) %>%

    # flg_japanese
    add_feature_per_category(train_data, flg_japanese, y, mean) %>%
    add_feature_per_category(train_data, flg_japanese, y, median) %>%
    add_feature_per_category(train_data, flg_japanese, y, min) %>%
    add_feature_per_category(train_data, flg_japanese, y, max) %>%
    add_feature_per_category(train_data, flg_japanese, y, sd) %>%

    # flg_emoji
    add_feature_per_category(train_data, flg_emoji, y, mean) %>%
    add_feature_per_category(train_data, flg_emoji, y, median) %>%
    add_feature_per_category(train_data, flg_emoji, y, min) %>%
    add_feature_per_category(train_data, flg_emoji, y, max) %>%
    add_feature_per_category(train_data, flg_emoji, y, sd) %>%

    # flg_official
    add_feature_per_category(train_data, flg_official, y, mean) %>%
    add_feature_per_category(train_data, flg_official, y, median) %>%
    add_feature_per_category(train_data, flg_official, y, min) %>%
    add_feature_per_category(train_data, flg_official, y, max) %>%
    add_feature_per_category(train_data, flg_official, y, sd) %>%

    # flg_movie_number
    add_feature_per_category(train_data, flg_movie_number, y, mean) %>%
    add_feature_per_category(train_data, flg_movie_number, y, median) %>%
    add_feature_per_category(train_data, flg_movie_number, y, min) %>%
    add_feature_per_category(train_data, flg_movie_number, y, max) %>%
    add_feature_per_category(train_data, flg_movie_number, y, sd) %>%

    # comments_ratings_disabled_japanese
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, y, mean) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, y, median) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, y, min) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, y, max) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, y, sd) %>%

    # categoryId - likes
    add_feature_per_category(train_data, categoryId, likes, mean) %>%
    dplyr::mutate(
      diff_categoryId_mean_likes  = likes - categoryId_mean_likes,
      ratio_categoryId_mean_likes = likes / categoryId_mean_likes
    ) %>%
    add_feature_per_category(train_data, categoryId, likes, median) %>%
    dplyr::mutate(
      diff_categoryId_median_likes  = likes - categoryId_median_likes,
      ratio_categoryId_median_likes = likes / categoryId_median_likes
    ) %>%
    add_feature_per_category(train_data, categoryId, likes, min) %>%
    dplyr::mutate(
      diff_categoryId_min_likes  = likes - categoryId_min_likes,
      ratio_categoryId_min_likes = likes / categoryId_min_likes
    ) %>%
    add_feature_per_category(train_data, categoryId, likes, max) %>%
    dplyr::mutate(
      diff_categoryId_max_likes  = likes - categoryId_max_likes,
      ratio_categoryId_max_likes = likes / categoryId_max_likes
    ) %>%
    add_feature_per_category(train_data, categoryId, likes, sd) %>%

    # categoryId - dislikes
    add_feature_per_category(train_data, categoryId, dislikes, mean) %>%
    dplyr::mutate(
      diff_categoryId_mean_dislikes  = dislikes - categoryId_mean_dislikes,
      ratio_categoryId_mean_dislikes = dislikes / categoryId_mean_dislikes
    ) %>%
    add_feature_per_category(train_data, categoryId, dislikes, median) %>%
    dplyr::mutate(
      diff_categoryId_median_dislikes  = dislikes - categoryId_median_dislikes,
      ratio_categoryId_median_dislikes = dislikes / categoryId_median_dislikes
    ) %>%
    add_feature_per_category(train_data, categoryId, dislikes, min) %>%
    dplyr::mutate(
      diff_categoryId_min_dislikes  = dislikes - categoryId_min_dislikes,
      ratio_categoryId_min_dislikes = dislikes / categoryId_min_dislikes
    ) %>%
    add_feature_per_category(train_data, categoryId, dislikes, max) %>%
    dplyr::mutate(
      diff_categoryId_max_dislikes  = dislikes - categoryId_max_dislikes,
      ratio_categoryId_max_dislikes = dislikes / categoryId_max_dislikes
    ) %>%
    add_feature_per_category(train_data, categoryId, dislikes, sd) %>%

    # categoryId - comment_count
    add_feature_per_category(train_data, categoryId, comment_count, mean) %>%
    dplyr::mutate(
      diff_categoryId_mean_comment_count  = comment_count - categoryId_mean_comment_count,
      ratio_categoryId_mean_comment_count = comment_count / categoryId_mean_comment_count
    ) %>%
    add_feature_per_category(train_data, categoryId, comment_count, median) %>%
    dplyr::mutate(
      diff_categoryId_median_comment_count  = comment_count - categoryId_median_comment_count,
      ratio_categoryId_median_comment_count = comment_count / categoryId_median_comment_count
    ) %>%
    add_feature_per_category(train_data, categoryId, comment_count, min) %>%
    dplyr::mutate(
      diff_categoryId_min_comment_count  = comment_count - categoryId_min_comment_count,
      ratio_categoryId_min_comment_count = comment_count / categoryId_min_comment_count
    ) %>%
    add_feature_per_category(train_data, categoryId, comment_count, max) %>%
    dplyr::mutate(
      diff_categoryId_max_comment_count  = comment_count - categoryId_max_comment_count,
      ratio_categoryId_max_comment_count = comment_count / categoryId_max_comment_count
    ) %>%
    add_feature_per_category(train_data, categoryId, comment_count, sd) %>%

    # comments_disabled - likes
    add_feature_per_category(train_data, comments_disabled, likes, mean) %>%
    dplyr::mutate(
      diff_comments_disabled_mean_likes  = likes - comments_disabled_mean_likes,
      ratio_comments_disabled_mean_likes = likes / comments_disabled_mean_likes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, likes, median) %>%
    dplyr::mutate(
      diff_comments_disabled_median_likes  = likes - comments_disabled_median_likes,
      ratio_comments_disabled_median_likes = likes / comments_disabled_median_likes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, likes, min) %>%
    dplyr::mutate(
      diff_comments_disabled_min_likes  = likes - comments_disabled_min_likes,
      ratio_comments_disabled_min_likes = likes / comments_disabled_min_likes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, likes, max) %>%
    dplyr::mutate(
      diff_comments_disabled_max_likes  = likes - comments_disabled_max_likes,
      ratio_comments_disabled_max_likes = likes / comments_disabled_max_likes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, likes, sd) %>%

    # comments_disabled - dislikes
    add_feature_per_category(train_data, comments_disabled, dislikes, mean) %>%
    dplyr::mutate(
      diff_comments_disabled_mean_dislikes  = dislikes - comments_disabled_mean_dislikes,
      ratio_comments_disabled_mean_dislikes = dislikes / comments_disabled_mean_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, dislikes, median) %>%
    dplyr::mutate(
      diff_comments_disabled_median_dislikes  = dislikes - comments_disabled_median_dislikes,
      ratio_comments_disabled_median_dislikes = dislikes / comments_disabled_median_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, dislikes, min) %>%
    dplyr::mutate(
      diff_comments_disabled_min_dislikes  = dislikes - comments_disabled_min_dislikes,
      ratio_comments_disabled_min_dislikes = dislikes / comments_disabled_min_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, dislikes, max) %>%
    dplyr::mutate(
      diff_comments_disabled_max_dislikes  = dislikes - comments_disabled_max_dislikes,
      ratio_comments_disabled_max_dislikes = dislikes / comments_disabled_max_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, dislikes, sd) %>%

    # ratings_disabled - comment_counts
    add_feature_per_category(train_data, ratings_disabled, comment_count, mean) %>%
    dplyr::mutate(
      diff_ratings_disabled_mean_comment_count  = comment_count - ratings_disabled_mean_comment_count,
      ratio_ratings_disabled_mean_comment_count = comment_count / ratings_disabled_mean_comment_count
    ) %>%
    add_feature_per_category(train_data, ratings_disabled, comment_count, median) %>%
    dplyr::mutate(
      diff_ratings_disabled_median_comment_count  = comment_count - ratings_disabled_median_comment_count,
      ratio_ratings_disabled_median_comment_count = comment_count / ratings_disabled_median_comment_count
    ) %>%
    add_feature_per_category(train_data, ratings_disabled, comment_count, min) %>%
    dplyr::mutate(
      diff_ratings_disabled_min_comment_count  = comment_count - ratings_disabled_min_comment_count,
      ratio_ratings_disabled_min_comment_count = comment_count / ratings_disabled_min_comment_count
    ) %>%
    add_feature_per_category(train_data, ratings_disabled, comment_count, max) %>%
    dplyr::mutate(
      diff_ratings_disabled_max_comment_count  = comment_count - ratings_disabled_max_comment_count,
      ratio_ratings_disabled_max_comment_count = comment_count / ratings_disabled_max_comment_count
    ) %>%
    add_feature_per_category(train_data, ratings_disabled, comment_count, sd) %>%

    # published_year - likes
    add_feature_per_category(train_data, published_year, likes, mean) %>%
    dplyr::mutate(
      diff_published_year_mean_likes  = likes - published_year_mean_likes,
      ratio_published_year_mean_likes = likes / published_year_mean_likes
    ) %>%
    add_feature_per_category(train_data, published_year, likes, median) %>%
    dplyr::mutate(
      diff_published_year_median_likes  = likes - published_year_median_likes,
      ratio_published_year_median_likes = likes / published_year_median_likes
    ) %>%
    add_feature_per_category(train_data, published_year, likes, min) %>%
    dplyr::mutate(
      diff_published_year_min_likes  = likes - published_year_min_likes,
      ratio_published_year_min_likes = likes / published_year_min_likes
    ) %>%
    add_feature_per_category(train_data, published_year, likes, max) %>%
    dplyr::mutate(
      diff_published_year_max_likes  = likes - published_year_max_likes,
      ratio_published_year_max_likes = likes / published_year_max_likes
    ) %>%
    add_feature_per_category(train_data, published_year, likes, sd) %>%

    # published_year - dislikes
    add_feature_per_category(train_data, published_year, dislikes, mean) %>%
    dplyr::mutate(
      diff_published_year_mean_dislikes  = dislikes - published_year_mean_dislikes,
      ratio_published_year_mean_dislikes = dislikes / published_year_mean_dislikes
    ) %>%
    add_feature_per_category(train_data, published_year, dislikes, median) %>%
    dplyr::mutate(
      diff_published_year_median_dislikes  = dislikes - published_year_median_dislikes,
      ratio_published_year_median_dislikes = dislikes / published_year_median_dislikes
    ) %>%
    add_feature_per_category(train_data, published_year, dislikes, min) %>%
    dplyr::mutate(
      diff_published_year_min_dislikes  = dislikes - published_year_min_dislikes,
      ratio_published_year_min_dislikes = dislikes / published_year_min_dislikes
    ) %>%
    add_feature_per_category(train_data, published_year, dislikes, max) %>%
    dplyr::mutate(
      diff_published_year_max_dislikes  = dislikes - published_year_max_dislikes,
      ratio_published_year_max_dislikes = dislikes / published_year_max_dislikes
    ) %>%
    add_feature_per_category(train_data, published_year, dislikes, sd) %>%

    # published_year - comment_counts
    add_feature_per_category(train_data, published_year, comment_count, mean) %>%
    dplyr::mutate(
      diff_published_year_mean_comment_count  = comment_count - published_year_mean_comment_count,
      ratio_published_year_mean_comment_count = comment_count / published_year_mean_comment_count
    ) %>%
    add_feature_per_category(train_data, published_year, comment_count, median) %>%
    dplyr::mutate(
      diff_published_year_median_comment_count  = comment_count - published_year_median_comment_count,
      ratio_published_year_median_comment_count = comment_count / published_year_median_comment_count
    ) %>%
    add_feature_per_category(train_data, published_year, comment_count, min) %>%
    dplyr::mutate(
      diff_published_year_min_comment_count  = comment_count - published_year_min_comment_count,
      ratio_published_year_min_comment_count = comment_count / published_year_min_comment_count
    ) %>%
    add_feature_per_category(train_data, published_year, comment_count, max) %>%
    dplyr::mutate(
      diff_published_year_max_comment_count  = comment_count - published_year_max_comment_count,
      ratio_published_year_max_comment_count = comment_count / published_year_max_comment_count
    ) %>%
    add_feature_per_category(train_data, published_year, comment_count, sd) %>%

    # flg_japanese - likes
    add_feature_per_category(train_data, flg_japanese, likes, mean) %>%
    dplyr::mutate(
      diff_flg_japanese_mean_likes  = likes - flg_japanese_mean_likes,
      ratio_flg_japanese_mean_likes = likes / flg_japanese_mean_likes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, likes, median) %>%
    dplyr::mutate(
      diff_flg_japanese_median_likes  = likes - flg_japanese_median_likes,
      ratio_flg_japanese_median_likes = likes / flg_japanese_median_likes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, likes, min) %>%
    dplyr::mutate(
      diff_flg_japanese_min_likes  = likes - flg_japanese_min_likes,
      ratio_flg_japanese_min_likes = likes / flg_japanese_min_likes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, likes, max) %>%
    dplyr::mutate(
      diff_flg_japanese_max_likes  = likes - flg_japanese_max_likes,
      ratio_flg_japanese_max_likes = likes / flg_japanese_max_likes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, likes, sd) %>%

    # flg_japanese - dislikes
    add_feature_per_category(train_data, flg_japanese, dislikes, mean) %>%
    dplyr::mutate(
      diff_flg_japanese_mean_dislikes  = dislikes - flg_japanese_mean_dislikes,
      ratio_flg_japanese_mean_dislikes = dislikes / flg_japanese_mean_dislikes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, dislikes, median) %>%
    dplyr::mutate(
      diff_flg_japanese_median_dislikes  = dislikes - flg_japanese_median_dislikes,
      ratio_flg_japanese_median_dislikes = dislikes / flg_japanese_median_dislikes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, dislikes, min) %>%
    dplyr::mutate(
      diff_flg_japanese_min_dislikes  = dislikes - flg_japanese_min_dislikes,
      ratio_flg_japanese_min_dislikes = dislikes / flg_japanese_min_dislikes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, dislikes, max) %>%
    dplyr::mutate(
      diff_flg_japanese_max_dislikes  = dislikes - flg_japanese_max_dislikes,
      ratio_flg_japanese_max_dislikes = dislikes / flg_japanese_max_dislikes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, dislikes, sd) %>%

    # flg_japanese - comment_count
    add_feature_per_category(train_data, flg_japanese, comment_count, mean) %>%
    dplyr::mutate(
      diff_flg_japanese_mean_comment_count  = comment_count - flg_japanese_mean_comment_count,
      ratio_flg_japanese_mean_comment_count = comment_count / flg_japanese_mean_comment_count
    ) %>%
    add_feature_per_category(train_data, flg_japanese, comment_count, median) %>%
    dplyr::mutate(
      diff_flg_japanese_median_comment_count  = comment_count - flg_japanese_median_comment_count,
      ratio_flg_japanese_median_comment_count = comment_count / flg_japanese_median_comment_count
    ) %>%
    add_feature_per_category(train_data, flg_japanese, comment_count, min) %>%
    dplyr::mutate(
      diff_flg_japanese_min_comment_count  = comment_count - flg_japanese_min_comment_count,
      ratio_flg_japanese_min_comment_count = comment_count / flg_japanese_min_comment_count
    ) %>%
    add_feature_per_category(train_data, flg_japanese, comment_count, max) %>%
    dplyr::mutate(
      diff_flg_japanese_max_comment_count  = comment_count - flg_japanese_max_comment_count,
      ratio_flg_japanese_max_comment_count = comment_count / flg_japanese_max_comment_count
    ) %>%
    add_feature_per_category(train_data, flg_japanese, comment_count, sd) %>%

    # comments_ratings_disabled_japanese - sum_likes_dislikes
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, sum_likes_dislikes, mean) %>%
    dplyr::mutate(
      diff_comments_ratings_disabled_japanese_mean_sum_likes_dislikes  = sum_likes_dislikes - comments_ratings_disabled_japanese_mean_sum_likes_dislikes,
      ratio_comments_ratings_disabled_japanese_mean_sum_likes_dislikes = sum_likes_dislikes / comments_ratings_disabled_japanese_mean_sum_likes_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, sum_likes_dislikes, median) %>%
    dplyr::mutate(
      diff_comments_ratings_disabled_japanese_median_sum_likes_dislikes  = sum_likes_dislikes - comments_ratings_disabled_japanese_median_sum_likes_dislikes,
      ratio_comments_ratings_disabled_japanese_median_sum_likes_dislikes = sum_likes_dislikes / comments_ratings_disabled_japanese_median_sum_likes_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, sum_likes_dislikes, min) %>%
    dplyr::mutate(
      diff_comments_ratings_disabled_japanese_min_sum_likes_dislikes  = sum_likes_dislikes - comments_ratings_disabled_japanese_min_sum_likes_dislikes,
      ratio_comments_ratings_disabled_japanese_min_sum_likes_dislikes = sum_likes_dislikes / comments_ratings_disabled_japanese_min_sum_likes_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, sum_likes_dislikes, max) %>%
    dplyr::mutate(
      diff_comments_ratings_disabled_japanese_max_sum_likes_dislikes  = sum_likes_dislikes - comments_ratings_disabled_japanese_max_sum_likes_dislikes,
      ratio_comments_ratings_disabled_japanese_max_sum_likes_dislikes = sum_likes_dislikes / comments_ratings_disabled_japanese_max_sum_likes_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, sum_likes_dislikes, sd) %>%

    # comments_ratings_disabled_japanese - comment_count
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, comment_count, mean) %>%
    dplyr::mutate(
      diff_comments_ratings_disabled_japanese_mean_comment_count  = comment_count - comments_ratings_disabled_japanese_mean_comment_count,
      ratio_comments_ratings_disabled_japanese_mean_comment_count = comment_count / comments_ratings_disabled_japanese_mean_comment_count
    ) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, comment_count, median) %>%
    dplyr::mutate(
      diff_comments_ratings_disabled_japanese_median_comment_count  = comment_count - comments_ratings_disabled_japanese_median_comment_count,
      ratio_comments_ratings_disabled_japanese_median_comment_count = comment_count / comments_ratings_disabled_japanese_median_comment_count
    ) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, comment_count, min) %>%
    dplyr::mutate(
      diff_comments_ratings_disabled_japanese_min_comment_count  = comment_count - comments_ratings_disabled_japanese_min_comment_count,
      ratio_comments_ratings_disabled_japanese_min_comment_count = comment_count / comments_ratings_disabled_japanese_min_comment_count
    ) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, comment_count, max) %>%
    dplyr::mutate(
      diff_comments_ratings_disabled_japanese_max_comment_count  = comment_count - comments_ratings_disabled_japanese_max_comment_count,
      ratio_comments_ratings_disabled_japanese_max_comment_count = comment_count / comments_ratings_disabled_japanese_max_comment_count
    ) %>%
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, comment_count, sd)
}


# Train & Evaluate --------------------------------------------------------

# モデルの構築と評価
train_and_eval <- function(split, recipe, model, formula) {

  # 前処理済データの作成
  trained_recipe <- recipes::prep(recipe, training = rsample::training(split))
  df.train <- recipes::juice(trained_recipe) %>%
    add_features_per_category(., .)
  df.test  <- recipes::bake(trained_recipe, new_data = rsample::testing(split)) %>%
    add_features_per_category(df.train)


  model %>%

    # モデルの学習
    {
      model <- (.)
      parsnip::fit(model, formula, data = df.train)
    } %>%

    # 学習済モデルによる予測
    {
      fit <- (.)
      list(
        train = predict(fit, df.train, type = "numeric")[[1]],
        test  = predict(fit, df.test,  type = "numeric")[[1]]
      )
    } %>%

    # 評価
    {
      lst.predicted <- (.)

      # 評価指標の一覧を定義
      metrics <- yardstick::metric_set(
        yardstick::rmse
      )

      # train データでモデルを評価
      df.result.train <- df.train %>%
        dplyr::mutate(
          predicted = lst.predicted$train
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
          predicted = lst.predicted$test
        ) %>%
        metrics(
          truth    = log(y + 1),
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
}


# その他 ---------------------------------------------------------------------

get_dummies <- function(data) {
  recipes::recipe(y ~ ., data) %>%
    recipes::step_dummy(recipes::all_nominal(), one_hot = T) %>%
    recipes::prep() %>%
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
