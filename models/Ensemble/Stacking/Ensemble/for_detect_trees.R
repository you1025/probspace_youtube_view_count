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
    ,KNN
    ,SVM
    ,NN.shallow
    ,NN.deep
    ,RF.shallow
    ,RF.deep
    ,XGB.shallow
    ,XGB.middle
    ,XGB.deep
    ,LGBM.shallow
    ,LGBM.deep
    ,V1
    ,V2
    ,cluster.10
    ,cluster.100
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
      max_depth = 4,
      colsample_bytree = 0.3333333,
      min_child_weight = 9,
      subsample = 0.7217391,
      gamma = 10^(-0.2966667),

      nfold = 8,
      nrounds = 5000,
      early_stopping_rounds = 20,
      nthread = 8
    )
  }
