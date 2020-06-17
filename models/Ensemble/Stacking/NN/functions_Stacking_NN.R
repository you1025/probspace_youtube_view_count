source("models/Ensemble/Stacking/functions_Stacking.R")

train_and_predict <- function(split, recipe, params, batch_size, seed) {

  set.seed(1025)
  tensorflow::tf$random$set_seed(seed = seed)
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


  # Test
  trained_recipe <- recipes::prep(recipe, training = train_data)
  baked_train.raw <- recipes::bake(trained_recipe, new_data = train_data) %>%
    add_dummies() %>%
    add_features_per_category(., .)
  baked_test <- recipes::bake(trained_recipe, new_data = test_data) %>%
    add_dummies() %>%
    add_features_per_category(baked_train.raw) %>%
    select_model_predictors()
  x_test <- baked_test %>% dplyr::select(-y) %>% as.matrix()

  test_data %>%

    # 予測の追加
    dplyr::mutate(predicted = predict(model, x_test)) %>%

    dplyr::select(
      id,
      predicted
    )
}
