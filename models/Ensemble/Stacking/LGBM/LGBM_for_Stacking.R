library(tidyverse)
library(tidymodels)
library(furrr)
library(lightgbm)

source("models/LGBM/functions_LGBM.R", encoding = "utf-8")
source("models/Ensemble/Stacking/LGBM/functions_Stacking_LGBM.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean()

# for Cross-Validation
df.cv <- create_cv(df.train_data)


# 前処理レシピの作成
recipe <- create_recipe(df.train_data)


# 並列処理
future::plan(future::multisession(workers = 8))

system.time({

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

  # hyper_parameters.deep <- list(
  #   learning_rate    = 0.01,
  #   max_depth        = 12,
  #   num_leaves       = 39,
  #   min_data_in_leaf = 28,
  #   feature_fraction = 0.9652174,
  #   bagging_freq     = 1,
  #   bagging_fraction = 0.7956522,
  #   lambda_l1        = 0.735,
  #   lambda_l2        = 0.825
  # )
  hyper_parameters.shallow <- list(
    learning_rate    = 0.01,
    max_depth        = 5,
    num_leaves       = 19,
    min_data_in_leaf = 26,
    feature_fraction = 0.9400000,
    bagging_freq     = 1,
    bagging_fraction = 0.8357143,
    lambda_l1        = 0.7857143,
    lambda_l2        = 0.8250000
  )
  hyper_parameters <- hyper_parameters.shallow


  # seed の生成
  set.seed(1025)
  seeds <- sample(1:10000, size = 10, replace = F)

  # 訓練データに対する予測値の算出
  df.predicted.train <-

    # seed 毎に予測値を生成
    purrr::map_dfr(seeds, function(seed) {

      furrr::future_map_dfr(
        df.cv$splits,
        train_and_predict,
        recipe = recipe,
        hyper_parameters,
        formula = formula,
        seed = seed,
        .options = furrr::future_options(seed = 1025L)
      )
    }) %>%
    
    # seed averaging
    dplyr::group_by(id) %>%
    dplyr::summarise(predicted = mean(predicted)) %>%
    
    dplyr::arrange(id)


  # テストデータに対する予測値の算出
  df.predicted.test <-

    # seed 毎に予測値を生成
    furrr::future_map_dfr(seeds, function(seed, formula) {

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
            filter_columns(formula, extra_columns = c("id"))
          x.test <- df.test %>%
            dplyr::select(-id) %>%
            as.matrix()

          list(
            # model 学習用
            train.dtrain = dtrain,
            train.dvalid = dvalid,
            
            # submit 用: test
            x.test = x.test,
            df_test = df.test
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
          max_depth        = hyper_parameters$max_depth,
          num_leaves       = hyper_parameters$num_leaves,
          min_data_in_leaf = hyper_parameters$min_data_in_leaf,
          feature_fraction = hyper_parameters$feature_fraction,
          bagging_freq     = hyper_parameters$bagging_freq,
          bagging_fraction = hyper_parameters$bagging_fraction,
          lambda_l1        = hyper_parameters$lambda_l1,
          lambda_l2        = hyper_parameters$lambda_l2,
          
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

      lst.train_valid_test$df_test %>%

        # 予測の追加
        dplyr::mutate(predicted = predict(model.fitted, lst.train_valid_test$x.test)) %>%

        dplyr::select(
          id,
          predicted
        )
    }, formula = formula, .options = furrr::future_options(seed = 1025L)) %>%

    # seed averaging
    dplyr::group_by(id) %>%
    dplyr::summarise(predicted = mean(predicted)) %>%

    dplyr::arrange(id)


  # ファイルへの書き出し
  save_predicts("LGBM", df.predicted.train, df.predicted.test)
})
