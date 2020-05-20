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
