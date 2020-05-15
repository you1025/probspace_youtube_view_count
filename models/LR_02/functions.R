source("functions.R", encoding = "utf-8")

create_cv <- function(df, v = 5, seed = 1025) {

  set.seed(seed)

  df %>%

    rsample::vfold_cv(v = v, strata = "categoryId")
}

# レシピの作成
create_recipe <- function(data) {

  recipes::recipe(y ~ ., data = data) %>%

    recipes::step_mutate(

      # タイトル
      title_length = stringr::str_length(title),

      # 投稿タイミング
      published_dow   = lubridate::wday(publishedAt, , label = T, abbr = T, locale = "C"),
      published_month = lubridate::month(publishedAt) %>% forcats::as_factor(),
      published_year  = lubridate::year(publishedAt)  %>% forcats::as_factor(),
      published_hour  = lubridate::hour(publishedAt)  %>% forcats::as_factor(),
#      days_from_published = (collection_date - lubridate::as_date(publishedAt)) %>% as.integer,
      # published_term_in_month = dplyr::case_when(
      #   dplyr::between(lubridate::day(publishedAt),  1,  5) ~ "term_1",
      #   dplyr::between(lubridate::day(publishedAt),  6, 10) ~ "term_2",
      #   dplyr::between(lubridate::day(publishedAt), 11, 15) ~ "term_3",
      #   dplyr::between(lubridate::day(publishedAt), 16, 20) ~ "term_4",
      #   dplyr::between(lubridate::day(publishedAt), 21, 25) ~ "term_5",
      #   dplyr::between(lubridate::day(publishedAt), 26, 31) ~ "term_6"
      # ) %>% forcats::as_factor(),

      # タグ
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

      # 説明文
      description_length = (dplyr::if_else(is.na(description), 0L, stringr::str_length(description)) + 1) %>% log,
      flg_url = ifelse(is.na(description), F, stringr::str_detect(description, pattern = "http(|s)://")),
      url_count = (ifelse(is.na(description), 0L, stringr::str_count(description, patter = "http(|s)://")) + 1) %>% log,

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

    ) %>%

    recipes::step_log(y, offset = 1, skip = T) %>%

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
    )
}
#create_recipe(df.train_data) %>% recipes::prep() %>% recipes::juice() %>% summary()

# モデルの構築と評価
train_and_eval <- function(split, recipe, model) {

  # 前処理済データの作成
  trained_recipe <- recipes::prep(recipe, training = rsample::training(split))
  df.train <- recipes::juice(trained_recipe)
  df.test  <- recipes::bake(trained_recipe, rsample::testing(split))


  model %>%

    # モデルの学習
    {
      model <- (.)
      parsnip::fit(
        model,
        y ~ .,
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
