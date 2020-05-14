source("functions.R", encoding = "utf-8")

# CV 作成
create_cv <- function(df, v = 5, seed = 2851) {

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
#      published_hour  = lubridate::hour(publishedAt)  %>% forcats::as_factor(),

      # タグ
      flg_no_tags = is.na(tags),
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
      # bin_comment_count = cut(
      #   comment_count,
      #   breaks = c(
      #     0, 0.6931472, 1.6094379, 2.1972246, 2.7080502, 3.1354942, 3.5263605, 3.9120230, 4.2766661, 4.6347290, 5.0106353,
      #     5.4116461, 5.8230459, 6.2989492, 6.7878450, 7.3957830, 8.2494834, 15.2317258, Inf
      #   ),
      #   include.lowest = T
      # ),

      # comment_count / likes / dislikes
      ratio_comments_likedis = ifelse(comment_count == 0, 0, (likes + dislikes) / comment_count),
#      sum_comments_likes_dislikes = comment_count + likes + dislikes,

      # 説明文
      flg_no_description = is.na(description),
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

      # # 投稿時間
      # # flg_japanese を考慮
      # published_hour  = ifelse(flg_japanese, (lubridate::hour(publishedAt) + 9) %% 24, (lubridate::hour(publishedAt) - 0) %% 24)  %>% forcats::as_factor(),

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
  df.train <- recipes::prep(recipe, training = rsample::training(split)) %>%
    recipes::juice()
  df.test <- recipes::prep(recipe, rsample::testing(split)) %>%
    recipes::juice()

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
          truth    = y,
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
