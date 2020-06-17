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
#      published_year  = lubridate::year(publishedAt) %>% forcats::as_factor(),

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
      ) %>% forcats::as_factor(),
      flg_comments_ratings_disabled_japanese_high      = (comments_ratings_disabled_japanese == "F_T_T"),
      flg_comments_ratings_disabled_japanese_very_high = (comments_ratings_disabled_japanese == "F_T_F"),
      flg_comments_ratings_disabled_japanese_low       = (comments_ratings_disabled_japanese %in% c("T_F_F", "T_T_T")),
      flg_comments_ratings_disabled_japanese_very_low  = (comments_ratings_disabled_japanese == "T_T_F"),

      # PCA: likes / dislikes / comment_count
      pc1 = prcomp(
        tibble::tibble(
          x1 = likes,
          x2 = dislikes
        ),
        scale = T
      )$x[,1],
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

    # scaling
    recipes::step_range(recipes::all_numeric(), - recipes::all_outcomes(), min = 0, max = 1) %>%

    # # ダミー変数化
    # recipes::step_dummy(recipes::all_nominal(), one_hot = T) %>%

    # 視聴回数の対数変換
    recipes::step_log(y, offset = 1, skip = T)
}

# ダミー変数を追加
add_dummies <- function(data) {

  recipes::recipe(~ ., data) %>%

    # special_segment の追加
    recipes::step_mutate(
      special_segment = dplyr::case_when(
        ratings_disabled      ~ "ratings_disabled",
        comment_count < 0.105 ~ "ratings_abled_low_comments",
        T                     ~ "others"
      ) %>%
        factor(levels = c("others", "ratings_disabled", "ratings_abled_low_comments"))
    ) %>%

    # ダミー化前を残したい(集約用)ので tmp 変数として保持
    recipes::step_mutate(
      special_segment_tmp = special_segment,
      categoryId_tmp      = categoryId,
      published_year_tmp  = published_year,
      published_dow_tmp   = published_dow,
      published_month_tmp = published_month
    ) %>%

    # One-Hot Encoding
    recipes::step_dummy(
      special_segment,
      categoryId,
      published_year,
      published_dow,
      published_month,
      one_hot = T
    ) %>%

    # ダミー化しない版を追加
    recipes::step_mutate(
      special_segment = special_segment_tmp,
      categoryId      = categoryId_tmp,
      published_year  = published_year_tmp,
      published_dow   = published_dow_tmp,
      published_month = published_month_tmp
    ) %>%
    recipes::step_rm(
      special_segment_tmp,
      categoryId_tmp,
      published_year_tmp,
      published_dow_tmp,
      published_month_tmp
    ) %>%

    recipes::prep() %>%
    recipes::juice()
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
    
    # scaling
    dplyr::mutate(
      dplyr::across(
        c(
          dplyr::matches("_mean_"),
          dplyr::matches("_median_"),
          dplyr::matches("_min_"),
          dplyr::matches("_max_"),
          dplyr::matches("_sd_")
        ),
        ~ (.x - min(.x)) / (max(.x) - min(.x))
      )
      
    )
}


# モデル生成 -------------------------------------------------------------------

# パラメータに応じたモデル生成
create_model_applied_parameters <- function(params, input_columns) {

  # モデル定義: 1 階層目
  model <- keras::keras_model_sequential() %>%
    keras::layer_dense(
      units      = params$units,
      activation = params$activation,
      kernel_regularizer = keras::regularizer_l1_l2(
        l1 = params$l1,
        l2 = params$l2
      ),
      input_shape = c(input_columns)
    )

  # 2 階層目以降
  for(k in 2:params$layers) {
    model <- model %>%
      keras::layer_dropout(rate = params$dropout_rate) %>%
#      keras::layer_batch_normalization() %>%
      keras::layer_dense(
        units      = params$units,
        activation = params$activation,
        kernel_regularizer = keras::regularizer_l1_l2(
          l1 = params$l1,
          l2 = params$l2
        )
      )
  }

  # 最終層
  model <- model %>%
    keras::layer_dense(units = 1)

  model
}

# Train & Evaluate --------------------------------------------------------

# 訓練用と検証用のデータ生成
create_train_valid_data <- function(data, recipe, valid_row = 5000) {

  # 検証用の行番号を生成
  valid_indices <- sample(nrow(data), valid_row, replace = F)

  # 訓練用と検証用に分離
  train_train <- data[-valid_indices,]
  train_valid <- data[ valid_indices,]
  trained_recipe <- recipes::prep(recipe, training = train_train)
  baked_train_train.raw <- recipes::bake(trained_recipe, train_train) %>%
    add_dummies() %>%
    add_features_per_category(., .)
  baked_train_train <- baked_train_train.raw %>%
    select_model_predictors()
  baked_train_valid <- recipes::bake(trained_recipe, train_valid) %>%
    add_dummies() %>%
    add_features_per_category(baked_train_train.raw) %>%
    select_model_predictors()

  list(
    x_train_train = baked_train_train %>% dplyr::select(-y) %>% as.matrix(),
    y_train_train = baked_train_train %>% dplyr::pull(y) %>% { log(1 + .) },
    x_train_valid = baked_train_valid %>% dplyr::select(-y) %>% as.matrix(),
    y_train_valid = baked_train_valid %>% dplyr::pull(y) %>% { log(1 + .) }
  )
}

# モデルの構築と評価
train_and_eval <- function(split, recipe, params, batch_size) {

  set.seed(1025)
  tensorflow::tf$random$set_seed(seed = 777)
  options("dplyr.summarise.inform" = F)

  # CV データの抽出
  train_data <- rsample::training(split)
  test_data <- rsample::testing(split)

  # 訓練/検証 データの作成
  lst.train_valid <- create_train_valid_data(train_data, recipe)


  # モデル作成
  n <- recipes::prep(recipe) %>%
    recipes::juice() %>%
    add_dummies() %>%
    add_features_per_category(., .) %>%
    select_model_predictors() %>%
    ncol()
  model <- create_model_applied_parameters(params, input_columns = n - 1) # y の分だけ 1 減らす

  # Compile
  model %>% keras::compile(
    optimizer = keras::optimizer_adam(lr = 0.001),
    loss = "mse",
    metrics = c("mse")
  )

  # 学習
  history <- model %>% keras::fit(
    # 訓練データ
    lst.train_valid$x_train_train,
    lst.train_valid$y_train_train,

    # 検証用データ(for Early Stopping)
    validation_data = list(
      lst.train_valid$x_train_valid,
      lst.train_valid$y_train_valid
    ),
    callbacks = list(
      keras::callback_early_stopping(
        monitor = "mse",
        patience = 1
      )
    ),

    epoch = 200,
    batch_size = batch_size,
    verbose = 0
  )


  # 訓練済レシピ
  trained_recipe <- recipes::prep(recipe, training = train_data)

  # Train
  baked_train.raw <- recipes::bake(trained_recipe, new_data = train_data) %>%
    add_dummies() %>%
    add_features_per_category(., .)
  baked_train <- baked_train.raw %>%
    select_model_predictors()
  x_train <- baked_train %>% dplyr::select(-y) %>% as.matrix()
  y_train <- baked_train %>% dplyr::pull(y) %>% { log(1 + .) }
  # Test
  baked_test <- recipes::bake(trained_recipe, new_data = test_data) %>%
    add_dummies() %>%
    add_features_per_category(baked_train.raw) %>%
    select_model_predictors()
  x_test <- baked_test %>% dplyr::select(-y) %>% as.matrix()
  y_test <- baked_test %>% dplyr::pull(y) %>% { log(1 + .) }

  # 汎化精度の算出
  train_rmse <- predict(model, x_train) %>% { sqrt(mean((y_train - .)^2)) }
  test_rmse  <- predict(model, x_test)  %>% { sqrt(mean((y_test  - .)^2)) }
  tibble::tibble(
    train_rmse = train_rmse,
    test_rmse  = test_rmse
  )
}
