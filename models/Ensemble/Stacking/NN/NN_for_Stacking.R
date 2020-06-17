library(tidyverse)
library(tidymodels)
library(furrr)
library(keras)

source("models/NN/functions_NN.R", encoding = "utf-8")
source("models/NN/01/functions.R", encoding = "utf-8")
source("models/Ensemble/Stacking/NN/functions_Stacking_NN.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean()

# for Cross-Validation
df.cv <- create_cv(df.train_data)


# 前処理レシピの作成
recipe <- create_recipe(df.train_data)


# 並列処理
future::plan(future::multisession(workers = 5))

system.time({

  # パラメータ定義
  # low-layers
  params.low <- list(
    layers = 2,
    units = 512,
    activation = "relu",
    l1 = 1e-04,
    l2 = 1e-04,
    dropout_rate = 0.06,
    batch_size = 64
  )
  # high-layers
  params.high <- list(
    layers = 7,
    units = 512,
    activation = "relu",
    l1 = 1e-03,
    l2 = 1e-04,
    dropout_rate = 0.027,
    batch_size = 64
  )
  params <- params.high

  set.seed(1025)
  seeds <- sample(1:10000, size = 5, replace = F)

  # 訓練データに対する予測値の算出
  df.predicted.train <- 

    purrr::map_dfr(seeds, function(seed) {
      # seed 毎に予測値を生成
      furrr::future_map_dfr(
        df.cv$splits,
        train_and_predict,
        recipe = recipe,
        params = params,
        batch_size = params$batch_size,
        seed = seed,
        .options = furrr::future_options(seed = 1025L)
      ) %>%
        dplyr::arrange(id)
    }) %>%

    # seed averaging
    dplyr::group_by(id) %>%
    dplyr::summarise(predicted = mean(predicted)) %>%

    dplyr::arrange(id)


  # テストデータに対する予測値の算出
  df.predicted.test <-

    purrr::map_dfr(seeds, function(seed) {

      set.seed(1025)
      tensorflow::tf$random$set_seed(seed = seed)
      options("dplyr.summarise.inform" = F)

      # 訓練/検証 データの作成
      lst.train_valid <- create_train_valid_data(df.train_data, recipe)

      # モデル作成
      n <- lst.train_valid$x_train_train %>% ncol()
      model <- create_model_applied_parameters(params, n)

      # Compile
      model %>% keras::compile(
        optimizer = "rmsprop",
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
            patience = 2
          )
        ),

        epoch = 200,
        batch_size = params$batch_size,
        verbose = 1
      )

      # Test
      trained_recipe <- recipes::prep(recipe, training = df.train_data)
      baked_train.raw <- recipes::bake(trained_recipe, new_data = df.train_data) %>%
        add_dummies() %>%
        add_features_per_category(., .)
      baked_test <-   recipes::bake(trained_recipe, new_data = df.test_data) %>%
        add_dummies() %>%
        add_features_per_category(baked_train.raw) %>%
        select_model_predictors(include_y = F)
      x_test <- baked_test %>% as.matrix()

      # 予測結果データセット
      tibble(
        id = 1:nrow(df.test_data),
        predicted = predict(model, x_test)
      ) %>%

        dplyr::select(
          id,
          predicted
        )
    }) %>%

      # seed averaging
      dplyr::group_by(id) %>%
      dplyr::summarise(predicted = mean(predicted)) %>%

      dplyr::arrange(id)

  # ファイルへの書き出し
  save_predicts("NN", df.predicted.train, df.predicted.test)
})
