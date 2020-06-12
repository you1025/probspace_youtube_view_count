library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/LR/functions_LR.R", encoding = "utf-8")
source("models/Ensemble/Stacking/functions_Stacking.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean()

# for Cross-Validation
df.cv <- create_cv(df.train_data)


# 前処理レシピの作成
recipe <- create_recipe(df.train_data)

# 学習＆予測用データの生成
trained_recipe <- recipes::prep(recipe, training = df.train_data)
df.train <- recipes::juice(trained_recipe) %>%
  add_features_per_category(., .)
df.test  <- recipes::bake(trained_recipe, new_data = df.test_data) %>%
  add_features_per_category(df.train)


# Model Definition --------------------------------------------------------

model <- parsnip::linear_reg(
  mode = "regression",
  penalty = 0.00001,
  mixture = 0.9666667
) %>%
  parsnip::set_engine(engine = "glmnet")


# 並列処理
future::plan(future::multisession(workers = 5))

system.time({
  set.seed(1025)

  # モデル構築用の説明変数を指定
  formula <- (
    y ~
      special_segment
    + special_segment:(
      categoryId
      + pc1
      + likes
      + dislikes
      + comment_count
      + title_length
      + tag_characters
      + tag_count
      + description_length
      + diff_likes_dislikes
      + sum_likes_dislikes
      + days_from_published
      + flg_japanese
      + published_dow
      + published_month
      + published_year
      + flg_no_tags
      + ratio_likes
      + ratio_comments_likedis
      + flg_no_description
      + description_length
      + flg_url
      + url_count
      + flg_emoji
      + flg_official
      + flg_movie_number
      + flg_categoryId_low
      + categoryId_mean_y
      + categoryId_min_y
      + published_year_mean_y
      + flg_japanese_mean_y
      + categoryId_max_comment_count
      + published_year_mean_pc1
      + comments_disabled_mean_pc1
      + diff_comments_disabled_mean_dislikes
      + published_year_median_likes
      + diff_published_year_mean_dislikes
    )
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
  save_predicts("LR", df.predicted.train, df.predicted.test)
})
