library(tidyverse)
library(tidymodels)
library(furrr)
library(keras)

source("models/NN_01/functions.R", encoding = "utf-8")

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

recipe <- create_recipe(df.train_data)



lst.splitted <- rsample::initial_split(df.train_data, prop = 4/5, strata = "categoryId") %>%
  {
    split <- (.)
    train <- rsample::training(split)
    test  <- rsample::testing(split)

    valid_indices <- sample(nrow(train), 3000, replace = F)

    # Train
    train_train <- train[-valid_indices,]
    train_valid <- train[ valid_indices,]
    trained_recipe <- recipes::prep(recipe, training = train_train)
    baked_train_train <- recipes::bake(trained_recipe, train_train)
    baked_train_valid <- recipes::bake(trained_recipe, train_valid)

    # Test
    baked_test <- recipes::bake(trained_recipe, test)

    list(
      # Train
      x_train_train = baked_train_train %>% dplyr::select(-y) %>% as.matrix(),
      y_train_train = baked_train_train %>% dplyr::pull(y) %>% { log(1 + .) },
      x_train_valid = baked_train_valid %>% dplyr::select(-y) %>% as.matrix(),
      y_train_valid = baked_train_valid %>% dplyr::pull(y) %>% { log(1 + .) },

      # Test
      x_test = baked_test %>% dplyr::select(-y) %>% as.matrix(),
      y_test = baked_test %>% dplyr::pull(y) %>% { log(1 + .) }
    )
  }



train_and_evaluate <- function(params, data) {

  # ハイパーパラメータの組み合わせごとにループ
  furrr::future_pmap_dfr(params, function(layers, units, activation, l1, l2, dropout_rate, batch_size, data) {

    # モデル定義
    model <- keras::keras_model_sequential() %>%
      keras::layer_dense(
        units = units,
        activation = activation,
        kernel_regularizer = keras::regularizer_l1_l2(l1 = l1, l2 = l2),
        input_shape = c(57)
      ) %>%
      keras::layer_dropout(rate = dropout_rate)
    for(k in 2:layers) {
      model <- model %>%
        keras::layer_dense(
          units = units,
          activation = activation,
          kernel_regularizer = keras::regularizer_l1_l2(l1 = l1, l2 = l2)
        ) %>%
        keras::layer_dropout(rate = dropout_rate)
    }

    model %>% keras::compile(
      optimizer = "rmsprop",
      loss = "mse",
      metrics = c("mse")
    )

    history <- model %>% keras::fit(
      data$x_train_train,
      data$y_train_train,
      validation_data = list(
        data$x_train_valid,
        data$y_train_valid
      ),
      callbacks = list(
        keras::callback_early_stopping(
          monitor = "mse",
          patience = 2
        )
      ),
      epoch = 50,
      batch_size = batch_size,
      verbose = 0
    )

    # 汎化精度の算出
    test_acc <- predict(model, data$x_test) %>% {
      mean((data$y_test - .)^2)
    }

    tibble::tibble(
      layers = layers,
      units  = units,
      activation = activation,
      l1 = l1,
      l2 = l2,
      batch_size = batch_size,
      dropout_rate = dropout_rate,
      test_acc = test_acc
    )
  }, data = data) %>%

    # 汎化精度でソート
    dplyr::arrange(test_acc)
}



# 並列処理
future::plan(future::multisession(workers = 8))

df.grid.params <- tidyr::crossing(
  layers = c(3, 4),
  units = c(32, 64),
  activation = "relu",
  l1 = c(0.001, 0.0001),
  l2 = c(0.001, 0.0001),
  dropout_rate = c(0.00, 0.001),
  batch_size = c(32, 64)
)[1,]

system.time(
  df.results <- train_and_evaluate(df.grid.params, lst.splitted)
)
df.results



  

