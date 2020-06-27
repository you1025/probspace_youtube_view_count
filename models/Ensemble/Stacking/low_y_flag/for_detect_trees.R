library(tidyverse)
library(tidymodels)
library(xgboost)

source("models/XGB/functions_XGB.R", encoding = "utf-8")
source("models/Ensemble/Stacking/low_y_flag/functions_Stacking_low_y_flag.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean() %>%
  dplyr::mutate(
    flg_low_1000  = (y <=  1000) %>% forcats::as_factor(),
    flg_low_5000  = (y <=  5000) %>% forcats::as_factor(),
    flg_low_10000 = (y <= 10000) %>% forcats::as_factor(),
    flg_low_30000 = (y <= 30000) %>% forcats::as_factor()
  )

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)

for_dummy_recipe <- recipes::recipe(y ~ ., df.train_data) %>%
  recipes::step_dummy(recipes::all_nominal(), one_hot = T)


# tree estimation ---------------------------------------------------------

recipes::prep(recipe, training = df.train_data) %>%
  recipes::juice() %>%
  add_features_per_category(., .) %>%

  # formula と同じ項目を選択
  dplyr::select(
    y
    ,categoryId
    ,likes
    ,dislikes
    ,comment_count
    ,comments_disabled
    ,ratings_disabled
    ,published_year
    ,published_month_x ,published_month_y
    ,channel_title_length
    ,flg_no_tags
    ,tag_characters
    ,tag_count
    ,description_length
    ,flg_japanese
    ,url_count
    ,flg_url
    ,flg_categoryId_high
    ,comments_ratings_disabled_japanese
    ,diff_published_year_mean_dislikes
  ) %>%

  # カテゴリ値対応
  get_dummies() %>%

  dplyr::mutate(flg_low = (df.train_data$flg_low_30000 == "TRUE")) %>% ### 変更点 ###

  {
    data <- (.)
    x <- dplyr::select(data, -y, -flg_low) %>% as.matrix()
    y <- data$flg_low

    xgboost::xgb.cv(
      params = list(
        objective = "binary:logistic",
        eval_metric = "logloss"
      ),

      data  = x,
      label = y,

      eta = 0.01,
      max_depth = 7,
      colsample_bytree = 0.8139535,
      min_child_weight = 2,
      subsample = 0.9,
      gamma = 10^(-0.2706667),

      nfold = 8,
      nrounds = 5000,
      early_stopping_rounds = 20,
      nthread = 8
    )
  }
