source("models/functions_Global.R", encoding = "utf-8")

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

# レシピの作成
create_recipe <- function(data) {

  recipe <- create_feature_engineerging_recipe(data)

  recipe %>%

    # 不要項目の削除
    recipes::step_rm(
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

    # 対数変換
    recipes::step_log(
      likes,
      dislikes,
      sum_likes_dislikes,
      tag_characters,
      tag_count,
      comment_count,
      description_length,
      url_count,

      offset = 1
    ) %>%
    recipes::step_mutate(
      diff_likes_dislikes = sign(diff_likes_dislikes) * log(abs(diff_likes_dislikes) + 1)
    ) %>%

    # 視聴回数の対数変換
    recipes::step_log(y, offset = 1, skip = T)
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

    # flg_japanese
    add_feature_per_category(train_data, flg_japanese, y, funs) %>%


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

    # comments_ratings_disabled_japanese - likes
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, likes, funs) %>%

    # comments_ratings_disabled_japanese - dislikes
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, dislikes, funs) %>%

    # comments_ratings_disabled_japanese - sum_likes_dislikes
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, sum_likes_dislikes, funs) %>%

    # comments_ratings_disabled_japanese - comment_count
    add_feature_per_category(train_data, comments_ratings_disabled_japanese, comment_count, funs)
}


# Train & Evaluate --------------------------------------------------------

# LightGBM 専用
train_and_eval_LGBM <- function(split, recipe, formula, hyper_params) {

  options("dplyr.summarise.inform" = F)

  # 項目選択処理
  filter_columns <- function(data, formula) {

    # 対象項目の一覧
    target_columns <- c("y", attr(terms(formula), "term.labels"))

    data %>%
      dplyr::select(
        dplyr::all_of(target_columns)
      )
  }

  # 前処理済データの作成
  lst.train_valid_test <- recipe %>%
    {
      recipe <- (.)

      # 訓練済レシピ
      trained_recipe <- recipes::prep(recipe, training = rsample::training(split))

      # train data
      df.train.baked <- recipes::juice(trained_recipe)
      df.train <- df.train.baked %>%
        # 訓練/検証 データに代表値を付与
        add_features_per_category(., .) %>%
        # 自前ラベルエンコーディング
        transform_categories() %>%
        # 対象項目のみを選択
        filter_columns(formula)
      x.train <- df.train %>%
        dplyr::select(-y) %>%
        as.matrix()
      y.train <- df.train$y

      # for early_stopping
      train_valid_split <- rsample::initial_split(df.train, prop = 4/5, strata = "categoryId")
      x.train.train <- rsample::training(train_valid_split) %>%
        dplyr::select(-y) %>%
        as.matrix()
      y.train.train <- rsample::training(train_valid_split)$y
      x.train.valid <- rsample::testing(train_valid_split) %>%
        dplyr::select(-y) %>%
        as.matrix()
      y.train.valid <- rsample::testing(train_valid_split)$y

      # for LightGBM Dataset
      dtrain <- lightgbm::lgb.Dataset(
        data  = x.train.train,
        label = y.train.train
      )
      dvalid <- lightgbm::lgb.Dataset(
        data  = x.train.valid,
        label = y.train.valid,
        reference = dtrain
      )


      # test data
      df.test  <- recipes::bake(trained_recipe, new_data = rsample::testing(split)) %>%
        # 訓練/検証 データに代表値を付与
        add_features_per_category(df.train.baked) %>%
        # 自前ラベルエンコーディング
        transform_categories() %>%
        # 対象項目のみを選択
        #dplyr::select(dplyr::all_of(target_columns))
        filter_columns(formula)
      x.test <- df.test %>%
        dplyr::select(-y) %>%
        as.matrix()
      y.test <- df.test$y %>% { (.) + 1 } %>% log


      list(
        ## model 学習用
        train.dtrain = dtrain,
        train.dvalid = dvalid,

        # RMSE 算出用: train
        x.train = x.train,
        y.train = y.train,

        ## RMSE 算出用: test
        x.test = x.test,
        y.test = y.test
      )
    }

  # 学習
  model.fitted <- lightgbm::lgb.train(

    # 学習パラメータの指定
    params = list(
      boosting_type = "gbdt",
      objective     = "regression",
      metric        = "rmse",

      # user defined
      max_depth        = hyper_params$max_depth,
      num_leaves       = hyper_params$num_leaves,
      min_data_in_leaf = hyper_params$min_data_in_leaf,
      feature_fraction = hyper_params$feature_fraction,
      bagging_freq     = hyper_params$bagging_freq,
      bagging_fraction = hyper_params$bagging_fraction,
      lambda_l1        = hyper_params$lambda_l1,
      lambda_l2        = hyper_params$lambda_l2,

      seed = 1234
    ),

    # 学習＆検証データ
    data   = lst.train_valid_test$train.dtrain,
    valids = list(valid = lst.train_valid_test$train.dvalid),

    # 木の数など
    learning_rate         = hyper_params$learning_rate,
    nrounds               = 20000,
    early_stopping_rounds = 200,
    verbose = -1,

    # カテゴリデータの指定
    categorical_feature = c(
      "categoryId"
    )
  )

  # RMSE の算出
  train_rmse <- tibble::tibble(
    actual = lst.train_valid_test$y.train,
    pred   = predict(model.fitted, lst.train_valid_test$x.train)
  ) %>%
    yardstick::rmse(truth = actual, estimate = pred) %>%
    dplyr::pull(.estimate)
  test_rmse <- tibble::tibble(
    actual = lst.train_valid_test$y.test,
    pred   = predict(model.fitted, lst.train_valid_test$x.test)
  ) %>%
    yardstick::rmse(truth = actual, estimate = pred) %>%
    dplyr::pull(.estimate)

  tibble::tibble(
    train_rmse = train_rmse,
    test_rmse  = test_rmse
  )
}

transform_categories <- function(data) {

  data %>%

    # # Label-Encoding
    dplyr::mutate(
      comments_disabled = as.integer(comments_disabled) - 1L,
      ratings_disabled  = as.integer(ratings_disabled)  - 1L,
      published_month   = as.integer(published_month)   - 1L,
      published_day     = as.integer(published_day)     - 1L,
      published_term_in_month = as.integer(published_term_in_month) - 1L,
      published_dow     = as.integer(published_dow)     - 1L,
      published_hour    = as.integer(published_hour)    - 1L,
      published_hour2   = as.integer(published_hour2)   - 1L,
      comments_ratings_disabled_japanese = as.integer(comments_ratings_disabled_japanese) - 1L
    ) %>%

    # フラグの処理
    dplyr::mutate(
      flg_categoryId_low  = as.integer(flg_categoryId_low),
      flg_categoryId_high = as.integer(flg_categoryId_high),
      flg_no_tags         = as.integer(flg_no_tags),
      flg_no_description  = as.integer(flg_no_description),
      flg_url             = as.integer(flg_url),
      flg_japanese        = as.integer(flg_japanese),
      flg_emoji           = as.integer(flg_emoji),
      flg_official        = as.integer(flg_official),
      flg_movie_number    = as.integer(flg_movie_number),
      flg_comments_ratings_disabled_japanese_high      = as.integer(flg_comments_ratings_disabled_japanese_high),
      flg_comments_ratings_disabled_japanese_very_high = as.integer(flg_comments_ratings_disabled_japanese_very_high),
      flg_comments_ratings_disabled_japanese_low       = as.integer(flg_comments_ratings_disabled_japanese_low),
      flg_comments_ratings_disabled_japanese_very_low  = as.integer(flg_comments_ratings_disabled_japanese_very_low)
    )
}
