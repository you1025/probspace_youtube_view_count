source("functions.R", encoding = "utf-8")

# レシピの作成
create_recipe <- function(data) {

  recipes::recipe(y ~ ., data = data) %>%

    recipes::step_mutate(

      # タイトル
      title_length = stringr::str_length(title),

      # 投稿タイミング
#      published_dow   = lubridate::wday(publishedAt, , label = T, abbr = T, locale = "C"),
      # published_dow_x = lubridate::wday(publishedAt) %>% {
      #   dow <- (.)
      #   theta <- ((dow - 1) / (7 - 1)) * 2 * pi
      #   cos(theta)
      # },
      # published_dow_y = lubridate::wday(publishedAt) %>% {
      #   dow <- (.)
      #   theta <- ((dow - 1) / (7 - 1)) * 2 * pi
      #   sin(theta)
      # },
#      published_month = lubridate::month(publishedAt) %>% forcats::as_factor(),
      # published_month_x = lubridate::month(publishedAt) %>% {
      #   month <- (.)
      #   theta <- ((month - 1) / (12 - 1)) * 2 * pi
      #   cos(theta)
      # },
      # published_month_y = lubridate::month(publishedAt) %>% {
      #   month <- (.)
      #   theta <- ((month - 1) / (12 - 1)) * 2 * pi
      #   sin(theta)
      # },
      published_year  = lubridate::year(publishedAt),

      # タグ
      flg_no_tags = is.na(tags) %>% as.integer(),
      tag_characters = (dplyr::if_else(is.na(tags), 0L, stringr::str_length(tags)) + 1) %>% log,
      tag_count      = (dplyr::if_else(is.na(tags), 0L, stringr::str_count(tags, pattern = "\\|") + 1L) + 1L) %>% log,

      # Likes/Dislikes
      likes    = log(likes + 1),
      dislikes = log(dislikes + 1),
      diff_likes_dislikes = log(likes - dislikes + 3),
      sum_likes_dislikes  = log(likes + dislikes + 1),
      ratio_likes = ifelse(likes+dislikes == 0, 0, likes / (likes + dislikes)),

      # コメント
      comment_count = log(comment_count + 1),

      # comment_count / likes / dislikes
      ratio_comments_likedis = ifelse(comment_count == 0, 0, (likes + dislikes) / comment_count),

      # 説明文
      flg_no_description = is.na(description) %>% as.integer(),
      description_length = (dplyr::if_else(is.na(description), 0L, stringr::str_length(description)) + 1) %>% log,
      flg_url   = ifelse(is.na(description), F, stringr::str_detect(description, pattern = "http(|s)://")) %>% as.integer(),
      url_count = (ifelse(is.na(description), 0L, stringr::str_count(description, patter = "http(|s)://")) + 1) %>% log,

      # 日本語フラグ
      flg_japanese = stringr::str_c(
        title,
        channelTitle,
        ifelse(is.na(tags), "", tags),
        ifelse(is.na(description), "", description),
        sep = ""
      ) %>%
        stringr::str_detect(pattern = "\\p{Hiragana}|\\p{Katakana}|\\p{Han}") %>% as.integer(),

      # 絵文字フラグ
      flg_emoji = stringr::str_c(
        title,
        channelTitle,
        ifelse(is.na(tags), "", tags),
        ifelse(is.na(description), "", description),
        sep = ""
      ) %>%
        stringr::str_detect(
          pattern = "/\\p{Emoji_Modifier_Base}\\p{Emoji_Modifier}?|\\p{Emoji_Presentation}|\\p{Emoji}\uFE0F/gu"
        ) %>%
        as.integer(),

      # 公式フラグ
      flg_official = stringr::str_c(
        title,
        channelTitle,
        ifelse(is.na(description), "", description),
        sep = ""
      ) %>%
        stringr::str_detect(pattern = stringr::regex("(公式|official)", ignore_case = T)) %>%
        as.integer(),

      # 動画番号フラグ
      flg_movie_number = stringr::str_c(
        title,
        ifelse(is.na(description), "", description),
        sep = ""
      ) %>%
        stringr::str_detect(pattern = stringr::regex("(#|＃|No(|.))\\d{1,3}", ignore_case = T)) %>%
        as.integer(),

      comments_disabled = as.integer(comments_disabled),
      ratings_disabled  = as.integer(ratings_disabled),

    ) %>%

    recipes::step_log(recipes::all_outcomes(), offset = 1, skip = T) %>%
    recipes::step_normalize(recipes::all_numeric(), - recipes::all_outcomes()) %>%

    recipes::step_rm(
      id,
      video_id,
      title,
      publishedAt,
      channelId,
      channelTitle,
      collection_date,
      tags,
      thumbnail_link,
      description
    ) %>%

    recipes::step_dummy(recipes::all_nominal())
}
#create_recipe(df.train_data) %>% recipes::prep() %>% recipes::juice() %>% summary()


# モデルの構築と評価
train_and_eval <- function(split, recipe, model) {

  # 前処理済データの作成
  trained_recipe <- recipes::prep(recipe, training = rsample::training(split))
  df.train <- recipes::juice(trained_recipe)
  df.test  <- recipes::bake(trained_recipe, new_data = rsample::testing(split))


  model %>%

    # モデルの学習
    {
      model <- (.)
      parsnip::fit(
        model,
        y ~
          likes
          + dislikes
          + title_length
          + tag_characters
          + description_length
          + url_count
          + flg_japanese
          + comments_disabled
          + ratings_disabled
          + published_year
          ,
        data = df.train
      )
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
