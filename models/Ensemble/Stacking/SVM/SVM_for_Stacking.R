library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/SVM/functions_SVM.R", encoding = "utf-8")
source("models/Ensemble/Stacking/SVM/functions_Stacking_SVM.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean() %>%
  add_extra_features_train()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean() %>%
  add_extra_features_test()

# for Cross-Validation
df.cv <- create_cv(df.train_data)


# 前処理レシピの作成
recipe <- create_recipe(df.train_data)

# 学習＆予測用データの生成
trained_recipe <- recipes::prep(recipe, training = df.train_data)
df.train <- recipes::juice(trained_recipe) %>%
  add_dummies() %>%
  add_features_per_category(., .)
df.test  <- recipes::bake(trained_recipe, new_data = df.test_data) %>%
  add_dummies() %>%
  add_features_per_category(df.train)


# Model Definition --------------------------------------------------------

model <- parsnip::svm_rbf(
  mode = "regression",
  cost = 2.566852,
  rbf_sigma = 0.02511886,
  margin = 0.137
) %>%
  parsnip::set_engine(engine = "kernlab")


# 並列処理
future::plan(future::multisession(workers = 5))

system.time({
  set.seed(1025)

  # モデル構築用の説明変数を指定
  formula <- (
    y ~
      likes
    + dislikes
    + comment_count
    + tag_characters
    + flg_japanese
    + ratings_disabled
    + published_year
    + flg_categoryId_low
    + flg_categoryId_high
    + categoryId_mean_y
    + categoryId_min_y
  )


  # 訓練データに対する予測値の算出
  df.predicted.train <- furrr::future_map_dfr(
    df.cv$splits,
    train_and_predict,
    recipe = recipe,
    model = model,
    formula = formula,
    .options = furrr::future_options(seed = 1025L)
  ) %>%
    dplyr::arrange(id)

  # テストデータに対する予測値の算出
  df.predicted.test <- parsnip::fit(model, formula, data = df.train) %>%
    {
      fit <- (.)
      df.test %>%
        dplyr::mutate(predicted = predict(fit, df.test,  type = "numeric")[[1]]) %>%
        dplyr::select(
          id,
          predicted
        )
    }

  # ファイルへの書き出し
  save_predicts("SVM", df.predicted.train, df.predicted.test)
})
