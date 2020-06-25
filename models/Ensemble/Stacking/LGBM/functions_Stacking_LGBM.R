source("models/Ensemble/Stacking/functions_Stacking.R", encoding = "utf-8")

train_and_predict <- function(split, recipe, hyper_parameters, formula, seed) {

  options("dplyr.summarise.inform" = F)

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
        filter_columns(formula, extra_columns = c("id", "y"))
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
        filter_columns(formula, extra_columns = c("id", "y"))
      x.test <- df.test %>%
        dplyr::select(-y) %>%
        as.matrix()
      y.test <- df.test$y %>% { (.) + 1 } %>% log


      list(
        # model 学習用
        train.dtrain = dtrain,
        train.dvalid = dvalid,

        # 予測値生成用: test
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

      seed = seed
    ),

    # 学習＆検証データ
    data   = lst.train_valid_test$train.dtrain,
    valids = list(valid = lst.train_valid_test$train.dvalid),

    # 木の数など
    learning_rate         = hyper_parameters$learning_rate,
    nrounds               = 20000,
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
    ) %>%
    dplyr::arrange(id)
}

# 項目の選択
filter_columns <- function(data, formula, extra_columns = NULL) {
  
  # 対象項目の一覧
  target_columns <- c(attr(terms(formula), "term.labels"), extra_columns)
  
  data %>%
    dplyr::select(
      dplyr::all_of(target_columns),
    )
}
