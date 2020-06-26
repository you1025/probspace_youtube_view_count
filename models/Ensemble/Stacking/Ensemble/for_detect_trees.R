library(tidyverse)
library(tidymodels)
library(xgboost)

source("models/Ensemble/Stacking/Ensemble/functions_Stacking_Ensemble.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_stacking_train_data()


# tree estimation ---------------------------------------------------------

df.train_data %>%

  # formula と同じ項目を選択
  dplyr::select(
    y
    , LR
    , KNN
    , SVM
    , NN.shallow
    , NN.deep
    , RF.shallow
    , RF.deep
    , XGB.shallow
    , XGB.middle
    , XGB.deep
    , LGBM.shallow
    , LGBM.deep
  ) %>%

  {
    data <- (.)
    x <- dplyr::select(data, -y) %>% as.matrix()
    y <- data$y

    xgboost::xgb.cv(
      params = list(
        objective = "reg:linear",
        eval_metric = "rmse"
      ),

      data  = x,
      label = y,

      eta = 0.01,
      max_depth = 3,
      colsample_bytree = 0.6666667,
      min_child_weight = 11,
      subsample = 0.7375,
      gamma = 10^(-0.2895833),

      nfold = 8,
      nrounds = 5000,
      early_stopping_rounds = 20,
      nthread = 8
    )
  }
