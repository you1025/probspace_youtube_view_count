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
      tags = dplyr::if_else(tags == "[none]", NA_character_, tags)
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
      flg_url   = dplyr::if_else(is.na(description), F, stringr::str_detect(description, pattern = "http(|s)://")),
      url_count = dplyr::if_else(is.na(description), 0L, stringr::str_count(description, patter = "http(|s)://")),


      ### 複合指標 ###

      # 公開からの経過日数
      days_from_published = as.integer(collection_date - lubridate::as_date(publishedAt)),

      # likes / dislikes
      diff_likes_dislikes = likes - dislikes,
      sum_likes_dislikes  = likes + dislikes,
      ratio_likes = dplyr::if_else(likes+dislikes == 0, 0, likes / (likes + dislikes)),

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
      flg_comments_ratings_disabled_japanese_very_low  = (comments_ratings_disabled_japanese == "T_T_F"),

      # PCA: likes / dislikes / comment_count
      pc1 = prcomp(
        tibble(
          x1 = likes,
          x2 = dislikes
        ),
        scale = T
      )$x[,1],

      # Special Segment
      special_segment = dplyr::case_when(
        ratings_disabled  ~ "ratings_disabled",
        comment_count < 4 ~ "ratings_abled_low_comments",
        T                 ~ "others"
      ) %>%
        factor(levels = c("others", "ratings_disabled", "ratings_abled_low_comments"))
    )
}


# Target Encoding ---------------------------------------------------------

# カテゴリ毎に target の代表値を算出
# カウントの極端に少ないカテゴリには補正あり
smoothed_categorical_value <- function(data, category, target, funs) {

  # smoothing parameters
  k <- 5
  f <- 1

  # for NSE
  category = dplyr::enquo(category)
  target   = dplyr::enquo(target)

  # category に依存しない集約値の算出
  # 補正のために使用
  df.outer_stat <- data %>%
    dplyr::group_by(special_segment) %>%
    dplyr::summarise(
      dplyr::across(!!target, .fns = funs, na.rm = T, .names = "outer_stat_{fn}_{col}")
    ) %>%
    dplyr::select(special_segment, dplyr::starts_with("outer_stat_"))


  # 指定 category 単位の集約値
  df.inner_stats <- data %>%
    dplyr::group_by(special_segment, !!category) %>%
    dplyr::summarise(
      n = n(),
      dplyr::across(!!target, .fns = funs, na.rm = T, .names = "inner_stat_{fn}_{col}")
    ) %>%
    dplyr::ungroup()


  # category 毎の代表値を補正付きに変換
  df.inner_stats %>%

    # to long-form
    tidyr::pivot_longer(
      cols = dplyr::starts_with("inner_stat_"),
      names_prefix = "inner_stat_",
      names_to = "variable",
      values_to = "inner_stat"
    ) %>%

    # category に依存しない集約値を結合
    dplyr::left_join(
      (
        df.outer_stat %>%
          tidyr::pivot_longer(
            cols = -special_segment,
            names_prefix = "outer_stat_",
            names_to = "variable",
            values_to = "outer_stat"
          ) 
      ),
      by = c("special_segment", "variable")
    ) %>%

    # 補正の実施
    dplyr::mutate(
      lambda = 1 / (1 + exp(-(n - k) / f)),
      smoothed_stat = lambda * inner_stat + (1 - lambda) * outer_stat
    ) %>%

    # to wide-form
    tidyr::pivot_wider(
      id_cols = c(special_segment, !!category),
      names_prefix = stringr::str_c(dplyr::quo_name(category), "_"),
      names_from = variable,
      values_from = smoothed_stat
    )
}

add_feature_per_category <- function(target_data, train_data, category, target, funs) {

  # for NSE
  category = dplyr::enquo(category)
  target   = dplyr::enquo(target)

  # category 毎の代表値を取得
  df.category_average <- smoothed_categorical_value(train_data, !!category, !!target, funs)

  # レコード全体での統計量
  # 補完に用いる
  df.total_summary <- train_data %>%
    dplyr::group_by(special_segment) %>%
    dplyr::summarise(
      dplyr::across(!!target, .fns = funs, na.rm = T, .names = "outer_stat_{fn}_{col}")
    ) %>%
    dplyr::select(special_segment, dplyr::starts_with("outer_stat_"))


  # 集約値の一覧
  df.aggregations <-

    # 集約キーの一覧
    (
      target_data %>%
        dplyr::select(special_segment, !!category) %>%
        dplyr::distinct()
    ) %>%

    # 集約値を結合
    dplyr::left_join(
      df.category_average,
      by = c("special_segment", dplyr::quo_name(category))
    ) %>%

    # to long-form
    # 直後に各集約値の名称を用いて補完用項目を結合するため
    tidyr::pivot_longer(
      cols = -c(special_segment, !!category),
      names_prefix = stringr::str_c(dplyr::quo_name(category), "_"),
      names_to = "variable",
      values_to = "inner_stat"
    ) %>%

    # レコード全体での統計量を結合
    dplyr::left_join(
      (
        df.total_summary %>%
          tidyr::pivot_longer(
            cols = -special_segment,
            names_prefix = "outer_stat_",
            names_to = "variable",
            values_to = "outer_stat"
          )
      ),
      by = c("special_segment", "variable")
    ) %>%

    # 補完
    dplyr::mutate(
      complemented_stat = dplyr::if_else(is.na(inner_stat), outer_stat, inner_stat)
    ) %>%

    # to wide-form
    tidyr::pivot_wider(
      id_cols = c(special_segment, !!category),
      names_prefix = stringr::str_c(dplyr::quo_name(category), "_"),
      names_from = variable,
      values_from = complemented_stat
    )

  # target_data に算出した代表値を結合
  target_data %>%
    dplyr::left_join(df.aggregations, by = c("special_segment", dplyr::quo_name(category)))
}

add_features_per_category <- function(target_data, train_data) {

  # 集約関数の一覧
  funs <- list(
    mean   = mean,
    median = median,
    min    = min,
    max    = max,
    sd     = sd
  )

  target_data %>%

    # categoryId
    add_feature_per_category(train_data, categoryId, y, funs) %>%

    # published_year
    add_feature_per_category(train_data, published_year, y, funs) %>%

    # published_month
    add_feature_per_category(train_data, published_month, y, funs) %>%

    # published_dow
    add_feature_per_category(train_data, published_dow, y, funs) %>%

    # comments_disabled
    add_feature_per_category(train_data, comments_disabled, y, funs) %>%

    # ratings_disabled
    add_feature_per_category(train_data, ratings_disabled, y, funs) %>%

    # flg_categoryId_low
    add_feature_per_category(train_data, flg_categoryId_low, y, funs) %>%

    # flg_categoryId_high
    add_feature_per_category(train_data, flg_categoryId_high, y, funs) %>%

    # flg_no_tags
    add_feature_per_category(train_data, flg_no_tags, y, funs) %>%

    # flg_no_description
    add_feature_per_category(train_data, flg_no_description, y, funs) %>%

    # flg_url
    add_feature_per_category(train_data, flg_url, y, funs) %>%

    # flg_japanese
    add_feature_per_category(train_data, flg_japanese, y, funs) %>%

    # flg_emoji
    add_feature_per_category(train_data, flg_emoji, y, funs) %>%

    # flg_official
    add_feature_per_category(train_data, flg_official, y, funs) %>%

    # flg_movie_number
    add_feature_per_category(train_data, flg_movie_number, y, funs) %>%

    # comments_ratings_disabled_japanese
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, y, funs) %>%

    # categoryId - pc1
    add_feature_per_category(train_data, categoryId, pc1, funs) %>%
    dplyr::mutate(
      diff_categoryId_mean_pc1    = pc1 - categoryId_mean_pc1,
      ratio_categoryId_mean_pc1   = pc1 / categoryId_mean_pc1,
      diff_categoryId_median_pc1  = pc1 - categoryId_median_pc1,
      ratio_categoryId_median_pc1 = pc1 / categoryId_median_pc1,
      diff_categoryId_min_pc1     = pc1 - categoryId_min_pc1,
      ratio_categoryId_min_pc1    = pc1 / categoryId_min_pc1,
      diff_categoryId_max_pc1     = pc1 - categoryId_max_pc1,
      ratio_categoryId_max_pc1    = pc1 / categoryId_max_pc1
    ) %>%

    # categoryId - likes
    add_feature_per_category(train_data, categoryId, likes, funs) %>%
    dplyr::mutate(
      diff_categoryId_mean_likes    = likes - categoryId_mean_likes,
      ratio_categoryId_mean_likes   = likes / categoryId_mean_likes,
      diff_categoryId_median_likes  = likes - categoryId_median_likes,
      ratio_categoryId_median_likes = likes / categoryId_median_likes,
      diff_categoryId_min_likes     = likes - categoryId_min_likes,
      ratio_categoryId_min_likes    = likes / categoryId_min_likes,
      diff_categoryId_max_likes     = likes - categoryId_max_likes,
      ratio_categoryId_max_likes    = likes / categoryId_max_likes
    ) %>%

    # categoryId - dislikes
    add_feature_per_category(train_data, categoryId, dislikes, funs) %>%
    dplyr::mutate(
      diff_categoryId_mean_dislikes    = dislikes - categoryId_mean_dislikes,
      ratio_categoryId_mean_dislikes   = dislikes / categoryId_mean_dislikes,
      diff_categoryId_median_dislikes  = dislikes - categoryId_median_dislikes,
      ratio_categoryId_median_dislikes = dislikes / categoryId_median_dislikes,
      diff_categoryId_min_dislikes     = dislikes - categoryId_min_dislikes,
      ratio_categoryId_min_dislikes    = dislikes / categoryId_min_dislikes,
      diff_categoryId_max_dislikes     = dislikes - categoryId_max_dislikes,
      ratio_categoryId_max_dislikes    = dislikes / categoryId_max_dislikes
    ) %>%

    # categoryId - comment_count
    add_feature_per_category(train_data, categoryId, comment_count, funs) %>%
    dplyr::mutate(
      diff_categoryId_mean_comment_count    = comment_count - categoryId_mean_comment_count,
      ratio_categoryId_mean_comment_count   = comment_count / categoryId_mean_comment_count,
      diff_categoryId_median_comment_count  = comment_count - categoryId_median_comment_count,
      ratio_categoryId_median_comment_count = comment_count / categoryId_median_comment_count,
      diff_categoryId_min_comment_count     = comment_count - categoryId_min_comment_count,
      ratio_categoryId_min_comment_count    = comment_count / categoryId_min_comment_count,
      diff_categoryId_max_comment_count     = comment_count - categoryId_max_comment_count,
      ratio_categoryId_max_comment_count    = comment_count / categoryId_max_comment_count
    ) %>%

    # comments_disabled - pc1
    add_feature_per_category(train_data, comments_disabled, pc1, funs) %>%
    dplyr::mutate(
      diff_comments_disabled_mean_pc1    = pc1 - comments_disabled_mean_pc1,
      ratio_comments_disabled_mean_pc1   = pc1 / comments_disabled_mean_pc1,
      diff_comments_disabled_median_pc1  = pc1 - comments_disabled_median_pc1,
      ratio_comments_disabled_median_pc1 = pc1 / comments_disabled_median_pc1,
      diff_comments_disabled_min_pc1     = pc1 - comments_disabled_min_pc1,
      ratio_comments_disabled_min_pc1    = pc1 / comments_disabled_min_pc1,
      diff_comments_disabled_max_pc1     = pc1 - comments_disabled_max_pc1,
      ratio_comments_disabled_max_pc1    = pc1 / comments_disabled_max_pc1
    ) %>%

    # comments_disabled - likes
    add_feature_per_category(train_data, comments_disabled, likes, funs) %>%
    dplyr::mutate(
      diff_comments_disabled_mean_likes    = likes - comments_disabled_mean_likes,
      ratio_comments_disabled_mean_likes   = likes / comments_disabled_mean_likes,
      diff_comments_disabled_median_likes  = likes - comments_disabled_median_likes,
      ratio_comments_disabled_median_likes = likes / comments_disabled_median_likes,
      diff_comments_disabled_min_likes     = likes - comments_disabled_min_likes,
      ratio_comments_disabled_min_likes    = likes / comments_disabled_min_likes,
      diff_comments_disabled_max_likes     = likes - comments_disabled_max_likes,
      ratio_comments_disabled_max_likes    = likes / comments_disabled_max_likes
    ) %>%

    # comments_disabled - dislikes
    add_feature_per_category(train_data, comments_disabled, dislikes, funs) %>%
    dplyr::mutate(
      diff_comments_disabled_mean_dislikes    = dislikes - comments_disabled_mean_dislikes,
      ratio_comments_disabled_mean_dislikes   = dislikes / comments_disabled_mean_dislikes,
      diff_comments_disabled_median_dislikes  = dislikes - comments_disabled_median_dislikes,
      ratio_comments_disabled_median_dislikes = dislikes / comments_disabled_median_dislikes,
      diff_comments_disabled_min_dislikes     = dislikes - comments_disabled_min_dislikes,
      ratio_comments_disabled_min_dislikes    = dislikes / comments_disabled_min_dislikes,
      diff_comments_disabled_max_dislikes     = dislikes - comments_disabled_max_dislikes,
      ratio_comments_disabled_max_dislikes    = dislikes / comments_disabled_max_dislikes
    ) %>%

    # ratings_disabled - comment_counts
    add_feature_per_category(train_data, ratings_disabled, comment_count, funs) %>%
    dplyr::mutate(
      diff_ratings_disabled_mean_comment_count    = comment_count - ratings_disabled_mean_comment_count,
      ratio_ratings_disabled_mean_comment_count   = comment_count / ratings_disabled_mean_comment_count,
      diff_ratings_disabled_median_comment_count  = comment_count - ratings_disabled_median_comment_count,
      ratio_ratings_disabled_median_comment_count = comment_count / ratings_disabled_median_comment_count,
      diff_ratings_disabled_min_comment_count     = comment_count - ratings_disabled_min_comment_count,
      ratio_ratings_disabled_min_comment_count    = comment_count / ratings_disabled_min_comment_count,
      diff_ratings_disabled_max_comment_count     = comment_count - ratings_disabled_max_comment_count,
      ratio_ratings_disabled_max_comment_count    = comment_count / ratings_disabled_max_comment_count
    ) %>%

    # published_year - pc1
    add_feature_per_category(train_data, published_year, pc1, funs) %>%
    dplyr::mutate(
      diff_published_year_mean_pc1    = pc1 - published_year_mean_pc1,
      ratio_published_year_mean_pc1   = pc1 / published_year_mean_pc1,
      diff_published_year_median_pc1  = pc1 - published_year_median_pc1,
      ratio_published_year_median_pc1 = pc1 / published_year_median_pc1,
      diff_published_year_min_pc1     = pc1 - published_year_min_pc1,
      ratio_published_year_min_pc1    = pc1 / published_year_min_pc1,
      diff_published_year_max_pc1     = pc1 - published_year_max_pc1,
      ratio_published_year_max_pc1    = pc1 / published_year_max_pc1
    ) %>%

    # published_year - likes
    add_feature_per_category(train_data, published_year, likes, funs) %>%
    dplyr::mutate(
      diff_published_year_mean_likes    = likes - published_year_mean_likes,
      ratio_published_year_mean_likes   = likes / published_year_mean_likes,
      diff_published_year_median_likes  = likes - published_year_median_likes,
      ratio_published_year_median_likes = likes / published_year_median_likes,
      diff_published_year_min_likes     = likes - published_year_min_likes,
      ratio_published_year_min_likes    = likes / published_year_min_likes,
      diff_published_year_max_likes     = likes - published_year_max_likes,
      ratio_published_year_max_likes    = likes / published_year_max_likes
    ) %>%

    # published_year - dislikes
    add_feature_per_category(train_data, published_year, dislikes, funs) %>%
    dplyr::mutate(
      diff_published_year_mean_dislikes    = dislikes - published_year_mean_dislikes,
      ratio_published_year_mean_dislikes   = dislikes / published_year_mean_dislikes,
      diff_published_year_median_dislikes  = dislikes - published_year_median_dislikes,
      ratio_published_year_median_dislikes = dislikes / published_year_median_dislikes,
      diff_published_year_min_dislikes     = dislikes - published_year_min_dislikes,
      ratio_published_year_min_dislikes    = dislikes / published_year_min_dislikes,
      diff_published_year_max_dislikes     = dislikes - published_year_max_dislikes,
      ratio_published_year_max_dislikes    = dislikes / published_year_max_dislikes
    ) %>%

    # published_year - comment_counts
    add_feature_per_category(train_data, published_year, comment_count, funs) %>%
    dplyr::mutate(
      diff_published_year_mean_comment_count    = comment_count - published_year_mean_comment_count,
      ratio_published_year_mean_comment_count   = comment_count / published_year_mean_comment_count,
      diff_published_year_median_comment_count  = comment_count - published_year_median_comment_count,
      ratio_published_year_median_comment_count = comment_count / published_year_median_comment_count,
      diff_published_year_min_comment_count     = comment_count - published_year_min_comment_count,
      ratio_published_year_min_comment_count    = comment_count / published_year_min_comment_count,
      diff_published_year_max_comment_count     = comment_count - published_year_max_comment_count,
      ratio_published_year_max_comment_count    = comment_count / published_year_max_comment_count
    ) %>%

    # flg_japanese - likes
    add_feature_per_category(train_data, flg_japanese, likes, funs) %>%
    dplyr::mutate(
      diff_flg_japanese_mean_likes    = likes - flg_japanese_mean_likes,
      ratio_flg_japanese_mean_likes   = likes / flg_japanese_mean_likes,
      diff_flg_japanese_median_likes  = likes - flg_japanese_median_likes,
      ratio_flg_japanese_median_likes = likes / flg_japanese_median_likes,
      diff_flg_japanese_min_likes     = likes - flg_japanese_min_likes,
      ratio_flg_japanese_min_likes    = likes / flg_japanese_min_likes,
      diff_flg_japanese_max_likes     = likes - flg_japanese_max_likes,
      ratio_flg_japanese_max_likes    = likes / flg_japanese_max_likes
    ) %>%

    # flg_japanese - dislikes
    add_feature_per_category(train_data, flg_japanese, dislikes, funs) %>%
    dplyr::mutate(
      diff_flg_japanese_mean_dislikes    = dislikes - flg_japanese_mean_dislikes,
      ratio_flg_japanese_mean_dislikes   = dislikes / flg_japanese_mean_dislikes,
      diff_flg_japanese_median_dislikes  = dislikes - flg_japanese_median_dislikes,
      ratio_flg_japanese_median_dislikes = dislikes / flg_japanese_median_dislikes,
      diff_flg_japanese_min_dislikes     = dislikes - flg_japanese_min_dislikes,
      ratio_flg_japanese_min_dislikes    = dislikes / flg_japanese_min_dislikes,
      diff_flg_japanese_max_dislikes     = dislikes - flg_japanese_max_dislikes,
      ratio_flg_japanese_max_dislikes    = dislikes / flg_japanese_max_dislikes
    ) %>%

    # flg_japanese - comment_count
    add_feature_per_category(train_data, flg_japanese, comment_count, funs) %>%
    dplyr::mutate(
      diff_flg_japanese_mean_comment_count    = comment_count - flg_japanese_mean_comment_count,
      ratio_flg_japanese_mean_comment_count   = comment_count / flg_japanese_mean_comment_count,
      diff_flg_japanese_median_comment_count  = comment_count - flg_japanese_median_comment_count,
      ratio_flg_japanese_median_comment_count = comment_count / flg_japanese_median_comment_count,
      diff_flg_japanese_min_comment_count     = comment_count - flg_japanese_min_comment_count,
      ratio_flg_japanese_min_comment_count    = comment_count / flg_japanese_min_comment_count,
      diff_flg_japanese_max_comment_count     = comment_count - flg_japanese_max_comment_count,
      ratio_flg_japanese_max_comment_count    = comment_count / flg_japanese_max_comment_count
    ) %>%

    # comments_ratings_disabled_japanese - sum_likes_dislikes
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, sum_likes_dislikes, funs) %>%
    dplyr::mutate(
      diff_comments_ratings_disabled_japanese_mean_sum_likes_dislikes    = sum_likes_dislikes - comments_ratings_disabled_japanese_mean_sum_likes_dislikes,
      ratio_comments_ratings_disabled_japanese_mean_sum_likes_dislikes   = sum_likes_dislikes / comments_ratings_disabled_japanese_mean_sum_likes_dislikes,
      diff_comments_ratings_disabled_japanese_median_sum_likes_dislikes  = sum_likes_dislikes - comments_ratings_disabled_japanese_median_sum_likes_dislikes,
      ratio_comments_ratings_disabled_japanese_median_sum_likes_dislikes = sum_likes_dislikes / comments_ratings_disabled_japanese_median_sum_likes_dislikes,
      diff_comments_ratings_disabled_japanese_min_sum_likes_dislikes     = sum_likes_dislikes - comments_ratings_disabled_japanese_min_sum_likes_dislikes,
      ratio_comments_ratings_disabled_japanese_min_sum_likes_dislikes    = sum_likes_dislikes / comments_ratings_disabled_japanese_min_sum_likes_dislikes,
      diff_comments_ratings_disabled_japanese_max_sum_likes_dislikes     = sum_likes_dislikes - comments_ratings_disabled_japanese_max_sum_likes_dislikes,
      ratio_comments_ratings_disabled_japanese_max_sum_likes_dislikes    = sum_likes_dislikes / comments_ratings_disabled_japanese_max_sum_likes_dislikes
    ) %>%

    # comments_ratings_disabled_japanese - comment_count
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, comment_count, funs) %>%
    dplyr::mutate(
      diff_comments_ratings_disabled_japanese_mean_comment_count    = comment_count - comments_ratings_disabled_japanese_mean_comment_count,
      ratio_comments_ratings_disabled_japanese_mean_comment_count   = comment_count / comments_ratings_disabled_japanese_mean_comment_count,
      diff_comments_ratings_disabled_japanese_median_comment_count  = comment_count - comments_ratings_disabled_japanese_median_comment_count,
      ratio_comments_ratings_disabled_japanese_median_comment_count = comment_count / comments_ratings_disabled_japanese_median_comment_count,
      diff_comments_ratings_disabled_japanese_min_comment_count     = comment_count - comments_ratings_disabled_japanese_min_comment_count,
      ratio_comments_ratings_disabled_japanese_min_comment_count    = comment_count / comments_ratings_disabled_japanese_min_comment_count,
      diff_comments_ratings_disabled_japanese_max_comment_count     = comment_count - comments_ratings_disabled_japanese_max_comment_count,
      ratio_comments_ratings_disabled_japanese_max_comment_count    = comment_count / comments_ratings_disabled_japanese_max_comment_count
    )
}


# Train & Evaluate --------------------------------------------------------

# モデルの構築と評価
train_and_eval <- function(split, recipe, model, formula) {

  options("dplyr.summarise.inform" = F)

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
