library(tidyverse)
library(tidymodels)
library(lightgbm)

source("models/LGBM/01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

# 訓練データ
df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean()

# 前処理レシピの作成
recipe <- create_recipe(df.train_data)


# Predict by Test Data ----------------------------------------------------

# モデルの学習
{
  set.seed(1025)

  # モデル構築用の説明変数を指定
  formula <- (
    y ~
      categoryId
    + likes
    + dislikes
    + comment_count
    + comments_disabled
    + ratings_disabled
    + title_length
    + channel_title_length
    + tag_characters
    + tag_count
    + description_length
    + days_from_published
    + diff_likes_dislikes
    + ratio_likes
    + ratio_comments_likedis
    + flg_japanese
    + published_year
    + flg_url
    + url_count
    + flg_movie_number
    + flg_comments_ratings_disabled_japanese_low
    + categoryId_max_y
    + published_year_max_y
  )

  # 前処理済データの作成
  lst.train_valid_test <- recipe %>%

    {
      recipe <- (.)

      # 訓練済レシピ
      trained_recipe <- recipes::prep(recipe, training = df.train_data)

      # train data
      df.train.baked <- recipes::juice(trained_recipe)
      df.train <- df.train.baked %>%
        # 訓練/検証 データに代表値を付与
        add_features_per_category(., .) %>%
        # 自前ラベルエンコーディング
        transform_categories() %>%
        # 対象項目のみを選択
        filter_columns(formula, extra_columns = c("y"))
      x.train <- df.train %>%
        dplyr::select(-y) %>%
        as.matrix()
      y.train <- df.train$y

      # for early_stopping
      train_valid_split <- rsample::initial_split(df.train, prop = 6/7, strata = "categoryId")
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
      df.test  <- recipes::bake(trained_recipe, new_data = df.test_data) %>%
        # 訓練/検証 データに代表値を付与
        add_features_per_category(df.train.baked) %>%
        # 自前ラベルエンコーディング
        transform_categories() %>%
        # 対象項目のみを選択
        filter_columns(formula)
      x.test <- df.test %>%
        as.matrix()


      list(
        # model 学習用
        train.dtrain = dtrain,
        train.dvalid = dvalid,

        # submit 用: test
        x.test = x.test
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
      max_depth        = 12,
      num_leaves       = 39,
      min_data_in_leaf = 28,
      feature_fraction = 0.9652174,
      bagging_freq     = 1,
      bagging_fraction = 0.7956522,
      lambda_l1        = 0.735,
      lambda_l2        = 0.825,

      seed = 1234
    ),

    # 学習＆検証データ
    data   = lst.train_valid_test$train.dtrain,
    valids = list(valid = lst.train_valid_test$train.dvalid),

    # 木の数など
    learning_rate = 0.01,
    nrounds       = 20000,
    early_stopping_rounds = 200,
    verbose = -1,

    # カテゴリデータの指定
    categorical_feature = c(
      "categoryId"
    )
  )

  # 予測結果
  pred <- predict(model.fitted, lst.train_valid_test$x.test) %>% exp %>% { (.) - 1 } %>% as.integer()
  tibble(
    id = 1:(length(pred)),
    y  = pred
  ) %>%

    # ファイルに出力
    {
      df.submit <- (.)

      # ファイル名
      filename <- stringr::str_c(
        "LGBM",
        lubridate::now(tz = "Asia/Tokyo") %>% format("%Y%m%dT%H%M%S"),
        sep = "_"
      ) %>%
        stringr::str_c("csv", sep = ".")

      # 出力ファイルパス
      filepath <- stringr::str_c("models/LGBM/01/output", filename, sep = "/")

      # 書き出し
      readr::write_csv(df.submit, filepath, col_names = T)
    }
}
