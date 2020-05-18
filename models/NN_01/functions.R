source("functions.R", encoding = "utf-8")

# レシピの作成
create_recipe <- function(data) {

  recipes::recipe(y ~ ., data = data) %>%

    recipes::step_mutate(

      # タイトル
      title_length = stringr::str_length(title),

      # 投稿タイミング
      published_dow   = lubridate::wday(publishedAt, , label = T, abbr = T, locale = "C"),
      published_month = lubridate::month(publishedAt) %>% forcats::as_factor(),
      published_year  = lubridate::year(publishedAt),
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

      # comment_count / likes / dislikes
      ratio_comments_likedis = ifelse(comment_count == 0, 0, (likes + dislikes) / comment_count),

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

      flg_categoryId_low  = (categoryId %in% c("19", "28", "29", "30")),
      flg_categoryId_high = (categoryId %in% c("1", "10", "20", "23", "24")),
    ) %>%

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
    
#    recipes::step_normalize(recipes::all_numeric(), - recipes::all_outcomes()) %>%
    recipes::step_range(recipes::all_numeric(), - recipes::all_outcomes(), min = 0, max = 1) %>%
    recipes::step_dummy(recipes::all_nominal()) %>%

    recipes::step_log(y, offset = 1, skip = T)
}
#create_recipe(df.train_data) %>% recipes::prep() %>% recipes::juice() %>% summary()


# パラメータに応じたモデル生成
create_model_applied_parameters <- function(params, n) {

  # モデル定義: 1 階層目
  model <- keras::keras_model_sequential() %>%
    keras::layer_dense(
      units      = params$units,
      activation = params$activation,
      kernel_regularizer = keras::regularizer_l1_l2(
        l1 = params$l1,
        l2 = params$l2
      ),
      input_shape = c(n)
    )

  # 2 階層目以降
  for(k in 2:params$layers) {
    model <- model %>%
      keras::layer_dropout(rate = params$dropout_rate) %>%
      keras::layer_batch_normalization() %>%
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

# 訓練用と検証用のデータ生成
create_train_valid_data <- function(data, recipe, valid_row = 5000) {

  # 検証用の行番号を生成
  valid_indices <- sample(nrow(data), valid_row, replace = F)

  # 訓練用と検証用に分離
  train_train <- data[-valid_indices,]
  train_valid <- data[ valid_indices,]
  trained_recipe <- recipes::prep(recipe, training = train_train)
  baked_train_train <- recipes::bake(trained_recipe, train_train)
  baked_train_valid <- recipes::bake(trained_recipe, train_valid)

  list(
    x_train_train = baked_train_train %>% dplyr::select(-y) %>% as.matrix(),
    y_train_train = baked_train_train %>% dplyr::pull(y) %>% { log(1 + .) },
    x_train_valid = baked_train_valid %>% dplyr::select(-y) %>% as.matrix(),
    y_train_valid = baked_train_valid %>% dplyr::pull(y) %>% { log(1 + .) }
  )
}

# モデルの構築と評価
train_and_eval_nn <- function(split, recipe, model, batch_size) {

  # CV データの抽出
  train_data <- rsample::training(split)
  test_data <- rsample::testing(split)

  # 訓練/検証 データの作成
  lst.train_valid <- create_train_valid_data(train_data, recipe)

  # Compile
  model %>% keras::compile(
#    optimizer = "rmsprop",
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
  baked_train <- recipes::bake(trained_recipe, new_data = train_data)
  x_train <- baked_train %>% dplyr::select(-y) %>% as.matrix()
  y_train <- baked_train %>% dplyr::pull(y) %>% { log(1 + .) }
  # Test
  baked_test <- recipes::bake(trained_recipe, new_data = test_data)
  x_test <- baked_test %>% dplyr::select(-y) %>% as.matrix()
  y_test <- baked_test %>% dplyr::pull(y) %>% { log(1 + .) }

  # 汎化精度の算出
  train_mse <- predict(model, x_train) %>% { mean((y_train - .)^2) }
  test_mse  <- predict(model, x_test)  %>% { mean((y_test  - .)^2) }
  tibble::tibble(
    train_mse = train_mse,
    test_mse  = test_mse
  )
}

