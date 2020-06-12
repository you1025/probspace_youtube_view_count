# TODO

library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/LR/01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)


# Model Definition --------------------------------------------------------

model <- parsnip::linear_reg(
  mode = "regression",
  penalty = parsnip::varying(),
  mixture = parsnip::varying()
) %>%
  parsnip::set_engine(engine = "glmnet")


# Hyper Parameter ---------------------------------------------------------

# df.grid.params <- dials::grid_regular(
#   dials::penalty(c(-6.0, -5.0)),
#   dials::mixture(c(0.95, 1.0)),
#   levels = 4
# )
df.grid.params <- tidyr::crossing(
  penalty = c(0.00001),
  mixture = c(0.9666667)
)
df.grid.params


# Parametr Fitting --------------------------------------------------------

# 並列処理
future::plan(future::multisession(workers = 5))

system.time({
  set.seed(1025)

  df.results <-

    # ハイパーパラメータの組み合わせごとにループ
#    furrr::future_pmap_dfr(df.grid.params, function(...) {
    purrr::pmap_dfr(df.grid.params, function(...) {

      # パラメータの適用
      model.applied <- parsnip::set_args(model, ...)

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

      # クロスバリデーションの分割ごとにモデル構築&評価
#      purrr::map_dfr(
      furrr::future_map_dfr(
        df.cv$splits,
        train_and_eval,
        recipe = recipe,
        model = model.applied,
        formula = formula
        ,.options = furrr::future_options(seed = 1025L)
      ) %>%

        # CV 分割全体の平均値を評価スコアとする
        dplyr::summarise_all(mean)
#    }, .options = furrr::future_options(seed = 1025L)) %>%
    }) %>%

    # 評価結果とパラメータを結合
    dplyr::bind_cols(df.grid.params) %>%

    # 評価スコアの順にソート(昇順)
    dplyr::arrange(
      test_rmse
    ) %>%

    dplyr::select(
      colnames(df.grid.params),

      train_rmse,
      test_rmse
    )
})
