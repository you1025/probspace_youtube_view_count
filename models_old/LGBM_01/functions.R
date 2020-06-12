source("functions.R", encoding = "utf-8")

# レシピの作成
create_recipe <- function(data) {

  recipe <- create_feature_engineerging_recipe(data)

  recipe %>%

    # 不要項目の削除
    recipes::step_rm(
      id,
      video_id,
      title,
      publishedAt,
      channelId,
      channelTitle,
      collection_date,
#      tags,
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

# LightGBM 専用
train_and_eval_LGBM <- function(split, recipe, formula, hyper_params) {

  options("dplyr.summarise.inform" = F)

  # 項目選択処理
  filter_columns <- function(data) {

    # 対象項目の一覧
    target_columns <- c("y", attr(terms(formula), "term.labels"))

    data %>%
      dplyr::select(
        dplyr::all_of(target_columns),

        # "mean" 全部のせ
        dplyr::matches("_mean_"),

        # "median" 全部のせ
        dplyr::matches("_median_"),

        # "min" 全部のせ
        dplyr::matches("_min_"),

        # # "max" 全部のせ
        # dplyr::matches("_max_"),

        # # "sd" 全部のせ
        # dplyr::matches("_sd_"),

        -dplyr::matches("flg_no_tags_"),
        -dplyr::matches("flg_no_description_"),
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
        filter_columns()
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
        filter_columns()
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
    learning_rate = hyper_params$learning_rate,
    nrounds       = 20000,
    early_stopping_rounds = 200,
    verbose = -1,

    # カテゴリデータの指定
    categorical_feature = c(
      "categoryId"
      #,"comments_disabled"
      #,"ratings_disabled"
    )
  )

  # MAE の算出
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
